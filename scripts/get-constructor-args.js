// Get constructor arguments for Etherscan verification
// Usage: node scripts/get-constructor-args.js <displayAddress> <paymentRecipient>

const { ethers } = require("ethers");

const args = process.argv.slice(2);

if (args.length !== 2) {
  console.log("Usage: node scripts/get-constructor-args.js <displayAddress> <paymentRecipient>");
  console.log("Example: node scripts/get-constructor-args.js 0x123...abc 0x456...def");
  process.exit(1);
}

const [displayAddress, paymentRecipient] = args;

// Validate addresses
if (!ethers.isAddress(displayAddress) || !ethers.isAddress(paymentRecipient)) {
  console.error("Error: Invalid address format");
  process.exit(1);
}

console.log("🔧 Constructor Arguments for CypherWorms");
console.log("=".repeat(50));
console.log("");
console.log("Contract: CypherWorms");
console.log("Address: 0xF11A83aEAa9467ECB06Fb56828b81F6aE6d59F03");
console.log("");
console.log("Arguments:");
console.log(`  _displayContract: ${displayAddress}`);
console.log(`  _paymentRecipient: ${paymentRecipient}`);
console.log("");

// ABI encode constructor arguments
const abiCoder = ethers.AbiCoder.defaultAbiCoder();
const encoded = abiCoder.encode(
  ["address", "address"],
  [displayAddress, paymentRecipient]
);

console.log("ABI-Encoded Constructor Arguments:");
console.log("=".repeat(50));
console.log(encoded);
console.log("");
console.log("For Etherscan (remove 0x prefix):");
console.log(encoded.slice(2));
console.log("");
console.log("=".repeat(50));
console.log("");
console.log("📝 To verify on Etherscan:");
console.log("");
console.log("Method 1 - Hardhat:");
console.log(`  npx hardhat verify --network mainnet \\`);
console.log(`    0xF11A83aEAa9467ECB06Fb56828b81F6aE6d59F03 \\`);
console.log(`    "${displayAddress}" \\`);
console.log(`    "${paymentRecipient}"`);
console.log("");
console.log("Method 2 - Etherscan UI:");
console.log("  1. Go to: https://etherscan.io/verifyContract");
console.log("  2. Enter contract address and upload flattened source");
console.log("  3. Paste the ABI-encoded args above (without 0x)");
console.log("");
