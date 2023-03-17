// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const {upgrades, ethers} = require("hardhat");

async function main() {
 
 
  const berry = await ethers.getContractAt("PocMon", "0xFe873Bb771Fd8398845Ffdac03a5A1FA068b3180");
  const tree = await ethers.getContractAt("PocMon", "0xe194f7F264819b92E0BA926305A465db180cCF95");
  const gold = await ethers.getContractAt("PocMon", "0x097CB7475A62E6BA115d2A3AE2e13aACFEC7e450");

await berry.setReflectionFeePercent(0)
await berry.setGemFeePercent(0)
await berry.setLiquidityFeePercent(0)

await tree.setReflectionFeePercent(0)
await tree.setGemFeePercent(0)
await tree.setLiquidityFeePercent(0)

await gold.setReflectionFeePercent(0)
await gold.setGemFeePercent(0)
await gold.setLiquidityFeePercent(0)

  console.log("Switched: Ok");

}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
