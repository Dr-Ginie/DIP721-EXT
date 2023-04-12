import { AuthClient } from "@dfinity/auth-client";
//import { renderIndex } from "./views";
//import { renderLoggedIn } from "./views/loggedIn";
import nft from "../../declarations/Cig_721_backend";
import registry from "../../declarations/nft_registry_backend";
import mergeImages from 'merge-images';

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
    const actor = nft.createActor(canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.mint(recipent)
}

window.bulkMint = async function (canisterId, count, recipent) {
    const actor = nft.createActor(canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.bulkMint(count, recipent)
}

window.addWhiteList = async function (canisterId, whiteList) {
    const actor = nft.createActor(canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.addWhiteList(whiteList)
}

window.setMintPrice = async function (canisterId, value) {
    const actor = nft.createActor(canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.setMintPrice(value)
}

window.createCollection = async function (canisterId, request) {
    const actor = registry.createActor(canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.createCollection(request)
}

window.addAttributes = async function (canisterId, zindex, attributes) {
    const actor = nft.createActor(canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.addAttributes(zindex, attributes)
}

window.getAttribute = async function (canisterId, zindex) {
    const actor = nft.createActor(canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.getAttribute(zindex)
}

window.fetchAttributes = async function (canisterId, zindex) {
    const actor = nft.createActor(canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.fetchAttributes(zindex)
}

window.removeAttrubute = async function (canisterId, zindex) {
    const actor = nft.createActor(canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.removeAttrubute(zindex)
}

// window.addLayer = async function (canisterId, number, layer) {
//     const actor = registry.createActor(canisterId, {
//         agentOptions: {
//             identity,
//         },
//     });
//     return actor.addLayer(number, layer)
// }

// window.removeLayer = async function (canisterId, number) {
//     const actor = registry.createActor(canisterId, {
//         agentOptions: {
//             identity,
//         },
//     });
//     return actor.removeLayer(number)
// }

window.removeFromWhiteList = async function (canisterId, principal) {
    const actor = nft.createActor(canisterId, {
        agentOptions: {
            identity,
        },
    });
    return actor.removeFromWhiteList(principal)
}

//const base64Image = await mergeImages(['/body.png', '/eyes.png', '/mouth.png'])

/*const colors = [{ value: "red", weight: 100 }, { value: "blue", weight: 100 }, { value: "yellow", weight: 100 }];
const directions = [{ value: "up", weight: 100 }, { value: "down", weight: 100 }, { value: "left", weight: 100 }, { value: "right", weight: 100 }];
const animal = [{ value: "wolf", weight: 100 }, { value: "cow", weight: 100 }, { value: "human", weight: 100 }, { value: "mouse", weight: 100 }];
const layers = [colors, directions, animal];

const DNA_DELIMITER = "-";
var dnaList = new Set();

const isDnaUnique = (_DnaList = new Set(), _dna = "") => {
    const _filteredDNA = filterDNAOptions(_dna);
    return !_DnaList.has(_filteredDNA);
};

const filterDNAOptions = (_dna) => {
    const dnaItems = _dna.split(DNA_DELIMITER);
    const filteredDNA = dnaItems.filter((element) => {
        const query = /(\?.*$)/;
        const querystring = query.exec(element);
        if (!querystring) {
            return true;
        }
        const options = querystring[1].split("&").reduce((r, setting) => {
            const keyPairs = setting.split("=");
            return { ...r, [keyPairs[0]]: keyPairs[1] };
        }, []);

        return options.bypassDNA;
    });

    return filteredDNA.join(DNA_DELIMITER);
};

const createDna = (_layers) => {
    let randNum = [];
    _layers.forEach((layer) => {
        var totalWeight = 0;
        layer.forEach((element) => {
            totalWeight += element.weight;
        });
        // number between 0 - totalWeight
        let random = Math.floor(Math.random() * totalWeight);
        for (var i = 0; i < layer.length; i++) {
            // subtract the current weight from the random weight until we reach a sub zero value.
            random -= layer[i].weight;
            if (random < 0) {
                return randNum.push(
                    `${layer[i].value}`
                );
            }
        }
    });
    return randNum.join(DNA_DELIMITER);
};

const startCreating = async () => {
    let layerConfigIndex = 0;
    let editionCount = 1;
    let growEditionSizeTo = 20;
    let failedCount = 0;
    let abstractedIndexes = [];
    let uniqueDnaTorrance = 5;

    while (
        editionCount <= growEditionSizeTo
    ) {
        let newDna = createDna(layers);
        if (isDnaUnique(dnaList, newDna)) {
            dnaList.add(filterDNAOptions(newDna));
            editionCount++;
            abstractedIndexes.shift();
        } else {
            console.log("DNA exists!");
            failedCount++;
            if (failedCount >= uniqueDnaTorrance) {
                console.log(
                    `You need more layers or elements to grow your edition to ${growEditionSizeTo} artworks!`
                );
                process.exit();
            }
        }
    }
    console.log(dnaList.length);
    console.log(dnaList);
};*/