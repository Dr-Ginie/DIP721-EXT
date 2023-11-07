import { readFileSync } from "fs";
import { Actor, HttpAgent, Identity } from "@dfinity/agent";
import { Ed25519KeyIdentity } from "@dfinity/identity";
import { _SERVICE as Service } from "./factory/service.did.d";
import { idlFactory } from "./factory/service.did";

// import fetch from "isomorphic-fetch";
export const host = "http://127.0.0.1:8000";

export const aliceIdentity = Ed25519KeyIdentity.generate();
export const bobIdentity = Ed25519KeyIdentity.generate();
export const johnIdentity = Ed25519KeyIdentity.generate();

// for testing only
// principal id = "xxzsj-nukpm-lgp77-ogouk-7u72u-qvpnj-ppjgn-o736o-z4ezi-jvegq-uae"

const secretKey = readFileSync("./deployer-test-secret", { encoding: "utf8" });
export const deployerIdentity = Ed25519KeyIdentity.fromSecretKey(
  Buffer.from(secretKey, "hex")
);

const canister_ids = JSON.parse(
  readFileSync("../.dfx/local/canister_ids.json", { encoding: "utf8" })
);
export const nftCanisterId = canister_ids["Dip_721_backend"].local as string;

const agent = (identity: Ed25519KeyIdentity) => {
  const agent = new HttpAgent({ host, identity });
  agent.fetchRootKey();
  return agent;
};

const createActor = async (identity: Identity): Promise<Service> => {
// const createActor = (identity: Identity): Service => {
  const agent = new HttpAgent({ host, fetch, identity });
  const actor = Actor.createActor<Service>(idlFactory, {
    canisterId: nftCanisterId,
    agent,
  });
  // Fetch root key for certificate validation during development
  await agent.fetchRootKey().catch((err) => {
    console.error(
      "Unable to fetch root key. Check to ensure that your local replica is running"
    );
    throw err;
  });
  return actor;
};

export const aliceActor = createActor(aliceIdentity);
export const bobActor = createActor(bobIdentity);
export const johnActor = createActor(johnIdentity);
export const deployerActor = createActor(deployerIdentity);

export default {
  alice: aliceIdentity,
  bob: bobIdentity,
  john: johnIdentity,
  deployer: deployerIdentity,
  allIDs: [aliceIdentity, bobIdentity, johnIdentity, deployerIdentity],
};
