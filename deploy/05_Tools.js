module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log, get } = deployments;
  const { deployer } = await getNamedAccounts();

  const BASE_URI = process.env.BASE_URI;
  const blacklist = await get("BlackList");
  const berry = await get("Berry");
  const tree = await get("Tree");
  const gold = await get("Gold");

    //TODO: 
console.log("Berry address is: ", berry.address)
console.log("Tree address is: ", tree.address)
console.log("Gold address is: ", gold.address)

  const deployResult = await deploy("Tools", {
    from: deployer,
    proxy: {
      proxyContract: "OpenZeppelinTransparentProxy",
      owner: deployer,
      execute: {
        init: {
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
    },
    log: true
  });
  if (deployResult.newlyDeployed) {
    log(`Tools deployed at ${deployResult.address}`);
  }
};

module.exports.tags = ["Tools"];
