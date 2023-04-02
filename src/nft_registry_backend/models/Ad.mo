import Principal "mo:base/Principal";
module {
    public type Ad = {
        owner:Principal;
        name:Text;
        amount:Nat;
    }
}