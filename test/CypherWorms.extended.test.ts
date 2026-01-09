import assert from "node:assert/strict";
import { describe, it, before, beforeEach, after } from "node:test";
import { network } from "hardhat";
import { parseEther, Address, zeroAddress } from "viem";

describe("CypherWorms - Extended Tests", async function () {
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

  // Gas tracking
  const gasUsage: Record<string, string> = {};

  function trackGas(name: string, gasUsed: bigint) {
    gasUsage[name] = gasUsed.toString();
    console.log(` ${name}: ${gasUsed.toString()} gas`);
  }

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

  async function increaseTime(seconds: number) {
    const testClient = await viem.getTestClient();
    await testClient.increaseTime({ seconds });
    await testClient.mine({ blocks: 1 });
  }

  before(async function () {
    const accounts = await getTestAccounts();
    owner = accounts.owner;
    primaryRecipient = accounts.primaryRecipient;
    secondaryRecipient = accounts.secondaryRecipient;
    user1 = accounts.user1;
    user2 = accounts.user2;
    user3 = accounts.user3;

    console.log("\n🧪 Running Extended Tests...\n");
  });

  beforeEach(async function () {
    specialEndLib = await viem.deployContract("SpecialEnd")
    preRevealLib = await viem.deployContract("PreReveal");
    specialLib = await viem.deployContract("Special", [
    ], {
      libraries: {
        SpecialEnd: specialEndLib.address,
      },
    });
    mockDisplay = await viem.deployContract("MockDisplay");
    mockERC20 = await viem.deployContract("MockERC20");

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
  // TRANSFER PROTECTION SYSTEM
  // ========================================

  describe("6. Transfer Protection System", function () {
    beforeEach(async function () {
      // Mint a token to user1
      await cypherWorms.write.ownerMint([user1, 1n]);
    });

    it("Should calculate correct protection price (free when base price = 0)", async function () {
      const price = await cypherWorms.read.getTransferProtectionPrice([1n]);
      assert.equal(price, 0n, "Price should be 0 when base price is 0");

      console.log(" Free protection when base price = 0");
    });

    it("Should calculate price based on token level", async function () {
      // Set base price to 1 ETH
      await cypherWorms.write.setTransferProtectionBasePrice([parseEther("1")]);

      // Token is level 0 (Null) initially - multiplier = 1
      let price = await cypherWorms.read.getTransferProtectionPrice([1n]);
      assert.equal(price, parseEther("1"), "Level 0 should be 1x base price");

      // Advance to level 1 (2 days)
      await increaseTime(2 * 24 * 60 * 60);
      price = await cypherWorms.read.getTransferProtectionPrice([1n]);
      assert.equal(price, parseEther("2"), "Level 1 should be 2x base price");

      // Advance to level 8 (180 days)
      await increaseTime(178 * 24 * 60 * 60);
      price = await cypherWorms.read.getTransferProtectionPrice([1n]);
      assert.equal(price, parseEther("9"), "Level 8 should be 9x base price");

      console.log(" Price scales correctly with token level");
    });

    it("Should protect transfer with correct payment", async function () {
      const [, , , user1Client] = await viem.getWalletClients();

      // Set base price to 0.1 ETH
      await cypherWorms.write.setTransferProtectionBasePrice([parseEther("0.1")]);

      // User1 protects their token (level 0, so 0.1 ETH)
      const hash = await cypherWorms.write.protectTransfer([1n], {
        account: user1Client.account,
        value: parseEther("0.1"),
      });

      const publicClient = await viem.getPublicClient();
      const receipt = await publicClient.getTransactionReceipt({ hash });
      trackGas("protectTransfer", receipt.gasUsed);

      // Verify payment split (70/30)
      const primaryPending = await cypherWorms.read.getPendingWithdrawal([primaryRecipient]);
      const secondaryPending = await cypherWorms.read.getPendingWithdrawal([secondaryRecipient]);

      assert.equal(primaryPending, parseEther("0.07"), "Primary should get 70%");
      assert.equal(secondaryPending, parseEther("0.03"), "Secondary should get 30%");

      console.log(" Protection payment processed with 70/30 split");
    });

    it("Should reject protection from non-owner", async function () {
      const [, , , , user2Client] = await viem.getWalletClients();

      await assert.rejects(
        async () => {
          await cypherWorms.write.protectTransfer([1n], {
            account: user2Client.account,
          });
        },
        /not token owner/,
        "Should revert for non-owner"
      );

      console.log(" Non-owner cannot protect token");
    });

    it("Should reject double protection", async function () {
      const [, , , user1Client] = await viem.getWalletClients();

      // First protection
      await cypherWorms.write.protectTransfer([1n], {
        account: user1Client.account,
      });

      // Second protection should fail
      await assert.rejects(
        async () => {
          await cypherWorms.write.protectTransfer([1n], {
            account: user1Client.account,
          });
        },
        /already protected/,
        "Should revert on double protection"
      );

      console.log(" Double protection rejected");
    });

    it("Should reject insufficient payment", async function () {
      const [, , , user1Client] = await viem.getWalletClients();

      await cypherWorms.write.setTransferProtectionBasePrice([parseEther("1")]);

      await assert.rejects(
        async () => {
          await cypherWorms.write.protectTransfer([1n], {
            account: user1Client.account,
            value: parseEther("0.5"), // Not enough
          });
        },
        /insufficient payment/,
        "Should revert with insufficient payment"
      );

      console.log(" Insufficient payment rejected");
    });

    it("Should refund excess payment", async function () {
      const [, , , user1Client] = await viem.getWalletClients();
      const publicClient = await viem.getPublicClient();

      await cypherWorms.write.setTransferProtectionBasePrice([parseEther("0.1")]);

      const balanceBefore = await publicClient.getBalance({ address: user1 });

      // Send 1 ETH when only 0.1 is needed
      const hash = await cypherWorms.write.protectTransfer([1n], {
        account: user1Client.account,
        value: parseEther("1"),
      });

      const receipt = await publicClient.getTransactionReceipt({ hash });
      const balanceAfter = await publicClient.getBalance({ address: user1 });

      // Calculate actual cost (0.1 ETH + gas)
      const gasCost = receipt.gasUsed * receipt.effectiveGasPrice;
      const expectedBalance = balanceBefore - parseEther("0.1") - gasCost;

      // Allow small difference for gas estimation
      const diff = expectedBalance > balanceAfter ?
        expectedBalance - balanceAfter : balanceAfter - expectedBalance;

      assert.ok(diff < parseEther("0.001"), "Should refund excess payment");

      console.log(" Excess payment refunded");
    });

    it("Should update base price correctly", async function () {
      const hash = await cypherWorms.write.setTransferProtectionBasePrice([parseEther("0.5")]);

      const basePrice = await cypherWorms.read.transferProtectionBasePrice();
      assert.equal(basePrice, parseEther("0.5"), "Base price should be updated");

      console.log(" Base price updated");
    });
  });

  // ========================================
  // PAYMENT & WITHDRAWAL SYSTEM
  // ========================================

  describe("7. Payment & Withdrawal System", function () {
    it("Should track pending withdrawals correctly", async function () {
      // Mint token and setup protection payment
      await cypherWorms.write.ownerMint([user1, 1n]);
      await cypherWorms.write.setTransferProtectionBasePrice([parseEther("1")]);

      const [, , , user1Client] = await viem.getWalletClients();
      await cypherWorms.write.protectTransfer([1n], {
        account: user1Client.account,
        value: parseEther("1"),
      });

      const primaryPending = await cypherWorms.read.getPendingWithdrawal([primaryRecipient]);
      const secondaryPending = await cypherWorms.read.getPendingWithdrawal([secondaryRecipient]);

      assert.equal(primaryPending, parseEther("0.7"), "Primary pending should be 0.7 ETH");
      assert.equal(secondaryPending, parseEther("0.3"), "Secondary pending should be 0.3 ETH");

      console.log(" Pending withdrawals tracked correctly");
    });

    it("Should allow withdrawal of pending balance", async function () {
      const [, primaryClient] = await viem.getWalletClients(); // primaryClient is at index 1
      const publicClient = await viem.getPublicClient();

      // Create pending withdrawal
      await cypherWorms.write.ownerMint([user1, 1n]);
      await cypherWorms.write.setTransferProtectionBasePrice([parseEther("1")]);

      const [, , , user1Client] = await viem.getWalletClients();
      await cypherWorms.write.protectTransfer([1n], {
        account: user1Client.account,
        value: parseEther("1"),
      });

      const balanceBefore = await publicClient.getBalance({ address: primaryRecipient });

      // Withdraw
      const hash = await cypherWorms.write.withdraw({
        account: primaryClient.account,
      });

      const receipt = await publicClient.getTransactionReceipt({ hash });
      trackGas("withdraw", receipt.gasUsed);

      const balanceAfter = await publicClient.getBalance({ address: primaryRecipient });
      const gasCost = receipt.gasUsed * receipt.effectiveGasPrice;

      // Should have received 0.7 ETH minus gas
      const expectedBalance = balanceBefore + parseEther("0.7") - gasCost;
      assert.ok(
        balanceAfter >= expectedBalance - parseEther("0.001") &&
        balanceAfter <= expectedBalance + parseEther("0.001"),
        "Should receive correct withdrawal amount"
      );

      // Pending should be 0 now
      const pendingAfter = await cypherWorms.read.getPendingWithdrawal([primaryRecipient]);
      assert.equal(pendingAfter, 0n, "Pending should be 0 after withdrawal");

      console.log(" Withdrawal successful");
    });

    it("Should reject withdrawal with zero balance", async function () {
      const [, primaryClient] = await viem.getWalletClients();

      await assert.rejects(
        async () => {
          await cypherWorms.write.withdraw({
            account: primaryClient.account,
          });
        },
        /no pending withdrawal/,
        "Should revert with no pending withdrawal"
      );

      console.log(" Zero balance withdrawal rejected");
    });

    it("Should handle receive() function for direct ETH payments", async function () {
      const [ownerClient] = await viem.getWalletClients();
      const publicClient = await viem.getPublicClient();

      // Send ETH directly to contract
      const hash = await ownerClient.sendTransaction({
        to: cypherWorms.address,
        value: parseEther("1"),
      });

      await publicClient.waitForTransactionReceipt({ hash });

      // Check 70/30 split
      const primaryPending = await cypherWorms.read.getPendingWithdrawal([primaryRecipient]);
      const secondaryPending = await cypherWorms.read.getPendingWithdrawal([secondaryRecipient]);

      assert.equal(primaryPending, parseEther("0.7"), "Primary should get 70%");
      assert.equal(secondaryPending, parseEther("0.3"), "Secondary should get 30%");

      console.log(" Direct ETH payment split correctly");
    });

    it("Should accumulate multiple payments", async function () {
      await cypherWorms.write.ownerMint([user1, 2n]);
      await cypherWorms.write.setTransferProtectionBasePrice([parseEther("1")]);

      const [, , , user1Client] = await viem.getWalletClients();

      // First payment
      await cypherWorms.write.protectTransfer([1n], {
        account: user1Client.account,
        value: parseEther("1"),
      });

      // Second payment
      await cypherWorms.write.protectTransfer([2n], {
        account: user1Client.account,
        value: parseEther("1"),
      });

      const primaryPending = await cypherWorms.read.getPendingWithdrawal([primaryRecipient]);
      const secondaryPending = await cypherWorms.read.getPendingWithdrawal([secondaryRecipient]);

      assert.equal(primaryPending, parseEther("1.4"), "Primary should have 1.4 ETH");
      assert.equal(secondaryPending, parseEther("0.6"), "Secondary should have 0.6 ETH");

      console.log(" Multiple payments accumulated correctly");
    });
  });

  // ========================================
  // TRANSFER & HOLD COUNT SYSTEM
  // ========================================

  describe("8. Transfer & Hold Count System", function () {
    beforeEach(async function () {
      await cypherWorms.write.ownerMint([user1, 1n]);
    });

    it("Should reset hold count on unprotected transfer", async function () {
      const [, , , user1Client] = await viem.getWalletClients();

      // Advance time
      await increaseTime(10 * 24 * 60 * 60);

      const daysBeforeTransfer = await cypherWorms.read.getHoldCountInDays([1n]);
      assert.ok(daysBeforeTransfer >= 10n, "Should have at least 10 days held");

      // Transfer without protection
      await cypherWorms.write.transferFrom([user1, user2, 1n], {
        account: user1Client.account,
      });

      const daysAfterTransfer = await cypherWorms.read.getHoldCountInDays([1n]);
      assert.equal(daysAfterTransfer, 0n, "Hold count should be reset");

      console.log(" Hold count reset on unprotected transfer");
    });

    it("Should preserve hold count on protected transfer", async function () {
      const [, , , user1Client] = await viem.getWalletClients();

      // Advance time to build up hold count
      await increaseTime(10 * 24 * 60 * 60);

      const daysBeforeProtection = await cypherWorms.read.getHoldCountInDays([1n]);
      assert.ok(daysBeforeProtection >= 10n, "Should have at least 10 days");

      // Protect transfer
      await cypherWorms.write.protectTransfer([1n], {
        account: user1Client.account,
      });

      // Transfer with protection (hold count should be preserved)
      await cypherWorms.write.transferFrom([user1, user2, 1n], {
        account: user1Client.account,
      });

      const daysAfterTransfer = await cypherWorms.read.getHoldCountInDays([1n]);

      // Hold count should still be around 10 days (within 1 day tolerance)
      assert.ok(daysAfterTransfer >= 9n && daysAfterTransfer <= 11n, "Hold count should be preserved");

      console.log(" Hold count preserved on protected transfer");
    });

    it("Should consume protection after one transfer", async function () {
      const [, , , user1Client, user2Client] = await viem.getWalletClients();

      // Build up hold time
      await increaseTime(10 * 24 * 60 * 60);

      // Protect and transfer first time (protection active)
      await cypherWorms.write.protectTransfer([1n], {
        account: user1Client.account,
      });

      await cypherWorms.write.transferFrom([user1, user2, 1n], {
        account: user1Client.account,
      });

      // Hold count should still be around 10 days
      let daysHeld = await cypherWorms.read.getHoldCountInDays([1n]);
      assert.ok(daysHeld >= 9n, "Hold count should be preserved on first transfer");

      // Transfer again WITHOUT new protection (protection consumed)
      await cypherWorms.write.transferFrom([user2, user3, 1n], {
        account: user2Client.account,
      });

      // Hold count should be reset now (protection was consumed)
      daysHeld = await cypherWorms.read.getHoldCountInDays([1n]);
      assert.equal(daysHeld, 0n, "Hold count should be reset after protection consumed");

      console.log(" Protection consumed after one transfer");
    });
  });

  // ========================================
  // METADATA SYSTEM
  // ========================================

  describe("9. Metadata System", function () {
    it("Should return pre-reveal metadata before reveal", async function () {
      await cypherWorms.write.ownerMint([user1, 1n]);

      const uri = await cypherWorms.read.tokenURI([1n]);

      assert.ok(typeof uri === "string", "Should return a string");
      assert.ok(uri.startsWith("data:"), "Should be a data URI");

      console.log(" Pre-reveal metadata returned");
    });

    it("Should reject tokenURI for non-existent token", async function () {
      await assert.rejects(
        async () => {
          await cypherWorms.read.tokenURI([999n]);
        },
        /token does not exist/,
        "Should revert for non-existent token"
      );

      console.log(" tokenURI rejects non-existent token");
    });
  });

  // ========================================
  // RECIPIENT MANAGEMENT
  // ========================================

  describe("10. Recipient Management", function () {
    it("Should update primary recipient", async function () {
      const newRecipient = user3;

      await cypherWorms.write.updatePrimaryRecipient([newRecipient]);

      const updatedRecipient = await cypherWorms.read.primaryRecipient();
      assert.equal(updatedRecipient.toLowerCase(), newRecipient.toLowerCase(), "Primary recipient should be updated");

      console.log(" Primary recipient updated");
    });

    it("Should transfer pending withdrawals to new recipient", async function () {
      // Create pending withdrawal
      await cypherWorms.write.ownerMint([user1, 1n]);
      await cypherWorms.write.setTransferProtectionBasePrice([parseEther("1")]);

      const [, , , user1Client] = await viem.getWalletClients();
      await cypherWorms.write.protectTransfer([1n], {
        account: user1Client.account,
        value: parseEther("1"),
      });

      const pendingBefore = await cypherWorms.read.getPendingWithdrawal([primaryRecipient]);
      assert.equal(pendingBefore, parseEther("0.7"), "Should have pending withdrawal");

      // Update recipient
      const newRecipient = user3;
      await cypherWorms.write.updatePrimaryRecipient([newRecipient]);

      // Old recipient should have 0
      const oldPending = await cypherWorms.read.getPendingWithdrawal([primaryRecipient]);
      assert.equal(oldPending, 0n, "Old recipient should have 0 pending");

      // New recipient should have the amount
      const newPending = await cypherWorms.read.getPendingWithdrawal([newRecipient]);
      assert.equal(newPending, parseEther("0.7"), "New recipient should have pending amount");

      console.log(" Pending withdrawals transferred to new recipient");
    });

    it("Should reject update to zero address", async function () {
      await assert.rejects(
        async () => {
          await cypherWorms.write.updatePrimaryRecipient([zeroAddress]);
        },
        /invalid recipient address/,
        "Should revert with zero address"
      );

      console.log(" Zero address recipient rejected");
    });

    it("Should reject update to same address", async function () {
      await assert.rejects(
        async () => {
          await cypherWorms.write.updatePrimaryRecipient([primaryRecipient]);
        },
        /same as current recipient/,
        "Should revert with same address"
      );

      console.log(" Same address update rejected");
    });
  });

  // ========================================
  // ERC20 RECOVERY
  // ========================================

  describe("11. ERC20 Recovery", function () {
    it("Should recover accidentally sent ERC20 tokens", async function () {
      // Mint ERC20 tokens to the contract
      await mockERC20.write.mint([cypherWorms.address, parseEther("100")]);

      const contractBalance = await mockERC20.read.balanceOf([cypherWorms.address]);
      assert.equal(contractBalance, parseEther("100"), "Contract should have 100 tokens");

      // Recover
      const hash = await cypherWorms.write.recoverERC20([mockERC20.address]);
      const publicClient = await viem.getPublicClient();
      const receipt = await publicClient.getTransactionReceipt({ hash });
      trackGas("recoverERC20", receipt.gasUsed);

      // Check 70/30 split
      const primaryBalance = await mockERC20.read.balanceOf([primaryRecipient]);
      const secondaryBalance = await mockERC20.read.balanceOf([secondaryRecipient]);

      assert.equal(primaryBalance, parseEther("70"), "Primary should get 70 tokens");
      assert.equal(secondaryBalance, parseEther("30"), "Secondary should get 30 tokens");

      console.log(" ERC20 tokens recovered with 70/30 split");
    });

    it("Should reject recovery of zero address", async function () {
      await assert.rejects(
        async () => {
          await cypherWorms.write.recoverERC20([zeroAddress]);
        },
        /invalid token address/,
        "Should revert with zero address"
      );

      console.log(" Zero address token recovery rejected");
    });

    it("Should reject recovery when no tokens present", async function () {
      await assert.rejects(
        async () => {
          await cypherWorms.write.recoverERC20([mockERC20.address]);
        },
        /no tokens to recover/,
        "Should revert with no tokens"
      );

      console.log(" No tokens recovery rejected");
    });
  });

  // ========================================
  // ROYALTY SYSTEM
  // ========================================

  describe("12. Royalty System", function () {
    it("Should setup royalties correctly", async function () {
      const hash = await cypherWorms.write.setupRoyalties();
      const publicClient = await viem.getPublicClient();
      const receipt = await publicClient.getTransactionReceipt({ hash });
      trackGas("setupRoyalties", receipt.gasUsed);

      console.log(" Royalties setup (5% to contract address)");
    });
  });

  // ========================================
  // SECURITY TESTS
  // ========================================

  describe("13. Security: Withdrawal Access Control", function () {
    it("Should only allow designated recipients to accumulate funds", async function () {
      await cypherWorms.write.ownerMint([user1, 1n]);
      await cypherWorms.write.setTransferProtectionBasePrice([parseEther("1")]);

      const [, , , user1Client] = await viem.getWalletClients();
      await cypherWorms.write.protectTransfer([1n], {
        account: user1Client.account,
        value: parseEther("1"),
      });

      // Check that ONLY primary and secondary recipients have pending balance
      const primaryPending = await cypherWorms.read.getPendingWithdrawal([primaryRecipient]);
      const secondaryPending = await cypherWorms.read.getPendingWithdrawal([secondaryRecipient]);
      const user1Pending = await cypherWorms.read.getPendingWithdrawal([user1]);
      const randomPending = await cypherWorms.read.getPendingWithdrawal([user3]);

      assert.equal(primaryPending, parseEther("0.7"), "Primary should have pending");
      assert.equal(secondaryPending, parseEther("0.3"), "Secondary should have pending");
      assert.equal(user1Pending, 0n, "User1 (payer) should have 0 pending");
      assert.equal(randomPending, 0n, "Random address should have 0 pending");

      console.log("✅ Only designated recipients accumulate funds");
    });

    it("Should prevent unauthorized users from withdrawing", async function () {
      const [, , , user1Client] = await viem.getWalletClients();

      // User1 has no pending balance
      const pending = await cypherWorms.read.getPendingWithdrawal([user1]);
      assert.equal(pending, 0n, "User1 should have 0 pending");

      // Attempt to withdraw should fail
      await assert.rejects(
        async () => {
          await cypherWorms.write.withdraw({
            account: user1Client.account,
          });
        },
        /no pending withdrawal/,
        "Should revert for user with no balance"
      );

      console.log("✅ Unauthorized withdrawal prevented");
    });

    it("Should ensure funds only come from legitimate sources", async function () {
      // All payment sources credit only the two recipients

      // Source 1: protectTransfer
      await cypherWorms.write.ownerMint([user1, 1n]);
      await cypherWorms.write.setTransferProtectionBasePrice([parseEther("0.1")]);

      const [, , , user1Client] = await viem.getWalletClients();
      await cypherWorms.write.protectTransfer([1n], {
        account: user1Client.account,
        value: parseEther("0.1"),
      });

      // Source 2: receive() - direct payment
      const [ownerClient] = await viem.getWalletClients();
      const publicClient = await viem.getPublicClient();

      const hash = await ownerClient.sendTransaction({
        to: cypherWorms.address,
        value: parseEther("0.2"),
      });
      await publicClient.waitForTransactionReceipt({ hash });

      // Verify ONLY the two recipients have funds
      const primaryTotal = await cypherWorms.read.getPendingWithdrawal([primaryRecipient]);
      const secondaryTotal = await cypherWorms.read.getPendingWithdrawal([secondaryRecipient]);

      // Total paid: 0.1 + 0.2 = 0.3 ETH
      // Primary should get: 0.07 + 0.14 = 0.21 ETH (70%)
      // Secondary should get: 0.03 + 0.06 = 0.09 ETH (30%)

      assert.equal(primaryTotal, parseEther("0.21"), "Primary gets exactly 70% of all payments");
      assert.equal(secondaryTotal, parseEther("0.09"), "Secondary gets exactly 30% of all payments");

      console.log("✅ All payment sources only credit designated recipients");
    });
  });

  // Print gas summary
  after(function () {
    console.log("\n EXTENDED TESTS GAS USAGE:");
    console.log("=".repeat(50));
    for (const [name, gas] of Object.entries(gasUsage)) {
      console.log(`${name.padEnd(30)} ${gas.padStart(15)} gas`);
    }
    console.log("=".repeat(50));
  });
});
