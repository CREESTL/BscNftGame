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

        tools = await upgrades.deployProxy(Tools, [blacklist.address, berry.address, tree.address, gold.address, BASE_URI]);
        artifacts = await upgrades.deployProxy(Artifacts, [BASE_URI, blacklist.address]);
        mining = await upgrades.deployProxy(Mining, [blacklist.address, tools.address]);
        
        await artifacts.setToolsAddress(tools.address);
        await tools.setArtifactsAddress(artifacts.address);
        await tools.setURI(1, "1.json");
        await tools.setRepairCost([0, 0, 5]);
        await tools.setMiningAddress(mining.address);

        [owner, address1, address2] = await ethers.getSigners();
    });

    describe("Mint functions", async () => {
        it("add tool with wrong strengh", async () => {
            await expect(tools.addTool(1, [], 101, 30, 1, 5, 10)).to.be.revertedWith("Tools: invalid strength value");
        });

        it("add tool with invalid artifact index", async () => {
            await expect(tools.addTool(1, [7], 200, 40, 9, 15, 90)).to.be.revertedWith("Tools: invalid arifact value");
        });

        it("add tool with invalid resource index", async () => {
            await expect(tools.addTool(10, [], 100, 30, 1, 5, 10)).to.be.revertedWith("Tools: invalid mining resource value");
        });

        it("add tools with zero mining duration", async () => {
            await expect(tools.addTool(1, [], 100, 0, 1, 5, 10)).to.be.revertedWith("Tools: mining duration must be greather than zero")
        })

        it("add tool (raspberry bush)", async () => {
            await expect(tools.addTool(1, [], 100, 30, 1, 5, 10)).to.emit(tools, "AddTool").withArgs(ethers.BigNumber.from(1));
        });

        it("mint without existed tools", async () => {
            await expect(tools.mint(address1.address, 1, 10)).to.be.revertedWith("Tools: no tools");
        });

        it("mint with tool id > _toolIds", async () => {
            await tools.addTool(1, [], 100, 30, 1, 5, 10);
            await expect(tools.mint(address1.address, 10, 10)).to.be.revertedWith("Tools: invalid id value");
        });

        it("mint to blacklist", async () => {
            await tools.addTool(1, [], 100, 30, 1, 5, 10);
            await blacklist.addToBlacklist(address1.address);
            await expect(tools.mint(address1.address, 1, 10)).to.be.revertedWith("Tools: user in blacklist");
        });

        it("mint (raspberry bush)", async () => {
            await tools.addTool(1, [], 100, 30, 1, 5, 10);
            await tools.mint(address1.address, 1, 10);
            
            let balance = await tools.balanceOf(address1.address, 1);
    
            expect(balance).eql(ethers.BigNumber.from(10));
        });
    
        it("mint batch without existed tools", async () => {
            await expect(tools.mintBatch(address1.address, [1, 2, 3], [1, 1, 1], ethers.utils.randomBytes(10))).to.be.revertedWith("Tools: no tools");
        });

        it("mintBatch with tool ids > _toolIds", async () => {
            await tools.addTool(1, [], 100, 30, 1, 5, 10);
            await expect(tools.mintBatch(address1.address, [10, 20, 30], [1, 1, 1], ethers.utils.randomBytes(10))).to.be.revertedWith("Tools: invalid id value");
        });

        it("mintBatch to blacklist", async () => {
            await tools.addTool(1, [], 100, 30, 1, 5, 10);
            await blacklist.addToBlacklist(address1.address);
            await expect(tools.mintBatch(address1.address, [1], [1], ethers.utils.randomBytes(10))).to.be.revertedWith("Tools: user in blacklist");
        });

        it("mintBatch (raspberry bush and strawberry bush)", async () => {
            await tools.addTool(1, [], 100, 30, 1, 5, 10);
            await tools.addTool(1, [], 150, 35, 3, 10, 30);
    
            await tools.mintBatch(address1.address, [1, 2], [1, 1], ethers.utils.randomBytes(10));
    
            let balance = [];
            balance.push(await tools.balanceOf(address1.address, 1));
            balance.push(await tools.balanceOf(address1.address, 2));
    
            expect(balance).eql([ethers.BigNumber.from(1), ethers.BigNumber.from(1)]);
        });
    });

    describe("Recipes Functions", async () => {
        it("create recipe", async () => {
            await tools.addTool(1, [], 100, 30, 1, 5, 10);
            await expect(tools.createRecipe(1, [0, 200, 40], [0, 0, 0, 0, 0, 0])).to.emit(tools, "CreateRecipe").withArgs(ethers.BigNumber.from(1));
        });

        it("create recipe with invalid tool types amount", async () => {
            await expect(tools.createRecipe(1, [0, 200, 40], [0, 0, 0, 0, 0, 0])).to.be.revertedWith("Tools: invalid toolTypes value");
        });

        it("create recipe with invalid resource amount", async () => {
            await tools.addTool(1, [], 100, 30, 1, 5, 10);
            await expect(tools.createRecipe(1, [200, 40], [0, 0, 0, 0, 0, 0])).to.be.revertedWith("Tools: invalid array size");
        });

        it("create recipe with invalid artifacts amount", async () => {
            await tools.addTool(1, [], 100, 30, 1, 5, 10);
            await expect(tools.createRecipe(1, [0, 200, 40], [0, 0, 0, 0, 0])).to.be.revertedWith("Tools: invalid array size");
        });

        it("get recipe", async () => {
            await tools.addTool(1, [], 100, 30, 1, 5, 10);
            await tools.createRecipe(1, [0, 200, 40], [0, 0, 0, 0, 0, 0]);
            let {toolType, resourcesAmount, artifactsAmount} = await tools.getRecipe(ethers.BigNumber.from(1));
            expect(toolType).eql(ethers.BigNumber.from(1));
            expect(resourcesAmount).eql([ethers.BigNumber.from(0), ethers.BigNumber.from(200), ethers.BigNumber.from(40)]);
            expect(artifactsAmount).eql([ethers.BigNumber.from(0), ethers.BigNumber.from(0), ethers.BigNumber.from(0), ethers.BigNumber.from(0), ethers.BigNumber.from(0), ethers.BigNumber.from(0)]);
        });

        it("craft", async () => {
            await tree.mint(address1.address, 2300);
            await gold.mint(address1.address, 400);

            await tree.connect(address1).approve(tools.address, 200);
            await gold.connect(address1).approve(tools.address, 40);

            await tools.addTool(1, [], 100, 30, 1, 5, 10);
            await tools.createRecipe(1, [0, 200, 40], [0, 0, 0, 0, 0, 0]);
            
            await tools.connect(address1).craft(1);

            let balance = await tools.balanceOf(address1.address, 1);
            expect(balance).eql(ethers.BigNumber.from(1));
        });

        it("craft", async () => {
            await tree.mint(address1.address, 23000);
            await gold.mint(address1.address, 40000);
            await artifacts.mint(1, address1.address, 1, ethers.utils.randomBytes(10));
        
            await tree.connect(address1).approve(tools.address, 5400);
            await gold.connect(address1).approve(tools.address, 1080);

            await artifacts.connect(address1).setApprovalForAll(tools.address, true);
            
            await tools.addTool(1, [0, 0, 0, 1, 0, 0], 400, 50, 40, 20, 300);
            await tools.createRecipe(1, [0, 5400, 1080], [1, 0, 0, 0, 0, 0]);
            
            await tools.connect(address1).craft(1);

            let balance = await tools.balanceOf(address1.address, 1);
            expect(balance).eql(ethers.BigNumber.from(1));
        });
    });

    describe("Repair functions", async () => {
        it("repair tool with 100% strength", async () => {
            await gold.mint(address1.address, 400);
            await gold.connect(address1).approve(tools.address, 40);

            await tools.addTool(1, [], 100, 30, 1, 5, 10);
            await tools.mint(address1.address, 1, 10);

            await expect(tools.connect(address1).repairTool(1, 5)).to.be.revertedWith("Tools: the tool is already strong enough");
        });

        it("repair tool after minig", async () => {
            console.log("berry addr: ", berry.address);
            await berry.mint(address1.address, 400);
            await gold.mint(address1.address, 400);

            await berry.connect(address1).approve(mining.address, 400);
            await gold.connect(address1).approve(tools.address, 40);

            await tools.addTool(1, [], 100, 30, 1, 5, 10);
            await tools.mint(address1.address, 1, 1);

            await tools.connect(address1).setApprovalForAll(mining.address, true);

            await mining.connect(address1).startMining(1);

            await network.provider.send("evm_increaseTime", [3600]);
            await network.provider.send("evm_mine");
            
            await mining.connect(address1).endMining(1);

            let strenghBefore = await tools.connect(address1).getStrength(1);

            await tools.connect(address1).repairTool(1, 1);

            let strenghAfter = await tools.connect(address1).getStrength(1);

            expect(strenghAfter).eql(strenghBefore.add(ethers.BigNumber.from(1)));
        });

        it("repair tool more than 100%", async () => {
            console.log("berry addr: ", berry.address);
            await berry.mint(address1.address, 400);
            await gold.mint(address1.address, 400);

            await berry.connect(address1).approve(mining.address, 400);
            await gold.connect(address1).approve(tools.address, 40);

            await tools.addTool(1, [], 100, 30, 1, 5, 10);
            await tools.mint(address1.address, 1, 1);

            await tools.connect(address1).setApprovalForAll(mining.address, true);

            await mining.connect(address1).startMining(1);

            await network.provider.send("evm_increaseTime", [3600]);
            await network.provider.send("evm_mine");
            
            await mining.connect(address1).endMining(1);

            await expect(tools.connect(address1).repairTool(1, 10)).to.be.revertedWith("Tools: the tool is already strong enough");
        });
    });

    describe("URI", async () => {
        it("get token uri", async () => {
            await tree.mint(address1.address, 2300);
            await gold.mint(address1.address, 400);

            await tree.connect(address1).approve(tools.address, 200);
            await gold.connect(address1).approve(tools.address, 40);

            await tools.addTool(1, [], 100, 30, 1, 5, 10);
            await tools.createRecipe(1, [0, 200, 40], [0, 0, 0, 0, 0, 0]);
            
            await tools.connect(address1).craft(1);

            let URI = await tools.uri(1);
            expect(URI).eql(BASE_URI+1+".json");
        });
    });
});