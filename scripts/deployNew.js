const { ethers, network, upgrades } = require("hardhat");
const fs = require("fs");
const path = require("path");
const delay = require("delay");
require("dotenv").config();

// JSON file to keep information about previous deployments
const fileName = "./deployOutput.json";
const OUTPUT_DEPLOY = require(fileName);

const PANCAKE_ROUTER_ADDRESS = process.env.PANCAKE_ROUTER_ADDRESS;
const ACC_ADDRESS = process.env.ACC_ADDRESS;
const BASE_URI = process.env.BASE_URI;

let contractName;

let artifactURIs = [
  "QmdC3otayo1QaoEA9Jf2Czvz2hHuX2w8umM1Kji7wZgNyH",
  "QmQrKjnhRo8rGrqDC6JjMfgAme3Poan96v1ri5EY28TN2P",
  "QmXKsHDa9TNkBZ8DEjxJTBcQFbSCvsv1XZTJz8YvgfjbWR",
  "QmVn9bhbdH68pgE5rBppAa4FcgoAvoVyXLVcH64wQ82Htm",
  "QmX54LcHuaVxd4mjPLUmXaPbJaTCgymrCuzHUBXD6JSSfe",
  "QmQtGq6Hxp9AAPes85ciJfjU1gCktHS319BAq5umoNEdEL",
];

async function main() {
  console.log(`[NOTICE!] Chain of deployment: ${network.name}`);

  // ====================================================

  // Contract #1: Gem

  contractName = "Gem";
  console.log(`[${contractName}]: Start of Deployment...`);
  let gemFactory = await ethers.getContractFactory(contractName);
  const gem = await gemFactory.deploy(1);
  await gem.deployed();
  console.log(`[${contractName}]: Deployment Finished!`);
  OUTPUT_DEPLOY[network.name][contractName].address = gem.address;

  // Verify
  console.log(`[${contractName}]: Start of Verification...`);

  await delay(90000);

  if (network.name === "bsc_mainnet") {
    url = "https://bscscan.com/address/" + gem.address + "#code";
  } else if (network.name === "bsc_testnet") {
    url = "https://testnet.bscscan.com/address/" + gem.address + "#code";
  }

  OUTPUT_DEPLOY[network.name][contractName].verification = url;

  try {
    await hre.run("verify:verify", {
      address: gem.address,
      constructorArguments: [1],
    });
  } catch (error) {
    console.error(error);
  }
  console.log(`[${contractName}]: Verification Finished!`);

  // ====================================================

  // Contract #2: Berry

  contractName = "Berry";
  console.log(`[${contractName}]: Start of Deployment...`);
  let berryFactory = await ethers.getContractFactory("PocMon");
  const berry = await berryFactory.deploy(
    PANCAKE_ROUTER_ADDRESS,
    gem.address,
    ACC_ADDRESS,
    ACC_ADDRESS
  );
  await berry.deployed();
  console.log(`[${contractName}]: Deployment Finished!`);
  OUTPUT_DEPLOY[network.name][contractName].address = berry.address;

  // Verify
  console.log(`[${contractName}]: Start of Verification...`);

  await delay(90000);

  if (network.name === "bsc_mainnet") {
    url = "https://bscscan.com/address/" + berry.address + "#code";
  } else if (network.name === "bsc_testnet") {
    url = "https://testnet.bscscan.com/address/" + berry.address + "#code";
  }

  OUTPUT_DEPLOY[network.name][contractName].verification = url;

  try {
    await hre.run("verify:verify", {
      address: berry.address,
      constructorArguments: [
        PANCAKE_ROUTER_ADDRESS,
        gem.address,
        ACC_ADDRESS,
        ACC_ADDRESS,
      ],
    });
  } catch (error) {
    console.error(error);
  }
  console.log(`[${contractName}]: Verification Finished!`);

  // ====================================================

  // Contract #3: Tree

  contractName = "Tree";
  console.log(`[${contractName}]: Start of Deployment...`);
  let treeFactory = await ethers.getContractFactory("PocMon");
  const tree = await treeFactory.deploy(
    PANCAKE_ROUTER_ADDRESS,
    gem.address,
    ACC_ADDRESS,
    ACC_ADDRESS
  );
  await tree.deployed();
  console.log(`[${contractName}]: Deployment Finished!`);
  OUTPUT_DEPLOY[network.name][contractName].address = tree.address;

  // Verify
  console.log(`[${contractName}]: Start of Verification...`);

  await delay(90000);

  if (network.name === "bsc_mainnet") {
    url = "https://bscscan.com/address/" + tree.address + "#code";
  } else if (network.name === "bsc_testnet") {
    url = "https://testnet.bscscan.com/address/" + tree.address + "#code";
  }

  OUTPUT_DEPLOY[network.name][contractName].verification = url;

  try {
    await hre.run("verify:verify", {
      address: tree.address,
      constructorArguments: [
        PANCAKE_ROUTER_ADDRESS,
        gem.address,
        ACC_ADDRESS,
        ACC_ADDRESS,
      ],
    });
  } catch (error) {
    console.error(error);
  }
  console.log(`[${contractName}]: Verification Finished!`);

  // ====================================================

  // Contract #4: Gold

  contractName = "Gold";
  console.log(`[${contractName}]: Start of Deployment...`);
  let goldFactory = await ethers.getContractFactory("PocMon");
  const gold = await goldFactory.deploy(
    PANCAKE_ROUTER_ADDRESS,
    gem.address,
    ACC_ADDRESS,
    ACC_ADDRESS
  );
  await gold.deployed();
  console.log(`[${contractName}]: Deployment Finished!`);
  OUTPUT_DEPLOY[network.name][contractName].address = gold.address;

  // Verify
  console.log(`[${contractName}]: Start of Verification...`);

  await delay(90000);

  if (network.name === "bsc_mainnet") {
    url = "https://bscscan.com/address/" + gold.address + "#code";
  } else if (network.name === "bsc_testnet") {
    url = "https://testnet.bscscan.com/address/" + gold.address + "#code";
  }

  OUTPUT_DEPLOY[network.name][contractName].verification = url;

  try {
    await hre.run("verify:verify", {
      address: gold.address,
      constructorArguments: [
        PANCAKE_ROUTER_ADDRESS,
        gem.address,
        ACC_ADDRESS,
        ACC_ADDRESS,
      ],
    });
  } catch (error) {
    console.error(error);
  }
  console.log(`[${contractName}]: Verification Finished!`);

  // ====================================================

  // Contract #5: Blacklist

  contractName = "BlackList";
  console.log(`[${contractName}]: Start of Deployment...`);
  let blackListFactory = await ethers.getContractFactory(contractName);
  const blacklist = await blackListFactory.deploy();
  await blacklist.deployed();
  console.log(`[${contractName}]: Deployment Finished!`);
  OUTPUT_DEPLOY[network.name][contractName].address = blacklist.address;

  // Verify
  console.log(`[${contractName}]: Start of Verification...`);

  await delay(90000);

  if (network.name === "bsc_mainnet") {
    url = "https://bscscan.com/address/" + blacklist.address + "#code";
  } else if (network.name === "bsc_testnet") {
    url = "https://testnet.bscscan.com/address/" + blacklist.address + "#code";
  }

  OUTPUT_DEPLOY[network.name][contractName].verification = url;

  try {
    await hre.run("verify:verify", {
      address: blacklist.address,
      constructorArguments: [],
    });
  } catch (error) {
    console.error(error);
  }
  console.log(`[${contractName}]: Verification Finished!`);

  // ====================================================

  // Contract #6: Tools

  // Deploy proxy and implementation
  contractName = "Tools";
  console.log(`[${contractName}]: Start of Deployment...`);
  let toolsFactory = await ethers.getContractFactory(contractName);
  const tools = await upgrades.deployProxy(toolsFactory, [
    blacklist.address,
    berry.address,
    tree.address,
    gold.address,
    BASE_URI,
  ]);
  await tools.deployed();
  console.log(`[${contractName}]: Deployment Finished!`);
  OUTPUT_DEPLOY[network.name][contractName].proxyAddress = tools.address;

  await delay(90000);

  // Get implementation address
  let toolsImplAddress = await upgrades.erc1967.getImplementationAddress(
    tools.address
  );
  OUTPUT_DEPLOY[network.name][contractName].implementationAddress =
    toolsImplAddress;

  // Verify proxy
  console.log(`[${contractName}][Proxy]: Start of Verification...`);
  if (network.name === "bsc_mainnet") {
    url = "https://bscscan.com/address/" + tools.address + "#code";
  } else if (network.name === "bsc_testnet") {
    url = "https://testnet.bscscan.com/address/" + tools.address + "#code";
  }
  OUTPUT_DEPLOY[network.name][contractName].proxyVerification = url;

  try {
    await hre.run("verify:verify", {
      address: tools.address,
    });
  } catch (error) {}
  console.log(`[${contractName}][Proxy]: Verification Finished!`);

  // ====================================================

  // Contract #7: Artifacts

  // Deploy proxy and implementation
  contractName = "Artifacts";
  console.log(`[${contractName}]: Start of Deployment...`);
  let artifactsFactory = await ethers.getContractFactory(contractName);
  const artifacts = await upgrades.deployProxy(artifactsFactory, [
    tools.address,
    BASE_URI,
    blacklist.address,
  ]);
  await artifacts.deployed();
  console.log(`[${contractName}]: Deployment Finished!`);
  OUTPUT_DEPLOY[network.name][contractName].proxyAddress = artifacts.address;

  await delay(90000);

  // Get implementation address
  let artifactsImplAddress = await upgrades.erc1967.getImplementationAddress(
    artifacts.address
  );
  OUTPUT_DEPLOY[network.name][contractName].implementationAddress =
    artifactsImplAddress;

  // Verify proxy
  console.log(`[${contractName}][Proxy]: Start of Verification...`);
  if (network.name === "bsc_mainnet") {
    url = "https://bscscan.com/address/" + artifacts.address + "#code";
  } else if (network.name === "bsc_testnet") {
    url = "https://testnet.bscscan.com/address/" + artifacts.address + "#code";
  }
  OUTPUT_DEPLOY[network.name][contractName].proxyVerification = url;

  try {
    await hre.run("verify:verify", {
      address: artifacts.address,
    });
  } catch (error) {}
  console.log(`[${contractName}][Proxy]: Verification Finished!`);

  // ====================================================

  // Contract #8: Mining

  // Deploy proxy and implementation
  contractName = "Mining";
  console.log(`[${contractName}]: Start of Deployment...`);
  let miningFactory = await ethers.getContractFactory(contractName);
  const mining = await upgrades.deployProxy(miningFactory, [
    blacklist.address,
    tools.address,
  ]);
  await mining.deployed();
  console.log(`[${contractName}]: Deployment Finished!`);
  OUTPUT_DEPLOY[network.name][contractName].proxyAddress = mining.address;

  await delay(90000);

  // Get implementation address
  let miningImplAddress = await upgrades.erc1967.getImplementationAddress(
    mining.address
  );
  OUTPUT_DEPLOY[network.name][contractName].implementationAddress =
    miningImplAddress;

  // Verify proxy
  console.log(`[${contractName}][Proxy]: Start of Verification...`);
  if (network.name === "bsc_mainnet") {
    url = "https://bscscan.com/address/" + mining.address + "#code";
  } else if (network.name === "bsc_testnet") {
    url = "https://testnet.bscscan.com/address/" + mining.address + "#code";
  }
  OUTPUT_DEPLOY[network.name][contractName].proxyVerification = url;

  try {
    await hre.run("verify:verify", {
      address: mining.address,
    });
  } catch (error) {}
  console.log(`[${contractName}][Proxy]: Verification Finished!`);

  // ====================================================

  console.log(`[Tools][Proxy]: Adding 6 initial artifacts...`);

  await tools.setArtifactsAddress(artifacts.address);
  await tools.setMiningAddress(mining.address);

  await delay(90000);

  // Add first 6 artifacts
  for (let i = 0; i < artifactURIs.length; i++) {
    await artifacts.addNewArtifact(artifactURIs[i]);
    console.log("Added artifact with URL: ", artifactURIs[i]);
  }

  console.log(`[Tools][Proxy]: Artifacts added!`);

  // ====================================================

  fs.writeFileSync(
    path.resolve(__dirname, fileName),
    JSON.stringify(OUTPUT_DEPLOY, null, "  ")
  );

  console.log(
    `\n***Deployment and verification are completed!***\n***See Results in "${
      __dirname + fileName
    }" file***`
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
