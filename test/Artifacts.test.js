const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

const BASE_URI = "http://123.com/";

describe("Traits contract tests", async () => {
    let BlackList;
    let Artifacts;

    let blacklist;
    let artifacts;

    beforeEach(async () => {
        BlackList = await ethers.getContractFactory("BlackList");
        blacklist = await BlackList.deploy();
        blacklist.deployed();

        Artifacts = await ethers.getContractFactory("Artifacts");
        artifacts = await upgrades.deployProxy(Artifacts, [BASE_URI, blacklist.address]);
        [owner, address1, address2] = await ethers.getSigners();
    });

    it("init", async () => {
        let baseURI = await artifacts.baseUri();
        let idCount = await artifacts.idCount();

        expect(baseURI).eql(BASE_URI);
        expect(idCount).eql(ethers.BigNumber.from(6));

        expect(await artifacts.artifactName(0)).eql("Magic smoothie");
        expect(await artifacts.artifactName(1)).eql("Money tree");
        expect(await artifacts.artifactName(2)).eql("Emerald");
        expect(await artifacts.artifactName(3)).eql("Goldberry");
        expect(await artifacts.artifactName(4)).eql("Diamond");
        expect(await artifacts.artifactName(5)).eql("Golden tree");

        expect(await artifacts.level(0)).eql(ethers.BigNumber.from(3));
        expect(await artifacts.level(1)).eql(ethers.BigNumber.from(3));
        expect(await artifacts.level(2)).eql(ethers.BigNumber.from(3));
        expect(await artifacts.level(3)).eql(ethers.BigNumber.from(4));
        expect(await artifacts.level(4)).eql(ethers.BigNumber.from(4));
        expect(await artifacts.level(5)).eql(ethers.BigNumber.from(4));
    });

    it("mint not owner", async () =>{
        await expect(artifacts.connect(address1).mint(0, address2.address, 1)).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("mint when pause", async () => {
        await expect(artifacts.mint(0, address2.address, 1)).to.be.revertedWith("Pausable: paused");
    })

    it("mint to blacklist", async () => {
        await blacklist.addToBlacklist(address2.address);
        await artifacts.pause();
        await expect(artifacts.mint(0, address2.address, 1)).to.be.revertedWith("User in blacklist");
    });

    it("mint successful", async () => {
        await artifacts.pause();
        await artifacts.mint(0, address2.address, 1);
        expect(ethers.BigNumber.from(1)).eql(await artifacts.balanceOf(address2.address, 0));
    });

    it("uri", async () => {
        expect(BASE_URI + "0.json").eql(await artifacts.uri(0));
    });

    it("uri error", async () => {
        await expect(artifacts.uri(7)).to.be.revertedWith("This token doesn't exist");
    });

    it("add new artifact", async () => {
        await artifacts.addNewArtifact("Test artifact", 9999);
        expect(await artifacts.idCount()).eql(ethers.BigNumber.from(7));
        expect(await artifacts.artifactName(6)).eql("Test artifact");
        expect(await artifacts.level(6)).eql(ethers.BigNumber.from(9999));
        expect(await artifacts.uri(6)).eql(BASE_URI + "6.json");
    });

    it("setApprovalForAll from blacklisted user", async () => {
        await blacklist.addToBlacklist(address1.address);
        await expect(artifacts.connect(address1).setApprovalForAll(address2.address, true)).to.be.revertedWith("User in blacklist");
    });

    it("safeTransferFrom from blacklisted user", async () => {
        await blacklist.addToBlacklist(address1.address);
        await expect(artifacts.connect(address1).safeTransferFrom(address1.address, address2.address, 0, 1, ethers.utils.randomBytes(10))).to.be.revertedWith("User in blacklist");
    });

    it("safeBatchTransferFrom from blacklisted user", async () => {
        await blacklist.addToBlacklist(address1.address);
        await expect(artifacts.safeBatchTransferFrom(address1.address, address2.address, [0, 1, 2], [1, 1, 1], ethers.utils.randomBytes(10))).to.be.revertedWith("User in blacklist");
    }); 
});