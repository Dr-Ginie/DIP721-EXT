/// EasyRandom library
///
///
///
/// Simple usage:
/// ```motoko
/// import EasyRandom "mo:easy-random/EasyRandom";
///
/// 
/// let entropy = await Random.blob(); 
/// let finite = Random.Finite(entropy);
/// let randomFromZeroToNine : ?Nat = EasyRandom.nextNat(finite, 10);
/// ```

import Random "mo:base/Random";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Float "mo:base/Float";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Debug "mo:base/Debug";

module {
    /// Generate a random number between 0 and [max] - 1, using the provided [finite].
    /// 
    /// As other Random methods, null is returned if [finite] doesn't contain enought entropy.
    public func nextNat(finite: Random.Finite, max: Nat) : ?Nat {
        // Find out the 2 pow that fits [max]
        let sqrt = Float.sqrt(Float.fromInt(max + 1));
        let exponent = Float.toInt(Float.ceil(sqrt));

        // Get a random number inside that range
        let optionRandom = finite.range(Nat8.fromIntWrap(exponent));
        if (optionRandom == null) {
            // Entropy finished
            return null;
        };
        let randomNumber = Option.get(optionRandom, 0);

        // Found random number inside [0-max] range
        var maxRandomNumber = Int.abs(Float.toInt(Float.pow(2, Float.fromInt(exponent))));
        ?((randomNumber * (max + 1)) / maxRandomNumber);
    };
};