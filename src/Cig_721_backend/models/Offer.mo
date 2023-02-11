import Time "mo:base/Time";

module {

    public type Offer = {
        offerId:Nat32;
        mintId:Nat32;
        seller:Principal;
        buyer:Principal;
        amount:Nat;
        token:Token;
        expiration:?Time.Time;
    };

    public type OfferRequest = {
        mintId:Nat32;
        amount:Nat;
        token:Token;
        expiration:?Time.Time;
    };

    public type Token = {
        #Cig20:Text;
        #Dip20:Text;
        #IRC2:Text;
        #EXT:Text;
    };
}