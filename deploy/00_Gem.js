module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log, get } = deployments;
  const { deployer } = await getNamedAccounts();

  const deployResult = await deploy("Gem", {
    from: deployer,
    args: [1],
    log: true
  });
  if (deployResult.newlyDeployed) {
    log(`Gem deployed at ${deployResult.address}`);
  }
};

module.exports.tags = ["Gem"];
