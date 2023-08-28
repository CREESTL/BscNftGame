/**
 * This file contains examples of forming signatures to be verified onchain
 */

const { arrayify } = require("ethers/lib/utils");
const { ethers } = require("hardhat");
const backendAcc = new ethers.Wallet(process.env.BACKEND_PRIVATE_KEY);
const encodePacked = ethers.utils.solidityPack;
const coder = ethers.utils.defaultAbiCoder;
const keccak256 = ethers.utils.solidityKeccak256;

// Encodes mining function parameters to get the hash of the tx
// The same hashing algorithm is used on-chain for `startMining` function
// This hash should be signed by the backend. The signature is checked on-chain as well
// address: The address of the Mining contract to call
// toolId: The ID of the tool used for mining
// user: The user who started mining
// recourcesAmount: The amount of recources to win after mining
// artifactsAmount: The amount of artifacts to win after mining
// nonce: The unique integer
function getTxHashMining(
  address,
  toolId,
  user,
  recourcesAmount,
  artifactsAmount,
  nonce
) {
  return keccak256(
    ["bytes"],
    [
      encodePacked(
        ["address", "uint256", "address", "uint256[]", "uint256[]", "uint256"],
        [address, toolId, user, recourcesAmount, artifactsAmount, nonce]
      ),
    ]
  );
}

// Forms a hash of all parameters and signs it with the backend private key
// The resulting signature should be passed to `startMining` function as the last parameter
// address: The address of the Mining contract to call
// toolId: The ID of the tool used for mining
// user: The user who started mining
// recourcesAmount: The amount of recources to win after mining
// artifactsAmount: The amount of artifacts to win after mining
// nonce: The unique integer
async function hashAndSignMining(
  address,
  toolId,
  user,
  recourcesAmount,
  artifactsAmount,
  nonce
) {
  // Signature is prefixed with "\x19Ethereum Signed Message:\n"
  let signature = await backendAcc.signMessage(
    // Bytes hash should be converted to array before signing
    arrayify(
      getTxHashMining(
        address,
        toolId,
        user,
        recourcesAmount,
        artifactsAmount,
        nonce
      )
    )
  );

  return signature;
}

// Encodes mining function parameters so that user cannot see them in raw format
// resourcesAmount: The amount of resources to be mined (array)
// artifactsAmount: The amount of artifacts to be mined (array)
// Returns the ABI-encoded arrays
function getRewardsHash(resourcesAmount, artifactsAmount) {
  return coder.encode(
    ["uint256[]", "uint256[]"],
    [resourcesAmount, artifactsAmount]
  );
}

module.exports = {
  getTxHashMining,
  hashAndSignMining,
  getRewardsHash,
};
