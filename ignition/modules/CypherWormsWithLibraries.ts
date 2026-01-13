import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

/**
 * CypherWorms deployment module with support for pre-deployed libraries
 * 
 * This module allows you to deploy CypherWorms using already deployed libraries
 * or deploy new ones if addresses are not provided.
 * 
 * Usage:
 * 1. With pre-deployed libraries:
 *    npx hardhat ignition deploy ignition/modules/CypherWormsWithLibraries.ts --network sepolia \
 *      --parameters deployments/sepolia-params.json
 * 
 * 2. Deploy everything fresh:
 *    npx hardhat ignition deploy ignition/modules/CypherWormsWithLibraries.ts --network sepolia
 * 
 * Create a parameters file (e.g., deployments/sepolia-params.json):
 * {
 *   "CypherWormsWithLibrariesModule": {
 *     "paymentRecipient": "0x...",  // REQUIRED: Payment recipient address
 *     "displayAddress": "0x...",    // Optional: Pre-deployed Display contract
 *     "preRevealAddress": "0x...",  // Optional: Pre-deployed PreReveal library
 *     "specialAddress": "0x...",    // Optional: Pre-deployed Special library
 *     "specialEndAddress": "0x..."  // Optional: Pre-deployed SpecialEnd library
 *   }
 * }
 */
const CypherWormsWithLibrariesModule = buildModule("CypherWormsWithLibrariesModule", (m) => {
  // =============================================================================
  // PARAMETERS
  // =============================================================================
  
  // Required: Payment recipient address (can be EOA or splitter contract)
  const paymentRecipient = m.getParameter<string>(
    "paymentRecipient",
    "0x0000000000000000000000000000000000000000" // MUST be replaced
  );

  // Optional: Pre-deployed contract addresses (empty string means not deployed)
  const displayAddress = m.getParameter<string>("displayAddress", "");
  const preRevealAddress = m.getParameter<string>("preRevealAddress", "");
  const specialAddress = m.getParameter<string>("specialAddress", "");
  const specialEndAddress = m.getParameter<string>("specialEndAddress", "");

  // =============================================================================
  // DISPLAY CONTRACT
  // =============================================================================
  
  let display;
  
  if (displayAddress) {
    // Use pre-deployed Display contract
    display = m.contractAt("Display", displayAddress);
    console.log(`Using pre-deployed Display at: ${displayAddress}`);
  } else {
    // Deploy Display with all its dependencies (from Display module)
    const DisplayModule = require("./Display.js").default;
    const displayModule = m.useModule(DisplayModule);
    display = displayModule.display;
    console.log("Deploying new Display contract with all libraries");
  }

  // =============================================================================
  // SPECIAL LIBRARIES
  // =============================================================================
  
  let specialEnd, preReveal, special;

  // SpecialEnd Library
  if (specialEndAddress) {
    specialEnd = m.contractAt("SpecialEnd", specialEndAddress);
    console.log(`Using pre-deployed SpecialEnd at: ${specialEndAddress}`);
  } else {
    specialEnd = m.library("SpecialEnd", { after: [display] });
    console.log("Deploying new SpecialEnd library");
  }

  // PreReveal Library
  if (preRevealAddress) {
    preReveal = m.contractAt("PreReveal", preRevealAddress);
    console.log(`Using pre-deployed PreReveal at: ${preRevealAddress}`);
  } else {
    preReveal = m.library("PreReveal", { after: [display] });
    console.log("Deploying new PreReveal library");
  }

  // Special Library (depends on SpecialEnd)
  if (specialAddress) {
    special = m.contractAt("Special", specialAddress);
    console.log(`Using pre-deployed Special at: ${specialAddress}`);
  } else {
    special = m.library("Special", { 
      after: [specialEnd, preReveal],
      libraries: {
        SpecialEnd: specialEnd,
      },
    });
    console.log("Deploying new Special library (with SpecialEnd dependency)");
  }

  // =============================================================================
  // CYPHERWORMS CONTRACT
  // =============================================================================
  
  const cypherWorms = m.contract("CypherWorms", [
    display,
    paymentRecipient,
  ], {
    after: [special],
    libraries: {
      PreReveal: preReveal,
      Special: special,
    },
  });

  // =============================================================================
  // POST-DEPLOYMENT SETUP
  // =============================================================================
  
  // Setup royalties (5% to contract, which forwards to paymentRecipient)
  m.call(cypherWorms, "setupRoyalties", []);

  // =============================================================================
  // RETURN ALL DEPLOYED/USED CONTRACTS
  // =============================================================================
  
  return { 
    cypherWorms, 
    display, 
    preReveal, 
    special, 
    specialEnd,
  };
});

export default CypherWormsWithLibrariesModule;
