require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-etherscan");
require("@nomicfoundation/hardhat-chai-matchers");
require("hardhat-tracer");
require("hardhat-contract-sizer");
require("solidity-coverage");
require("hardhat-gas-reporter");
require("hardhat-deploy");
require("@primitivefi/hardhat-dodoc");

const { BSCSCAN_API_KEY, ACC_PRIVATE_KEY } = process.env;

module.exports = {
  solidity: {
    version: "0.8.12",
    settings: {
      optimizer: {
        enabled: true,
        runs: 10,
      },
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
      forking: {
        url: "https://bscrpc.com",
        blockNumber: 31910000,
      },
    },
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    bsc_mainnet: {
      url: `https://rpc-mainnet.maticvigil.com/`,
      accounts: [ACC_PRIVATE_KEY],
      verify: {
        etherscan: {
          apiKey: BSCSCAN_API_KEY,
        },
      },
    },
    bsc_testnet: {
      url: `https://data-seed-prebsc-2-s2.binance.org:8545`,
      accounts: [ACC_PRIVATE_KEY],
      gasPrice: 20000000000,
      verify: {
        etherscan: {
          apiKey: BSCSCAN_API_KEY,
        },
      },
    },
  },
  mocha: {
    timeout: 20000000000,
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  skipFiles: ["node_modules"],
  gasReporter: {
    enabled: true,
    url: "http://localhost:8545",
  },
  dodoc: {
    exclude: ["mocks", "lin", "errors"],
    runOnCompile: false,
    freshOutput: true,
    outputDir: "./docs/contracts",
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: true,
    strict: true,
    runOnCompile: false,
  },
  etherscan: {
    apiKey: {
      bsc: BSCSCAN_API_KEY,
      bscTestnet: BSCSCAN_API_KEY,
    },
  },
  // For Hardhat-deploy
  verify: {
    etherscan: {
      apiKey: BSCSCAN_API_KEY
    },
  },
};
