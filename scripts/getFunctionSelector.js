const { ethers } = require("hardhat");

/*

Outputs a function selector given a function signature.
Could be used for debug

*/

function getFunctionSelector(signature) {
  const signatureBytes = ethers.utils.toUtf8Bytes(signature);
  const signatureHash = ethers.utils.keccak256(signatureBytes);
  // We need first 4 bytes (8 characters).
  // Hash starts with '0x' which we don't need
  const fourBytes = signatureHash.slice(0, 10);
  return fourBytes;
}

function main() {
  // Place your signature here
  let signatures = [
    "corrupt(address,uint256,uint256)",
    "safeTransferFrom(address,address,uint256,uint256,bytes)",
    "getResourcesTypesAmount()",
    "getResourceAddress(uint256)",
    "getArtifactsTypesAmount()",
    "getArtifactsAddress()",
    "endMining(uint256)",
    "check(address)",
    "getMiningAddress()",
    "craft(uint256)",
    "transferFrom(address,address,uint256)",
  ];
  for (let i = 0; i < signatures.length; i++) {
    let signature = signatures[i];
    console.log("Signature is: ", signature);
    let selector = getFunctionSelector(signature);
    console.log("Function selector is: ", selector);
  }
}

main();

process.exit(0);
