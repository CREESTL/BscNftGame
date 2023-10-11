const { ethers, network, upgrades } = require("hardhat");
const { expect } = require("chai");
const {
  loadFixture,
  time,
} = require("@nomicfoundation/hardhat-network-helpers");
const { hashAndSignMining, getRewardsHash } = require("../scripts/hash.js");
let PANCAKE_ROUTER_ADDRESS;
if (network.name == "hardhat") {
  PANCAKE_ROUTER_ADDRESS = process.env.PANCAKE_ROUTER_ADDRESS_MAINNET;
} else {
  console.log("Can only run tests on local fork of BSC Mainnet");
  process.exit(1);
}
const BASE_URI = process.env.BASE_URI;

// Create account to sign messages
const ACC_PRIVATE_KEY = process.env.ACC_PRIVATE_KEY;
const unconnectedSigner = new ethers.Wallet(ACC_PRIVATE_KEY);
const signer = unconnectedSigner.connect(ethers.provider);

let artifactURIs = [
  "QmdC3otayo1QaoEA9Jf2Czvz2hHuX2w8umM1Kji7wZgNyH",
  "QmQrKjnhRo8rGrqDC6JjMfgAme3Poan96v1ri5EY28TN2P",
  "QmXKsHDa9TNkBZ8DEjxJTBcQFbSCvsv1XZTJz8YvgfjbWR",
  "QmVn9bhbdH68pgE5rBppAa4FcgoAvoVyXLVcH64wQ82Htm",
  "QmX54LcHuaVxd4mjPLUmXaPbJaTCgymrCuzHUBXD6JSSfe",
  "QmQtGq6Hxp9AAPes85ciJfjU1gCktHS319BAq5umoNEdEL",
];

let contractName;

describe("Mining contract", () => {
  // Deploy all contracts before each test suite
  async function deploys() {
    [ownerAcc, clientAcc1, clientAcc2] = await ethers.getSigners();

    // Send funds from owner to signer for gas
    let tx = {
      from: ownerAcc.address,
      to: signer.address,
      value: ethers.utils.parseEther("2"),
    };
    await ownerAcc.sendTransaction(tx);

    // Contract #1: Gem

    contractName = "Gem";
    let gemFactory = await ethers.getContractFactory(contractName);
    const gem = await gemFactory.connect(signer).deploy(1);
    await gem.deployed();

    // Contract #2: Berry

    contractName = "Berry";
    let berryFactory = await ethers.getContractFactory("PocMon");
    const berry = await berryFactory
      .connect(signer)
      .deploy(
        PANCAKE_ROUTER_ADDRESS,
        gem.address,
        signer.address,
        signer.address
      );
    await berry.deployed();

    // Contract #3: Tree

    contractName = "Tree";
    let treeFactory = await ethers.getContractFactory("PocMon");
    const tree = await treeFactory
      .connect(signer)
      .deploy(
        PANCAKE_ROUTER_ADDRESS,
        gem.address,
        signer.address,
        signer.address
      );
    await tree.deployed();

    // Contract #4: Gold

    contractName = "Gold";
    let goldFactory = await ethers.getContractFactory("PocMon");
    const gold = await goldFactory
      .connect(signer)
      .deploy(
        PANCAKE_ROUTER_ADDRESS,
        gem.address,
        signer.address,
        signer.address
      );
    await gold.deployed();

    // Contract #5: Blacklist

    contractName = "BlackList";
    let blackListFactory = await ethers.getContractFactory(contractName);
    const blacklist = await blackListFactory.connect(signer).deploy();
    await blacklist.deployed();

    // Contract #6: Tools

    // Deploy proxy and implementation
    contractName = "Tools";
    let toolsFactory = await ethers.getContractFactory(contractName);
    const tools = await upgrades.deployProxy(toolsFactory.connect(signer), [
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
    const artifacts = await upgrades.deployProxy(
      artifactsFactory.connect(signer),
      [tools.address, BASE_URI, blacklist.address]
    );
    await artifacts.deployed();

    // Contract #8: Mining

    contractName = "Mining";
    let miningFactory = await ethers.getContractFactory(contractName);
    const mining = await upgrades.deployProxy(miningFactory.connect(signer), [
      blacklist.address,
      tools.address,
    ]);
    await mining.deployed();

    // ====================================================

    // Set addresses
    await tools.connect(signer).setArtifactsAddress(artifacts.address);
    await tools.connect(signer).setMiningAddress(mining.address);

    // Add 6 initial artifacts
    for (let i = 0; i < artifactURIs.length; i++) {
      await artifacts.connect(signer).addNewArtifact(artifactURIs[i]);
    }

    // Transfer 99% of total supply of each token to Mining contract
    let totalSupply = await berry.totalSupply();
    let transferAmount = totalSupply.mul(9900).div(10000);
    await berry.connect(signer).transfer(mining.address, transferAmount);
    await tree.connect(signer).transfer(mining.address, transferAmount);
    await gold.connect(signer).transfer(mining.address, transferAmount);

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

  describe("Main functions", () => {
    describe("Start Mining", () => {
      it("Should start mining", async () => {
        let { gem, berry, tree, gold, blacklist, tools, artifacts, mining } =
          await loadFixture(deploys);

        // Craft a tool first
        // Random numbers
        let maxStrength = 700;
        let miningDuration = 100;
        let energyCost = 10;
        let strengthCost = 10;
        let resourcesAmount = 10000000000;
        let artifactsAmounts = [5, 10, 15, 20, 25, 30];
        let newURI = "testing";

        await tools
          .connect(signer)
          .addTool(
            maxStrength,
            miningDuration,
            energyCost,
            strengthCost,
            resourcesAmount,
            artifactsAmounts,
            newURI
          );

        await gold
          .connect(signer)
          .approve(tools.address, await gold.balanceOf(signer.address));
        await tree
          .connect(signer)
          .approve(tools.address, await tree.balanceOf(signer.address));
        let artifactAmount = 15_000_000; // Random number
        for (let artifactType = 1; artifactType <= 6; artifactType++) {
          await artifacts
            .connect(signer)
            .mint(artifactType, signer.address, artifactAmount);
        }
        await artifacts.connect(signer).setApprovalForAll(tools.address, true);
        await tools.connect(signer).craft(1);

        // Proceed to mining

        // Random nonce for mining
        let nonce = 777;
        // ID of the freshly crafted tool
        let toolId = 1;

        // Amount of resources to win after mining
        // Random numbers
        let resourceWinAmount = [1_000_000, 1_000_100, 1_000_200];
        // Amount of artifacts to win after mining
        // Random numbers
        let artifactWinAmount = [1, 2, 3];

        // Encode parameters to start mining
        let encodedRewards = getRewardsHash(
          resourceWinAmount,
          artifactWinAmount
        );

        let signature = hashAndSignMining(
          ACC_PRIVATE_KEY,
          mining.address,
          1,
          signer.address,
          resourceWinAmount,
          artifactWinAmount,
          nonce
        );

        // Approve transfer of resources and tools
        await berry
          .connect(signer)
          .approve(mining.address, await berry.balanceOf(signer.address));
        await tools.connect(signer).setApprovalForAll(mining.address, true);

        // Now start mining
        await expect(
          mining
            .connect(signer)
            .startMining(1, signer.address, encodedRewards, signature, nonce)
        ).to.emit(mining, "MiningStarted");
      });
    });
  });
});
