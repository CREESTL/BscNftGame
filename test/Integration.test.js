const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
require("dotenv").config();

xdescribe("Mining contract tests", async () =>  {
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
    const INIT_RESOURCES_AMOUNT = ethers.BigNumber.from("10000000000000000000");

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
        await tools.setRepairCost([0, 0, ethers.BigNumber.from("200000000000000000")]);
        await tools.setMiningAddress(mining.address);

        // add raspberry bush
        await tools.addTool(1, 100, 30, 1, 5, 10);
        // add magic berry
        await tools.addTool(1, 400, 50, 30, 20, 300);
        // create recipe for raspberry bush
        await tools.createRecipe(1, [0, 200, 40], [0, 0, 0, 0, 0, 0]);
        // create recipe for magic berry
        await tools.createRecipe(2, [0, 5400, 1080], [1, 0, 0, 0, 0, 0]);
                
        [owner, address1, address2] = await ethers.getSigners();

        await berry.mint(address1.address, INIT_RESOURCES_AMOUNT);
        await tree.mint(address1.address, INIT_RESOURCES_AMOUNT);
        await gold.mint(address1.address, INIT_RESOURCES_AMOUNT);

        await berry.mint(mining.address, INIT_RESOURCES_AMOUNT);
        await tree.mint(mining.address, INIT_RESOURCES_AMOUNT);
        await gold.mint(mining.address, INIT_RESOURCES_AMOUNT);
    });

    describe("Process 1 - craft", async () => {
        it("craft without artifacts in recipe", async () => {
            let balanceBefore = await tools.balanceOf(address1.address, 1);

            await tree.connect(address1).approve(tools.address, 200);
            await gold.connect(address1).approve(tools.address, 40);

            await tools.connect(address1).craft(1);

            let balanceAfter = await tools.balanceOf(address1.address, 1);

            expect(balanceAfter).eql(balanceBefore.add(ethers.BigNumber.from(1)));
            expect(await tree.balanceOf(address1.address)).eql(INIT_RESOURCES_AMOUNT.sub(ethers.BigNumber.from(200)));
            expect(await gold.balanceOf(address1.address)).eql(INIT_RESOURCES_AMOUNT.sub(ethers.BigNumber.from(40)));
        });

        it("craft with artifact in recipe", async () => {
            let balanceBefore = await tools.balanceOf(address1.address, 2);
            
            await artifacts.mint(1, address1.address, 1, ethers.utils.randomBytes(10));
            console.log(await artifacts.balanceOf(address1.address, 1));


            await artifacts.connect(address1).setApprovalForAll(tools.address, true);
            await tree.connect(address1).approve(tools.address, 5400);
            await gold.connect(address1).approve(tools.address, 1080);

            await tools.connect(address1).craft(2);

            let balanceAfter = await tools.balanceOf(address1.address, 2);

            expect(balanceAfter).eql(balanceBefore.add(ethers.BigNumber.from(1)));
            expect(await tree.balanceOf(address1.address)).eql(INIT_RESOURCES_AMOUNT.sub(ethers.BigNumber.from(5400)));
            expect(await gold.balanceOf(address1.address)).eql(INIT_RESOURCES_AMOUNT.sub(ethers.BigNumber.from(1080)));
        });
    });

    describe("Process 2 - mining", async () => {
        it("mining", async () => {            
            await artifacts.mint(1, address1.address, 1, ethers.utils.randomBytes(10));
            await artifacts.connect(address1).setApprovalForAll(tools.address, true);

            await berry.connect(address1).approve(mining.address, 30);
            await tree.connect(address1).approve(tools.address, 5400);
            await gold.connect(address1).approve(tools.address, 1080);

            await tools.connect(address1).craft(2);
            await tools.connect(address1).setApprovalForAll(mining.address, true);
            
            await mining.connect(address1).startMining(1);

            await network.provider.send("evm_increaseTime", [36000]);
            await network.provider.send("evm_mine");
            
            await mining.connect(address1).endMining(1);

            let balanceBefore = await berry.balanceOf(address1.address);

            await mining.setRewards(address1.address, [300, 0, 0], [0, 0, 0, 1, 0, 0]);
            await mining.connect(address1).getRewards();

            expect(await berry.balanceOf(address1.address)).eql(balanceBefore.add(ethers.BigNumber.from(300)));
            expect(await artifacts.balanceOf(address1.address, 4)).eql(ethers.BigNumber.from(1));
            expect(await tools.balanceOf(address1.address, 2)).eql(ethers.BigNumber.from(1));
            expect(await tools.connect(address1).getStrength(1)).eql(ethers.BigNumber.from(380));
        });
    });

    describe("Process 3 - repair tool", async () => {
        it("repair tool after mining", async () => {
            await artifacts.mint(1, address1.address, 1, ethers.utils.randomBytes(10));
            await artifacts.connect(address1).setApprovalForAll(tools.address, true);

            await berry.connect(address1).approve(mining.address, 30);
            await tree.connect(address1).approve(tools.address, 5400);
            await gold.connect(address1).approve(tools.address, 1080);

            await tools.connect(address1).craft(2);
            await tools.connect(address1).setApprovalForAll(mining.address, true);
            
            await mining.connect(address1).startMining(1);

            await network.provider.send("evm_increaseTime", [36000]);
            await network.provider.send("evm_mine");
            
            await mining.connect(address1).endMining(1);

            await mining.setRewards(address1.address, [300, 0, 0], [0, 0, 0, 1, 0, 0]);
            await mining.connect(address1).getRewards();

            let balanceBefore = await gold.balanceOf(address1.address);
            let strengthBefore = await tools.connect(address1).getStrength(1);
            
            await gold.connect(address1).approve(tools.address, ethers.BigNumber.from("4000000000000000000"));

            await tools.connect(address1).repairTool(1, 20);

            let balanceAfter = await gold.balanceOf(address1.address);
            let strengthAfter = await tools.connect(address1.address).getStrength(1);

            console.log(strengthBefore);
            console.log(strengthAfter);
            console.log(balanceBefore);
            console.log(balanceAfter);

            expect(strengthAfter).eql(strengthBefore.add(ethers.BigNumber.from(20)));
            expect(balanceAfter).eql(balanceBefore.sub(ethers.BigNumber.from("4000000000000000000")));
        });
    });
});