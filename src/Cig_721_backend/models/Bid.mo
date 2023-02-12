import Principal "mo:base/Principal";
import Offer "./Offer";

module {
    private type Offer = Offer.Offer;

    public type Bid = {
        owner:Principal;
        offer:Offer;
    };
}