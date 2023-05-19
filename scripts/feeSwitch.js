// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { upgrades, ethers } = require("hardhat");

async function main() {
  const berry = await ethers.getContractAt(
    "PocMon",
    "0xf01cdeff5dE5a2ff3399147588165792f4A51Ffe"
  );
  const tree = await ethers.getContractAt(
    "PocMon",
    "0x933edB289A7Cf1CfBfB06010E3B7b8Ed9ADEeF31"
  );
  const gold = await ethers.getContractAt(
    "PocMon",
    "0xEd25Ee3bbE7832fd15456A06570C0b9bf610BF71"
  );

  await berry.setReflectionFeePercent(0);
  await berry.setGemFeePercent(0);
  await berry.setLiquidityFeePercent(0);

  await tree.setReflectionFeePercent(0);
  await tree.setGemFeePercent(0);
  await tree.setLiquidityFeePercent(0);

  await gold.setReflectionFeePercent(0);
  await gold.setGemFeePercent(0);
  await gold.setLiquidityFeePercent(0);

  console.log("Switched: Ok");
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
