#!/bin/bash

# Flatten CypherWorms contract for Etherscan verification
# This preserves all NatSpec documentation

echo "📄 Flattening CypherWorms contract..."

npx hardhat flatten contracts/CypherWorms.sol > CypherWorms-flattened.sol

echo "✅ Flattened contract created: CypherWorms-flattened.sol"
echo ""
echo "📋 Contract Info:"
echo "   - Compiler: 0.8.17"
echo "   - Optimization: Yes (200 runs)"
echo "   - EVM Version: london"
echo "   - License: MIT"
echo ""
echo "🔗 To verify on Etherscan:"
echo "   1. Go to: https://etherscan.io/verifyContract"
echo "   2. Enter address: 0xF11A83aEAa9467ECB06Fb56828b81F6aE6d59F03"
echo "   3. Upload the flattened file: CypherWorms-flattened.sol"
echo "   4. Or use: npx hardhat verify --network mainnet 0xF11A83aEAa9467ECB06Fb56828b81F6aE6d59F03 <DISPLAY_ADDRESS> <PAYMENT_RECIPIENT>"
echo ""
echo "📝 Constructor arguments needed:"
echo "   - Display contract address"
echo "   - Payment recipient address"
