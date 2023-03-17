// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const {upgrades, ethers} = require("hardhat");

async function main() {
  const Gem = await ethers.getContractFactory("Gem");
  const Berry = await ethers.getContractFactory("PocMon");
  const Tree = await ethers.getContractFactory("PocMon");
  const Gold = await ethers.getContractFactory("PocMon");
  const Artifacts = await ethers.getContractFactory("Artifacts");
  const Blacklist = await ethers.getContractFactory("BlackList");
  const Tools = await ethers.getContractFactory("Tools");
  const Mining = await ethers.getContractFactory("Mining");

  const gem = await Gem.deploy(1);
  const berry = await Berry.deploy(process.env.PANCAKE_ROUTER, gem.address, process.env.PUBLIC_KEY, process.env.PUBLIC_KEY);
  const tree = await Tree.deploy(process.env.PANCAKE_ROUTER, gem.address, process.env.PUBLIC_KEY, process.env.PUBLIC_KEY);
  const gold = await Gold.deploy(process.env.PANCAKE_ROUTER, gem.address, process.env.PUBLIC_KEY, process.env.PUBLIC_KEY);
  const blacklist = await Blacklist.deploy();

  const tools = await upgrades.deployProxy(Tools, [blacklist.address, berry.address, tree.address, gold.address, process.env.BASE_URI]);
  const artifacts = await upgrades.deployProxy(Artifacts, [tools.address, process.env.BASE_URI, blacklist.address]);
  const mining = await upgrades.deployProxy(Mining, [blacklist.address, tools.address]);

  await artifacts.setToolsAddress(tools.address);
  await tools.setArtifactsAddress(artifacts.address);
  await tools.setMiningAddress(mining.address);

  console.log("Tools address: ", tools.address);
  console.log("Artifacts address: ", artifacts.address);
  console.log("Mining address: ", mining.address);
  console.log("Blacklist address: ", blacklist.address);
  console.log("Berry address: ", berry.address);
  console.log("Tree address: ", tree.address);
  console.log("Gold address: ", gold.address);
  console.log("Gem address: ", gem.address);
  // // add raspberry bush
  // await tools.addTool(1, 100, 30, 1, 5, 10);
  // // add magic berry
  // await tools.addTool(1, 400, 50, 30, 20, 300);
  // // create recipe for raspberry bush
  // await tools.createRecipe(1, [0, 200, 40], [0, 0, 0, 0, 0, 0]);
  // // create recipe for magic berry
  // await tools.createRecipe(2, [0, 5400, 1080], [1, 0, 0, 0, 0, 0]);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
