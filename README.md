
**deploy commands**
DFX_MOC_PATH="$(vessel bin)/moc" dfx deploy Cig_721_backend --argument '(record {
        collectionCreator = principal "qtkcs-s2ah4-2525z-isucu-pkb3c-gdhke-pp2l2-xt5ye-ttcin-3weru-xqe";
        royalty = 2.0;
        name = "Collection name";
        description = "a colelction of 10000 hungry rats";
        bannerImage = blob  "0xdfgdfdsdfsdf";
        profileImage = blob "0xfgfdgfgsdfsd";
        canvasWidth = 2400;
        canvasHeight = 2400;
})'

DFX_MOC_PATH="$(vessel bin)/moc" dfx deploy nft_registry_backend --argument '(principal "qtkcs-s2ah4-2525z-isucu-pkb3c-gdhke-pp2l2-xt5ye-ttcin-3weru-xqe")'
DFX_MOC_PATH="$(vessel bin)/moc" dfx generate
DFX_MOC_PATH="$(vessel bin)/moc" dfx deploy Cig_721_frontend


**distribute cycles**
dfx ledger fabricate-cycles --amount 1000000 --all
dfx ledger fabricate-cycles --amount 1000000 --canister nft_registry_backend