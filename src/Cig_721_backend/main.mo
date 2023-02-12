import JSON "mo:json/JSON";
import HashMap "mo:stable/HashMap";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import List "mo:base/List";
import SHA256 "mo:crypto/SHA/SHA256";
import Hex "mo:encoding/Hex";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Error "mo:base/Error";
import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Metadata "models/Metadata";
import Offer "models/Offer";
import Principal "mo:base/Principal";
import Prim "mo:prim";
import Cycles "mo:base/ExperimentalCycles";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Dip20 "./services/Dip20";
import Cig20 "./services/Cig20";
import ICRC2 "./services/ICRC2";
import Nat64 "mo:base/Nat64";

actor class Cig721(_collectionOwner : Principal, _royalty : Float) = this {

  private type Metadata = Metadata.Metadata;
  private type Offer = Offer.Offer;
  private type OfferRequest = Offer.OfferRequest;
  private type Token = Offer.Token;

  let pHash = Principal.hash;
  let pEqual = Principal.equal;

  let tHash = Text.hash;
  let tEqual = Text.equal;

  let n32Hash = func(a : Nat32) : Nat32 { a };
  let n32Equal = Nat32.equal;

  let collectionOwner = _collectionOwner;
  let royalty = _royalty;
  let icrc2Buffer = 1000000000 * 1;

  private stable var mintId : Nat32 = 1;
  private stable var offerId : Nat32 = 1;
  private stable var holders = HashMap.empty<Principal, HashMap.HashMap<Nat32, Metadata>>();
  private stable var manifest = HashMap.empty<Nat32, Principal>();
  private stable var metaData = HashMap.empty<Nat32, Metadata>();
  private stable var offers = HashMap.empty<Nat32, [Offer]>();
  private stable var sales = HashMap.empty<Nat32, OfferRequest>();

  public query func getMemorySize() : async Nat {
    let size = Prim.rts_memory_size();
    size;
  };

  public query func getHeapSize() : async Nat {
    let size = Prim.rts_heap_size();
    size;
  };

  public query func getCycles() : async Nat {
    Cycles.balance();
  };

  public query func balance(owner : Principal) : async [Metadata] {
    let exist = HashMap.get(holders, owner, pHash, pEqual);
    var result = Buffer.Buffer<Metadata>(0);
    switch (exist) {
      case (?exist) {
        for ((id, data) in HashMap.entries(exist)) {
          result.add(data);
        };
      };
      case (null) {
        throw (Error.reject("No Data for Principal " #Principal.toText(owner)));
      };
    };
    Buffer.toArray(result);
  };

  public query func getdata(owner : Principal, id : Nat32) : async Metadata {
    let exist = HashMap.get(holders, owner, pHash, pEqual);
    switch (exist) {
      case (?exist) {
        switch (HashMap.get(exist, id, n32Hash, n32Equal)) {
          case (?data) {
            data;
          };
          case (null) {
            throw (Error.reject("No Data for mintId " #Nat32.toText(id)));
          };
        };
      };
      case (null) {
        throw (Error.reject("No Data for Principal " #Principal.toText(owner)));
      };
    };
  };

  public shared ({ caller }) func mint(jsonString : Text, owner : Principal) : async Nat32 {
    assert (caller == collectionOwner);
    let currentId = mintId;
    mintId := mintId + 1;
    let data : Metadata = {
      mintId = currentId;
      data = Text.encodeUtf8(jsonString);
    };
    _mint(data, owner);
    manifest := HashMap.insert(manifest, currentId, n32Hash, n32Equal, caller).0;
    currentId;
  };

  public shared ({ caller }) func sell(_mintId : Nat32, offerRequest : OfferRequest) : async () {
    assert (_isOwner(caller, _mintId));
    sales := HashMap.insert(sales, mintId, n32Hash, n32Equal, offerRequest).0;
  };

  public shared ({ caller }) func buy(_mintId : Nat32) : async Nat32 {
    let offerRequest = HashMap.get(sales, _mintId, n32Hash, n32Equal);
    let _owner = await* _getOwner(_mintId);
    switch (offerRequest) {
      case (?offerRequest) {
        let currentId = offerId;
        offerId := offerId + 1;
        let offer = {
          offerId = currentId;
          mintId = offerRequest.mintId;
          seller = _owner;
          buyer = caller;
          amount = offerRequest.amount;
          token = offerRequest.token;
          expiration = offerRequest.expiration;
        };
        await _acceptOffer(offer);
        let _ = HashMap.remove(sales, _mintId, n32Hash, n32Equal);
        currentId;
      };
      case (null) {
        throw (Error.reject("No Data for MintId " #Nat32.toText(_mintId)));
      };
    };
  };

  public shared ({ caller }) func makeOffer(offerRequest : OfferRequest) : async Nat32 {
    await* _makeOffer(offerRequest, caller);
  };

  public shared ({ caller }) func acceptOffer(_mintId : Nat32, _offerId : Nat32) : async Nat32 {
    let _offers = await* _getOffers(_mintId);
    let offer = Array.find<Offer>(_offers, func(e : Offer) : Bool { e.offerId == _offerId });
    switch (offer) {
      case (?offer) {
        await _acceptOffer(offer);
        let _ = HashMap.remove(offers, _mintId, n32Hash, n32Equal);
      };
      case (null) {
        throw (Error.reject("No Data for OfferId " #Nat32.toText(_offerId)));
      };
    };
    _offerId;
  };

  private func _getOwner(_mintId : Nat32) : async* Principal {
    let _owner = HashMap.get(manifest, _mintId, n32Hash, n32Equal);
    switch (_owner) {
      case (?_owner) {
        _owner;
      };
      case (null) {
        throw (Error.reject("No Data for Owner"));
      };
    };
  };

  private func _getOffers(_mintId : Nat32) : async* [Offer] {
    let exist = HashMap.get(offers, _mintId, n32Hash, n32Equal);
    switch (exist) {
      case (?exist) {
        exist;
      };
      case (null) {
        throw (Error.reject("No Data for MintId " #Nat32.toText(_mintId)));
      };
    };
  };

  private func _mint(data : Metadata, _owner : Principal) {
    metaData := HashMap.insert(metaData, data.mintId, n32Hash, n32Equal, data).0;
    let exist = HashMap.get(holders, _owner, pHash, pEqual);

    switch (exist) {
      case (?exist) {
        let tempMap = HashMap.insert(exist, data.mintId, n32Hash, n32Equal, data).0;
        holders := HashMap.insert(holders, _owner, pHash, pEqual, tempMap).0;
      };
      case (null) {
        var tempMap = HashMap.empty<Nat32, Metadata>();
        tempMap := HashMap.insert(tempMap, data.mintId, n32Hash, n32Equal, data).0;
        holders := HashMap.insert(holders, _owner, pHash, pEqual, tempMap).0;
      };
    };
  };

  private func _makeOffer(offerRequest : OfferRequest, caller : Principal) : async* Nat32 {
    let exist = HashMap.get(metaData, offerRequest.mintId, n32Hash, n32Equal);
    let _owner = await* _getOwner(offerRequest.mintId);
    switch (exist) {
      case (?exist) {
        let currentId = offerId;
        offerId := offerId + 1;
        let offer = {
          offerId = currentId;
          mintId = offerRequest.mintId;
          seller = _owner;
          buyer = caller;
          amount = offerRequest.amount;
          token = offerRequest.token;
          expiration = offerRequest.expiration;
        };
        var _offers = await* _getOffers(offerRequest.mintId);
        _offers := Array.append(_offers, [offer]);
        offers := HashMap.insert(offers, currentId, n32Hash, n32Equal, _offers).0;
        currentId;
      };
      case (null) {
        throw (Error.reject("No Data for mintId " #Nat32.toText(offerRequest.mintId)));
      };
    };
  };

  private func _transfer(from : Principal, to : Principal, _mintId : Nat32) : async* () {
    let exist = HashMap.get(holders, from, pHash, pEqual);
    let exist2 = HashMap.get(holders, to, pHash, pEqual);

    switch (exist) {
      case (?exist) {
        switch (exist2) {
          case (?exist2) {
            let tempMap = HashMap.remove(exist, _mintId, n32Hash, n32Equal);
            switch (tempMap.1) {
              case (?value) {
                holders := HashMap.insert(holders, from, pHash, pEqual, tempMap.0).0;
                let tempMap2 = HashMap.insert(exist2, _mintId, n32Hash, n32Equal, value);
                holders := HashMap.insert(holders, to, pHash, pEqual, tempMap2.0).0;
              };
              case (null) {
                throw (Error.reject("No Data for mintId " #Nat32.toText(_mintId)));
              };
            };
          };
          case (null) {
            let tempMap = HashMap.remove(exist, _mintId, n32Hash, n32Equal);
            switch (tempMap.1) {
              case (?value) {
                holders := HashMap.insert(holders, from, pHash, pEqual, tempMap.0).0;
                var tempMap2 = HashMap.empty<Nat32, Metadata>();
                tempMap2 := HashMap.insert(tempMap2, _mintId, n32Hash, n32Equal, value).0;
                holders := HashMap.insert(holders, to, pHash, pEqual, tempMap2).0;
              };
              case (null) {
                throw (Error.reject("No Data for mintId " #Nat32.toText(_mintId)));
              };
            };
          };
        };
      };
      case (null) {
        throw (Error.reject("Invalid Holder"));
      };
    };
    let _ = HashMap.remove(offers, _mintId, n32Hash, n32Equal);
    manifest := HashMap.insert(manifest, _mintId, n32Hash, n32Equal, to).0;
  };

  private func _acceptOffer(offer : Offer) : async () {
    let _allowance = await _tokenAllowance(offer);
    assert (_allowance >= offer.amount);
    await _tokenTransferFrom(offer);
    await* _transfer(offer.seller, offer.buyer, offer.mintId)

  };

  private func _tokenAllowance(offer : Offer) : async Nat {
    switch (offer.token) {
      case (#Cig20(value)) {
        await Cig20.service(value).allowance(offer.seller, offer.buyer);
      };
      case (#Dip20(value)) {
        await Dip20.service(value).allowance(offer.seller, offer.buyer);
      };
      case (#IRC2(value)) {
        let now = Time.now();
        let args = {
          account = { owner = offer.buyer; subaccount = null };
          spender = Principal.fromActor(this);

        };
        let result = await ICRC2.service(value).icrc2_allowance(args);
        let expires_at = Nat64.toNat(result.expires_at) + icrc2Buffer;
        assert (expires_at < now);
        result.allowance;

      };
      case (#EXT(value)) {
        throw (Error.reject("No Implmentation"));
      };
    };
  };

  private func _isOwner(caller : Principal, _mintId : Nat32) : Bool {
    let exist = HashMap.get(holders, caller, pHash, pEqual);
    switch (exist) {
      case (?exist) {
        let exist2 = HashMap.get(exist, _mintId, n32Hash, n32Equal);
        switch (exist2) {
          case (?exist2) {
            true;
          };
          case (null) {
            false;
          };
        };
      };
      case (null) {
        false;
      };
    };
  };

  private func _tokenTransferFrom(offer : Offer) : async () {
    switch (offer.token) {
      case (#Cig20(value)) {
        let result = await Cig20.service(value).transferFrom(offer.seller, offer.buyer, offer.amount);
        switch (result) {
          case (#Ok(value)) {

          };
          case (#Err(value)) {
            assert (false);
          };
        };
      };
      case (#Dip20(value)) {
        let result = await Dip20.service(value).transferFrom(offer.seller, offer.buyer, offer.amount);
        switch (result) {
          case (#Ok(value)) {

          };
          case (#Err(value)) {
            assert (false);
          };
        };
      };
      case (#IRC2(value)) {
        let now = Time.now();
        let from = { owner = offer.seller; subaccount = null };
        let to = { owner = offer.buyer; subaccount = null };
        let args : ICRC2.TransferFromArgs = {
          from = from;
          to = to;
          amount = offer.amount;
          fee = 0;
          memo = Text.encodeUtf8("");
          created_at_time = 0;

        };
        let result = await ICRC2.service(value).icrc2_transfer_from(args);
        switch (result) {
          case (#Ok(value)) {

          };
          case (#Err(value)) {
            assert (false);
          };
        };

      };
      case (#EXT(value)) {
        throw (Error.reject("No Implmentation"));
      };
    };
  };
};
