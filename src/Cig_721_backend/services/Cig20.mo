module {

    public type TxReceipt = {
        #Ok : Text;
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
        balanceOf : shared query Principal -> async Nat;
        allowance : shared query (Principal, Principal) -> async Nat;
        transferFrom : shared (Principal, Principal, Nat) -> async TxReceipt;
        transfer : shared (Principal, Nat) -> async TxReceipt;
    } {
        return actor (canister) : actor {
            balanceOf : shared query Principal -> async Nat;
            allowance : shared query (Principal, Principal) -> async Nat;
            transferFrom : shared (Principal, Principal, Nat) -> async TxReceipt;
            transfer : shared (Principal, Nat) -> async TxReceipt;
        };
    };
};
