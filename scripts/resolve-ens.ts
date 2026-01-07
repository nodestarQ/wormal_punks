import { createPublicClient, http } from "viem";
import { mainnet } from "viem/chains";
import { normalize } from "viem/ens";

/**
 * Helper script to resolve ENS names to addresses
 * 
 * Usage:
 *   npx ts-node scripts/resolve-ens.ts
 *   
 * This will output the resolved addresses for eip7503.eth and warptoad.eth
 * Copy these addresses to use in deployment parameters
 */

async function main() {
  console.log("🔍 Resolving ENS names on Ethereum mainnet...\n");

  const mainnetClient = createPublicClient({
    chain: mainnet,
    transport: http("https://eth.llamarpc.com"),
  });

  try {
    const primary = await mainnetClient.getEnsAddress({
      name: normalize("eip7503.eth"),
    });

    const secondary = await mainnetClient.getEnsAddress({
      name: normalize("warptoad.eth"),
    });

    if (!primary || !secondary) {
      throw new Error("ENS resolution returned null - names may not be registered");
    }

    console.log("✅ ENS Resolution Complete\n");
    console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    console.log("Primary Recipient (70%):  eip7503.eth");
    console.log("Address:                 ", primary);
    console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    console.log("Secondary Recipient (30%): warptoad.eth");
    console.log("Address:                  ", secondary);
    console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

    console.log("📋 Copy these addresses for deployment:\n");
    console.log(`Primary:   ${primary}`);
    console.log(`Secondary: ${secondary}\n`);

    console.log("🚀 To deploy, create a parameters file:");
    console.log(`
cat > ignition/parameters/sepolia.json << EOF
{
  "CypherWormsModule": {
    "primaryRecipient": "${primary}",
    "secondaryRecipient": "${secondary}"
  }
}
EOF
`);

    console.log("Then deploy with:");
    console.log("npx hardhat ignition deploy ignition/modules/CypherWorms.ts --network sepolia --parameters ignition/parameters/sepolia.json\n");

    return { primary, secondary };
  } catch (error) {
    console.error("❌ ENS Resolution failed!");
    console.error(error);
    console.error("\nPossible reasons:");
    console.error("- ENS names not registered");
    console.error("- Network connection issues");
    console.error("- RPC endpoint unavailable\n");
    process.exit(1);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
