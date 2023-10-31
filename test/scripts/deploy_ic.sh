#!/usr/bin/bash
dfx start --background
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