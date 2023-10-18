const { ethers, network, upgrades } = require("hardhat");
const { expect } = require("chai");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const {
  loadFixture,
  time,
} = require("@nomicfoundation/hardhat-network-helpers");

const zeroAddress = ethers.constants.AddressZero;
const { parseEther, parseUnits } = ethers.utils;

let PANCAKE_ROUTER_ADDRESS;
if (network.name == "hardhat") {
  PANCAKE_ROUTER_ADDRESS = process.env.PANCAKE_ROUTER_ADDRESS_MAINNET;
  console.log("\n\n[NOTICE!] Make sure you run tests in forked BSC Mainnet!");
} else {
  console.log("Can only run tests on local fork of BSC Mainnet");
  process.exit(1);
}

const BASE_URI = process.env.BASE_URI;

let artifactURIs = [
  "QmdC3otayo1QaoEA9Jf2Czvz2hHuX2w8umM1Kji7wZgNyH",
  "QmQrKjnhRo8rGrqDC6JjMfgAme3Poan96v1ri5EY28TN2P",
  "QmXKsHDa9TNkBZ8DEjxJTBcQFbSCvsv1XZTJz8YvgfjbWR",
  "QmVn9bhbdH68pgE5rBppAa4FcgoAvoVyXLVcH64wQ82Htm",
  "QmX54LcHuaVxd4mjPLUmXaPbJaTCgymrCuzHUBXD6JSSfe",
  "QmQtGq6Hxp9AAPes85ciJfjU1gCktHS319BAq5umoNEdEL",
];

let contractName;

describe("Resources (Berry, Tree, Gold) contracts", () => {
  // Deploy all contracts before each test suite
  async function deploys() {
    [ownerAcc, clientAcc1, clientAcc2] = await ethers.getSigners();

    // Contract #1: Gem

    contractName = "Gem";
    let gemFactory = await ethers.getContractFactory(contractName);
    const gem = await gemFactory.connect(ownerAcc).deploy(1);
    await gem.deployed();

    // Contract #2: Berry

    contractName = "Berry";
    let berryFactory = await ethers.getContractFactory("PocMon");
    const berry = await berryFactory
      .connect(ownerAcc)
      .deploy(
        contractName,
        PANCAKE_ROUTER_ADDRESS,
        gem.address,
        ownerAcc.address,
        ownerAcc.address
      );
    await berry.deployed();

    // Contract #3: Tree

    contractName = "Tree";
    let treeFactory = await ethers.getContractFactory("PocMon");
    const tree = await treeFactory
      .connect(ownerAcc)
      .deploy(
        contractName,
        PANCAKE_ROUTER_ADDRESS,
        gem.address,
        ownerAcc.address,
        ownerAcc.address
      );
    await tree.deployed();

    // Contract #4: Gold

    contractName = "Gold";
    let goldFactory = await ethers.getContractFactory("PocMon");
    const gold = await goldFactory
      .connect(ownerAcc)
      .deploy(
        contractName,
        PANCAKE_ROUTER_ADDRESS,
        gem.address,
        ownerAcc.address,
        ownerAcc.address
      );
    await gold.deployed();

    // Contract #5: Blacklist

    contractName = "BlackList";
    let blackListFactory = await ethers.getContractFactory(contractName);
    const blacklist = await blackListFactory.connect(ownerAcc).deploy();
    await blacklist.deployed();

    // Contract #6: Tools

    // Deploy proxy and implementation
    contractName = "Tools";
    let toolsFactory = await ethers.getContractFactory(contractName);
    await toolsFactory.connect(ownerAcc);
    const tools = await upgrades.deployProxy(toolsFactory, [
      blacklist.address,
      berry.address,
      tree.address,
      gold.address,
      BASE_URI,
    ]);
    await tools.deployed();

    // Contract #7: Artifacts

    contractName = "Artifacts";
    let artifactsFactory = await ethers.getContractFactory(contractName);
    await artifactsFactory.connect(ownerAcc);
    const artifacts = await upgrades.deployProxy(artifactsFactory, [
      tools.address,
      BASE_URI,
      blacklist.address,
    ]);
    await artifacts.deployed();

    // Contract #8: Mining

    contractName = "Mining";
    let miningFactory = await ethers.getContractFactory(contractName);
    await miningFactory.connect(ownerAcc);
    const mining = await upgrades.deployProxy(miningFactory, [
      blacklist.address,
      tools.address,
    ]);
    await mining.deployed();

    // ====================================================

    // Set addresses
    await tools.setArtifactsAddress(artifacts.address);
    await tools.setMiningAddress(mining.address);

    // Add 6 initial artifacts
    for (let i = 0; i < artifactURIs.length; i++) {
      await artifacts.addNewArtifact(artifactURIs[i]);
    }

    // Transfer 99% of total supply of each token to Mining contract
    let totalSupply = await berry.totalSupply();
    let transferAmount = totalSupply.mul(9900).div(10000);
    await berry.connect(ownerAcc).transfer(mining.address, transferAmount);
    await tree.connect(ownerAcc).transfer(mining.address, transferAmount);
    await gold.connect(ownerAcc).transfer(mining.address, transferAmount);

    return {
      gem,
      berry,
      tree,
      gold,
      blacklist,
      tools,
      artifacts,
      mining,
    };
  }

  describe("Getters", () => {
    describe("Get name", () => {
      it("Each token should have a correct name", async () => {
        let { gem, berry, tree, gold, blacklist, tools, artifacts, mining } =
          await loadFixture(deploys);

        expect(await berry.name()).to.equal("Berry");
        expect(await tree.name()).to.equal("Tree");
        expect(await gold.name()).to.equal("Gold");
      });
    });
  });
});
