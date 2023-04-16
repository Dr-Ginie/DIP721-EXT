
module {
    public type CollectionRequest = {
        collectionCreator : Text; 
        external_url:Text;
        royalty : Float; 
        name : Text; 
        description : Text; 
        bannerImage : Blob; 
        profileImage : Blob;
        canvasWidth:Nat32;
        canvasHeight:Nat32;
    }
}