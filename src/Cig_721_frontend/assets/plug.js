let registryActor;
let nftActor;
let principal;

const whitelist = ["rrkah-fqaaa-aaaaa-aaaaq-cai"];

async function setupRegistryActor(canister) {
    registryActor = await window.ic.plug.createActor({
        canisterId: canister,
        interfaceFactory: registryIDL,
    });
    console.log("Registry actor")
    console.log(registryActor)
}

async function setupNFTActor(canister) {
    nftActor = await window.ic.plug.createActor({
        canisterId: canister,
        interfaceFactory: nftIdl,
    });
    console.log("NFT Actor")
    console.log(nftActor)
}

async function isConnected() {
    await window?.ic?.plug?.requestConnect({
        whitelist,
    })
    principal = await window.ic.plug.agent.getPrincipal();
    console.log(principal);
    await setupRegistryActor("rrkah-fqaaa-aaaaa-aaaaq-cai");
}

function getPrincipal() {
    return principal.toString()
}

async function transfer(params) {
    const result = await window.ic.plug.requestTransfer(params);
    console.log(result);
    return jsonFactory(result)
}

function jsonFactory(json) {
    return JSON.stringify(json, (key, value) =>
        typeof value === 'bigint'
            ? value.toString()
            : value // return everything else unchanged
    )
}