const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("Tools tests", async () => {
  let Tools;
  let Blacklist;
  let Berry;
  let Tree;
  let Gold;
  let Artifacts;
  let Mining;

  let tools;
  let blacklist;
  let berry;
  let tree;
  let gold;
  let artifacts;
  let mining;

  const BASE_URI = "ipfs://testdir/";

  beforeEach(async () => {
    Berry = await ethers.getContractFactory("Resource");
    Tree = await ethers.getContractFactory("Resource");
    Gold = await ethers.getContractFactory("Resource");
    Artifacts = await ethers.getContractFactory("Artifacts");
    Blacklist = await ethers.getContractFactory("BlackList");
    Tools = await ethers.getContractFactory("Tools");
    Mining = await ethers.getContractFactory("Mining");

    berry = await Berry.deploy();
    tree = await Tree.deploy();
    gold = await Gold.deploy();
    blacklist = await Blacklist.deploy();

    tools = await upgrades.deployProxy(Tools, [
      blacklist.address,
      berry.address,
      tree.address,
      gold.address,
      BASE_URI,
    ]);
    artifacts = await upgrades.deployProxy(Artifacts, [
      tools.address,
      BASE_URI,
      blacklist.address,
    ]);
    mining = await upgrades.deployProxy(Mining, [
      blacklist.address,
      tools.address,
    ]);

    await tools.setArtifactsAddress(artifacts.address);
    await tools.setURI(1, "1.json");
    //await tools.setRepairCost([0, 0, 5]);
    await tools.setMiningAddress(mining.address);

    // Add first 6 artifacts
    for (i = 0; i < 6; i++) {
      await artifacts.addNewArtifact();
    }

    [owner, acc1, acc2] = await ethers.getSigners();
  });

  describe("Mint functions", async () => {
    it("add tool with wrong strengh", async () => {
      await expect(
        tools.addTool(101, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json")
      ).to.be.revertedWith("Tools: invalid strength value");
    });

    it("add tools with zero mining duration", async () => {
      await expect(
        tools.addTool(100, 0, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json")
      ).to.be.revertedWith("Tools: mining duration must be greather than zero");
    });

    it("add tool (raspberry bush)", async () => {
      await expect(
        tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json")
      )
        .to.emit(tools, "AddTool")
        .withArgs(ethers.BigNumber.from(1));
    });

    it("mint without existed tools", async () => {
      await expect(tools.mint(acc1.address, 1, 10)).to.be.revertedWith(
        "Tools: no tools"
      );
    });

    it("mint with tool id > _toolIds", async () => {
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await expect(tools.mint(acc1.address, 10, 10)).to.be.revertedWith(
        "Tools: invalid toolTypes value"
      );
    });

    it("mint to blacklist", async () => {
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await blacklist.addToBlacklist(acc1.address);
      await expect(tools.mint(acc1.address, 1, 10)).to.be.revertedWith(
        "Tools: user in blacklist"
      );
    });

    it("mint (raspberry bush)", async () => {
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await tools.mint(acc1.address, 1, 10);

      let balance = await tools.balanceOf(acc1.address, 1);

      expect(balance).eql(ethers.BigNumber.from(10));
    });

    it("mint batch without existed tools", async () => {
      await expect(
        tools.mintBatch(
          acc1.address,
          [1, 2, 3],
          [1, 1, 1],
          ethers.utils.randomBytes(10)
        )
      ).to.be.revertedWith("Tools: no tools");
    });

    it("mintBatch with tool ids > _toolIds", async () => {
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await expect(
        tools.mintBatch(
          acc1.address,
          [10, 20, 30],
          [1, 1, 1],
          ethers.utils.randomBytes(10)
        )
      ).to.be.revertedWith("Tools: invalid toolTypes value");
    });

    it("mintBatch to blacklist", async () => {
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await blacklist.addToBlacklist(acc1.address);
      await expect(
        tools.mintBatch(acc1.address, [1], [1], ethers.utils.randomBytes(10))
      ).to.be.revertedWith("Tools: user in blacklist");
    });

    it("mintBatch (raspberry bush and strawberry bush)", async () => {
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await tools.addTool(150, 35, 3, 10, 2, [0, 1, 0, 0, 0, 0], "1.json");

      await tools.mintBatch(
        acc1.address,
        [1, 2],
        [1, 1],
        ethers.utils.randomBytes(10)
      );

      let balance = [];
      balance.push(await tools.balanceOf(acc1.address, 1));
      balance.push(await tools.balanceOf(acc1.address, 2));

      expect(balance).eql([ethers.BigNumber.from(1), ethers.BigNumber.from(1)]);
    });
  });

  describe("Recipes Functions", async () => {
    it("create recipe", async () => {
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await expect(tools.setRecipe(1, 50, [0, 0, 0, 0, 0, 0]))
        .to.emit(tools, "RecipeCreatedOrUpdated")
        .withArgs(ethers.BigNumber.from(1), 50, [0, 0, 0, 0, 0, 0]);
    });

    it("create recipe with invalid tool types amount", async () => {
      await expect(
        tools.setRecipe(1, 50, [0, 0, 0, 0, 0, 0])
      ).to.be.revertedWith("Tools: invalid toolTypes value");
    });

    /*         it("create recipe with invalid resource amount", async () => {
            await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
            await expect(tools.setRecipe(1, 150, [0, 0, 0, 0, 0, 0])).to.be.revertedWith("Tools: invalid array size");
        }); */

    it("create recipe with invalid artifacts amount", async () => {
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await expect(tools.setRecipe(1, 50, [0, 0, 0, 0, 0])).to.be.revertedWith(
        "Tools: invalid array size"
      );
    });

    it("get recipe", async () => {
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await tools.setRecipe(1, 50, [0, 0, 0, 0, 0, 0]);
      let { resourcesAmount, artifactsAmount } = await tools.getRecipe(
        ethers.BigNumber.from(1)
      );

      expect(resourcesAmount).eql(ethers.BigNumber.from(50));
      expect(artifactsAmount).eql([
        ethers.BigNumber.from(0),
        ethers.BigNumber.from(0),
        ethers.BigNumber.from(0),
        ethers.BigNumber.from(0),
        ethers.BigNumber.from(0),
        ethers.BigNumber.from(0),
      ]);
    });

    it("craft", async () => {
      await tree.mint(acc1.address, 2300);
      await gold.mint(acc1.address, 400);

      await tree.connect(acc1).approve(tools.address, 200);
      await gold.connect(acc1).approve(tools.address, 50);

      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await tools.setRecipe(1, 1, [0, 0, 0, 0, 0, 0]);

      await tools.connect(acc1).craft(1);

      let balance = await tools.balanceOf(acc1.address, 1);
      expect(balance).eql(ethers.BigNumber.from(1));
    });

    it("craft", async () => {
      await tree.mint(acc1.address, 23000);
      await gold.mint(acc1.address, 40000);
      await artifacts.mint(1, acc1.address, 1, ethers.utils.randomBytes(10));

      await tree.connect(acc1).approve(tools.address, 5400);
      await gold.connect(acc1).approve(tools.address, 1080);

      await artifacts.connect(acc1).setApprovalForAll(tools.address, true);

      await tools.addTool(400, 50, 40, 20, 300, [1, 0, 0, 0, 0, 0], "1.json");
      await tools.setRecipe(1, 100, [1, 0, 0, 0, 0, 0]);

      await tools.connect(acc1).craft(1);

      let balance = await tools.balanceOf(acc1.address, 1);
      expect(balance).eql(ethers.BigNumber.from(1));
    });

    it("set tool properties", async () => {
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await tools.mint(acc1.address, 1, 1);
      let result = await tools.getToolProperties(acc1.address, 1);
      expect(result.toString()).to.be.equal([1, 100, 5, 30, 1].toString());

      await tools.setToolProperties(1, 150, 15, 10, 2);
      result = await tools.getToolTypeProperties(1);

      expect(result.toString()).to.be.equal([150, 2, 15, 10].toString());
    });

    it("revert safeBatchTransferFrom with Tools: tokenId is unique", async () => {
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await tools.mint(acc1.address, 1, 2);
      await tools.mint(acc1.address, 2, 1);
      await tools.connect(acc1).setApprovalForAll(owner.address, true);
      expect(await tools.balanceOf(acc1.address, 1)).to.be.equal(2);
      expect(await tools.balanceOf(acc2.address, 1)).to.be.equal(0);

      expect(await tools.balanceOf(acc1.address, 2)).to.be.equal(1);
      expect(await tools.balanceOf(acc2.address, 2)).to.be.equal(0);
      await expect(
        tools.safeBatchTransferFrom(
          acc1.address,
          acc2.address,
          [1, 2, 3],
          [1, 2, 1],
          ethers.utils.randomBytes(10)
        )
      ).to.be.revertedWith("Tools: tokenId is unique");
    });

    it("safeBatchTransferFrom", async () => {
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await tools.mint(acc1.address, 1, 2);
      await tools.mint(acc1.address, 2, 1);
      await tools.connect(acc1).setApprovalForAll(owner.address, true);
      expect(await tools.balanceOf(acc1.address, 1)).to.be.equal(2);
      expect(await tools.balanceOf(acc2.address, 1)).to.be.equal(0);

      expect(await tools.balanceOf(acc1.address, 2)).to.be.equal(1);
      expect(await tools.balanceOf(acc2.address, 2)).to.be.equal(0);
      await tools.safeBatchTransferFrom(
        acc1.address,
        acc2.address,
        [1, 2, 3],
        [1, 1, 1],
        ethers.utils.randomBytes(10)
      );
      expect(await tools.balanceOf(acc1.address, 1)).to.be.equal(0);
      expect(await tools.balanceOf(acc2.address, 1)).to.be.equal(2);

      expect(await tools.balanceOf(acc1.address, 2)).to.be.equal(0);
      expect(await tools.balanceOf(acc2.address, 2)).to.be.equal(1);
    });

    it("setArtifactsAddress", async () => {
      expect(await tools.getArtifactsTypesAmount()).to.be.equal(6);
      await expect(
        tools.connect(acc1).increaseArtifactAmount()
      ).to.be.revertedWith("Tools: caller is not an Artifacts contract");
      await tools.setArtifactsAddress(acc1.address);
      await tools.connect(acc1).increaseArtifactAmount();
      expect(await tools.getArtifactsTypesAmount()).to.be.equal(7);
    });

    it("onERC1155Received", async () => {
      expect(
        await tools.onERC1155Received(acc1.address, acc2.address, 1, 1, 1)
      ).to.be.equal("0xf23a6e61");
    });

    it("onERC1155BatchReceived", async () => {
      expect(
        await tools.onERC1155BatchReceived(
          acc1.address,
          acc2.address,
          [1, 1],
          [1, 1],
          1
        )
      ).to.be.equal("0xbc197c81");
    });

    it("supportsInterface", async () => {
      expect(await tools.supportsInterface("0xd9b67a26")).to.be.equal(true);
    });

    it("revert corrupt with Tools: msg.sender isn't Mining contract", async () => {
      await expect(tools.corrupt(acc1.address, 1, 10)).to.be.revertedWith(
        "Tools: msg.sender isn't Mining contract"
      );
    });

    it("set base uri", async () => {
      expect(await tools.uri(1)).to.be.equal("ipfs://testdir/1.json");
      await tools.setBaseURI("https://");
      expect(await tools.uri(1)).to.be.equal("https://1.json");
    });

    it("get recipe rewert with Pausable: paused", async () => {
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await tools.pause();
      await expect(tools.getRecipe(1)).to.be.revertedWith("Pausable: paused");
      await tools.pause();
      let result = await tools.getRecipe(1);
      expect(result).to.not.be.equal(0);
    });

    it("safe transfer from revert with Tools: tokenId is unique", async () => {
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await tools.mint(acc1.address, 1, 1);
      await expect(
        tools.safeTransferFrom(
          acc1.address,
          acc2.address,
          1,
          2,
          ethers.utils.randomBytes(10)
        )
      ).to.be.revertedWith("Tools: tokenId is unique");
    });

    it("safe transfer from revert with Tools: tool doesn't exist", async () => {
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await tools.mint(acc1.address, 1, 1);
      await expect(
        tools.safeTransferFrom(
          acc1.address,
          acc2.address,
          2,
          1,
          ethers.utils.randomBytes(10)
        )
      ).to.be.revertedWith("Tools: tool doesn't exist");
    });

    it("get artifacts address", async () => {
      expect(await tools.getArtifactsAddress()).to.be.equal(artifacts.address);
    });

    it("get mining adress", async () => {
      expect(await tools.getMiningAddress()).to.be.equal(mining.address);
    });

    it("get resource amount", async () => {
      expect(await tools.getResourceAmount()).to.be.equal(3);
    });

    it("get artifact amount", async () => {
      expect(await tools.getArtifactsTypesAmount()).to.be.equal(6);
    });

    it("get tools types amount", async () => {
      expect(await tools.getToolsTypesAmount()).to.be.equal(0);
    });

    it("revert repair tool with Tools: tool does not exist", async () => {
      await expect(tools.repairTool(1)).to.be.revertedWith(
        "Tools: tool does not exist"
      );
    });

    it("revert set tool properties with Tools: invalid toolTypes value", async () => {
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await expect(
        tools.setToolProperties(7, 150, 15, 10, 2)
      ).to.be.revertedWith("Tools: invalid toolTypes value");
    });

    it("revert set tool properties with Tools: invalid strength value", async () => {
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await expect(
        tools.setToolProperties(1, 151, 15, 10, 2)
      ).to.be.revertedWith("Tools: invalid strength value");
    });

    it("revert set tool properties with Tools: mining duration must be greather than zero", async () => {
      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await expect(
        tools.setToolProperties(1, 150, 0, 10, 2)
      ).to.be.revertedWith("Tools: mining duration must be greather than zero");
    });
  });

  describe("Repair functions", async () => {
    it("repair tool with 100% strength", async () => {
      await gold.mint(acc1.address, 400);
      await gold.connect(acc1).approve(tools.address, 40);

      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await tools.mint(acc1.address, 1, 10);

      await expect(tools.connect(acc1).repairTool(1)).to.be.revertedWith(
        "Tools: the tool is already strong enough"
      );
    });

    it("repair tool after minig", async () => {
      console.log("berry addr: ", berry.address);
      await berry.mint(acc1.address, 400);
      await gold.mint(acc1.address, 400);

      await berry.connect(acc1).approve(mining.address, 400);
      await gold.connect(acc1).approve(tools.address, 40);

      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await tools.mint(acc1.address, 1, 1);

      await tools.connect(acc1).setApprovalForAll(mining.address, true);

      await mining
        .connect(owner)
        .startMining(1, acc1.address, [1, 0, 0], [1, 0, 0, 0, 0, 0]);

      await network.provider.send("evm_increaseTime", [3600]);
      await network.provider.send("evm_mine");

      await mining.connect(acc1).endMining(1);

      let strenghBefore = await tools.connect(acc1).getStrength(1);

      await tools.connect(acc1).repairTool(1);

      let strenghAfter = await tools.connect(acc1).getStrength(1);

      expect(strenghAfter).eql(strenghBefore.add(ethers.BigNumber.from(5)));
    });
  });

  describe("URI", async () => {
    it("get token uri", async () => {
      await tree.mint(acc1.address, 2300);
      await gold.mint(acc1.address, 400);

      await tree.connect(acc1).approve(tools.address, 200);
      await gold.connect(acc1).approve(tools.address, 50);

      await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
      await tools.setRecipe(1, 1, [0, 0, 0, 0, 0, 0]);

      await tools.connect(acc1).craft(1);

      let URI = await tools.uri(1);
      expect(URI).eql(BASE_URI + 1 + ".json");
    });
  });
});
