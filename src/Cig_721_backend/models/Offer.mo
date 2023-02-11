import Time "mo:base/Time";

module {

    public type Offer = {
        id:Nat32;
        metaDataId:Nat32;
        seller:Principal;
        buyer:Principal;
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