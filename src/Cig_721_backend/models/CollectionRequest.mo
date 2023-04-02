
module {
    public type CollectionRequest = {
        collectionCreator : Principal; 
        royalty : Float; 
        name : Text; 
        description : Text; 
        bannerImage : Blob; 
        profileImage : Blob;
    }
}