// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const {upgrades, ethers} = require("hardhat");

async function main() {
  //const Gem = await ethers.getContractFactory("Gem");
  const gem = await ethers.getContractAt("Gem", "0xAe15c8932c02773F53a271e586A071227b0A5Ff5");
  const Berry = await ethers.getContractFactory("PocMon");
/*   const Tree = await ethers.getContractFactory("PocMon");
  const Gold = await ethers.getContractFactory("PocMon");
 */
  //const gem = await Gem.deploy(1);
  const berry = await Berry.deploy(process.env.PANCAKE_ROUTER, gem.address, process.env.PUBLIC_KEY, process.env.PUBLIC_KEY);
/*   const tree = await Tree.deploy(process.env.PANCAKE_ROUTER, gem.address, process.env.PUBLIC_KEY, process.env.PUBLIC_KEY);
  const gold = await Gold.deploy(process.env.PANCAKE_ROUTER, gem.address, process.env.PUBLIC_KEY, process.env.PUBLIC_KEY);
 */

  console.log("Berry address: ", berry.address);
 /*  console.log("Tree address: ", tree.address);
  console.log("Gold address: ", gold.address);
  console.log("Gem address: ", gem.address); */

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
