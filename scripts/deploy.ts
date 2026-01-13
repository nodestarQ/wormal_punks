import { ethers } from "hardhat";

/**
 * Deploy CypherWorms with pre-deployed libraries
 * 
 * Usage:
 * PAYMENT_RECIPIENT=0x... \
 * DISPLAY_ADDRESS=0x... \
 * PREREVEAL_ADDRESS=0x... \
 * SPECIAL_ADDRESS=0x... \
 * npx hardhat run scripts/deploy.ts --network sepolia
 */

async function main() {
  console.log("🚀 CypherWorms Deployment Script");
  console.log("=" .repeat(50));

  // Get deployment parameters from environment
  const paymentRecipient = process.env.PAYMENT_RECIPIENT;
  const displayAddress = process.env.DISPLAY_ADDRESS;
  const preRevealAddress = process.env.PREREVEAL_ADDRESS;
  const specialAddress = process.env.SPECIAL_ADDRESS;
  const specialEndAddress = process.env.SPECIALEND_ADDRESS;

  if (!paymentRecipient || paymentRecipient === "0x0000000000000000000000000000000000000000") {
    console.error("❌ Error: PAYMENT_RECIPIENT must be set to a valid address");
    console.error("   Example: PAYMENT_RECIPIENT=0x123...abc npx hardhat run scripts/deploy.ts");
    process.exit(1);
  }

  console.log("\n📋 Deployment Configuration:");
  console.log(`   Payment Recipient: ${paymentRecipient}`);
  console.log(`   Display: ${displayAddress || "Will deploy new"}`);
  console.log(`   PreReveal: ${preRevealAddress || "Will deploy new"}`);
  console.log(`   Special: ${specialAddress || "Will deploy new"}`);
  console.log(`   SpecialEnd: ${specialEndAddress || "Will deploy new"}`);

  const [deployer] = await ethers.getSigners();
  console.log(`\n🔑 Deployer Address: ${deployer.address}`);
  
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log(`💰 Deployer Balance: ${ethers.formatEther(balance)} ETH`);

  if (balance < ethers.parseEther("0.2")) {
    console.warn("⚠️  Warning: Balance may be insufficient for deployment");
  }

  console.log("\n" + "=".repeat(50));
  console.log("Starting deployment...\n");

  // Deploy or use existing Display
  let display;
  if (displayAddress) {
    console.log(`📍 Using pre-deployed Display at ${displayAddress}`);
    display = await ethers.getContractAt("Display", displayAddress);
  } else {
    console.log("📦 Deploying Display contract...");
    console.log("   (This may take a while - many library dependencies)");
    // Note: Display deployment requires all its libraries
    // For now, we'll require Display to be pre-deployed
    console.error("❌ Error: Display must be pre-deployed. Set DISPLAY_ADDRESS environment variable.");
    process.exit(1);
  }

  // Deploy or use SpecialEnd
  let specialEnd;
  if (specialEndAddress) {
    console.log(`📍 Using pre-deployed SpecialEnd at ${specialEndAddress}`);
    specialEnd = specialEndAddress;
  } else {
    console.log("📦 Deploying SpecialEnd library...");
    const SpecialEnd = await ethers.getContractFactory("SpecialEnd");
    const specialEndContract = await SpecialEnd.deploy();
    await specialEndContract.waitForDeployment();
    specialEnd = await specialEndContract.getAddress();
    console.log(`   ✅ SpecialEnd deployed to: ${specialEnd}`);
  }

  // Deploy or use PreReveal
  let preReveal;
  if (preRevealAddress) {
    console.log(`📍 Using pre-deployed PreReveal at ${preRevealAddress}`);
    preReveal = preRevealAddress;
  } else {
    console.log("📦 Deploying PreReveal library...");
    const PreReveal = await ethers.getContractFactory("PreReveal");
    const preRevealContract = await PreReveal.deploy();
    await preRevealContract.waitForDeployment();
    preReveal = await preRevealContract.getAddress();
    console.log(`   ✅ PreReveal deployed to: ${preReveal}`);
  }

  // Deploy or use Special
  let special;
  if (specialAddress) {
    console.log(`📍 Using pre-deployed Special at ${specialAddress}`);
    special = specialAddress;
  } else {
    console.log("📦 Deploying Special library (with SpecialEnd)...");
    const Special = await ethers.getContractFactory("Special", {
      libraries: {
        SpecialEnd: specialEnd,
      },
    });
    const specialContract = await Special.deploy();
    await specialContract.waitForDeployment();
    special = await specialContract.getAddress();
    console.log(`   ✅ Special deployed to: ${special}`);
  }

  // Deploy CypherWorms
  console.log("\n📦 Deploying CypherWorms contract...");
  const CypherWorms = await ethers.getContractFactory("CypherWorms", {
    libraries: {
      PreReveal: preReveal,
      Special: special,
    },
  });

  const cypherWorms = await CypherWorms.deploy(
    displayAddress,
    paymentRecipient
  );

  await cypherWorms.waitForDeployment();
  const cypherWormsAddress = await cypherWorms.getAddress();

  console.log(`   ✅ CypherWorms deployed to: ${cypherWormsAddress}`);

  // Setup royalties
  console.log("\n📦 Setting up royalties (5%)...");
  const tx = await cypherWorms.setupRoyalties();
  await tx.wait();
  console.log("   ✅ Royalties configured");

  // Summary
  console.log("\n" + "=".repeat(50));
  console.log("🎉 DEPLOYMENT COMPLETE!");
  console.log("=".repeat(50));
  console.log("\n📋 Deployed Addresses:");
  console.log(`   CypherWorms: ${cypherWormsAddress}`);
  console.log(`   Display: ${displayAddress}`);
  console.log(`   PreReveal: ${preReveal}`);
  console.log(`   Special: ${special}`);
  console.log(`   SpecialEnd: ${specialEnd}`);
  console.log(`   Payment Recipient: ${paymentRecipient}`);

  console.log("\n📝 Save these addresses for future reference!");

  console.log("\n🔧 Next Steps:");
  console.log("   1. Verify contracts on Etherscan (if not auto-verified)");
  console.log("   2. Set transfer protection base price:");
  console.log(`      await cypherWorms.setTransferProtectionBasePrice(ethers.parseEther("0.01"))`);
  console.log("   3. Perform owner mint (750 max, one-time):");
  console.log(`      await cypherWorms.ownerMint("0xRecipient", 750)`);
  console.log("   4. Perform strategic mint (225 max, one-time):");
  console.log(`      await cypherWorms.strategicMint("0xRecipient", 225)`);
  console.log("   5. Configure SeaDrop for public minting");
  console.log("\n✅ Contract ready for use!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("\n❌ Deployment failed:");
    console.error(error);
    process.exit(1);
  });
