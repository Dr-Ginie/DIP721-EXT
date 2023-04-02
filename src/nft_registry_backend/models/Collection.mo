module {
    public type Collection = {
        name:Text;
        canister:Text;
        description:Text;
        bannerUrl:Text;
        spotlightUrl:Text;
        website:Text;
        community:Text;
        team:[TeamMember];
        category:Category;
    };

    public type TeamMember = {
        name:Text;
        title:Text;
        description:Text;
        profileUrl:Text;
        social:Text;
    };

    public type Category = {
        #PFP;
        #Music;
        #Art;
        #Gaming;
        #Photography;
    };
}