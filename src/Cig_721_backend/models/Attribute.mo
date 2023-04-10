module {
    public type Attribute = {
        display_type:?Text; 
        trait_type:Text;
        value:Value;
        weight:Nat32;
        layer:?Layer;
    };

    public type Layer = {
        value:Blob;
        contentType:Text;
    };

    public type Value = {
        #text:Text;
        #number:Int;
        #float:Float;
    }
}