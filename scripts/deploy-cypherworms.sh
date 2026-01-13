#!/bin/bash

# CypherWorms Deployment Script
# Usage: ./scripts/deploy-cypherworms.sh <network> <payment-recipient>
# Example: ./scripts/deploy-cypherworms.sh sepolia 0x123...abc

set -e

NETWORK=$1
PAYMENT_RECIPIENT=$2

if [ -z "$NETWORK" ] || [ -z "$PAYMENT_RECIPIENT" ]; then
  echo "Usage: $0 <network> <payment-recipient>"
  echo "Example: $0 sepolia 0x123...abc"
  echo ""
  echo "Networks: sepolia, mainnet"
  exit 1
fi

echo "🚀 Deploying CypherWorms to $NETWORK"
echo "💰 Payment Recipient: $PAYMENT_RECIPIENT"
echo ""

# Create parameters file
PARAMS_FILE="ignition/parameters/${NETWORK}-deploy.json"
cat > $PARAMS_FILE << EOF
{
  "CypherWormsWithLibrariesModule": {
    "paymentRecipient": "$PAYMENT_RECIPIENT"
  }
}
EOF

echo "✅ Created parameters file: $PARAMS_FILE"
echo ""

# Confirm with user
echo "⚠️  This will deploy to $NETWORK network."
echo "⚠️  Make sure you have:"
echo "    - Sufficient ETH for gas (~6M gas for fresh deploy)"
echo "    - Private key in .env file"
echo "    - RPC URL configured for $NETWORK"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Deployment cancelled"
  exit 1
fi

echo ""
echo "📦 Compiling contracts..."
npx hardhat compile

echo ""
echo "🚀 Deploying to $NETWORK..."
npx hardhat ignition deploy ignition/modules/CypherWormsWithLibraries.ts \
  --network $NETWORK \
  --parameters $PARAMS_FILE \
  --verify

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📋 Next steps:"
echo "  1. Check deployed addresses in: ignition/deployments/chain-*/deployed_addresses.json"
echo "  2. Configure transfer protection: cypherWorms.setTransferProtectionBasePrice()"
echo "  3. Perform reserve mints: cypherWorms.ownerMint() and strategicMint()"
echo "  4. Setup SeaDrop for public mint"
echo "  5. Test payment flow: mint → protect → transfer → withdraw"
echo ""
echo "💡 To update payment recipient later:"
echo "  await cypherWorms.updatePaymentRecipient('0xNewAddress')"
