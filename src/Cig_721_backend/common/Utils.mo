import Int64 "mo:base/Int64";
import Nat64 "mo:base/Nat64";
import Nat "mo:base/Nat";
import Float "mo:base/Float";
import Array "mo:base/Array";
import List "mo:base/List";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Char "mo:base/Char";
import Option "mo:base/Option";
import Prim "mo:prim";
import Int "mo:base/Int";
import Int32 "mo:base/Int32";
import Nat32 "mo:base/Nat32";
import JSON "mo:json/JSON";
import Blob "mo:base/Blob";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";
import Nat8 "mo:base/Nat8";
import Attribute "../models/Attribute";
import Buffer "mo:base/Buffer";

module {

    private type JSON = JSON.JSON;
    private type Attribute = Attribute.Attribute;

    public func natToFloat(value : Nat) : Float {
        return Float.fromInt(value);
    };

    public func floatToNat(value : Float) : Nat {
        let int = Float.toInt(value);
        let text = Int.toText(int);
        return textToNat(text);
    };

    public func includesText(string : Text, term : Text) : Bool {
        let stringArray = Iter.toArray<Char>(toLowerCase(string).chars());
        let termArray = Iter.toArray<Char>(toLowerCase(term).chars());

        var i = 0;
        var j = 0;

        while (i < stringArray.size() and j < termArray.size()) {
            if (stringArray[i] == termArray[j]) {
                i += 1;
                j += 1;
                if (j == termArray.size()) { return true };
            } else {
                i += 1;
                j := 0;
            };
        };
        false;
    };

    public func toLowerCase(value : Text) : Text {
        let chars = Text.toIter(value);
        var lower = "";
        for (c : Char in chars) {
            lower := Text.concat(lower, Char.toText(Prim.charToLower(c)));
        };
        return lower;
    };

    public func nat32ToInt(value : Nat32) : Int {
        let int32 = Int32.fromNat32(value);
        Int32.toInt(int32);
    };

    public func textToNat32(txt : Text) : Nat32 {
        assert (txt.size() > 0);
        let chars = txt.chars();

        var num : Nat32 = 0;
        for (v in chars) {
            let charToNum = Char.toNat32(v) -48;
            assert (charToNum >= 0 and charToNum <= 9);
            num := num * 10 + charToNum;
        };

        num;
    };

    public func textToNat(txt : Text) : Nat {
        assert (txt.size() > 0);
        let chars = txt.chars();

        var num : Nat = 0;
        for (v in chars) {
            let charToNum = Char.toNat32(v) -48;
            assert (charToNum >= 0 and charToNum <= 9);
            num := num * 10 + Nat32.toNat(charToNum);
        };

        num;
    };

    public func attributeToJSON(attribute : Attribute) : JSON {
        let map : HashMap.HashMap<Text, JSON> = HashMap.HashMap<Text, JSON>(
            0,
            Text.equal,
            Text.hash,
        );
        map.put("trait_type", #String(attribute.trait_type));

        switch (attribute.value) {
            case (#text(value)) {
                map.put("value", #String(value));
            };
            case (#number(value)) {
                map.put("value", #Number(value));
            };
            case (#float(value)) {
                map.put("value", #String(Float.toText(value)));
            };
        };

        switch (attribute.display_type) {
            case (?value) {
                map.put("display_type", #String(value));
            };
            case (null) {

            };
        };
        #Object(Iter.toArray(map.entries()));
    };

    public func createMetaData(description:Text,external_url:Text, image:Text, name:Text, attributes : [Attribute],) : JSON {
        let map : HashMap.HashMap<Text, JSON> = HashMap.HashMap<Text, JSON>(
            0,
            Text.equal,
            Text.hash,
        );
        var _attributes:Buffer.Buffer<JSON> = Buffer.fromArray([]);
        map.put("description", #String(description));
        map.put("external_url", #String(external_url));
        map.put("image", #String(image));
        map.put("name", #String(name));

        for(attribute in attributes.vals()){
            let json = attributeToJSON(attribute);
            _attributes.add(json);
        };
        map.put("attributes", #Array(Buffer.toArray(_attributes)));
        #Object(Iter.toArray(map.entries()));
    };
};
