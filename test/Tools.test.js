const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("Tools tests", async () => {
    let Tools;
    let Blacklist;
    let Berry;
    let Tree;
    let Gold;

    let tools;
    let blacklist;
    let berry;
    let tree;
    let gold;

    const BASE_URI = "ipfs://testdir/";

    beforeEach(async () => {
        Berry = await ethers.getContractFactory("Resource");
        Tree = await ethers.getContractFactory("Resource");
        Gold = await ethers.getContractFactory("Resource");

        berry = await Berry.deploy();
        tree = await Tree.deploy();
        gold = await Gold.deploy();

        Blacklist = await ethers.getContractFactory("BlackList");
        blacklist = await Blacklist.deploy();
        blacklist.deployed();

        Tools = await ethers.getContractFactory("Tools");
        tools = await upgrades.deployProxy(Tools, [blacklist.address, berry.address, tree.address, gold.address, BASE_URI]);

        [owner, address1, address2] = await ethers.getSigners();
    });

    it("add tool (raspberry bush)", async () => {
        await expect(tools.addTool(1, [], 100, 30, 1, 5, 10)).to.emit(tools, "AddTool").withArgs(ethers.BigNumber.from(1));
    });

    describe("mint", async () => {
        it("mint (raspberry bush)", async () => {
            await tools.addTool(1, [], 100, 30, 1, 5, 10);
            await tools.mint(address1.address, 1, 10);
            
            let balance = await tools.balanceOf(address1.address, 1);
    
            expect(balance).eql(ethers.BigNumber.from(10));
        });
    
        it("mintBatch (raspberry bush and strawberry bush)", async () => {
            await tools.addTool(1, [], 100, 30, 1, 5, 10);
            await tools.addTool(1, [], 150, 35, 3, 10, 30);
    
            await tools.mintBatch(address1.address, [1, 2], [10, 10], ethers.utils.randomBytes(10));
    
            let balance = [];
            balance.push(await tools.balanceOf(address1.address, 1));
            balance.push(await tools.balanceOf(address1.address, 2));
    
            expect(balance).eql([ethers.BigNumber.from(10), ethers.BigNumber.from(10)]);
        });
    });
    
});