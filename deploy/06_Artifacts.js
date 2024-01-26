module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log, get } = deployments;
  const { deployer } = await getNamedAccounts();

  const BASE_URI = process.env.BASE_URI;
  const blacklist = await get("BlackList");
  const tools = await get("Tools");

  const deployResult = await deploy("Artifacts", {
    from: deployer,
    proxy: {
      owner: deployer,
      proxyContract: "OpenZeppelinTransparentProxy",
      execute: {
        methodName: "initialize",
        args: [tools.address, BASE_URI, blacklist.address],
      },
    },
  });
  if (deployResult.newlyDeployed) {
    log(`Artifacts deployed at ${deployResult.address}`);
  }
};

module.exports.tags = ["Artifacts"];
