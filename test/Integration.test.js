const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
require("dotenv").config();

describe("Mining contract tests", async () =>  {
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
        await tools.setMiningAddress(mining.address);

        // add raspberry bush
        await tools.addTool(100, 30, 1, 5, 10, [1, 0, 0, 0, 0, 0], "1.json");
        // add magic berry
        await tools.addTool(400, 50, 30, 20, 300, [1, 0, 0, 0, 0, 0], "1.json");
        // create recipe for raspberry bush
        await tools.setRecipe(1, 2, [0, 0, 0, 0, 0, 0]);
        // create recipe for magic berry
        await tools.setRecipe(2, 5, [1, 0, 0, 0, 0, 0]);
                
        [owner, acc1, acc2] = await ethers.getSigners();

        await berry.mint(acc1.address, INIT_RESOURCES_AMOUNT);
        await tree.mint(acc1.address, INIT_RESOURCES_AMOUNT);
        await gold.mint(acc1.address, INIT_RESOURCES_AMOUNT);

        await berry.mint(mining.address, INIT_RESOURCES_AMOUNT);
        await tree.mint(mining.address, INIT_RESOURCES_AMOUNT);
        await gold.mint(mining.address, INIT_RESOURCES_AMOUNT);
    });

    describe("Process 1 - craft", async () => {
        it("craft without artifacts in recipe", async () => {
            let balanceBefore = await tools.balanceOf(acc1.address, 1);

            await tree.connect(acc1).approve(tools.address, 10);
            await gold.connect(acc1).approve(tools.address, 10);

            await tools.connect(acc1).craft(1);

            let balanceAfter = await tools.balanceOf(acc1.address, 1);

            expect(balanceAfter).to.be.equal(balanceBefore.add(ethers.BigNumber.from(1)));
            expect(await tree.balanceOf(acc1.address)).to.be.equal(INIT_RESOURCES_AMOUNT.sub(ethers.BigNumber.from(10)));
            expect(await gold.balanceOf(acc1.address)).to.be.equal(INIT_RESOURCES_AMOUNT.sub(ethers.BigNumber.from(2)));
        });

        it("craft with artifact in recipe", async () => {
            let balanceBefore = await tools.balanceOf(acc1.address, 2);
        
            await artifacts.mint(1, acc1.address, 1, ethers.utils.randomBytes(10));


            expect(await artifacts.balanceOf(acc1.address, 1)).to.be.equal(1)
            await artifacts.connect(acc1).setApprovalForAll(tools.address, true);
            await tree.connect(acc1).approve(tools.address, 25);
            await gold.connect(acc1).approve(tools.address, 5);

            await tools.connect(acc1).craft(2);
            expect(await artifacts.balanceOf(acc1.address, 1)).to.be.equal(0)

            let balanceAfter = await tools.balanceOf(acc1.address, 2);

            expect(balanceAfter).to.be.equal(balanceBefore.add(ethers.BigNumber.from(1)));
            
            expect(await tree.balanceOf(acc1.address)).to.be.equal(INIT_RESOURCES_AMOUNT.sub(ethers.BigNumber.from(25)));
            expect(await gold.balanceOf(acc1.address)).to.be.equal(INIT_RESOURCES_AMOUNT.sub(ethers.BigNumber.from(5)));
        });
    });

    describe("Process 2 - mining", async () => {
        it("mining", async () => {            
            await artifacts.mint(1, acc1.address, 1, ethers.utils.randomBytes(10));
            await artifacts.connect(acc1).setApprovalForAll(tools.address, true);

            await berry.connect(acc1).approve(mining.address, 30);
            await tree.connect(acc1).approve(tools.address, 25);
            await gold.connect(acc1).approve(tools.address, 5);

            await tools.connect(acc1).craft(2);
            await tools.connect(acc1).setApprovalForAll(mining.address, true);
            
            await mining.connect(owner).startMining(1, acc1.address, [300, 0, 0], [0, 0, 0, 1, 0, 0]);

            await network.provider.send("evm_increaseTime", [36000]);
            await network.provider.send("evm_mine");
            
            await mining.connect(acc1).endMining(1);

            let balanceBefore = await berry.balanceOf(acc1.address);

            await mining.connect(acc1).getRewards();

            expect(await berry.balanceOf(acc1.address)).to.be.equal(balanceBefore.add(ethers.BigNumber.from(300)));
            expect(await artifacts.balanceOf(acc1.address, 4)).to.be.equal(ethers.BigNumber.from(1));
            expect(await tools.balanceOf(acc1.address, 2)).to.be.equal(ethers.BigNumber.from(1));
            expect(await tools.connect(acc1).getStrength(1)).to.be.equal(ethers.BigNumber.from(380));
        });

        it("2 minings and rewards claim", async () => {            
            await artifacts.mint(1, acc1.address, 1, ethers.utils.randomBytes(10));
            await artifacts.connect(acc1).setApprovalForAll(tools.address, true);

            await berry.connect(acc1).approve(mining.address, 60);
            await tree.connect(acc1).approve(tools.address, 25);
            await gold.connect(acc1).approve(tools.address, 5);


            await tools.connect(acc1).craft(2);
            await tools.connect(acc1).setApprovalForAll(mining.address, true);
            
            await mining.connect(owner).startMining(1, acc1.address, [300, 0, 0], [0, 0, 0, 1, 0, 0]);

            await network.provider.send("evm_increaseTime", [36000]);
            await network.provider.send("evm_mine");

            await mining.connect(acc1).endMining(1);

            await mining.connect(owner).startMining(1, acc1.address, [300, 0, 0], [0, 0, 0, 1, 0, 0]);

            await network.provider.send("evm_increaseTime", [36000]);
            await network.provider.send("evm_mine");
            
            await mining.connect(acc1).endMining(1);

            let balanceBefore = await berry.balanceOf(acc1.address);

            await mining.connect(acc1).getRewards();

            expect(await berry.balanceOf(acc1.address)).to.be.equal(balanceBefore.add(ethers.BigNumber.from(600)));
            expect(await artifacts.balanceOf(acc1.address, 4)).to.be.equal(ethers.BigNumber.from(2));
            expect(await tools.balanceOf(acc1.address, 2)).to.be.equal(ethers.BigNumber.from(1));
            expect(await tools.connect(acc1).getStrength(1)).to.be.equal(ethers.BigNumber.from(360));
        });
    });

    describe("Process 3 - repair tool", async () => {
        it("repair tool after mining", async () => {
            await artifacts.mint(1, acc1.address, 1, ethers.utils.randomBytes(10));
            await artifacts.connect(acc1).setApprovalForAll(tools.address, true);

            await berry.connect(acc1).approve(mining.address, 30);
            await tree.connect(acc1).approve(tools.address, 25);
            await gold.connect(acc1).approve(tools.address, 5);

            await tools.connect(acc1).craft(2);
            await tools.connect(acc1).setApprovalForAll(mining.address, true);
            
            await mining.connect(owner).startMining(1, acc1.address, [300, 0, 0], [0, 0, 0, 1, 0, 0]);

            await network.provider.send("evm_increaseTime", [36000]);
            await network.provider.send("evm_mine");
            
            await mining.connect(acc1).endMining(1);

            await mining.connect(acc1).getRewards();

            let balanceBefore = await gold.balanceOf(acc1.address);
            let strengthBefore = await tools.connect(acc1).getStrength(1);
            
            await gold.connect(acc1).approve(tools.address, ethers.BigNumber.from("4000000000000000000"));

            await tools.connect(acc1).repairTool(1);

            let balanceAfter = await gold.balanceOf(acc1.address);
            let strengthAfter = await tools.connect(acc1.address).getStrength(1);

            console.log(strengthBefore);
            console.log(strengthAfter);
            console.log(balanceBefore);
            console.log(balanceAfter);

            expect(strengthAfter).to.be.equal(strengthBefore.add(ethers.BigNumber.from(20)));
            expect(balanceAfter).to.be.equal(balanceBefore.sub(ethers.BigNumber.from("4")));
        });
    });
});