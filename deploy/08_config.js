const delay = require("delay");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log, get } = deployments;
  const { deployer } = await getNamedAccounts();

  const mining = await get("Mining");
  const artifacts = await get("Artifacts");
  const tools = await get("Tools");
  const toolsProxy = await ethers.getContractAt("Tools", tools.address);
  const artifactsProxy = await ethers.getContractAt(
    "Artifacts",
    artifacts.address,
  );

  const berryLocal = await get("Berry");
  const treeLocal = await get("Tree");
  const goldLocal = await get("Gold");
  const berry = await ethers.getContractAt("Berry", berryLocal.address);
  const tree = await ethers.getContractAt("Tree", treeLocal.address);
  const gold = await ethers.getContractAt("Gold", goldLocal.address);
   
  await toolsProxy.setArtifactsAddress(artifacts.address);
  await toolsProxy.setMiningAddress(mining.address);

  console.log("[CONFIG] Transferring 99% of each resource to Mining");
  let totalSupply = await berry.totalSupply();
  let transferAmount = totalSupply.mul(9900).div(10000);

  await berry.transfer(mining.address, transferAmount);
  await tree.transfer(mining.address, transferAmount);
  await gold.transfer(mining.address, transferAmount);

  log("Config finished");
};
module.exports.tags = ["Config"];
