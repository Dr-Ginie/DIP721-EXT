import fs, {readFileSync} from "fs";

import test, {Assertions} from "ava";

import {aliceActor, bobActor, deployerActor, johnActor, deployerIdentity, aliceIdentity} from "../setup";

const normalActors = [aliceActor, bobActor, johnActor];
const allActors = [...normalActors, deployerActor];

const image = readFileSync("./iwancheez", {encoding: "utf8"});

test("Start Mint", async (t: Assertions) => {
  deployerActor.startMint(BigInt(60 * 5));
});

test("Mint one", async (t: Assertions) => {
  deployerActor.mint(Buffer.from(image), deployerIdentity.getPrincipal());
});

test("Mint Bulk", async (t: Assertions) => {
  const imageU8 = Buffer.from(image);
  const images = [];
  for (let i = 0; i++; i < 100) {
    images.push(imageU8);
  }
  console.log(images.length);
  deployerActor.bulkMint(images, deployerIdentity.getPrincipal());
});

test("transfer", async (t: Assertions) => {
  deployerActor.transfer(aliceIdentity.getPrincipal(), 1);
});
