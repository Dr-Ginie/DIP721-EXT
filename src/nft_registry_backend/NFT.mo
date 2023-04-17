import Principal "mo:base/Principal";
import Nat64 "mo:base/Nat64";

module {

    public func service(canister : Text) : actor {
        getCollectionCreator : shared () -> async Principal;
    } {
        return actor (canister) : actor {
            getCollectionCreator : shared () -> async Principal;
        };
    };
};
