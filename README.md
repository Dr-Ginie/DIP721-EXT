**deploy commands**
DFX_MOC_PATH="$(vessel bin)/moc" dfx deploy --network ic Dip_721_backend --argument '(record {
        collectionCreator = "g6y37-bv4cm-k6fim-6vsqi-5admi-2j7cl-xjz35-hck36-3ntz4-nlm6h-fae";
        external_url = "https://www.stringcheese.social";
        royalty = 0.0;
        name = "Cheezie";
        description = "say cheeze !";
        bannerImage = blob  "0x";
        profileImage = blob "0x";
        canvasWidth = 490;
        canvasHeight = 490;
})'

**deploy commands local**
DFX_MOC_PATH="$(vessel bin)/moc" dfx deploy Dip_721_backend --argument '(record {
        collectionCreator = "xxzsj-nukpm-lgp77-ogouk-7u72u-qvpnj-ppjgn-o736o-z4ezi-jvegq-uae";
        external_url = "https://www.stringcheese.social";
        royalty = 0.0;
        name = "Cheezie";
        description = "say cheeze !";
        bannerImage = blob  "0xdfgdfdsdfsdf";
        profileImage = blob "0xfgfdgfgsdfsd";
        canvasWidth = 980;
        canvasHeight = 980;
})'

**reisntall commands**
DFX_MOC_PATH="$(vessel bin)/moc" dfx canister --network ic install Dip_721_backend --argument '(record {
           collectionCreator = "g6y37-bv4cm-k6fim-6vsqi-5admi-2j7cl-xjz35-hck36-3ntz4-nlm6h-fae";
        external_url = "https://www.stringcheese.social";
        royalty = 0.0;
        name = "Cheezie";
        description = "say cheeze !";
        bannerImage = blob  "0x";
        profileImage = blob "0x";
        canvasWidth = 490;
        canvasHeight = 490;
})' --mode reinstall

DFX_MOC_PATH="$(vessel bin)/moc" dfx deploy nft_registry_backend --argument '(principal "i47jd-kewyq-vcner-l4xf7-edf77-aw4xp-u2kpb-2qai2-6ie7k-tcngl-oqe")'
DFX_MOC_PATH="$(vessel bin)/moc" dfx generate
DFX_MOC_PATH="$(vessel bin)/moc" dfx deploy Dip_721_frontend


**distribute cycles**
dfx ledger fabricate-cycles --amount 1000000 --all
dfx ledger fabricate-cycles --amount 1000000 --canister nft_registry_backend


todo

line 402 is owner assert. using holders hashmap
add images to hashmap along with menifets during mint

write test functions inside canister and outside canister.