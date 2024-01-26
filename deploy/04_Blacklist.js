module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log, get } = deployments;
  const { deployer } = await getNamedAccounts();

  const deployResult = await deploy("BlackList", {
    from: deployer,
    log: true
  });
  if (deployResult.newlyDeployed) {
    log(`Blacklist deployed at ${deployResult.address}`);
  }
};

module.exports.tags = ["Blacklist"];
