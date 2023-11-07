import fs, { readFileSync } from "fs";
import { aliceActor, bobActor, deployerActor, johnActor, deployerIdentity, aliceIdentity } from "../setup";

const normalActors = [aliceActor, bobActor, johnActor];
const allActors = [...normalActors, deployerActor];
const image = readFileSync("./iwancheez.png", { encoding: "utf8" });

describe("Mint it",  () => {
  

  test("Start Mint", async () => {
    const a = await deployerActor;
    a.startMint(BigInt(60 * 5));
  });

  test("Mint one", async () => {
    const a = await deployerActor;
    var res = await a.mint(Buffer.from(image), deployerIdentity.getPrincipal());
    console.log(res);
  });

  test("Mint Bulk", async () => {
    const a = await deployerActor;
    const imageU8 = Buffer.from(image);
    const images = [];
    for (let i = 0; i++; i < 100) {
      images.push(imageU8);
    }
    console.log(images.length);
    var res = await a.bulkMint(images, deployerIdentity.getPrincipal());
    console.log(res);
  });

  test("transfer", async () => {
    const a = await deployerActor;
    var res = await a.transfer(aliceIdentity.getPrincipal(), 1);
    console.log(res);
  });
});
