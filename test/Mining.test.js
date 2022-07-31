const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
require("dotenv").config();

describe("Mining contract tests", async () =>  {
    let Tools;
    let Mining;
    let BlackList;
    let Berry;
    let Tree;
    let Gold;

    let tools;
    let mining;
    let blackList;
    let berry;
    let tree;
    let gold;

    const REWARD_RATE = 12345;
    const BASE_URI = "ipfs://123/"

    beforeEach(async () => {
        Gem = await ethers.getContractFactory("Gem");
        gem = await Gem.deploy(1);

        Resource = await ethers.getContractFactory("PocMon");
        resource = await Resource.deploy(process.env.UNISWAP_ROUTER, gem.address, process.env.PUBLIC_KEY, process.env.PUBLIC_KEY);
        resource.deployed();

        BlackList = await ethers.getContractFactory("BlackList");
        blackList = await BlackList.deploy();
        blackList.deployed();

        Mining = await ethers.getContractFactory("Mining");
        mining = await upgrades.deployProxy(Mining, [REWARD_RATE, blackList.address]);
        mining.deployed();

        Tools = await ethers.getContractFactory("Tools");
        tools = await upgrades.deployProxy(Tools, [blacklist.address, berry.address, tree.address, gold.address, BASE_URI]);
    });

    it("start mining", async () => {
        await tools.mint(address1.address, )
    });
    
    it("", async () => {});
    it("", async () => {});
    it("", async () => {});
    it("", async () => {});
});