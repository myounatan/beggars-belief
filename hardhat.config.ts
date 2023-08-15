import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-etherscan';
import '@openzeppelin/hardhat-upgrades';

import 'dotenv/config';

// load tasks
// import './tasks';

// load .env file
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

const MNEMONIC = process.env.MNEMONIC;

const INFURA_SEPOLIA = process.env.INFURA_SEPOLIA;
const INFURA_GOERLI = process.env.INFURA_GOERLI;
const INFURA_MAINNET = process.env.INFURA_MAINNET;

const config: HardhatUserConfig = {
  // set solidity version with optimizer enabled
  solidity: {
    compilers: [
      {
        version: '0.8.18',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },

  networks: {
    mainnet: {
      chainId: 1,
      url: INFURA_MAINNET,
      accounts: {
        mnemonic: MNEMONIC,
      },
    },
    goerli: {
      chainId: 5,
      url: INFURA_GOERLI,
      accounts: {
        mnemonic: MNEMONIC,
      },
    },
    sepolia: {
      chainId: 11155111,
      url: INFURA_SEPOLIA,
      accounts: {
        mnemonic: MNEMONIC,
      },
    },
    hardhat: {
      forking: {
        url: `${INFURA_MAINNET}`, // typescript i hate and love u
        blockNumber: 16000000,
      },
      //allowUnlimitedContractSize: true,
      chainId: 31337,
    },
  },

  mocha: {
    timeout: 100000,
  },

  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};

export default config;
