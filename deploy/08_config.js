const delay = require("delay");

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log, get } = deployments;
    const { deployer } = await getNamedAccounts();

    const mining = await get("Mining");
    const artifacts = await get("Artifacts");
    const tools = await get("Tools");
    const toolsProxy = await ethers.getContractAt("Tools", tools.address)
    const artifactsProxy = await ethers.getContractAt("Artifacts", artifacts.address)

    await toolsProxy.setArtifactsAddress(artifacts.address);
    await toolsProxy.setMiningAddress(mining.address);

    await delay(90000);
    // Add first 6 artifacts
    for (i = 0; i < 6; i++) {
        await artifactsProxy.addNewArtifact();
    }
    log("Config finished");
};
module.exports.tags = ['Config'];
