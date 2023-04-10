import Principal "mo:base/Principal";
module {
    public type WhiteList = {
        title:Text;
        description:Text;
        duration:Nat;
        value:[Principal];
    }
}