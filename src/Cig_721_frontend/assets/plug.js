var registryCanister = "p26c3-yyaaa-aaaan-qdd6q-cai";
var principal;

async function connectPlug() {
    await window?.ic?.plug?.requestConnect();
    principal = await window.ic.plug.agent.getPrincipal();
    isPlug = true;
    return principal.toString();
}

async function isAuthenticated() {
    return await window.ic.plug.isConnected();;
}

var attributesList = []

async function newAttribute(weight, trait_type, value_type, value, contentType, layer_value, display_type) {
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

async function addAttribute(canisterId, number) {
    console.log(attributesList);
    console.log("add attribue");
    console.log(isPlug);
    var actor = await window.ic.plug.createActor({
        canisterId: canisterId,
        interfaceFactory: nftIDL,
    });
    console.log(attributesList[0])
    let result = await actor.addAttribute(number, attributesList);
    console.log(result);
    attributesList = [];
    
}