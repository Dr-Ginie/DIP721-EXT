import { aliceActor, bobActor, deployerActor, johnActor } from "../setup";

const normalActors = [aliceActor, bobActor, johnActor];
const allActors = [...normalActors, deployerActor];

it("Cover metadata.", async () => {
  console.log("testing");
  // (await Promise.all(allActors.map(actor => actor.git_commit_hash()))).forEach(result =>
  //   t.true(typeof result === "string" && result !== "")
  // );
  // (await Promise.all(allActors.map(actor => actor.rust_toolchain_info()))).forEach(result =>
  //   t.true(typeof result === "string" && result !== "")
  // );
  // (await Promise.all(allActors.map(actor => actor.dfx_info()))).forEach(result =>
  //   t.true(typeof result === "string" && result !== "")
  // );
});
