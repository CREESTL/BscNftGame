require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  gasReporter: {
    enabled: process.env.REPORT_GAS ? true : false,
  },
  networks: {
    mainnet: {
      url: process.env.MAINNET_URL || '',
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : []
    },
    testnet: {
      url: process.env.TESTNET_URL || '',
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : []
    }
  },
  etherscan: {
    apiKey: {
      testnet: ""
    }
  }
};
