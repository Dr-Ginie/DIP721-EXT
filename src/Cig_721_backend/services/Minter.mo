import Principal "mo:base/Principal";
import Nat64 "mo:base/Nat64";

module {

    public func service(canister : Text) : actor {
        compose : shared ([[Nat8]], Nat32, Nat32) -> async [Nat8];
    } {
        return actor (canister) : actor {
            compose : shared ([[Nat8]], Nat32, Nat32) -> async [Nat8];
        };
    };
};
