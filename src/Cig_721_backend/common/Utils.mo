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

module {
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
};
