import hardhatToolboxViemPlugin from "@nomicfoundation/hardhat-toolbox-viem";
import { configVariable, defineConfig } from "hardhat/config";
import path from "path";

export default defineConfig({
  plugins: [hardhatToolboxViemPlugin],
  paths: {
    sources: "./contracts",
  },
  verify: {
    etherscan: {
      apiKey: process.env.ETHERSCAN_API_KEY!,
    },
  },
  solidity: {
    profiles: {
      default: {
        compilers: [
          {
            version: "0.8.17",
            settings: {
              optimizer: {
                enabled: true,
                runs: 200,
              },
              remappings: [
                "solmate/=node_modules/solmate/src/",
                "ERC721A/=node_modules/erc721a/contracts/",
              ],
            },
          },
          {
            version: "0.8.28",
            settings: {
              remappings: [
                "solmate/=node_modules/solmate/src/",
                "ERC721A/=node_modules/erc721a/contracts/",
              ],
            },
          },
        ],
      },
      production: {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
          remappings: [
            "solmate/=node_modules/solmate/src/",
            "ERC721A/=node_modules/erc721a/contracts/",
          ],
        },
      },
    },
  },
  networks: {
    hardhatMainnet: {
      type: "edr-simulated",
      chainType: "l1",
    },
    hardhatOp: {
      type: "edr-simulated",
      chainType: "op",
    },
    sepolia: {
      type: "http",
      chainType: "l1",
      url: process.env.SEPOLIA_RPC_URL!,
      accounts: [process.env.SEPOLIA_PRIVATE_KEY!],
    },
  },
});
