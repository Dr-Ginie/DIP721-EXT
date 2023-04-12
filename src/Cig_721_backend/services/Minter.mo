import Principal "mo:base/Principal";
import Nat64 "mo:base/Nat64";

module {

    public type TxReceipt = {
        #Ok : Nat;
        #Err : {
            #InsufficientAllowance;
            #InsufficientBalance;
            #ErrorOperationStyle;
            #Unauthorized;
            #LedgerTrap;
            #ErrorTo;
            #Other : Text;
            #BlockUsed;
            #ActiveProposal;
            #AmountTooSmall;
        };
    };

    public func service(canister : Text) : actor {
        compose : shared ([[Nat8]], Nat32, Nat32) -> async [Nat8];
    } {
        return actor (canister) : actor {
            compose : shared ([[Nat8]], Nat32, Nat32) -> async [Nat8];
        };
    };
};
