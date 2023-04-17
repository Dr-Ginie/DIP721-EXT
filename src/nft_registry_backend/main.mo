import JSON "mo:json/JSON";
import HashMap "mo:stable/HashMap";
import StableBuffer "mo:stable-buffer/StableBuffer";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import List "mo:base/List";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Float "mo:base/Float";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Error "mo:base/Error";
import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Principal "mo:base/Principal";
import Prim "mo:prim";
import Cycles "mo:base/ExperimentalCycles";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Nat64 "mo:base/Nat64";
import { recurringTimer; cancelTimer; setTimer } = "mo:base/Timer";
import Ad "models/Ad";
import Collection "models/Collection";
import Dip20 "Dip20";
import NFT "NFT";
import Constants "../Constants";
import Modclub "modclub";
import Cig721 "../Cig_721_backend/main";
import CollectionRequest "../Cig_721_backend/models/CollectionRequest";

actor class NFT_Registry(_owner : Principal) = this {

  let pHash = Principal.hash;
  let pEqual = Principal.equal;

  let tHash = Text.hash;
  let tEqual = Text.equal;

  let n32Hash = func(a : Nat32) : Nat32 { a };
  let n32Equal = Nat32.equal;

  private stable let owner = _owner;
  private stable var timerId : ?Nat = null;
  private stable let registrationFee : Nat = 2000000000;

  public type Collection = Collection.Collection;
  public type CollectionRequest = CollectionRequest.CollectionRequest;
  public type Category = Collection.Category;
  public type Ad = Ad.Ad;
  private stable var modclub_environment = "prod";
  private stable var ModclubRulesAdded = false;

  private stable var createdCollections = HashMap.empty<Principal, [Text]>();
  private stable var collections = HashMap.empty<Text, Collection>();
  private stable var tempCollections = HashMap.empty<Text, Collection>();
  private stable var mainBannerAd : ?Ad = null;
  private stable var bannerAdBid : ?Ad = null;
  private stable var spotlights : [Ad] = [];
  private stable var spotlightBids : [Ad] = [];

  private stable var testResult : ?Modclub.ContentResult = null;

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

  public shared ({ caller }) func ModclubCallback(result : Modclub.ContentResult) {
    testResult := ?result;
    switch (modclub_environment) {
      case ("staging") {
        assert (caller == Principal.fromText(Modclub.MODCLUB_CANISTER_ID_DEV));
      };
      case ("prod") {
        assert (caller == Principal.fromText(Modclub.MODCLUB_CANISTER_ID_PROD));
      };
      case (_) {
        throw Error.reject("Please Provide correct environment value");
      };
    };
    switch (result.status) {
      case (#approved) {
        //remove from regsitration queue
        //add collection to collections hashmap
        let exist = HashMap.get(tempCollections, result.sourceId, tHash, tEqual);
        switch (exist) {
          case (?exist) {
            collections := HashMap.insert(collections, result.sourceId, tHash, tEqual, exist).0;
            tempCollections := HashMap.remove(tempCollections, result.sourceId, tHash, tEqual).0;
          };
          case (null) {

          };
        };
      };
      case (#rejected) {
        collections := HashMap.remove(collections, result.sourceId, tHash, tEqual).0;
        tempCollections := HashMap.remove(tempCollections, result.sourceId, tHash, tEqual).0;
      };
      case (#new) {

      };
    };
  };

  public query func getTestResult() : async ?Modclub.ContentResult {
    testResult;
  };

  public query func fetchSpotlights(category : Category) : async [Ad] {
    switch (category) {
      case (#PFP) {
        Array.filter(
          spotlights,
          func(e : Ad) : Bool {
            let exist = HashMap.get(collections, e.name, tHash, tEqual);
            switch (exist) {
              case (?exist) {
                exist.category == #PFP;
              };
              case (null) {
                false;
              };
            };
          },
        );
      };
      case (#Music) {
        Array.filter(
          spotlights,
          func(e : Ad) : Bool {
            let exist = HashMap.get(collections, e.name, tHash, tEqual);
            switch (exist) {
              case (?exist) {
                exist.category == #Music;
              };
              case (null) {
                false;
              };
            };
          },
        );
      };
      case (#Art) {
        Array.filter(
          spotlights,
          func(e : Ad) : Bool {
            let exist = HashMap.get(collections, e.name, tHash, tEqual);
            switch (exist) {
              case (?exist) {
                exist.category == #Art;
              };
              case (null) {
                false;
              };
            };
          },
        );
      };
      case (#Gaming) {
        Array.filter(
          spotlights,
          func(e : Ad) : Bool {
            let exist = HashMap.get(collections, e.name, tHash, tEqual);
            switch (exist) {
              case (?exist) {
                exist.category == #Gaming;
              };
              case (null) {
                false;
              };
            };
          },
        );
      };
      case (#Photography) {
        Array.filter(
          spotlights,
          func(e : Ad) : Bool {
            let exist = HashMap.get(collections, e.name, tHash, tEqual);
            switch (exist) {
              case (?exist) {
                exist.category == #Photography;
              };
              case (null) {
                false;
              };
            };
          },
        );
      };
    };

  };

  public query func fetchCollections() : async [Collection] {
    var _collections = Buffer.Buffer<Collection>(0);
    for ((name, _collection) in HashMap.entries(collections)) {
      _collections.add(_collection);
    };
    Buffer.toArray(_collections);
  };

  public query func fetchCollectionsByCategory(category : Category) : async [Collection] {
    var _collections = Buffer.Buffer<Collection>(0);
    for ((name, _collection) in HashMap.entries(collections)) {
      if (_collection.category == category) {
        _collections.add(_collection);
      };
    };
    Buffer.toArray(_collections);
  };

  public query func getTimerId() : async ?Nat {
    timerId;
  };

  public query func fetchSpotlightBids() : async [Ad] {
    spotlightBids;
  };

  public query func getCollection(name : Text) : async ?Collection {
    HashMap.get(collections, name, tHash, tEqual);
  };

  public query func getMainBannerAd() : async ?Ad {
    mainBannerAd;
  };

  public query func getBNannerAdBid() : async ?Ad {
    bannerAdBid;
  };

  public query func fetchCreatedCollections() : async [(Principal, [Text])] {
    _fetchCreatedCollections();
  };

  public query func getCreatedCollections(creator : Principal) : async [Text] {
    _getCreatedCollections(creator);
  };

  public shared ({ caller }) func createCollection(request : CollectionRequest) : async Text {
    Cycles.add(1_700_000_000_000);
    let canister = await Cig721.Cig721(request);
    let canisterId = Principal.toText(Principal.fromActor(canister));
    _addToCreatedCollection(caller, [canisterId]);
    canisterId

  };

  public shared ({ caller }) func addToCreatedCollection(canister : Text) : async () {
    // verify that the canisters being added were created by the caller
    let creator = await NFT.service(canister).getCollectionCreator();
    assert(caller == creator);
    _addToCreatedCollection(caller, [canister]);
  };

  public shared ({ caller }) func removeFromCreatedCollection(canister : Text) : async [Text] {
    _removeFromCreatedCollection(caller, canister);
    _getCreatedCollections(caller);
  };

  public shared ({ caller }) func testRegisterCollection(collection : Collection) : async Text {
    collections := HashMap.insert(collections, collection.name, tHash, tEqual, collection).0;
    collection.name;
  };

  public shared ({ caller }) func registerCollection(collection : Collection) : async Text {
    assert (owner == caller);
    let _isRegistered = isRegistered(collection.name);
    let _isRegisteredTemp = isRegisteredTemp(collection.name);
    if (_isRegistered or _isRegisteredTemp) {
      throw (Error.reject("Collection is name is not available"));
    };
    let allowance = await Dip20.service(Constants.WICP_Canister).allowance(caller, Principal.fromActor(this));
    if (allowance < registrationFee) return throw (Error.reject("InsufficientAllowance"));
    let result = await Dip20.service(Constants.WICP_Canister).transferFrom(caller, Principal.fromActor(this), registrationFee);
    switch (result) {
      case (#Ok(value)) {
        tempCollections := HashMap.insert(tempCollections, collection.name, tHash, tEqual, collection).0;
        await _submitContentToModclub(collection.canister, collection.name);
      };
      case (#Err(value)) {
        throw (Error.reject("Issue Transfering Funds"));
      };
    };
  };

  public shared ({ caller }) func bannerBid(ad : Ad) : async Dip20.TxReceipt {
    let _isRegistered = isRegistered(ad.name);
    let _isWinningBid = isWinningBid(ad.amount);
    assert (_isRegistered);
    assert (_isWinningBid);
    let allowance = await Dip20.service(Constants.WICP_Canister).allowance(caller, Principal.fromActor(this));
    if (allowance < ad.amount) return #Err(#InsufficientAllowance);
    let result = await Dip20.service(Constants.WICP_Canister).transferFrom(caller, Principal.fromActor(this), ad.amount);
    switch (result) {
      case (#Ok(value)) {
        bannerAdBid := ?ad;
        await refundAd(bannerAdBid);
      };
      case (#Err(value)) {
        #Err(value);
      };
    };

  };

  public shared ({ caller }) func spotlightBid(ad : Ad) : async Dip20.TxReceipt {
    let _isRegistered = isRegistered(ad.name);
    assert (_isRegistered);
    let allowance = await Dip20.service(Constants.WICP_Canister).allowance(caller, Principal.fromActor(this));
    if (allowance < ad.amount) return #Err(#InsufficientAllowance);
    let result = await Dip20.service(Constants.WICP_Canister).transferFrom(caller, Principal.fromActor(this), ad.amount);
    switch (result) {
      case (#Ok(value)) {
        spotlightBids := Array.append(spotlightBids, [ad]);
        #Ok(value);
      };
      case (#Err(value)) {
        #Err(value);
      };
    };

  };

  public func startAdTimer() : async () {
    //runs ads for 24hrs
    //var timerId = recurringTimer(#seconds(86400), _resetAds);
    switch (timerId) {
      case (?exist) {

      };
      case (null) {
        timerId := ?recurringTimer(#seconds(300), _resetAds);
      };
    };
  };

  private func _resetAds() : async () {
    mainBannerAd := bannerAdBid;
    spotlights := spotlightBids;
    spotlightBids := [];
  };

  private func isRegistered(name : Text) : Bool {
    let exist = HashMap.get(collections, name, tHash, tEqual);
    switch (exist) {
      case (?exist) true;
      case (null) false;
    };
  };

  private func isRegisteredTemp(name : Text) : Bool {
    let exist = HashMap.get(tempCollections, name, tHash, tEqual);
    switch (exist) {
      case (?exist) true;
      case (null) false;
    };
  };

  private func isWinningBid(value : Nat) : Bool {
    switch (bannerAdBid) {
      case (?exist) {
        value > exist.amount;
      };
      case (null) {
        return true;
      };
    };
  };

  private func refundAd(ad : ?Ad) : async Dip20.TxReceipt {
    switch (ad) {
      case (?ad) {
        await Dip20.service(Constants.WICP_Canister).transfer(ad.owner, ad.amount);
      };
      case (null) {
        #Err(#Other("No ad found to refund"));
      };
    };
  };

  private func _fetchCreatedCollections() : [(Principal, [Text])] {
    Iter.toArray(HashMap.entries(createdCollections));
  };

  private func _getCreatedCollections(creator : Principal) : [Text] {
    let exist = HashMap.get(createdCollections, creator, pHash, pEqual);
    switch (exist) {
      case (?exist) {
        exist;
      };
      case (null) { [] };
    };
  };

  private func _addToCreatedCollection(creator : Principal, canisters : [Text]) {
    let exist = HashMap.get(createdCollections, creator, pHash, pEqual);
    switch (exist) {
      case (?exist) {
        var _canisters = Array.append(exist, canisters);
        createdCollections := HashMap.insert(createdCollections, creator, pHash, pEqual, _canisters).0;
      };
      case (null) {
        createdCollections := HashMap.insert(createdCollections, creator, pHash, pEqual, canisters).0;
      };
    };
  };

  private func _removeFromCreatedCollection(creator : Principal, canister : Text) {
    var _collections = _getCreatedCollections(creator);
    _collections := Array.filter(
      _collections,
      func(e : Text) : Bool {
        e != canister;
      },
    );
    createdCollections := HashMap.insert(createdCollections, creator, pHash, pEqual, _collections).0;
  };

  private func _submitContentToModclub(canisterId : Text, name : Text) : async Text {
    let href = "https://wi732-4aaaa-aaaan-qc45a-cai.raw.ic0.app/" #canisterId;
    await Modclub.getModclubActor(modclub_environment).submitHtmlContent(name, "<div><p>Please review <a href='" #href # "' target='_blank'>this NFT collection</a>.</p></div>", ?("" #name # " NFT Collection"));
  };

  public func testSubmitContentToModclub(name : Text) : async Text {
    let href = "https://wi732-4aaaa-aaaan-qc45a-cai.raw.ic0.app/";
    await Modclub.getModclubActor(modclub_environment).submitHtmlContent(name, "<div><p>Please review <a href='" #href # "' target='_blank'>this NFT collection</a>.</p></div>", ?("" #name # " NFT Collection"));
  };

  public shared ({ caller }) func setSubscribeCallback() : async () {
    assert (owner == caller);
    await Modclub.getModclubActor(modclub_environment).subscribe({
      callback = ModclubCallback;
    });
  };

  public shared ({ caller }) func updateRules() : async () {
    assert (owner == caller);
    let rules = [
      "This post threatens violence against an individual or a group of people",
      "This post glorifies violence",
      "This post threatens or promotes terrorism or violent extremism",
    ];
    await Modclub.getModclubActor(modclub_environment).addRules(rules, null);
  };

  public shared ({ caller }) func updateModSettings() : async () {
    assert (owner == caller);
    let settings : Modclub.ProviderSettings = {
      minVotes = 2;
      minStaked = 5;
    };
    await Modclub.getModclubActor(modclub_environment).updateSettings(Principal.fromActor(this), settings);
  };

};

//"<div><p>Please review <a href='https://wi732-4aaaa-aaaan-qc45a-cai.raw.ic0.app/#/detail-view' target='_blank'>this NFT collection</a>.</p><p>You should filter 'Showing' to 'Entire Collection' in order to see all of the NFT images.</p><ul><li><a href='N/A' target='_blank'>Web</a></li></ul></div>"
