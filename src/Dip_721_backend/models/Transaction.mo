import Principal "mo:base/Principal";
import Time "mo:base/Time";

module {
    public type Transaction = {
        from:Principal;
        to:Principal;
        mintId:Nat32;
        createdAt:Time.Time;
    };
}