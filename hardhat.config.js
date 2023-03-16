require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-truffle5");
require('dotenv').config()
const { ACC_PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.12",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  //allowUnlimitedContractSize: true,

  networks: {
    hardhat: {
      forking: {
        url: `https://bsc-dataseed1.defibit.io/`,
      },
      initialBaseFeePerGas: 0,
      gasPrice: 1,
    },

    testnet: {
      url: "https://data-seed-prebsc-2-s1.binance.org:8545",
      accounts: [ACC_PRIVATE_KEY],
      gas: 21000000,
      gasPrice: 8000000000,
  },
  },

  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
