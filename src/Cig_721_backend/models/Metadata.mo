import Principal "mo:base/Principal";
import JSON "mo:json/JSON";

module {

    private type JSON = JSON.JSON;

    public type Metadata = {
        id:Nat32;
        owner:Principal;
        data:Text;
    }
}