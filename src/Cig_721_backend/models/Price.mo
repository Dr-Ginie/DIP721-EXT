import Offer "./Offer";
import Time "mo:base/Time";
module {

    private type Offer = Offer.Offer;

    public type Price = {
        offer : Offer;
        timeStamp : Time.Time;
    };
};
