import Account "../models/Account";
import Principal "mo:base/Principal";

module {

    type Account = Account.Account;

    public type TxReceipt = {
        #Ok : Nat;
        #Err : TransferFromError;
    };

    public type TransferFromError = {
        #BadFee : { expected_fee : Nat };
        #BadBurn : { min_burn_amount : Nat };
        // The [from] account does not hold enough funds for the transfer.
        #InsufficientFunds : { balance : Nat };
        // The caller exceeded its allowance.
        #InsufficientAllowance : { allowance : Nat };
        #TooOld;
        #CreatedInFuture : { ledger_time : Nat64 };
        #Duplicate : { duplicate_of : Nat };
        #TemporarilyUnavailable;
        #GenericError : { error_code : Nat; message : Text };
    };

    public type AllowanceArgs = {
        account : Account;
        spender : Principal;
    };

    public type Allowance = {
        allowance : Nat;
        expires_at : Nat64;
    };

    public type TransferArgs = {
        from : Account;
        to : Account;
        amount : Nat;
        fee : Nat;
        memo : Blob;
        created_at_time : Nat64;
    };

    public func service(canister : Text) : actor {
        icrc1_balance_of : shared query Principal -> async Nat;
        icrc2_allowance : shared query (AllowanceArgs) -> async Allowance;
        icrc2_transfer_from : shared (TransferArgs) -> async TxReceipt;
        icrc1_transfer : shared (TransferArgs) -> async TxReceipt;
    } {
        return actor (canister) : actor {
            icrc1_balance_of : shared query Principal -> async Nat;
            icrc2_allowance : shared query (AllowanceArgs) -> async Allowance;
            icrc2_transfer_from : shared (TransferArgs) -> async TxReceipt;
            icrc1_transfer : shared (TransferArgs) -> async TxReceipt;
        };
    };
};
