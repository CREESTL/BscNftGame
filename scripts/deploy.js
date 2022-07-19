// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const {upgrades, ethers} = require("hardhat");

async function main() {
  const BlackList = await ethers.getContractFactory("BlackList");
  const blacklist = await BlackList.deploy();

  await blacklist.deployed();
  console.log("blacklist deployed to:", blacklist.address);


  const Artifacts = await ethers.getContractFactory("Artifacts");
  const artifacts = await upgrades.deployProxy(Artifacts, [process.env.BASE_URL, blacklist.address]);

  await artifacts.deployed();
  console.log("artifacts deployed to:", artifacts.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
