#!/bin/bash
dfx stop
dfx start --background --clean

# create a temp dir for the root key
ROOT_HOME=$(mktemp -d)
ROOT_PUBLIC_KEY="principal \"$(HOME=$ROOT_HOME dfx identity get-principal)\""
PRINCIPAL=\"$(HOME=$ROOT_HOME dfx identity get-principal)\"
# ROOT_PUBLIC_KEY="principal \"$(dfx identity get-principal)\""
DEPLOYER=\"xxzsj-nukpm-lgp77-ogouk-7u72u-qvpnj-ppjgn-o736o-z4ezi-jvegq-uae\"

HOME=$ROOT_HOME DFX_MOC_PATH="$(vessel bin)/moc" dfx deploy Dip_721_backend --argument "(record {
        collectionCreator = $DEPLOYER;
        external_url =  \"https://www.stringcheese.social\";
        royalty = 0.0;
        name = \"Cheezie\";
        description = \"description\";
        bannerImage = blob  \"0x\";
        profileImage = blob \"0x\";
        canvasWidth = 490;
        canvasHeight = 490;
})"

cd ..
npm run test
# node dist/integrations/mint.js



# HOME=$ROOT_HOME DFX_MOC_PATH="$(vessel bin)/moc" dfx canister call Dip_721_backend startMint '(3600)'
# HOME=$ROOT_HOME DFX_MOC_PATH="$(vessel bin)/moc" dfx canister call Dip_721_backend mint "(blob "0x", $ROOT_PUBLIC_KEY)"
# HOME=$ROOT_HOME DFX_MOC_PATH="$(vessel bin)/moc" dfx canister call Dip_721_backend mint "(blob "0x", $ROOT_PUBLIC_KEY)"
# HOME=$ROOT_HOME DFX_MOC_PATH="$(vessel bin)/moc" dfx canister call Dip_721_backend bulkMint '(
#         record {
#                 [blob "0x"];
#                 id = 0;
#         }
#     )'