/**
 * This file contains examples of forming signatures to be verified onchain
 */

const { arrayify } = require("ethers/lib/utils");
const { ethers } = require("hardhat");
const backendAcc = new ethers.Wallet(process.env.BACKEND_PRIVATE_KEY);
const encodePacked = ethers.utils.solidityPack;
const coder = ethers.utils.defaultAbiCoder;
const keccak256 = ethers.utils.solidityKeccak256;

function getRewardsHash(resourcesAmount, artifactsAmount) {
  return coder.encode(
    ["uint256[]", "uint256[]"],
    [resourcesAmount, artifactsAmount]
  );
}

async function main() {
  console.log(
    "Hash for rewards is:\n",
    getRewardsHash([777, 546, 999], [2, 1999])
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
