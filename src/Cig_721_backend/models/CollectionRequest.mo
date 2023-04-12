
module {
    public type CollectionRequest = {
        collectionCreator : Principal; 
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