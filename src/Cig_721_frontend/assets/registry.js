async function createCollection(request) {
    console.log(request)
    const result = await registryActor.createCollection(request); 
    console.log(result);
    return jsonFactory(result);
}
