import M "mo:matchers/Matchers";
import Option "mo:base/Option";
import Random "mo:base/Random";
import EasyRandom "../src/EasyRandom";
import S "mo:matchers/Suite";
import T "mo:matchers/Testable";

let suite = S.suite("nextNat", [
    S.testLazy("returns a number between 0 and 10",
      func() : Nat {
        let finite = Random.Finite("test");
        let value : ?Nat = EasyRandom.nextNat(finite, 10);
        let unwrppedValue = Option.get(value, 0);
        unwrppedValue;
      },
      M.equals(T.nat(2))),
]);

S.run(suite);
