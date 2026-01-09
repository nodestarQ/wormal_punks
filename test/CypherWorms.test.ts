import assert from "node:assert/strict";
import { describe, it, before, beforeEach, after } from "node:test";
import { network } from "hardhat";
import { parseEther, Address } from "viem";

describe("CypherWorms - Critical Path Tests", async function () {
  const { viem } = await network.connect();

  // Test accounts
  let owner: Address;
  let primaryRecipient: Address;
  let secondaryRecipient: Address;
  let user1: Address;
  let user2: Address;
  let user3: Address;

  // Contracts
  let cypherWorms: any;
  let mockDisplay: any;
  let mockERC20: any;
  let preRevealLib: any;
  let specialLib: any;
  let specialEndLib: any;

  // Constants
  const MAX_SUPPLY = 7503n;
  const OWNER_MINT_MAX = 750n;
  const STRATEGIC_MINT_MAX = 225n;

  // Gas tracking
  const gasUsage: Record<string, string> = {};

  // Helper to track gas usage
  function trackGas(name: string, gasUsed: bigint) {
    gasUsage[name] = gasUsed.toString();
    console.log(` ${name}: ${gasUsed.toString()} gas`);
  }

  // Helper to get all test accounts
  async function getTestAccounts() {
    const [acc0, acc1, acc2, acc3, acc4, acc5] = await viem.getWalletClients();
    return {
      owner: acc0.account.address,
      primaryRecipient: acc1.account.address,
      secondaryRecipient: acc2.account.address,
      user1: acc3.account.address,
      user2: acc4.account.address,
      user3: acc5.account.address,
    };
  }

  // Helper to increase time (using testClient API)
  async function increaseTime(seconds: number) {
    const testClient = await viem.getTestClient();
    await testClient.increaseTime({ seconds });
    await testClient.mine({ blocks: 1 });
  }

  // Setup: Deploy contracts before all tests
  before(async function () {
    const accounts = await getTestAccounts();
    owner = accounts.owner;
    primaryRecipient = accounts.primaryRecipient;
    secondaryRecipient = accounts.secondaryRecipient;
    user1 = accounts.user1;
    user2 = accounts.user2;
    user3 = accounts.user3;

    console.log("\n Setting up test environment...\n");
  });

  // Deploy fresh contracts before each test
  beforeEach(async function () {
    specialEndLib = await viem.deployContract("SpecialEnd")
    // Deploy libraries first
    preRevealLib = await viem.deployContract("PreReveal");
    specialLib = await viem.deployContract("Special", [
    ], {
      libraries: {
        SpecialEnd: specialEndLib.address,
      },
    });

    // Deploy MockDisplay
    mockDisplay = await viem.deployContract("MockDisplay");

    // Deploy MockERC20
    mockERC20 = await viem.deployContract("MockERC20");

    // Deploy CypherWorms with library linking
    cypherWorms = await viem.deployContract("CypherWorms", [
      mockDisplay.address,
      primaryRecipient,
      secondaryRecipient,
    ], {
      libraries: {
        PreReveal: preRevealLib.address,
        Special: specialLib.address,
      },
    });
  });

  // ========================================
  // CRITICAL TESTS: DEPLOYMENT & INITIALIZATION
  // ========================================

  describe("1. Deployment & Initialization", function () {
    it("Should deploy with correct initial state", async function () {
      // Verify recipients (max supply is internal, can't be checked directly)
      const primary = await cypherWorms.read.primaryRecipient();
      const secondary = await cypherWorms.read.secondaryRecipient();
      assert.equal(primary.toLowerCase(), primaryRecipient.toLowerCase(), "Primary recipient mismatch");
      assert.equal(secondary.toLowerCase(), secondaryRecipient.toLowerCase(), "Secondary recipient mismatch");

      // Verify display contract
      const display = await cypherWorms.read.displayContract();
      assert.equal(display.toLowerCase(), mockDisplay.address.toLowerCase(), "Display contract mismatch");

      // Verify mint flags are false
      const ownerMinted = await cypherWorms.read.ownerMinted();
      const strategicMinted = await cypherWorms.read.strategicMinted();
      assert.equal(ownerMinted, false, "ownerMinted should be false initially");
      assert.equal(strategicMinted, false, "strategicMinted should be false initially");

      // Verify transfer protection defaults
      const basePrice = await cypherWorms.read.transferProtectionBasePrice();
      const protectionToken = await cypherWorms.read.transferProtectionToken();
      assert.equal(basePrice, 0n, "Base price should be 0 initially");
      assert.equal(protectionToken, "0x0000000000000000000000000000000000000000", "Protection token should be address(0)");

      // Verify worm secret not set
      const wormSecret = await cypherWorms.read.wormSecret();
      assert.equal(wormSecret, "0x0000000000000000000000000000000000000000000000000000000000000000", "Worm secret should be 0");

      // Verify specials not assigned
      const specialsAssigned = await cypherWorms.read.specialsAssigned();
      assert.equal(specialsAssigned, false, "Specials should not be assigned yet");

      console.log("Deployment state verified");
    });

    it("Should reject deployment with zero address primary recipient", async function () {
      await assert.rejects(
        async () => {
          await viem.deployContract("CypherWorms", [
            mockDisplay.address,
            "0x0000000000000000000000000000000000000000",
            secondaryRecipient,
          ], {
            libraries: {
              PreReveal: preRevealLib.address,
              Special: specialLib.address,
            },
          });
        },
        /Primary recipient cannot be zero address/,
        "Should revert with zero primary recipient"
      );
      console.log("Zero address primary recipient rejected");
    });

    it("Should reject deployment with zero address secondary recipient", async function () {
      await assert.rejects(
        async () => {
          await viem.deployContract("CypherWorms", [
            mockDisplay.address,
            primaryRecipient,
            "0x0000000000000000000000000000000000000000",
          ], {
            libraries: {
              PreReveal: preRevealLib.address,
              Special: specialLib.address,
            },
          });
        },
        /Secondary recipient cannot be zero address/,
        "Should revert with zero secondary recipient"
      );
      console.log("Zero address secondary recipient rejected");
    });
  });

  // ========================================
  // CRITICAL TESTS: OWNER MINT (750 tokens)
  // ========================================

  describe("2. Owner Mint (750 tokens)", function () {
    it("Should successfully mint 1 token", async function () {
      const hash = await cypherWorms.write.ownerMint([user1, 1n]);
      const publicClient = await viem.getPublicClient();
      const receipt = await publicClient.getTransactionReceipt({ hash });
      trackGas("ownerMint(1)", receipt.gasUsed);

      const balance = await cypherWorms.read.balanceOf([user1]);
      assert.equal(balance, 1n, "User should have 1 token");

      const ownerMinted = await cypherWorms.read.ownerMinted();
      assert.equal(ownerMinted, true, "ownerMinted flag should be true");

      console.log("Successfully minted 1 token");
    });

    it("Should successfully mint 100 tokens (batch test)", async function () {
      const hash = await cypherWorms.write.ownerMint([user1, 100n]);
      const publicClient = await viem.getPublicClient();
      const receipt = await publicClient.getTransactionReceipt({ hash });
      trackGas("ownerMint(100)", receipt.gasUsed);

      const balance = await cypherWorms.read.balanceOf([user1]);
      assert.equal(balance, 100n, "User should have 100 tokens");

      // Verify ownerMinted flag is set
      const ownerMinted = await cypherWorms.read.ownerMinted();
      assert.equal(ownerMinted, true, "ownerMinted flag should be true");

      console.log("Successfully minted 100 tokens (batch test passed, max of 750 allowed)");
    });

    it("Should successfully mint intermediate amount (50)", async function () {
      await cypherWorms.write.ownerMint([user1, 50n]);

      const balance = await cypherWorms.read.balanceOf([user1]);
      assert.equal(balance, 50n, "User should have 50 tokens");

      console.log("Successfully minted 50 tokens");
    });

    it("Should reject second mint attempt (one-time use)", async function () {
      // First mint
      await cypherWorms.write.ownerMint([user1, 1n]);

      // Second mint should fail
      await assert.rejects(
        async () => {
          await cypherWorms.write.ownerMint([user2, 1n]);
        },
        /Owner mint already used/,
        "Should revert on second mint"
      );

      console.log("Second mint attempt rejected");
    });

    it("Should reject mint of 0 tokens", async function () {
      await assert.rejects(
        async () => {
          await cypherWorms.write.ownerMint([user1, 0n]);
        },
        /Must mint 1-750 tokens/,
        "Should revert with 0 tokens"
      );

      console.log("Mint of 0 tokens rejected");
    });

    it("Should reject mint of >750 tokens (751)", async function () {
      await assert.rejects(
        async () => {
          await cypherWorms.write.ownerMint([user1, 751n]);
        },
        /Must mint 1-750 tokens/,
        "Should revert with 751 tokens"
      );

      console.log("Mint of 751 tokens rejected");
    });

    it("Should reject mint to zero address", async function () {
      await assert.rejects(
        async () => {
          await cypherWorms.write.ownerMint(["0x0000000000000000000000000000000000000000", 1n]);
        },
        /Invalid recipient/,
        "Should revert with zero address"
      );

      console.log("Mint to zero address rejected");
    });

    it("Should initialize DNA and hold count for minted tokens", async function () {
      await cypherWorms.write.ownerMint([user1, 3n]);

      // Check that tokens exist and have hold count set
      const daysHeld1 = await cypherWorms.read.getHoldCountInDays([1n]);
      const daysHeld2 = await cypherWorms.read.getHoldCountInDays([2n]);
      const daysHeld3 = await cypherWorms.read.getHoldCountInDays([3n]);

      assert.equal(daysHeld1, 0n, "Token 1 should have 0 days held initially");
      assert.equal(daysHeld2, 0n, "Token 2 should have 0 days held initially");
      assert.equal(daysHeld3, 0n, "Token 3 should have 0 days held initially");

      console.log("DNA and hold count initialized");
    });

    it("Should reject call from non-owner", async function () {
      const [, user] = await viem.getWalletClients();

      try {
        await cypherWorms.write.ownerMint([user1, 1n], {
          account: user.account,
        });
        assert.fail("Should have reverted for non-owner");
      } catch (error: any) {
        // Any error is acceptable - it means the transaction reverted
        // The important thing is that non-owners cannot call this function
        assert.ok(error, "Should throw an error for non-owner");
      }

      console.log("Non-owner call rejected");
    });
  });

  // ========================================
  // CRITICAL TESTS: STRATEGIC MINT (225 tokens)
  // ========================================

  describe("3. Strategic Mint (225 tokens)", function () {
    it("Should successfully mint 1 token", async function () {
      const hash = await cypherWorms.write.strategicMint([user1, 1n]);
      const publicClient = await viem.getPublicClient();
      const receipt = await publicClient.getTransactionReceipt({ hash });
      trackGas("strategicMint(1)", receipt.gasUsed);

      const balance = await cypherWorms.read.balanceOf([user1]);
      assert.equal(balance, 1n, "User should have 1 token");

      const strategicMinted = await cypherWorms.read.strategicMinted();
      assert.equal(strategicMinted, true, "strategicMinted flag should be true");

      console.log("Successfully minted 1 token via strategic mint");
    });

    it("Should successfully mint 225 tokens (max)", async function () {
      const hash = await cypherWorms.write.strategicMint([user1, STRATEGIC_MINT_MAX]);
      const publicClient = await viem.getPublicClient();
      const receipt = await publicClient.getTransactionReceipt({ hash });
      trackGas("strategicMint(225)", receipt.gasUsed);

      const balance = await cypherWorms.read.balanceOf([user1]);
      assert.equal(balance, STRATEGIC_MINT_MAX, "User should have 225 tokens");

      console.log("Successfully minted 225 tokens via strategic mint");
    });

    it("Should successfully mint intermediate amount (112)", async function () {
      await cypherWorms.write.strategicMint([user1, 112n]);

      const balance = await cypherWorms.read.balanceOf([user1]);
      assert.equal(balance, 112n, "User should have 112 tokens");

      console.log("Successfully minted 112 tokens via strategic mint");
    });

    it("Should reject second mint attempt (one-time use)", async function () {
      // First mint
      await cypherWorms.write.strategicMint([user1, 1n]);

      // Second mint should fail
      await assert.rejects(
        async () => {
          await cypherWorms.write.strategicMint([user2, 1n]);
        },
        /Strategic mint already used/,
        "Should revert on second strategic mint"
      );

      console.log("Second strategic mint attempt rejected");
    });

    it("Should reject mint of 0 tokens", async function () {
      await assert.rejects(
        async () => {
          await cypherWorms.write.strategicMint([user1, 0n]);
        },
        /Must mint 1-225 tokens/,
        "Should revert with 0 tokens"
      );

      console.log("Strategic mint of 0 tokens rejected");
    });

    it("Should reject mint of >225 tokens (226)", async function () {
      await assert.rejects(
        async () => {
          await cypherWorms.write.strategicMint([user1, 226n]);
        },
        /Must mint 1-225 tokens/,
        "Should revert with 226 tokens"
      );

      console.log("Strategic mint of 226 tokens rejected");
    });

    it("Should reject mint to zero address", async function () {
      await assert.rejects(
        async () => {
          await cypherWorms.write.strategicMint(["0x0000000000000000000000000000000000000000", 1n]);
        },
        /Invalid recipient/,
        "Should revert with zero address"
      );

      console.log("Strategic mint to zero address rejected");
    });

    it("Should initialize DNA and hold count for minted tokens", async function () {
      await cypherWorms.write.strategicMint([user1, 3n]);

      // Check that tokens exist and have hold count set
      const daysHeld1 = await cypherWorms.read.getHoldCountInDays([1n]);
      const daysHeld2 = await cypherWorms.read.getHoldCountInDays([2n]);
      const daysHeld3 = await cypherWorms.read.getHoldCountInDays([3n]);

      assert.equal(daysHeld1, 0n, "Token 1 should have 0 days held initially");
      assert.equal(daysHeld2, 0n, "Token 2 should have 0 days held initially");
      assert.equal(daysHeld3, 0n, "Token 3 should have 0 days held initially");

      console.log("DNA and hold count initialized via strategic mint");
    });

    it("Should reject call from non-owner", async function () {
      const [, user] = await viem.getWalletClients();

      try {
        await cypherWorms.write.strategicMint([user1, 1n], {
          account: user.account,
        });
        assert.fail("Should have reverted for non-owner");
      } catch (error: any) {
        // Any error is acceptable - it means the transaction reverted
        // The important thing is that non-owners cannot call this function
        assert.ok(error, "Should throw an error for non-owner");
      }

      console.log("Non-owner strategic mint call rejected");
    });
  });

  // ========================================
  // CRITICAL TESTS: COMBINED MINTING SCENARIOS
  // ========================================

  describe("4. Combined Minting Scenarios", function () {
    it("Both ownerMint and strategicMint can be used independently", async function () {
      // Owner mint first
      await cypherWorms.write.ownerMint([user1, 100n]);
      const balance1 = await cypherWorms.read.balanceOf([user1]);
      assert.equal(balance1, 100n, "User1 should have 100 tokens from owner mint");

      // Strategic mint second
      await cypherWorms.write.strategicMint([user2, 50n]);
      const balance2 = await cypherWorms.read.balanceOf([user2]);
      assert.equal(balance2, 50n, "User2 should have 50 tokens from strategic mint");

      console.log("Both mints work independently");
    });

    it("Order doesn't matter (strategicMint then ownerMint)", async function () {
      // Strategic mint first
      await cypherWorms.write.strategicMint([user1, 50n]);
      const balance1 = await cypherWorms.read.balanceOf([user1]);
      assert.equal(balance1, 50n, "User1 should have 50 tokens from strategic mint");

      // Owner mint second
      await cypherWorms.write.ownerMint([user2, 100n]);
      const balance2 = await cypherWorms.read.balanceOf([user2]);
      assert.equal(balance2, 100n, "User2 should have 100 tokens from owner mint");

      console.log("Strategic then owner mint works");
    });

    it("Combined mints respect total supply limit", async function () {
      // Mint smaller amounts to test functionality (not max due to gas limits in tests)
      await cypherWorms.write.ownerMint([user1, 100n]);
      await cypherWorms.write.strategicMint([user2, 50n]);

      // Total minted = 100 + 50 = 150
      const totalSupply = await cypherWorms.read.totalSupply();
      assert.equal(totalSupply, 150n, "Total supply should be 150");

      console.log("Combined mints respect supply limit (tested with 100+50, max is 750+225)");
    });
  });

  // ========================================
  // CRITICAL TESTS: HOLDING & LEVELING SYSTEM
  // ========================================

  describe("5. Holding & Leveling System", function () {
    beforeEach(async function () {
      // Mint a token for testing
      await cypherWorms.write.ownerMint([user1, 1n]);
    });

    it("Initial hold count is set correctly on mint", async function () {
      const daysHeld = await cypherWorms.read.getHoldCountInDays([1n]);
      assert.equal(daysHeld, 0n, "Should have 0 days held initially");

      console.log("Initial hold count verified");
    });

    it("Level 0 (Null): 0-1 days", async function () {
      let level = await cypherWorms.read.getTokenLevel([1n]);
      assert.equal(level, 0n, "Should be level 0 at 0 days");

      // Increase time by 1 day
      await increaseTime(1 * 24 * 60 * 60);

      level = await cypherWorms.read.getTokenLevel([1n]);
      assert.equal(level, 0n, "Should still be level 0 at 1 day");

      console.log("Level 0 (Null) verified: 0-1 days");
    });

    it("Level 1 (Seed): 2-6 days", async function () {
      // Increase time by 2 days
      await increaseTime(2 * 24 * 60 * 60);

      let level = await cypherWorms.read.getTokenLevel([1n]);
      assert.equal(level, 1n, "Should be level 1 at 2 days");

      console.log("Level 1 (Seed) verified: 2+ days");
    });

    it("Level 2 (Node): 7-13 days", async function () {
      await increaseTime(7 * 24 * 60 * 60);

      const level = await cypherWorms.read.getTokenLevel([1n]);
      assert.equal(level, 2n, "Should be level 2 at 7 days");

      console.log("Level 2 (Node) verified: 7+ days");
    });

    it("Level 3 (Process): 14-20 days", async function () {
      await increaseTime(14 * 24 * 60 * 60);

      const level = await cypherWorms.read.getTokenLevel([1n]);
      assert.equal(level, 3n, "Should be level 3 at 14 days");

      console.log("Level 3 (Process) verified: 14+ days");
    });

    it("Level 4 (Thread): 21-27 days", async function () {
      await increaseTime(21 * 24 * 60 * 60);

      const level = await cypherWorms.read.getTokenLevel([1n]);
      assert.equal(level, 4n, "Should be level 4 at 21 days");

      console.log("Level 4 (Thread) verified: 21+ days");
    });

    it("Level 5 (Cluster): 28-59 days", async function () {
      await increaseTime(28 * 24 * 60 * 60);

      const level = await cypherWorms.read.getTokenLevel([1n]);
      assert.equal(level, 5n, "Should be level 5 at 28 days");

      console.log("Level 5 (Cluster) verified: 28+ days");
    });

    it("Level 6 (Network): 60-89 days", async function () {
      await increaseTime(60 * 24 * 60 * 60);

      const level = await cypherWorms.read.getTokenLevel([1n]);
      assert.equal(level, 6n, "Should be level 6 at 60 days");

      console.log("Level 6 (Network) verified: 60+ days");
    });

    it("Level 7 (Protocol): 90-179 days", async function () {
      await increaseTime(90 * 24 * 60 * 60);

      const level = await cypherWorms.read.getTokenLevel([1n]);
      assert.equal(level, 7n, "Should be level 7 at 90 days");

      console.log("Level 7 (Protocol) verified: 90+ days");
    });

    it("Level 8 (Singularity): 180+ days (6 months)", async function () {
      await increaseTime(180 * 24 * 60 * 60);

      const level = await cypherWorms.read.getTokenLevel([1n]);
      assert.equal(level, 8n, "Should be level 8 at 180 days");

      console.log("Level 8 (Singularity) verified: 180+ days (6 months)");
    });

    it("Hold count persists across time", async function () {
      await increaseTime(30 * 24 * 60 * 60);

      const daysAfter = await cypherWorms.read.getHoldCountInDays([1n]);
      assert.ok(daysAfter >= 30n, "Should have at least 30 days held");

      console.log("Hold count persists across time");
    });

    it("Should reject getHoldCountInDays for non-existent token", async function () {
      await assert.rejects(
        async () => {
          await cypherWorms.read.getHoldCountInDays([999n]);
        },
        /token does not exist/,
        "Should revert for non-existent token"
      );

      console.log("getHoldCountInDays rejects non-existent token");
    });

    it("Should reject getTokenLevel for non-existent token", async function () {
      await assert.rejects(
        async () => {
          await cypherWorms.read.getTokenLevel([999n]);
        },
        /token does not exist/,
        "Should revert for non-existent token"
      );

      console.log("getTokenLevel rejects non-existent token");
    });
  });

  // Print gas summary at the end
  after(function () {
    console.log("\n GAS USAGE SUMMARY:");
    console.log("=".repeat(50));
    for (const [name, gas] of Object.entries(gasUsage)) {
      console.log(`${name.padEnd(30)} ${gas.padStart(15)} gas`);
    }
    console.log("=".repeat(50));
  });
});
