const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Traits contract tests", async () => {
    let BlackList;
    let blacklist;

    beforeEach(async () => {
        BlackList = await ethers.getContractFactory("BlackList");
        blacklist = await BlackList.deploy();
        blacklist.deployed();

        [owner, address1, address2] = await ethers.getSigners();
    });

    it("Add to blacklist negative (not owner)", async () => {
        await expect(blacklist.connect(address1).addToBlacklist(address2.address)).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Add to blacklist negative (user already in blacklist)", async () => {
        await blacklist.addToBlacklist(address2.address);
        await expect(blacklist.addToBlacklist(address2.address)).to.be.revertedWith("User already in blacklist");
    });

    it("Add to blacklist positive", async () => {
        await blacklist.addToBlacklist(address2.address);
        expect(await blacklist.check(address2.address)).equal(true);
    });

    it("Remove from blacklist negative (not owner)", async () => {
        await blacklist.addToBlacklist(address2.address);
        await expect(blacklist.connect(address1).removeFromBlacklist(address2.address)).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Remove from blacklist negative (user already removed from blacklist)", async () => {
        await blacklist.addToBlacklist(address2.address);
        await blacklist.removeFromBlacklist(address2.address);
        await expect(blacklist.removeFromBlacklist(address2.address)).to.be.revertedWith("User is not in blacklist");
    });

    it("Remove from blacklist positive", async () => {
        await blacklist.addToBlacklist(address2.address);
        await blacklist.removeFromBlacklist(address2.address);
        expect(await blacklist.check(address2.address)).equal(false);
    });
});