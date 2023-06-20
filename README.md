
**deploy commands**
DFX_MOC_PATH="$(vessel bin)/moc" dfx deploy --network ic Dip_721_backend --argument '(record {
        collectionCreator = "i47jd-kewyq-vcner-l4xf7-edf77-aw4xp-u2kpb-2qai2-6ie7k-tcngl-oqe";
        external_url = "https://www.youtube.com/";
        royalty = 2.0;
        name = "Collection name";
        description = "a colelction of 10000 hungry rats";
        bannerImage = blob  "0xdfgdfdsdfsdf";
        profileImage = blob "0xfgfdgfgsdfsd";
        canvasWidth = 2400;
        canvasHeight = 2400;
})'

**reisntall commands**
DFX_MOC_PATH="$(vessel bin)/moc" dfx canister --network ic install Dip_721_backend --argument '(record {
        collectionCreator = "i47jd-kewyq-vcner-l4xf7-edf77-aw4xp-u2kpb-2qai2-6ie7k-tcngl-oqe";
        external_url = "https://www.youtube.com/";
        royalty = 2.0;
        name = "Collection name";
        description = "a colelction of 10000 hungry rats";
        bannerImage = blob  "0xdfgdfdsdfsdf";
        profileImage = blob "0xfgfdgfgsdfsd";
        canvasWidth = 2400;
        canvasHeight = 2400;
})' --mode reinstall

DFX_MOC_PATH="$(vessel bin)/moc" dfx deploy nft_registry_backend --argument '(principal "i47jd-kewyq-vcner-l4xf7-edf77-aw4xp-u2kpb-2qai2-6ie7k-tcngl-oqe")'
DFX_MOC_PATH="$(vessel bin)/moc" dfx generate
DFX_MOC_PATH="$(vessel bin)/moc" dfx deploy Dip_721_frontend


**distribute cycles**
dfx ledger fabricate-cycles --amount 1000000 --all
dfx ledger fabricate-cycles --amount 1000000 --canister nft_registry_backend