import Time "mo:base/Time";
import Token "./Token";
module {

    private type Token = Token.Token;

    public type Offer = {
        offerId:Nat32;
        mintId:Nat32;
        seller:Principal;
        buyer:Principal;
        amount:Nat;
        token:?Token;
        icp:Nat;
        expiration:?Time.Time;
    };

    public type OfferRequest = {
        mintId:Nat32;
        amount:Nat;
        token:?Token;
        icp:Nat;
        expiration:?Time.Time;
    };
}