import JSON "mo:json/JSON";
import HashMap "mo:stable/HashMap";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import List "mo:base/List";
import SHA256 "mo:crypto/SHA/SHA256";
import Hex "mo:encoding/Hex";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Float "mo:base/Float";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Error "mo:base/Error";
import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Metadata "models/Metadata";
import MintRequest "models/MintRequest";
import Offer "models/Offer";
import Bid "models/Bid";
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
import Utils "common/Utils";
import Token "./models/Token";
import { recurringTimer; cancelTimer; setTimer } = "mo:base/Timer";

actor class Cig721(_collectionCreator : Principal, _royalty : Float, _name : Text) = this {

  private type Metadata = Metadata.Metadata;
  private type MintRequest = MintRequest.MintRequest;
  private type Offer = Offer.Offer;
  private type Bid = Bid.Bid;
  private type OfferRequest = Offer.OfferRequest;
  private type Token = Token.Token;

  let pHash = Principal.hash;
  let pEqual = Principal.equal;

  let tHash = Text.hash;
  let tEqual = Text.equal;

  let n32Hash = func(a : Nat32) : Nat32 { a };
  let n32Equal = Nat32.equal;

  let icrc2Buffer = 1000000000 * 1;

  private stable var collectionOwner = _collectionCreator;
  private stable var collectionCreator = _collectionCreator;
  private stable let royalty = _royalty;
  private stable let name = _name;

  private stable var mintId : Nat32 = 1;
  private stable var offerId : Nat32 = 1;
  private stable var holders = HashMap.empty<Principal, HashMap.HashMap<Nat32, Metadata>>();
  private stable var manifest = HashMap.empty<Nat32, Principal>();
  private stable var metaData = HashMap.empty<Nat32, Metadata>();
  private stable var offers = HashMap.empty<Nat32, [Offer]>();
  private stable var sales = HashMap.empty<Nat32, OfferRequest>();
  private stable var approved = HashMap.empty<Nat32, Principal>();
  private stable var bids = HashMap.empty<Nat32, HashMap.HashMap<Principal, Offer>>();
  private stable var winningBids = HashMap.empty<Nat32, Offer>();

  ///Query Methods
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

  public query func getMintCount() : async Nat32 {
    mintId;
  };

  public query func getName() : async Text {
    name;
  };

  public query func getRoyalty() : async Float {
    royalty;
  };

  public query func getCollectionOwner() : async Principal {
    collectionOwner;
  };

  public query func getCollectionCreator() : async Principal {
    collectionCreator;
  };

  public query func getOwner(_mintId : Nat32) : async Principal {
    _getOwner(_mintId);
  };

  public query func fetchOffers(_mintId : Nat32) : async [Offer] {
    let exist = HashMap.get(offers, _mintId, n32Hash, n32Equal);
    switch (exist) {
      case (?exist) {
        exist;
      };
      case (null) { [] };
    };
  };

  public query func fetchBids(_mintId : Nat32) : async [Bid] {
    let exist = HashMap.get(bids, _mintId, n32Hash, n32Equal);
    var _bids = Buffer.Buffer<Bid>(0);
    switch (exist) {
      case (?exist) {
        for ((owner, _offer) in HashMap.entries(exist)) {
          _bids.add({ owner = owner; offer = _offer });
        };
      };
      case (null) {

      };
    };
    Buffer.toArray(_bids);
  };

  public query func fetchsales(_mintId : Nat32) : async [OfferRequest] {
    var _bids = Buffer.Buffer<OfferRequest>(0);
    for ((id, _offer) in HashMap.entries(sales)) {
      _bids.add(_offer);
    };
    Buffer.toArray(_bids);
  };

  public query func fetchOwners(_mintIds : [Nat32]) : async [{
    owner : Principal;
    mintId : Nat32;
  }] {
    var result = Buffer.Buffer<{ owner : Principal; mintId : Nat32 }>(0);
    for (_mintId in _mintIds.vals()) {
      result.add({ owner = _getOwner(_mintId); mintId = _mintId });
    };
    Buffer.toArray(result);
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

  public query func getData(_mintId : Nat32) : async Metadata {
    let _owner = _getOwner(_mintId);
    let exist = HashMap.get(holders, _owner, pHash, pEqual);
    switch (exist) {
      case (?exist) {
        switch (HashMap.get(exist, _mintId, n32Hash, n32Equal)) {
          case (?data) {
            data;
          };
          case (null) {
            throw (Error.reject("No Data for mintId " #Nat32.toText(_mintId)));
          };
        };
      };
      case (null) {
        throw (Error.reject("No Data for Principal " #Principal.toText(_owner)));
      };
    };
  };
  ///Update Methods

  public func winningBid(_mintId : Nat32) : async Offer {
    await* _winningBid(_mintId);
  };

  //Call close mint to set the Owner to this canister and prevent additioanl minting
  public shared ({ caller }) func closeMint() : async () {
    collectionOwner := Principal.fromActor(this);
  };

  public shared ({ caller }) func mint(request : MintRequest) : async Nat32 {
    assert (caller == collectionOwner);
    let currentId = mintId;
    mintId := mintId + 1;
    let _metadata : Metadata = {
      mintId = currentId;
      data = request.data;
    };
    _mint(_metadata, request.owner);
    manifest := HashMap.insert(manifest, currentId, n32Hash, n32Equal, caller).0;
    currentId;
  };

  public shared ({ caller }) func bulkMint(requests : [MintRequest]) : async [Nat32] {
    assert (caller == collectionOwner);
    var result : [Nat32] = [];
    for (request in requests.vals()) {
      let currentId = mintId;
      mintId := mintId + 1;
      let _metadata : Metadata = {
        mintId = currentId;
        data = request.data;
      };
      _mint(_metadata, request.owner);
      manifest := HashMap.insert(manifest, currentId, n32Hash, n32Equal, caller).0;
      result := Array.append(result, [currentId]);
    };
    result;
  };

  public shared ({ caller }) func transfer(to : Principal, _mintId : Nat32) : async () {
    assert (_isOwner(caller, _mintId));
    await* _transfer(to, _mintId);
  };

  public shared ({ caller }) func transferFrom(from : Principal, to : Principal, _mintId : Nat32) : async () {
    assert (_isOwner(from, _mintId));
    let exist = HashMap.get(approved, _mintId, n32Hash, n32Equal);
    switch (exist) {
      case (?exist) {
        if (exist == caller) {
          await* _transfer(to, _mintId);
        };
      };
      case (null) {
        throw (Error.reject("Unauthorized " #Nat32.toText(_mintId)));
      };
    };
  };

  public shared ({ caller }) func approve(to : Principal, _mintId : Nat32) : async () {
    assert (_isOwner(caller, _mintId));
    approved := HashMap.insert(approved, _mintId, n32Hash, n32Equal, to).0;
    _removeOffers(_mintId);
  };

  public shared ({ caller }) func allowance(_owner : Principal, _mintId : Nat32) : async Bool {
    assert (_isOwner(_owner, _mintId));
    let exist = HashMap.get(approved, _mintId, n32Hash, n32Equal);
    switch (exist) {
      case (?exist) {
        exist == caller;
      };
      case (null) {
        false;
      };
    };
  };

  public shared ({ caller }) func sell(_mintId : Nat32, offerRequest : OfferRequest) : async () {
    assert (_isOwner(caller, _mintId));
    sales := HashMap.insert(sales, mintId, n32Hash, n32Equal, offerRequest).0;
  };

  public shared ({ caller }) func bid(_mintId : Nat32, bidRequest : Offer) : async () {
    await _bid(_mintId, bidRequest);
  };

  public shared ({ caller }) func auction(offerRequest : OfferRequest, duration : Nat) : async () {
    assert (_isOwner(caller, offerRequest.mintId));
    let offer : Offer = {
      offerId = 0;
      mintId = offerRequest.mintId;
      seller = caller;
      buyer = caller;
      amount = offerRequest.amount;
      token = offerRequest.token;
      expiration = null;
    };
    winningBids := HashMap.insert(winningBids, offerRequest.mintId, n32Hash, n32Equal, offer).0;
    ignore setTimer(
      #seconds(duration),
      func() : async () {
        await _endAuction(offerRequest.mintId);
      },
    );
  };

  public shared ({ caller }) func buy(_mintId : Nat32) : async Nat32 {
    let offerRequest = HashMap.get(sales, _mintId, n32Hash, n32Equal);
    let _owner = _getOwner(_mintId);
    switch (offerRequest) {
      case (?offerRequest) {
        let isExpired = _isExpired(offerRequest.expiration);
        assert (isExpired == false);
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
        try {
          await _acceptOffer(offer);
        } catch (e) {
          assert (false);
        };
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
        let isExpired = _isExpired(offer.expiration);
        assert (isExpired == false);
        try {
          await _acceptOffer(offer);
        } catch (e) {
          assert (false);
        };
      };
      case (null) {
        throw (Error.reject("No Data for OfferId " #Nat32.toText(_offerId)));
      };
    };
    _offerId;
  };

  ///Private Methods
  private func _getOwner(_mintId : Nat32) : Principal {
    let _owner = HashMap.get(manifest, _mintId, n32Hash, n32Equal);
    switch (_owner) {
      case (?_owner) {
        _owner;
      };
      case (null) {
        assert (true);
        Principal.fromActor(this);
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
    let _owner = _getOwner(offerRequest.mintId);
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

  private func _endAuction(_mintId : Nat32) : async () {
    let exist = HashMap.get(winningBids, _mintId, n32Hash, n32Equal);
    switch (exist) {
      case (?exist) {
        if (exist.buyer != exist.seller) {
          await _acceptOffer(exist);
        };
      };
      case (null) {

      };
    };
  };

  private func _bid(_mintId : Nat32, bidRequest : Offer) : async () {
    let exist = HashMap.get(bids, _mintId, n32Hash, n32Equal);
    let _winningBid = HashMap.get(winningBids, _mintId, n32Hash, n32Equal);
    let _owner = _getOwner(_mintId);
    await _tokenTransferFrom(bidRequest);
    switch (_winningBid) {
      case (?_winningBid) {
        if (bidRequest.amount > _winningBid.amount) {
          winningBids := HashMap.insert(winningBids, _mintId, n32Hash, n32Equal, bidRequest).0;
          switch (exist) {
            case (?exist) {
              let tempMap = HashMap.insert(exist, _owner, pHash, pEqual, bidRequest).0;
              bids := HashMap.insert(bids, _mintId, n32Hash, n32Equal, tempMap).0;
            };
            case (null) {
              var tempMap = HashMap.empty<Principal, Offer>();
              tempMap := HashMap.insert(tempMap, _owner, pHash, pEqual, bidRequest).0;
              bids := HashMap.insert(bids, _mintId, n32Hash, n32Equal, tempMap).0;
            };
          };
        };
      };
      case (null) {
        winningBids := HashMap.insert(winningBids, _mintId, n32Hash, n32Equal, bidRequest).0;
        switch (exist) {
          case (?exist) {
            let tempMap = HashMap.insert(exist, _owner, pHash, pEqual, bidRequest).0;
            bids := HashMap.insert(bids, _mintId, n32Hash, n32Equal, tempMap).0;
          };
          case (null) {
            var tempMap = HashMap.empty<Principal, Offer>();
            tempMap := HashMap.insert(tempMap, _owner, pHash, pEqual, bidRequest).0;
            bids := HashMap.insert(bids, _mintId, n32Hash, n32Equal, tempMap).0;
          };
        };
      };
    };
  };

  private func _transfer(to : Principal, _mintId : Nat32) : async* () {
    let from = _getOwner(_mintId);
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
    _removeOffers(_mintId);
    manifest := HashMap.insert(manifest, _mintId, n32Hash, n32Equal, to).0;

  };

  private func _removeOffers(_mintId : Nat32) {
    offers := HashMap.remove(offers, _mintId, n32Hash, n32Equal).0;
    approved := HashMap.remove(approved, _mintId, n32Hash, n32Equal).0;
    sales := HashMap.remove(sales, _mintId, n32Hash, n32Equal).0;
    bids := HashMap.remove(bids, _mintId, n32Hash, n32Equal).0;
    winningBids := HashMap.remove(winningBids, _mintId, n32Hash, n32Equal).0;
  };

  private func _acceptOffer(offer : Offer) : async () {
    let _allowance = await _tokenAllowance(offer);
    assert (_allowance >= offer.amount);
    await _tokenTransfer(offer);
    await* _transfer(offer.buyer, offer.mintId)

  };

  private func _winningBid(_mintId : Nat32) : async* Offer {
    let exist = HashMap.get(winningBids, _mintId, n32Hash, n32Equal);
    switch (exist) {
      case (?exist) {
        exist;
      };
      case (null) {
        throw (Error.reject("No Data for mintId " #Nat32.toText(_mintId)));
      };
    };
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

  private func _isExpired(time : ?Time.Time) : Bool {
    let now = Time.now();
    switch (time) {
      case (?time) {
        time < now;
      };
      case (null) {
        false;
      };
    };
  };

  private func _tokenTransfer(offer : Offer) : async () {
    assert (offer.amount > 0);
    switch (offer.token) {
      case (#Cig20(value)) {
        let royalties = Float.mul(Utils.natToFloat(offer.amount), royalty);
        let _amount = offer.amount - Utils.floatToNat(royalties);
        let result = await Cig20.service(value).transfer(offer.buyer, _amount);
        let royaltyResult = await Cig20.service(value).transfer(collectionCreator, Utils.floatToNat(royalties));
        switch (result) {
          case (#Ok(value)) {

          };
          case (#Err(value)) {
            throw (Error.reject("Token Transfer Error"));
          };
        };
      };
      case (#Dip20(value)) {
        let royalties = Float.mul(Utils.natToFloat(offer.amount), royalty);
        let _amount = offer.amount - Utils.floatToNat(royalties);
        let result = await Dip20.service(value).transfer(offer.buyer, _amount);
        let royaltyResult = await Dip20.service(value).transfer(collectionCreator, Utils.floatToNat(royalties));
        switch (result) {
          case (#Ok(value)) {

          };
          case (#Err(value)) {
            throw (Error.reject("Token Transfer Error"));
          };
        };
      };
      case (#IRC2(value)) {
        let royalties = Float.mul(Utils.natToFloat(offer.amount), royalty);
        let _amount = offer.amount - Utils.floatToNat(royalties);
        let now = Time.now();

        let from = { owner = offer.seller; subaccount = null };
        let to = { owner = offer.buyer; subaccount = null };
        let toRoyalties = { owner = collectionCreator; subaccount = null };

        let args : ICRC2.TransferArgs = {
          from = from;
          to = to;
          amount = _amount;
          fee = 0;
          memo = Text.encodeUtf8("");
          created_at_time = 0;

        };

        let argsRoyalties : ICRC2.TransferArgs = {
          from = from;
          to = toRoyalties;
          amount = Utils.floatToNat(royalties);
          fee = 0;
          memo = Text.encodeUtf8("");
          created_at_time = 0;

        };

        let result = await ICRC2.service(value).icrc2_transfer_from(args);
        let royaltyResult = await ICRC2.service(value).icrc2_transfer_from(argsRoyalties);

        switch (result) {
          case (#Ok(value)) {

          };
          case (#Err(value)) {
            throw (Error.reject("Token Transfer Error"));
          };
        };

      };
      case (#EXT(value)) {
        throw (Error.reject("No Implmentation"));
      };
    };
  };

  private func _tokenTransferFrom(offer : Offer) : async () {
    assert (offer.amount > 0);
    switch (offer.token) {
      case (#Cig20(value)) {
        let result = await Cig20.service(value).transferFrom(offer.buyer, Principal.fromActor(this), offer.amount);
        switch (result) {
          case (#Ok(value)) {

          };
          case (#Err(value)) {
            throw (Error.reject("Token Transfer Error"));
          };
        };
      };
      case (#Dip20(value)) {
        let result = await Dip20.service(value).transferFrom(offer.buyer, Principal.fromActor(this), offer.amount);
        switch (result) {
          case (#Ok(value)) {

          };
          case (#Err(value)) {
            throw (Error.reject("Token Transfer Error"));
          };
        };
      };
      case (#IRC2(value)) {
        let now = Time.now();

        let from = { owner = offer.buyer; subaccount = null };
        let to = { owner = Principal.fromActor(this); subaccount = null };
        let toRoyalties = { owner = collectionCreator; subaccount = null };

        let args : ICRC2.TransferArgs = {
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
            throw (Error.reject("Token Transfer Error"));
          };
        };

      };
      case (#EXT(value)) {
        throw (Error.reject("No Implmentation"));
      };
    };
  };
};
