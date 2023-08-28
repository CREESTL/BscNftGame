module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log, get } = deployments;
  const { deployer } = await getNamedAccounts();

  const BASE_URI = process.env.BASE_URI;
  const blacklist = await get("BlackList");
  const berry = await get("Berry");
  const tree = await get("Tree");
  const gold = await get("Gold");

  const deployResult = await deploy("Tools", {
    from: deployer,
    proxy: {
      proxyContract: "OpenZeppelinTransparentProxy",
      execute: {
        methodName: "initialize",
        args: [
          blacklist.address,
          berry.address,
          tree.address,
          gold.address,
          BASE_URI,
        ],
      },
    },
  });
  if (deployResult.newlyDeployed) {
    log(`Tools deployed at ${deployResult.address}`);
  }
};
