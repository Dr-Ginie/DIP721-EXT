#!/bin/bash
# dfx start --background

# create a temp dir for the root key

ROOT_HOME=$(mktemp -d)
ROOT_PUBLIC_KEY="principal \"$(HOME=$ROOT_HOME dfx identity get-principal)\""
PRINCIPAL=\"$(HOME=$ROOT_HOME dfx identity get-principal)\"



# ROOT_PUBLIC_KEY="principal \"$(dfx identity get-principal)\""

# DFX_MOC_PATH="$(vessel bin)/moc" dfx deploy Dip_721_backend --argument '(record {
#         collectionCreator = $ROOT_PUBLIC_KEY;
#         external_url = "https://www.stringcheese.social";
#         royalty = 0.0;
#         name = "Cheezie";
#         description = "say cheeze !";
#         bannerImage = blob  "0x";
#         profileImage = blob "0x";
#         canvasWidth = 490;
#         canvasHeight = 490;
# })'

# start mint for an hour
# mint 1000 nfts with metadata on a basic pic
# close mint

# HOME=$ROOT_HOME DFX_MOC_PATH="$(vessel bin)/moc" dfx canister call Dip_721_backend startMint '(3600)'

HOME=$ROOT_HOME DFX_MOC_PATH="$(vessel bin)/moc" dfx canister call Dip_721_backend mint "(blob "0x", $ROOT_PUBLIC_KEY)"

HOME=$ROOT_HOME DFX_MOC_PATH="$(vessel bin)/moc" dfx canister call Dip_721_backend mint "(blob "0x", $ROOT_PUBLIC_KEY)"


# HOME=$ROOT_HOME DFX_MOC_PATH="$(vessel bin)/moc" dfx canister call Dip_721_backend bulkMint '(
#         record {
#                 [blob "0x"];
#                 id = 0;
#         }
#     )'