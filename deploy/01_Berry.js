module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log, get } = deployments;
    const { deployer } = await getNamedAccounts();

    const PANCAKE_ROUTER_ADDRESS = process.env.PANCAKE_ROUTER_ADDRESS;
    const gem = await get("Gem");
    const deployResult = await deploy("Berry", {
      from: deployer,
      contract: "PocMon",
          args: [
              PANCAKE_ROUTER_ADDRESS,
              gem.address,
              deployer,
              deployer
          ]
    });
    if (deployResult.newlyDeployed) {
        log(`Berry deployed at ${deployResult.address}`);
    }
};
