import { AuthClient } from "@dfinity/auth-client";
import { createActor as nft } from "../../declarations/Cig_721_backend";
import { createActor as registry } from "../../declarations/nft_registry_backend";

var identity

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
        return identity.getPrincipal().toString();
    }
};

window.isAuthenticated = async function () {
    const authClient = await AuthClient.create();
    return await authClient.isAuthenticated();
}

window.getPrincipal = function () {
    return identity.getPrincipal().toString();
}

window.mint = async function (canisterId, recipent) {
    const actor = nft(canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.mint(recipent)
}

window.bulkMint = async function (canisterId, count, recipent) {
    const actor = nft(canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.bulkMint(count, recipent)
}

window.addWhiteList = async function (canisterId, whiteList) {
    const actor = nft(canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.addWhiteList(whiteList)
}

window.setMintPrice = async function (canisterId, value) {
    const actor = nft(canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.setMintPrice(value)
}

window.createCollection = async function (canisterId, collectionCreator, external_url, profileImage, name, description, canvasHeight, bannerImage, canvasWidth, royalty) {
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
    const actor = registry(canisterId, {
        agentOptions: {
            identity,
        },
    });
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
            value_ = {"float":value}
            break;
        case 'text':
            value_ = {"text":value}
            break;
        case 'number':
            value_ = {"number":value}
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
    const actor = nft(canisterId, {
        agentOptions: {
            identity,
        },
    });
    let result = await actor.addAttribute(number, attributesList);
    attributesList = [];
    console.log(result);
}

window.getAttribute = async function (canisterId, zindex) {
    const actor = nft(canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.getAttribute(zindex)
}

window.fetchAttributes = async function (canisterId, zindex) {
    const actor = nft(canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.fetchAttributes(zindex)
}

window.removeAttrubute = async function (canisterId, zindex) {
    const actor = nft(canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.removeAttrubute(zindex)
}

// window.addLayer = async function (canisterId, number, layer) {
//     const actor = registry(canisterId, {
//         agentOptions: {
//             identity,
//         },
//     });
//     return actor.addLayer(number, layer)
// }

// window.removeLayer = async function (canisterId, number) {
//     const actor = registry(canisterId, {
//         agentOptions: {
//             identity,
//         },
//     });
//     return actor.removeLayer(number)
// }

window.removeFromWhiteList = async function (canisterId, principal) {
    const actor = nft(canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.removeFromWhiteList(principal)
}

function stringify(obj) {
    let cache = [];
    let str = JSON.stringify(obj, function (key, value) {
        if (typeof value === "object" && value !== null) {
            if (cache.indexOf(value) !== -1) {
                // Circular reference found, discard key
                return;
            }
            // Store value in our collection
            cache.push(value);
        }
        return value;
    });
    cache = null; // reset the cache
    return str;
}