import Constants "../../Constants";
module {

    public type IcpXdrConversionRateCertifiedResponse = {
        certificate : [Nat8];
        data : IcpXdrConversionRate;
        hash_tree : [Nat8];
    };

    public type IcpXdrConversionRate = {
        xdr_permyriad_per_icp : Nat64;
        timestamp_seconds : Nat64;
    };

    public func service() : actor {
        getPrice : shared query Nat -> async Nat;
    } {
        return actor (Constants.Token_Registery_Canister) : actor {
            getPrice : shared query Nat -> async Nat;
        };
    };
};
