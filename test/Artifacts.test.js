const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Traits contract tests", async () => {
    let BlackList;
    let Artifacts;

    let blacklist;
    let artifacts;

    const BASE_URL = "http://123.com/";

    beforeEach(async () => {
        BlackList = await ethers.getContractFactory("BlackList");
        blacklist = await BlackList.deploy();
        blacklist.deployed();

        Artifacts = await ethers.getContractFactory("Artifacts");
        artifacts = await Artifacts.deploy(BASE_URL, blacklist.address);
        artifacts.deployed();
    });

    it("", async () => {
        
    });
});