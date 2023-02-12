import Principal "mo:base/Principal";
import Nat32 "mo:base/Nat32";
import Token "./Token";
import Time "mo:base/Time";
module {

    private type Token = Token.Token;

    public type Bid = {
        bidId:Nat32;
        mintId:Nat32;
        owner:Principal;
        amount:Nat;
        token:Token;
        timeStamp:Time.Time;

    };
}