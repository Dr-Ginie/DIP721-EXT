import Time "mo:base/Time";
import Token "Token";

module {
    private type Token = Token.Token;

    public type Auction = {
        end : Time.Time;
        mintId : Nat32;
        amount : Nat;
        token : Token;
    };

    public type AuctionRequest = {
        duration : Nat;
        mintId : Nat32;
        amount : Nat;
        token : Token;
    };
};
