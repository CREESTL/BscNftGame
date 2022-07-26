const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
require("dotenv").config();

describe("Mining contract tests", async () =>  {
    let Mining;
    let BlackList;
    let Resource;
    let Gem;

    let mining;
    let blackList;
    let resource;
    let gem;

    const REWARD_RATE = 12345;

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
    });

    // it("initialize", async () => {
    //     let rewardRate = await mining.rewardRate();
    //     expect(rewardRate).eql(ethers.BigNumber.from(REWARD_RATE));
    // });

    // it("", async () => {
    //     let 
    // });
});