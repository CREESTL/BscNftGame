const { makeGetInstanceFunction } = require("@openzeppelin/hardhat-upgrades/dist/admin");
const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("Mining tests", async () => {
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

        tools = await upgrades.deployProxy(Tools, [blacklist.address, berry.address, tree.address, gold.address, BASE_URI]);
        artifacts = await upgrades.deployProxy(Artifacts, [BASE_URI, blacklist.address]);
        mining = await upgrades.deployProxy(Mining, [blacklist.address, tools.address]);
        
        await artifacts.setToolsAddress(tools.address);
        await tools.setArtifactsAddress(artifacts.address);
        await tools.setURI(1, "1.json");
        await tools.setMiningAddress(mining.address);

        [owner, acc1, acc2] = await ethers.getSigners();
    });

    describe("main functions", async () => {
        it("shuold revert startMining with Mining: this user already started mining process", async () => {
            await berry.mint(acc1.address, 400);
            await gold.mint(acc1.address, 400);

            await berry.connect(acc1).approve(mining.address, 400);
            await gold.connect(acc1).approve(tools.address, 40);

            await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
            await tools.mint(acc1.address, 1, 1);

            await tools.connect(acc1).setApprovalForAll(mining.address, true);

            await mining.connect(owner).startMining(1, acc1.address, [1, 0, 0], [1, 0, 0, 0, 0, 0]);

            await expect(mining.connect(owner).startMining(1, acc1.address, [1, 0, 0], [1, 0, 0, 0, 0, 0])).to.be.revertedWith("Mining: this user already started mining process")
        });
        
        it("onERC1155Received", async () => {
            expect(await tools.onERC1155Received(acc1.address, acc2.address, 1, 1, 1)).to.be.equal("0xf23a6e61")
        });

        it("onERC1155BatchReceived", async () => {
            expect(await tools.onERC1155BatchReceived(acc1.address, acc2.address, [1, 1], [1, 1], 1)).to.be.equal("0xbc197c81")
        });

        it("supportsInterface", async () => {
            expect(await tools.supportsInterface("0xd9b67a26")).to.be.equal(true)
        });

        it("shuold revert startMining with Pausable: paused", async () => {
            await berry.mint(acc1.address, 400);
            await gold.mint(acc1.address, 400);

            await berry.connect(acc1).approve(mining.address, 400);
            await gold.connect(acc1).approve(tools.address, 40);

            await tools.addTool(20, 30, 1, 20, 1, [1, 0, 0, 0, 0, 0], "1.json");
            await tools.mint(acc1.address, 1, 1);

            await tools.connect(acc1).setApprovalForAll(mining.address, true);

            await mining.pause()
            await expect(mining.connect(owner).startMining(1, acc1.address, [1, 0, 0], [1, 0, 0, 0, 0, 0])).to.be.revertedWith("Pausable: paused")
            await mining.pause()
            await blacklist.addToBlacklist(acc1.address)
            await expect(mining.connect(owner).startMining(1, acc1.address, [1, 0, 0], [1, 0, 0, 0, 0, 0])).to.be.revertedWith("User in blacklist")
        });

        it("shuold revert startMining with User in blacklist", async () => {
            await berry.mint(acc1.address, 400);
            await gold.mint(acc1.address, 400);

            await berry.connect(acc1).approve(mining.address, 400);
            await gold.connect(acc1).approve(tools.address, 40);

            await tools.addTool(20, 30, 1, 20, 1, [1, 0, 0, 0, 0, 0], "1.json");
            await tools.mint(acc1.address, 1, 1);

            await tools.connect(acc1).setApprovalForAll(mining.address, true);

            await blacklist.addToBlacklist(acc1.address)
            await expect(mining.connect(owner).startMining(1, acc1.address, [1, 0, 0], [1, 0, 0, 0, 0, 0])).to.be.revertedWith("User in blacklist")
        });

        it("shuold revert startMining with Mining: not enougth strength", async () => {
            await berry.mint(acc1.address, 400);
            await gold.mint(acc1.address, 400);

            await berry.connect(acc1).approve(mining.address, 400);
            await gold.connect(acc1).approve(tools.address, 40);

            await tools.addTool(20, 30, 1, 20, 1, [1, 0, 0, 0, 0, 0], "1.json");
            await tools.mint(acc1.address, 1, 1);

            await tools.connect(acc1).setApprovalForAll(mining.address, true);

            await expect(mining.connect(owner).startMining(1, acc1.address, [1, 0, 0], [1, 0, 0, 0, 0, 0])).to.be.revertedWith("Mining: not enougth strength")
        });

        it("shuold revert endMining with Mining: user doesn't mine", async () => {
            await berry.mint(acc1.address, 400);
            await gold.mint(acc1.address, 400);

            await berry.connect(acc1).approve(mining.address, 400);
            await gold.connect(acc1).approve(tools.address, 40);

            await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
            await tools.mint(acc1.address, 1, 1);

            await tools.connect(acc1).setApprovalForAll(mining.address, true);

            await mining.connect(owner).startMining(1, acc1.address, [1, 0, 0], [1, 0, 0, 0, 0, 0]);

            await network.provider.send("evm_increaseTime", [3600]);
            await network.provider.send("evm_mine");
            
            await expect(mining.connect(acc2).endMining(1)).to.be.revertedWith("Mining: user doesn't mine");
        });

        it("shuold revert endMining with Mining: too early", async () => {
            await berry.mint(acc1.address, 400);
            await gold.mint(acc1.address, 400);

            await berry.connect(acc1).approve(mining.address, 400);
            await gold.connect(acc1).approve(tools.address, 40);

            await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
            await tools.mint(acc1.address, 1, 1);

            await tools.connect(acc1).setApprovalForAll(mining.address, true);

            await mining.connect(owner).startMining(1, acc1.address, [1, 0, 0], [1, 0, 0, 0, 0, 0]);
            
            await expect(mining.connect(acc1).endMining(1)).to.be.revertedWith("Mining: too early");
        });

        it("shuold getRewards", async () => {
            await berry.mint(acc1.address, 400);
            await tree.mint(mining.address, 400);
            await gold.mint(acc1.address, 400);

            await berry.connect(acc1).approve(mining.address, 400);
            await gold.connect(acc1).approve(tools.address, 40);

            await tools.addTool(100, 30, 1, 5, 1, [1, 0, 0, 0, 0, 0], "1.json");
            await tools.mint(acc1.address, 1, 1);

            await tools.connect(acc1).setApprovalForAll(mining.address, true);

            await mining.connect(owner).startMining(1, acc1.address, [0, 123, 0], [2, 1, 0, 0, 0, 0]);

            await network.provider.send("evm_increaseTime", [3600]);
            await network.provider.send("evm_mine");
            
            await mining.connect(acc1).endMining(1);

            expect(await artifacts.balanceOf(acc1.address, 1)).to.be.equal(0)
            expect(await artifacts.balanceOf(acc1.address, 2)).to.be.equal(0)
            expect(await artifacts.balanceOf(acc1.address, 3)).to.be.equal(0)
            expect(await artifacts.balanceOf(acc1.address, 4)).to.be.equal(0)
            expect(await artifacts.balanceOf(acc1.address, 5)).to.be.equal(0)
            expect(await artifacts.balanceOf(acc1.address, 6)).to.be.equal(0)

            expect(await berry.balanceOf(acc1.address)).to.be.equal(399)
            expect(await tree.balanceOf(acc1.address)).to.be.equal(0)
            expect(await gold.balanceOf(acc1.address)).to.be.equal(400)

            await mining.connect(acc1).getRewards()

            expect(await berry.balanceOf(acc1.address)).to.be.equal(399)
            expect(await tree.balanceOf(acc1.address)).to.be.equal(123)
            expect(await gold.balanceOf(acc1.address)).to.be.equal(400)

            expect(await artifacts.balanceOf(acc1.address, 1)).to.be.equal(2)
            expect(await artifacts.balanceOf(acc1.address, 2)).to.be.equal(1)
            expect(await artifacts.balanceOf(acc1.address, 3)).to.be.equal(0)
            expect(await artifacts.balanceOf(acc1.address, 4)).to.be.equal(0)
            expect(await artifacts.balanceOf(acc1.address, 5)).to.be.equal(0)
            expect(await artifacts.balanceOf(acc1.address, 6)).to.be.equal(0)
        })
    })
})