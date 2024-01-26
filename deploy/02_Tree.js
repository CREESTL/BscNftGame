module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log, get } = deployments;
  const { deployer } = await getNamedAccounts();

  // Router address is different for testnet and mainnet
  let PANCAKE_ROUTER_ADDRESS;
  if (network.name == "bsc_testnet") {
    PANCAKE_ROUTER_ADDRESS = process.env.PANCAKE_ROUTER_ADDRESS_TESTNET;
  } else if (network.name == "bsc_mainnet") {
    PANCAKE_ROUTER_ADDRESS = process.env.PANCAKE_ROUTER_ADDRESS_MAINNET;
  }
  if (PANCAKE_ROUTER_ADDRESS == "") {
    console.log("Invalid Router address!");
    process.exit(1);
  }

  const gem = await get("Gem");
  const deployResult = await deploy("Tree", {
    from: deployer,
    contract: "Tree",
    args: ["TREE", PANCAKE_ROUTER_ADDRESS, gem.address, deployer, deployer],
    log: true
  });
  if (deployResult.newlyDeployed) {
    log(`Tree deployed at ${deployResult.address}`);
  }
};

module.exports.tags = ["Tree"];
