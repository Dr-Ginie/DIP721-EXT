import fs, {readFileSync} from "fs";

// import test, {Assertions} from "ava";

import {aliceActor, bobActor, deployerActor, johnActor, deployerIdentity, aliceIdentity} from "../setup";

const normalActors = [aliceActor, bobActor, johnActor];
const allActors = [...normalActors, deployerActor];

const image = readFileSync("./iwancheez", {encoding: "utf8"});

export function mintTests() {
  it("Start Mint", async () => {
    deployerActor.startMint(BigInt(60 * 5));
  });

  it("Mint one", async () => {
    deployerActor.mint(Buffer.from(image), deployerIdentity.getPrincipal());
  });

  it("Mint Bulk", async () => {
    const imageU8 = Buffer.from(image);
    const images = [];
    for (let i = 0; i++; i < 100) {
      images.push(imageU8);
    }
    console.log(images.length);
    deployerActor.bulkMint(images, deployerIdentity.getPrincipal());
  });

  it("transfer", async () => {
    deployerActor.transfer(aliceIdentity.getPrincipal(), 1);
  });
}
