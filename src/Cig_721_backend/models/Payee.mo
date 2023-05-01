import Token "Token";
module {
    public type Payee = {
        to:Principal;
        from:Principal;
        amount:Nat;
        token:Token.Token;
        mintId:Nat32;
    }
}