module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log, get } = deployments;
  const { deployer } = await getNamedAccounts();

  const blacklist = await get("BlackList");
  const artifacts = await get("Artifacts");
  const tools = await get("Tools");

  const deployResult = await deploy("Mining", {
    from: deployer,
    proxy: {
      proxyContract: "OpenZeppelinTransparentProxy",
      execute: {
        methodName: "initialize",
        args: [blacklist.address, tools.address],
      },
    },
  });
  if (deployResult.newlyDeployed) {
    log(`Mining deployed at ${deployResult.address}`);
  }
};