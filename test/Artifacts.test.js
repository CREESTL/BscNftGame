const { makeGetInstanceFunction } = require("@openzeppelin/hardhat-upgrades/dist/admin");
const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("Artifacts tests", async () => {
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
        it("should revert mint to be reverted with Artifacts: This artifact doesn't exist", async () => {
            await expect(artifacts.mint(7, acc1.address, 1, ethers.utils.randomBytes(10))).to.be.revertedWith("Artifacts: This artifact doesn't exist")
        });

        it("should revert uri to be reverted with Artifacts: This artifact doesn't exist", async () => {
            await expect(artifacts.uri(7)).to.be.revertedWith("Artifacts: This artifact doesn't exist")
        });

        it("should return uri", async () => {
            expect(await artifacts.uri(1)).to.be.equal("ipfs://testdir/1.json")
        });
        
        it("should getArtifactsTypesAmount", async () => {
            expect(await artifacts.getArtifactsTypesAmount()).to.be.equal("6")
        });

        it("should addNewArtifact", async () => {
            expect(await artifacts.getArtifactsTypesAmount()).to.be.equal("6")
            expect(await tools.getArtifactsTypesAmount()).to.be.equal("6")
            await artifacts.addNewArtifact()
            expect(await artifacts.getArtifactsTypesAmount()).to.be.equal("7")
            expect(await tools.getArtifactsTypesAmount()).to.be.equal("7")
        });

        it("should pause", async () => {
            expect(await artifacts.balanceOf(acc1.address, 1)).to.be.equal(0)
            await artifacts.mint(1, acc1.address, 1, ethers.utils.randomBytes(10))
            expect(await artifacts.balanceOf(acc1.address, 1)).to.be.equal(1)
            await artifacts.pause()
            await expect(artifacts.mint(1, acc1.address, 1, ethers.utils.randomBytes(10))).to.be.revertedWith("Pausable: paused")
            await artifacts.pause()
            await artifacts.mint(1, acc1.address, 1, ethers.utils.randomBytes(10))
            expect(await artifacts.balanceOf(acc1.address, 1)).to.be.equal(2)
        });

        it("should revert lootArtifact with Artifacts: only mining contract can call this function", async () => {
            await expect(artifacts.lootArtifact(acc1.address, 1)).to.be.revertedWith("Artifacts: only mining contract can call this function")
        });

        it("should revert setToolsAddress with Artifacts: zero address", async () => {
            await expect(artifacts.setToolsAddress("0x0000000000000000000000000000000000000000")).to.be.revertedWith("Artifacts: zero address")
        });

        it("should revert mint with Artifacts: user in blacklist", async () => {
            await blacklist.addToBlacklist(acc1.address)
            await expect(artifacts.mint(1, acc1.address, 1, ethers.utils.randomBytes(10))).to.be.revertedWith("Artifacts: user in blacklist")
        });

        it("should revert mintBatch with Artifacts: this artifact type doesn't exists", async () => {
            expect(await artifacts.balanceOf(acc1.address, 1)).to.be.equal(0)
            expect(await artifacts.balanceOf(acc1.address, 2)).to.be.equal(0)
            await expect(artifacts.mintBatch(acc1.address, [1, 7], [2, 1], ethers.utils.randomBytes(10))).to.be.revertedWith("Artifacts: this artifact type doesn't exists")

        });

        it("should mintBatch", async () => {
            expect(await artifacts.balanceOf(acc1.address, 1)).to.be.equal(0)
            expect(await artifacts.balanceOf(acc1.address, 2)).to.be.equal(0)
            await artifacts.mintBatch(acc1.address, [1, 2], [2, 1], ethers.utils.randomBytes(10))
            expect(await artifacts.balanceOf(acc1.address, 1)).to.be.equal(2)
            expect(await artifacts.balanceOf(acc1.address, 2)).to.be.equal(1)
        });

        it("should lootArtifact", async () => {
            await tools.setMiningAddress(owner.address)
            expect(await artifacts.balanceOf(acc1.address, 1)).to.be.equal(0)
            await artifacts.lootArtifact(acc1.address, 1)
            expect(await artifacts.balanceOf(acc1.address, 1)).to.be.equal(1)
        });
        
    })
})