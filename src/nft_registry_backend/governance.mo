import JSON "mo:json/JSON";
import HashMap "mo:stable/HashMap";
import StableBuffer "mo:stable-buffer/StableBuffer";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import List "mo:base/List";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Float "mo:base/Float";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Error "mo:base/Error";
import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Principal "mo:base/Principal";
import Prim "mo:prim";
import Cycles "mo:base/ExperimentalCycles";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Nat64 "mo:base/Nat64";
import { recurringTimer; cancelTimer; setTimer } = "mo:base/Timer";
import Ad "models/Ad";
import Collection "models/Collection";
import Dip20 "Dip20";
import Constants "Constants";


actor class NFT_Registry(_owner : Principal) = this {
    let pHash = Principal.hash;
    let pEqual = Principal.equal;

    let tHash = Text.hash;
    let tEqual = Text.equal;

    let n32Hash = func(a : Nat32) : Nat32 { a };
    let n32Equal = Nat32.equal;

    public type Collection = Collection.Collection;

}