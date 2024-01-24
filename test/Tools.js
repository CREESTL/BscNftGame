const { ethers, network, upgrades } = require("hardhat");
const { expect } = require("chai");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const {
  loadFixture,
  time,
} = require("@nomicfoundation/hardhat-network-helpers");

const zeroAddress = ethers.constants.AddressZero;
const { parseEther, parseUnits } = ethers.utils;
const { hashAndSignMining, getRewardsHash } = require("../scripts/hash.js");

const ACC_PRIVATE_KEY = process.env.ACC_PRIVATE_KEY;
const unconnectedSigner = new ethers.Wallet(ACC_PRIVATE_KEY);
const signer = unconnectedSigner.connect(ethers.provider);

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

describe("Tools contract", () => {
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
    let berryFactory = await ethers.getContractFactory("Berry");
    const berry = await berryFactory
      .connect(ownerAcc)
      .deploy(
        contractName,
        PANCAKE_ROUTER_ADDRESS,
        gem.address,
        ownerAcc.address,
        ownerAcc.address,
      );
    await berry.deployed();

    // Contract #3: Tree

    contractName = "Tree";
    let treeFactory = await ethers.getContractFactory("Tree");
    const tree = await treeFactory
      .connect(ownerAcc)
      .deploy(
        contractName,
        PANCAKE_ROUTER_ADDRESS,
        gem.address,
        ownerAcc.address,
        ownerAcc.address,
      );
    await tree.deployed();

    // Contract #4: Gold

    contractName = "Gold";
    let goldFactory = await ethers.getContractFactory("Gold");
    const gold = await goldFactory
      .connect(ownerAcc)
      .deploy(
        contractName,
        PANCAKE_ROUTER_ADDRESS,
        gem.address,
        ownerAcc.address,
        ownerAcc.address,
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
    describe("Get strength", () => {
      it("Should get current strength of the tool", async () => {
        let { gem, berry, tree, gold, blacklist, tools, artifacts, mining } =
          await loadFixture(deploys);

        let maxStrength = 85;
        let miningDuration = 100;
        let energyCost = 10;
        let strengthCost = 30;
        let resourcesAmount = 10000000000;
        let artifactsAmounts = [0, 0, 0, 0, 0, 0];
        let newURI = "testing";

        await tools.addTool(
          maxStrength,
          miningDuration,
          energyCost,
          strengthCost,
          resourcesAmount,
          artifactsAmounts,
          newURI,
        );

        // Transfer some resources to client
        await gold
          .connect(ownerAcc)
          .transfer(clientAcc1.address, await gold.balanceOf(ownerAcc.address));
        await tree
          .connect(ownerAcc)
          .transfer(clientAcc1.address, await tree.balanceOf(ownerAcc.address));

        // Approve transfer from client to tools
        await gold
          .connect(clientAcc1)
          .approve(tools.address, await gold.balanceOf(clientAcc1.address));
        await tree
          .connect(clientAcc1)
          .approve(tools.address, await tree.balanceOf(clientAcc1.address));

        // Mint artifacts to client
        let artifactAmount = 15_000_000;
        for (let artifactType = 1; artifactType <= 6; artifactType++) {
          await artifacts.mint(
            artifactType,
            clientAcc1.address,
            artifactAmount,
          );
        }
        await artifacts
          .connect(clientAcc1)
          .setApprovalForAll(tools.address, true);

        // Tool has not been crafted yet. Should have 0 strength.
        expect(await tools.ownsTool(clientAcc1.address, 1)).to.equal(false);
        expect(await tools.getStrength(clientAcc1.address, 1)).to.equal(0);
        let [toolType, strength] = await tools.getToolProperties(
          clientAcc1.address,
          1,
        );
        expect(strength).to.equal(0);

        await tools.connect(clientAcc1).craft(1);

        // Now tool's strength should be equal to max strength
        expect(await tools.ownsTool(clientAcc1.address, 1)).to.equal(true);
        expect(await tools.getStrength(clientAcc1.address, 1)).to.equal(
          maxStrength,
        );
        [toolType, strength] = await tools.getToolProperties(
          clientAcc1.address,
          1,
        );
        expect(strength).to.equal(maxStrength);
      });
    });
  });

  describe("Main functions", () => {
    describe("Craft", () => {
      describe("From Owner", () => {
        it("Should craft toolType 1", async () => {
          let { gem, berry, tree, gold, blacklist, tools, artifacts, mining } =
            await loadFixture(deploys);

          let maxStrength = 85;
          let miningDuration = 100;
          let energyCost = 10;
          let strengthCost = 30;
          let resourcesAmount = 10000000000;
          let artifactsAmounts = [0, 0, 0, 0, 0, 0];
          let newURI = "testing";

          await tools.addTool(
            maxStrength,
            miningDuration,
            energyCost,
            strengthCost,
            resourcesAmount,
            artifactsAmounts,
            newURI,
          );

          await gold.approve(
            tools.address,
            await gold.balanceOf(ownerAcc.address),
          );
          await tree.approve(
            tools.address,
            await tree.balanceOf(ownerAcc.address),
          );
          let artifactAmount = 15_000_000;
          for (let artifactType = 1; artifactType <= 6; artifactType++) {
            await artifacts.mint(
              artifactType,
              ownerAcc.address,
              artifactAmount,
            );
          }
          await artifacts.setApprovalForAll(tools.address, true);

          await tools.craft(1);
        });

        it("Should craft toolType 2", async () => {
          let { gem, berry, tree, gold, blacklist, tools, artifacts, mining } =
            await loadFixture(deploys);

          let maxStrength = 85;
          let miningDuration = 100;
          let energyCost = 10;
          let strengthCost = 30;
          let resourcesAmount = 100;
          let artifactsAmounts = [0, 0, 0, 0, 0, 0];
          let newURI = "testing";

          await tools.addTool(
            maxStrength,
            miningDuration,
            energyCost,
            strengthCost,
            resourcesAmount,
            artifactsAmounts,
            newURI,
          );

          await gold.approve(
            tools.address,
            await gold.balanceOf(ownerAcc.address),
          );
          await tree.approve(
            tools.address,
            await tree.balanceOf(ownerAcc.address),
          );
          let artifactAmount = 15_000_000;
          for (let artifactType = 1; artifactType <= 6; artifactType++) {
            await artifacts.mint(
              artifactType,
              ownerAcc.address,
              artifactAmount,
            );
          }
          await artifacts.setApprovalForAll(tools.address, true);

          await tools.craft(1);
        });

        it("Should craft toolType 3", async () => {
          let { gem, berry, tree, gold, blacklist, tools, artifacts, mining } =
            await loadFixture(deploys);

          let maxStrength = 85;
          let miningDuration = 8000;
          let energyCost = 10;
          let strengthCost = 30;
          let resourcesAmount = 100;
          let artifactsAmounts = [0, 0, 0, 0, 0, 0];
          let newURI = "testing";

          await tools.addTool(
            maxStrength,
            miningDuration,
            energyCost,
            strengthCost,
            resourcesAmount,
            artifactsAmounts,
            newURI,
          );

          await gold.approve(
            tools.address,
            await gold.balanceOf(ownerAcc.address),
          );
          await tree.approve(
            tools.address,
            await tree.balanceOf(ownerAcc.address),
          );
          let artifactAmount = 15_000_000;
          for (let artifactType = 1; artifactType <= 6; artifactType++) {
            await artifacts.mint(
              artifactType,
              ownerAcc.address,
              artifactAmount,
            );
          }
          await artifacts.setApprovalForAll(tools.address, true);

          await tools.craft(1);
        });

        it("Should craft toolType 4", async () => {
          let { gem, berry, tree, gold, blacklist, tools, artifacts, mining } =
            await loadFixture(deploys);

          let maxStrength = 500;
          let miningDuration = 120;
          let energyCost = 1;
          let strengthCost = 1;
          // Low values so that owner has enough resources to craft
          let resourcesAmount = 5;
          let artifactsAmounts = [4, 4, 4, 4, 4, 4];
          let newURI = "testing";

          // Add a new tool with toolType = 1
          await tools.addTool(
            maxStrength,
            miningDuration,
            energyCost,
            strengthCost,
            resourcesAmount,
            artifactsAmounts,
            newURI,
          );

          // Approve transfer of resources to craft
          await gold.approve(
            tools.address,
            await gold.balanceOf(ownerAcc.address),
          );
          await tree.approve(
            tools.address,
            await tree.balanceOf(ownerAcc.address),
          );
          // Mint artifacts
          let artifactAmount = 15_000_000;
          for (let artifactType = 1; artifactType <= 6; artifactType++) {
            await artifacts.mint(
              artifactType,
              ownerAcc.address,
              artifactAmount,
            );
          }
          // Approve transfer of artifacts to craft
          await artifacts.setApprovalForAll(tools.address, true);

          // Craft new tool
          await tools.craft(1);
        });
      });
      describe("From Client", () => {
        it("Should craft toolType 1", async () => {
          let { gem, berry, tree, gold, blacklist, tools, artifacts, mining } =
            await loadFixture(deploys);

          let maxStrength = 85;
          let miningDuration = 100;
          let energyCost = 10;
          let strengthCost = 30;
          let resourcesAmount = 10000000000;
          let artifactsAmounts = [0, 0, 0, 0, 0, 0];
          let newURI = "testing";

          await tools.addTool(
            maxStrength,
            miningDuration,
            energyCost,
            strengthCost,
            resourcesAmount,
            artifactsAmounts,
            newURI,
          );

          // Transfer some resources to client
          await gold
            .connect(ownerAcc)
            .transfer(
              clientAcc1.address,
              await gold.balanceOf(ownerAcc.address),
            );
          await tree
            .connect(ownerAcc)
            .transfer(
              clientAcc1.address,
              await tree.balanceOf(ownerAcc.address),
            );

          // Approve transfer from client to tools
          await gold
            .connect(clientAcc1)
            .approve(tools.address, await gold.balanceOf(clientAcc1.address));
          await tree
            .connect(clientAcc1)
            .approve(tools.address, await tree.balanceOf(clientAcc1.address));

          // Mint artifacts to client
          let artifactAmount = 15_000_000;
          for (let artifactType = 1; artifactType <= 6; artifactType++) {
            await artifacts.mint(
              artifactType,
              clientAcc1.address,
              artifactAmount,
            );
          }
          await artifacts
            .connect(clientAcc1)
            .setApprovalForAll(tools.address, true);

          await tools.connect(clientAcc1).craft(1);
        });
        it("Should craft toolType 2", async () => {
          let { gem, berry, tree, gold, blacklist, tools, artifacts, mining } =
            await loadFixture(deploys);

          let maxStrength = 85;
          let miningDuration = 100;
          let energyCost = 10;
          let strengthCost = 30;
          let resourcesAmount = 100;
          let artifactsAmounts = [0, 0, 0, 0, 0, 0];
          let newURI = "testing";

          await tools.addTool(
            maxStrength,
            miningDuration,
            energyCost,
            strengthCost,
            resourcesAmount,
            artifactsAmounts,
            newURI,
          );

          // Transfer some resources to client
          await gold
            .connect(ownerAcc)
            .transfer(
              clientAcc1.address,
              await gold.balanceOf(ownerAcc.address),
            );
          await tree
            .connect(ownerAcc)
            .transfer(
              clientAcc1.address,
              await tree.balanceOf(ownerAcc.address),
            );

          // Approve transfer from client to tools
          await gold
            .connect(clientAcc1)
            .approve(tools.address, await gold.balanceOf(clientAcc1.address));
          await tree
            .connect(clientAcc1)
            .approve(tools.address, await tree.balanceOf(clientAcc1.address));

          // Mint artifacts to client
          let artifactAmount = 15_000_000;
          for (let artifactType = 1; artifactType <= 6; artifactType++) {
            await artifacts.mint(
              artifactType,
              clientAcc1.address,
              artifactAmount,
            );
          }
          await artifacts
            .connect(clientAcc1)
            .setApprovalForAll(tools.address, true);

          await tools.connect(clientAcc1).craft(1);
        });
        it("Should craft toolType 3", async () => {
          let { gem, berry, tree, gold, blacklist, tools, artifacts, mining } =
            await loadFixture(deploys);

          let maxStrength = 85;
          let miningDuration = 8000;
          let energyCost = 10;
          let strengthCost = 30;
          let resourcesAmount = 100;
          let artifactsAmounts = [0, 0, 0, 0, 0, 0];
          let newURI = "testing";

          await tools.addTool(
            maxStrength,
            miningDuration,
            energyCost,
            strengthCost,
            resourcesAmount,
            artifactsAmounts,
            newURI,
          );

          // Transfer some resources to client
          await gold
            .connect(ownerAcc)
            .transfer(
              clientAcc1.address,
              await gold.balanceOf(ownerAcc.address),
            );
          await tree
            .connect(ownerAcc)
            .transfer(
              clientAcc1.address,
              await tree.balanceOf(ownerAcc.address),
            );

          // Approve transfer from client to tools
          await gold
            .connect(clientAcc1)
            .approve(tools.address, await gold.balanceOf(clientAcc1.address));
          await tree
            .connect(clientAcc1)
            .approve(tools.address, await tree.balanceOf(clientAcc1.address));

          // Mint artifacts to client
          let artifactAmount = 15_000_000;
          for (let artifactType = 1; artifactType <= 6; artifactType++) {
            await artifacts.mint(
              artifactType,
              clientAcc1.address,
              artifactAmount,
            );
          }
          await artifacts
            .connect(clientAcc1)
            .setApprovalForAll(tools.address, true);

          await tools.connect(clientAcc1).craft(1);
        });

        it("Should craft toolType 4", async () => {
          let { gem, berry, tree, gold, blacklist, tools, artifacts, mining } =
            await loadFixture(deploys);

          let maxStrength = 500;
          let miningDuration = 120;
          let energyCost = 1;
          let strengthCost = 1;
          let resourcesAmount = 5;
          let artifactsAmounts = [4, 4, 4, 4, 4, 4];
          let newURI = "testing";

          await tools.addTool(
            maxStrength,
            miningDuration,
            energyCost,
            strengthCost,
            resourcesAmount,
            artifactsAmounts,
            newURI,
          );

          // Transfer some resources to client
          await gold
            .connect(ownerAcc)
            .transfer(
              clientAcc1.address,
              await gold.balanceOf(ownerAcc.address),
            );
          await tree
            .connect(ownerAcc)
            .transfer(
              clientAcc1.address,
              await tree.balanceOf(ownerAcc.address),
            );

          // Approve transfer from client to tools
          await gold
            .connect(clientAcc1)
            .approve(tools.address, await gold.balanceOf(clientAcc1.address));
          await tree
            .connect(clientAcc1)
            .approve(tools.address, await tree.balanceOf(clientAcc1.address));

          // Mint artifacts to client
          let artifactAmount = 15_000_000;
          for (let artifactType = 1; artifactType <= 6; artifactType++) {
            await artifacts.mint(
              artifactType,
              clientAcc1.address,
              artifactAmount,
            );
          }
          await artifacts
            .connect(clientAcc1)
            .setApprovalForAll(tools.address, true);

          await tools.connect(clientAcc1).craft(1);
        });
      });
      describe("Fails", () => {
        it("Should fail to craft if user has not enough resources", async () => {
          let { gem, berry, tree, gold, blacklist, tools, artifacts, mining } =
            await loadFixture(deploys);

          let maxStrength = 85;
          let miningDuration = 100;
          let energyCost = 10;
          let strengthCost = 30;
          let resourcesAmount = 10000000000;
          let artifactsAmounts = [0, 0, 0, 0, 0, 0];
          let newURI = "testing";

          await tools.addTool(
            maxStrength,
            miningDuration,
            energyCost,
            strengthCost,
            resourcesAmount,
            artifactsAmounts,
            newURI,
          );

          // Transfer some resources to client
          await gold.connect(ownerAcc).transfer(
            clientAcc1.address,
            // Give client not enough resources for craft
            100,
          );
          await tree.connect(ownerAcc).transfer(
            clientAcc1.address,
            // Give client not enough resources for craft
            100,
          );

          // Approve transfer from client to tools
          await gold
            .connect(clientAcc1)
            .approve(tools.address, await gold.balanceOf(clientAcc1.address));
          await tree
            .connect(clientAcc1)
            .approve(tools.address, await tree.balanceOf(clientAcc1.address));

          // Mint artifacts to client
          let artifactAmount = 15_000_000;
          for (let artifactType = 1; artifactType <= 6; artifactType++) {
            await artifacts.mint(
              artifactType,
              clientAcc1.address,
              artifactAmount,
            );
          }
          await artifacts
            .connect(clientAcc1)
            .setApprovalForAll(tools.address, true);

          await expect(tools.connect(clientAcc1).craft(1)).to.be.revertedWith(
            "PocMon: transfer amount exceeds balance",
          );
        });
      });
    });
  });
  describe("Transfer", () => {
    it("Should transfer tool with not max strength to mining", async () => {
      let { gem, berry, tree, gold, blacklist, tools, artifacts, mining } =
        await loadFixture(deploys);

      let maxStrength = 85;
      let miningDuration = 100;
      let energyCost = 10;
      let strengthCost = 30;
      let resourcesAmount = 10000000000;
      let artifactsAmounts = [0, 0, 0, 0, 0, 0];
      let newURI = "testing";

      await tools.addTool(
        maxStrength,
        miningDuration,
        energyCost,
        strengthCost,
        resourcesAmount,
        artifactsAmounts,
        newURI,
      );

      await tools.mint(clientAcc1.address, 1, 1);
      expect(await tools.ownsTool(clientAcc1.address, 1)).to.be.true;

      // increase maxStrength for tool with type 1
      await tools.setToolProperties(
        1,
        maxStrength + 5,
        miningDuration,
        energyCost,
        strengthCost,
      );

      // should transfer to mining
      await expect(
        tools
          .connect(clientAcc1)
          .safeTransferFrom(
            clientAcc1.address,
            mining.address,
            1,
            1,
            ethers.utils.toUtf8Bytes(""),
          ),
      ).to.be.not.reverted;
    });

    it("Should transfer tool with not max strength from mining", async () => {
      let { gem, berry, tree, gold, blacklist, tools, artifacts, mining } =
        await loadFixture(deploys);

      let maxStrength = 85;
      let miningDuration = 100;
      let energyCost = 10;
      let strengthCost = 30;
      let resourcesAmount = 10000000000;
      let artifactsAmounts = [0, 0, 0, 0, 0, 0];
      let newURI = "testing";

      await tools.addTool(
        maxStrength,
        miningDuration,
        energyCost,
        strengthCost,
        resourcesAmount,
        artifactsAmounts,
        newURI,
      );

      await tools.mint(signer.address, 1, 1);
      expect(await tools.ownsTool(signer.address, 1)).to.be.true;

      // increase maxStrength for tool with type 1
      await tools.setToolProperties(
        1,
        maxStrength + 5,
        miningDuration,
        energyCost,
        strengthCost,
      );

      // Proceed transfer to mining

      // Send funds from owner to signer for gas
      let tx = {
        from: ownerAcc.address,
        to: signer.address,
        value: ethers.utils.parseEther("2"),
      };
      await ownerAcc.sendTransaction(tx);
      await mining.connect(ownerAcc).transferOwnership(signer.address);

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
      let encodedRewards = getRewardsHash(resourceWinAmount, artifactWinAmount);

      let signature = hashAndSignMining(
        ACC_PRIVATE_KEY,
        mining.address,
        1,
        signer.address,
        resourceWinAmount,
        artifactWinAmount,
        nonce,
      );

      // Approve transfer of resources and tools
      await berry
        .connect(ownerAcc)
        .transfer(signer.address, await berry.balanceOf(ownerAcc.address));
      await berry
        .connect(signer)
        .approve(mining.address, await berry.balanceOf(signer.address));
      await tools.connect(signer).setApprovalForAll(mining.address, true);

      // Now start mining
      await expect(
        mining
          .connect(signer)
          .startMining(1, signer.address, encodedRewards, signature, nonce),
      ).to.emit(mining, "MiningStarted");

      // wait miningDuration time
      await time.increase(miningDuration);

      // end mining(transfer tool from mining)
      await expect(mining.connect(signer).endMining(1)).to.be.not.reverted;
    });

    it("Should fail transfer tool with not max strength to user", async () => {
      let { gem, berry, tree, gold, blacklist, tools, artifacts, mining } =
        await loadFixture(deploys);

      let maxStrength = 85;
      let miningDuration = 100;
      let energyCost = 10;
      let strengthCost = 30;
      let resourcesAmount = 10000000000;
      let artifactsAmounts = [0, 0, 0, 0, 0, 0];
      let newURI = "testing";

      await tools.addTool(
        maxStrength,
        miningDuration,
        energyCost,
        strengthCost,
        resourcesAmount,
        artifactsAmounts,
        newURI,
      );

      await tools.mint(clientAcc1.address, 1, 2);
      expect(await tools.ownsTool(clientAcc1.address, 1)).to.be.true;
      expect(await tools.ownsTool(clientAcc1.address, 2)).to.be.true;
      expect(await tools.getStrength(clientAcc1.address, 1)).to.be.equal(
        maxStrength,
      );
      expect(await tools.getStrength(clientAcc1.address, 2)).to.be.equal(
        maxStrength,
      );

      // should transfer token with max strength
      await tools
        .connect(clientAcc1)
        .safeTransferFrom(
          clientAcc1.address,
          clientAcc2.address,
          1,
          1,
          ethers.utils.toUtf8Bytes(""),
        );
      expect(await tools.ownsTool(clientAcc2.address, 1)).to.be.true;
      expect(await tools.ownsTool(clientAcc1.address, 1)).to.be.false;

      // increase maxStrength for tool with type 1
      await tools.setToolProperties(
        1,
        maxStrength + 5,
        miningDuration,
        energyCost,
        strengthCost,
      );

      // should fail transfer to user
      await expect(
        tools
          .connect(clientAcc1)
          .safeTransferFrom(
            clientAcc1.address,
            clientAcc2.address,
            2,
            1,
            ethers.utils.toUtf8Bytes(""),
          ),
      ).to.be.revertedWith("Tools: transfer of used tool not to the mining");
    });
  });
});
