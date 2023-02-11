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

  private stable var mintId : Nat32 = 1;
  private stable var offerId : Nat32 = 1;
  private stable var holders = HashMap.empty<Principal, HashMap.HashMap<Nat32, Metadata>>();
  private stable var metaData = HashMap.empty<Nat32, Metadata>();
  private stable var offers = HashMap.empty<Nat32, Offer>();

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
      owner = owner;
      data = Text.encodeUtf8(jsonString);
    };
    _mint(data);
    currentId;
  };

  public shared ({caller}) func makeOffer(offerRequest:OfferRequest): async Nat32 {
    await* _makeOffer(offerRequest, caller);
  };

  private func _makeOffer(offerRequest : OfferRequest, caller : Principal) : async* Nat32 {
    let exist = HashMap.get(metaData, offerRequest.mintId, n32Hash, n32Equal);
    switch (exist) {
      case (?exist) {
        let currentId = offerId;
        offerId := offerId + 1;
        let offer = {
          offerId = currentId;
          mintId = offerRequest.mintId;
          seller = exist.owner;
          buyer = caller;
          amount = offerRequest.amount;
          token = offerRequest.token;
          expiration = offerRequest.expiration;
        };
        offers := HashMap.insert(offers, currentId, n32Hash, n32Equal, offer).0;
        currentId
      };
      case (null) {
        throw (Error.reject("No Data for mintId " #Nat32.toText(offerRequest.mintId)));
      };
    };
  };

  private func _mint(data : Metadata) {
    metaData := HashMap.insert(metaData, data.mintId, n32Hash, n32Equal, data).0;
    let owner = data.owner;
    let exist = HashMap.get(holders, owner, pHash, pEqual);

    switch (exist) {
      case (?exist) {
        let tempMap = HashMap.insert(exist, data.mintId, n32Hash, n32Equal, data).0;
        holders := HashMap.insert(holders, owner, pHash, pEqual, tempMap).0;
      };
      case (null) {

      };
    };
  };
};
