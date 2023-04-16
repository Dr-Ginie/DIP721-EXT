import { AuthClient } from "@dfinity/auth-client";
import { createActor as nft, idlFactory as nftIdl } from "../../declarations/Cig_721_backend";
import { createActor as registry, idlFactory as registryIDL } from "../../declarations/nft_registry_backend";

var identity
var isPlug = false;
var registryCanister = "p26c3-yyaaa-aaaan-qdd6q-cai";
var principal;

window.connectPlug = async function () {
    await window?.ic?.plug?.requestConnect();
    principal = await window.ic.plug.agent.getPrincipal();
    isPlug = true;
    return principal.toString();
}

window.auth = async function (provider) {
    const authClient = await AuthClient.create();
    let isAuth = await authClient.isAuthenticated()

    if (isAuth) {
        identity = await authClient.getIdentity();
        return identity.getPrincipal().toString();
    } else {
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
        isPlug = false;
        return identity.getPrincipal().toString();
    }
};

window.isAuthenticated = async function () {
    if (isPlug) {
        return await window.ic.plug.isConnected();;
    } else {
        const authClient = await AuthClient.create();
        return await authClient.isAuthenticated();
    }
}

window.getPrincipal = function () {
    if (isPlug) {
        return principal;
    } else {
        return identity.getPrincipal().toString();
    }
}

window.mint = async function (canisterId, recipent) {
    var actor;
    if (isPlug) {
        actor = await window.ic.plug.createActor({
            canisterId: canisterId,
            interfaceFactory: nftIdl,
        });
    } else {
        actor = nft(canisterId, {
            agentOptions: {
                identity,
            },
        });
    }
    return actor.mint(recipent)
}

window.bulkMint = async function (canisterId, count, recipent) {
    var actor;
    if (isPlug) {
        actor = await window.ic.plug.createActor({
            canisterId: canisterId,
            interfaceFactory: nftIdl,
        });
    } else {
        actor = nft(canisterId, {
            agentOptions: {
                identity,
            },
        });
    }
    return actor.bulkMint(count, recipent)
}

window.addWhiteList = async function (canisterId, whiteList) {
    var actor;
    if (isPlug) {
        actor = await window.ic.plug.createActor({
            canisterId: canisterId,
            interfaceFactory: nftIdl,
        });
    } else {
        actor = nft(canisterId, {
            agentOptions: {
                identity,
            },
        });
    }
    return actor.addWhiteList(whiteList)
}

window.setMintPrice = async function (canisterId, value) {
    var actor;
    if (isPlug) {
        actor = await window.ic.plug.createActor({
            canisterId: canisterId,
            interfaceFactory: nftIdl,
        });
    } else {
        actor = nft(canisterId, {
            agentOptions: {
                identity,
            },
        });
    }
    return actor.setMintPrice(value)
}

window.createCollection = async function (collectionCreator, external_url, profileImage, name, description, canvasHeight, bannerImage, canvasWidth, royalty) {
    let request = {
        'collectionCreator': collectionCreator,
        'external_url': external_url,
        'profileImage': profileImage,
        'name': name,
        'description': description,
        'canvasHeight': canvasHeight,
        'bannerImage': bannerImage,
        'canvasWidth': canvasWidth,
        'royalty': royalty,
    };
    var actor;
    if (isPlug) {
        actor = await window.ic.plug.createActor({
            canisterId: registryCanister,
            interfaceFactory: registryIDL,
        });
    } else {
        actor = registry(registryCanister, {
            agentOptions: {
                identity,
            },
        });
    }
    return actor.createCollection(request)
}

var attributesList = []

window.newAttribute = async function (weight, trait_type, value_type, value, contentType, layer_value, display_type) {
    console.log(weight)
    console.log(trait_type)
    console.log(value_type)
    console.log(value)
    console.log(contentType)
    console.log(layer_value)
    console.log(display_type)

    var value_;

    switch (value_type) {
        case 'float':
            value_ = { "float": value }
            break;
        case 'text':
            value_ = { "text": value }
            break;
        case 'number':
            value_ = { "number": value }
            break;
    }

    let layer = {
        'contentType': contentType,
        'value': layer_value,
    };

    let attribute = {
        'weight': weight,
        'trait_type': trait_type,
        'value': value_,
        'layer': [layer],
        'display_type': display_type,
    }

    attributesList.push(attribute)
}

window.addAttribute = async function (canisterId, number) {
    console.log(attributesList);
    console.log("add attribue");
    console.log(isPlug);
    var actor;
    switch (isPlug) {
        case true:
            console.log("is plug")
            actor = await window.ic.plug.createActor({
                canisterId: canisterId,
                interfaceFactory: nftIdl,
            });
            break;
        case false:
            console.log("is not plug")
            actor = nft(canisterId, {
                agentOptions: {
                    identity,
                },
            });
            break;
    }
    console.log(attributesList[0])
    let result = await actor.addAttribute(number, attributesList);
    console.log(result);
    attributesList = [];
    
}

window.getAttribute = async function (canisterId, zindex) {
    if (isPlug) {
        console.log("is plug")
        var actor = await window.ic.plug.createActor({
            canisterId: canisterId,
            interfaceFactory: nftIdl,
        });
        return actor.getAttribute(zindex)
    } else {
        console.log("not plug")
        var actor = nft(canisterId, {
            agentOptions: {
                identity,
            },
        });
        return actor.getAttribute(zindex)
    }
}

window.fetchAttributes = async function (canisterId, zindex) {
    var actor;
    if (isPlug) {
        actor = await window.ic.plug.createActor({
            canisterId: canisterId,
            interfaceFactory: nftIdl,
        });
    } else {
        actor = nft(canisterId, {
            agentOptions: {
                identity,
            },
        });
    }
    return actor.fetchAttributes(zindex)
}

window.removeAttrubute = async function (canisterId, zindex) {
    var actor;
    if (isPlug) {
        actor = await window.ic.plug.createActor({
            canisterId: canisterId,
            interfaceFactory: nftIdl,
        });
    } else {
        actor = nft(canisterId, {
            agentOptions: {
                identity,
            },
        });
    }
    return actor.removeAttrubute(zindex)
}

window.removeFromWhiteList = async function (canisterId, principal) {
    var actor;
    if (isPlug) {
        actor = await window.ic.plug.createActor({
            canisterId: canisterId,
            interfaceFactory: nftIdl,
        });
    } else {
        actor = nft(canisterId, {
            agentOptions: {
                identity,
            },
        });
    }
    return actor.removeFromWhiteList(principal)
}