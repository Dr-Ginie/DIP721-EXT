import { AuthClient } from "@dfinity/auth-client";
//import { renderIndex } from "./views";
//import { renderLoggedIn } from "./views/loggedIn";
import nft from "../../declarations/Cig_721_backend";
import registry from "../../declarations/nft_registry_backend";

var identity

window.auth = async function (provider) {
    const authClient = await AuthClient.create();
    if (await authClient.isAuthenticated()) {
        handleAuthenticated(authClient);
    }
    //renderIndex();


    const days = BigInt(1);
    const hours = BigInt(24);
    const nanoseconds = BigInt(3600000000000);
    const nfid = 'https://nfid.one/authenticate/?applicationName=SpaceTurtle&applicationLogo=https://flutter.dev/images/flutter-logo-sharing.png#authorize';
    const II = 'https://identity.ic0.app/#authorize';

    await authClient.login({
        onSuccess: async () => {
            identity = await authClient.getIdentity();
        },
        identityProvider: provider === "nfid" ? nfid : II,
        // Maximum authorization expiration is 8 days
        maxTimeToLive: days * hours * nanoseconds,
    });
};

window.getPrincipal = function () {
    return identity.getPrincipal().toString();
}

window.mint = async function (mintRequest) {
    const actor = nft.createActor(nft.canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.mint(mintRequest)
}

window.bulkMint = async function (mintRequests) {
    const actor = nft.createActor(nft.canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.bulkMint(mintRequests)
}

window.createCollection = async function (request) {
    const actor = registry.createActor(registry.canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.createCollection(request)
}

window.setAttributes = async function (attributes) {
    const actor = registry.createActor(nft.canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.setAttributes(attributes)
}

window.addLayer = async function (number,layer) {
    const actor = registry.createActor(nft.canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.addLayer(number,layer)
}