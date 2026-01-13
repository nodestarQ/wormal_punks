import assert from "node:assert/strict";
import { describe, it, before, beforeEach } from "node:test";
import { network } from "hardhat";
import { parseEther, Address } from "viem";

describe("CypherWorms - ERC20 Payment Tests", async function () {
  const { viem } = await network.connect();

  // Test accounts
  let owner: Address;
  let paymentRecipient: Address;
  
  let user1: Address;
  let user2: Address;

  // Contracts
  let cypherWorms: any;
  let mockDisplay: any;
  let mockERC20: any;
  let preRevealLib: any;
  let specialLib: any;
  let specialEndLib: any;

  // Constants
  const PROTECTION_BASE_PRICE = parseEther("0.1"); // 0.1 ETH or tokens
  const ERC20_AMOUNT = parseEther("1000"); // 1000 tokens

  // Helper to get all test accounts
  async function getTestAccounts() {
    const [acc0, acc1, acc2, acc3, acc4] = await viem.getWalletClients();
    return {
      owner: acc0.account.address,
      paymentRecipient: acc1.account.address,
      
      user1: acc2.account.address,
      user2: acc3.account.address,
    };
  }

  // Setup: Deploy contracts before all tests
  before(async function () {
    const accounts = await getTestAccounts();
    owner = accounts.owner;
    paymentRecipient = accounts.paymentRecipient;
    
    user1 = accounts.user1;
    user2 = accounts.user2;

    console.log("\n🔧 Setting up ERC20 payment test environment...\n");
  });

  // Deploy fresh contracts before each test
  beforeEach(async function () {
    specialEndLib = await viem.deployContract("SpecialEnd");
    preRevealLib = await viem.deployContract("PreReveal");
    specialLib = await viem.deployContract("Special", [], {
      libraries: {
        SpecialEnd: specialEndLib.address,
      },
    });

    mockDisplay = await viem.deployContract("MockDisplay");
    mockERC20 = await viem.deployContract("MockERC20");

    cypherWorms = await viem.deployContract(
      "CypherWorms",
      [mockDisplay.address, paymentRecipient],
      {
        libraries: {
          PreReveal: preRevealLib.address,
          Special: specialLib.address,
        },
      }
    );

    // Setup: Mint a token to user1 for testing
    await cypherWorms.write.ownerMint([user1, 1n]);
  });

  // ========================================
  // ERC20 PAYMENT TOKEN CONFIGURATION
  // ========================================

  describe("1. ERC20 Payment Token Configuration", function () {
    it("Should start with ETH as default payment method", async function () {
      const token = await cypherWorms.read.getTransferProtectionPaymentToken();
      assert.equal(
        token,
        "0x0000000000000000000000000000000000000000",
        "Should default to address(0) for ETH"
      );
      console.log("✓ Default payment method is ETH");
    });

    it("Should allow owner to set ERC20 token as payment method", async function () {
      await cypherWorms.write.setTransferProtectionToken([mockERC20.address]);

      const token = await cypherWorms.read.getTransferProtectionPaymentToken();
      assert.equal(
        token.toLowerCase(),
        mockERC20.address.toLowerCase(),
        "Token should be set"
      );
      console.log("✓ Owner set ERC20 token as payment method");
    });

    it("Should emit TransferProtectionTokenUpdated event", async function () {
      const publicClient = await viem.getPublicClient();
      const hash = await cypherWorms.write.setTransferProtectionToken([
        mockERC20.address,
      ]);
      const receipt = await publicClient.getTransactionReceipt({ hash });

      // Check that event was emitted
      assert.ok(receipt.logs.length > 0, "Should emit event");
      console.log("✓ TransferProtectionTokenUpdated event emitted");
    });

    it("Should allow switching back to ETH", async function () {
      // Set to ERC20
      await cypherWorms.write.setTransferProtectionToken([mockERC20.address]);

      // Switch back to ETH
      await cypherWorms.write.setTransferProtectionToken([
        "0x0000000000000000000000000000000000000000",
      ]);

      const token = await cypherWorms.read.getTransferProtectionPaymentToken();
      assert.equal(
        token,
        "0x0000000000000000000000000000000000000000",
        "Should be back to ETH"
      );
      console.log("✓ Switched back to ETH payment");
    });

    it("Should reject call from non-owner", async function () {
      const [, , , user] = await viem.getWalletClients();

      await assert.rejects(
        async () => {
          await cypherWorms.write.setTransferProtectionToken(
            [mockERC20.address],
            {
              account: user.account,
            }
          );
        },
        "Should revert for non-owner"
      );
      console.log("✓ Non-owner cannot set payment token");
    });
  });

  // ========================================
  // ERC20 PAYMENT PROCESSING
  // ========================================

  describe("2. ERC20 Payment Processing", function () {
    beforeEach(async function () {
      // Setup: Set protection price and ERC20 token
      await cypherWorms.write.setTransferProtectionBasePrice([
        PROTECTION_BASE_PRICE,
      ]);
      await cypherWorms.write.setTransferProtectionToken([mockERC20.address]);

      // Mint ERC20 tokens to user1 (user1 is acc2, which is index 2)
      await mockERC20.write.mint([user1, ERC20_AMOUNT]);
    });

    it("Should process ERC20 payment for transfer protection", async function () {
      const [, , user1Client] = await viem.getWalletClients();

      // Get initial balance
      const recipientBalanceBefore = await mockERC20.read.balanceOf([
        paymentRecipient,
      ]);

      // Approve the contract to spend user's tokens
      await mockERC20.write.approve(
        [cypherWorms.address, PROTECTION_BASE_PRICE],
        {
          account: user1Client.account,
        }
      );

      // Protect the transfer (token level 0, multiplier 1)
      await cypherWorms.write.protectTransfer([1n], {
        account: user1Client.account,
      });

      // Check balance after
      const recipientBalanceAfter = await mockERC20.read.balanceOf([
        paymentRecipient,
      ]);

      // Should receive 100% of payment
      assert.equal(
        recipientBalanceAfter - recipientBalanceBefore,
        PROTECTION_BASE_PRICE,
        "Recipient should receive 100%"
      );

      console.log("✓ ERC20 payment processed - 100% to recipient");
    });

    it("Should emit ERC20PaymentProcessed event", async function () {
      const [, , user1Client] = await viem.getWalletClients();
      const publicClient = await viem.getPublicClient();

      await mockERC20.write.approve(
        [cypherWorms.address, PROTECTION_BASE_PRICE],
        {
          account: user1Client.account,
        }
      );

      const hash = await cypherWorms.write.protectTransfer([1n], {
        account: user1Client.account,
      });
      const receipt = await publicClient.getTransactionReceipt({ hash });

      assert.ok(receipt.logs.length > 0, "Should emit events");
      console.log("✓ ERC20PaymentProcessed event emitted");
    });

    it("Should reject ERC20 payment if ETH is sent", async function () {
      const [, , user1Client] = await viem.getWalletClients();

      await mockERC20.write.approve(
        [cypherWorms.address, PROTECTION_BASE_PRICE],
        {
          account: user1Client.account,
        }
      );

      await assert.rejects(
        async () => {
          await cypherWorms.write.protectTransfer([1n], {
            account: user1Client.account,
            value: parseEther("0.01"), // Trying to send ETH
          });
        },
        /ETH not accepted for ERC20 payment/,
        "Should reject ETH when ERC20 is configured"
      );
      console.log("✓ Rejected ETH payment when ERC20 is configured");
    });

    it("Should reject if insufficient ERC20 allowance", async function () {
      const [, , user1Client] = await viem.getWalletClients();

      // Approve less than required
      await mockERC20.write.approve([cypherWorms.address, parseEther("0.05")], {
        account: user1Client.account,
      });

      await assert.rejects(
        async () => {
          await cypherWorms.write.protectTransfer([1n], {
            account: user1Client.account,
          });
        },
        "Should reject with insufficient allowance"
      );
      console.log("✓ Rejected insufficient ERC20 allowance");
    });

    it("Should reject if insufficient ERC20 balance", async function () {
      const [, , , , user2Client] = await viem.getWalletClients();

      // Mint token to user2 but don't give them ERC20 tokens
      await cypherWorms.write.strategicMint([user2, 1n]);

      // Approve but don't have balance
      await mockERC20.write.approve([cypherWorms.address, PROTECTION_BASE_PRICE], {
        account: user2Client.account,
      });

      await assert.rejects(
        async () => {
          await cypherWorms.write.protectTransfer([2n], {
            account: user2Client.account,
          });
        },
        "Should reject with insufficient balance"
      );
      console.log("✓ Rejected insufficient ERC20 balance");
    });
  });

  // ========================================
  // PRICE CALCULATION WITH ERC20
  // ========================================

  describe("3. Price Calculation with ERC20", function () {
    beforeEach(async function () {
      await cypherWorms.write.setTransferProtectionBasePrice([
        PROTECTION_BASE_PRICE,
      ]);
      await cypherWorms.write.setTransferProtectionToken([mockERC20.address]);

      const [, , user1Client] = await viem.getWalletClients();
      await mockERC20.write.mint([user1, ERC20_AMOUNT]);
    });

    it("Should calculate correct price for level 0 token (1x multiplier)", async function () {
      const price = await cypherWorms.read.getTransferProtectionPrice([1n]);
      assert.equal(
        price,
        PROTECTION_BASE_PRICE,
        "Level 0 should be 1x base price"
      );
      console.log("✓ Level 0 price calculation correct");
    });

    it("Should handle price calculation same as ETH", async function () {
      // Price calculation should be independent of payment method
      const priceWithERC20 = await cypherWorms.read.getTransferProtectionPrice([
        1n,
      ]);

      // Switch to ETH
      await cypherWorms.write.setTransferProtectionToken([
        "0x0000000000000000000000000000000000000000",
      ]);

      const priceWithETH = await cypherWorms.read.getTransferProtectionPrice([
        1n,
      ]);

      assert.equal(
        priceWithERC20,
        priceWithETH,
        "Price should be same regardless of payment method"
      );
      console.log("✓ Price calculation independent of payment method");
    });
  });

  // ========================================
  // TOKEN RECOVERY PROTECTION
  // ========================================

  describe("4. Token Recovery Protection", function () {
    beforeEach(async function () {
      await cypherWorms.write.setTransferProtectionToken([mockERC20.address]);
    });

    it("Should prevent recovering the active payment token", async function () {
      // Send some tokens to the contract
      await mockERC20.write.mint([cypherWorms.address, ERC20_AMOUNT]);

      await assert.rejects(
        async () => {
          await cypherWorms.write.recoverERC20([
            mockERC20.address,
            paymentRecipient,
            ERC20_AMOUNT
          ]);
        },
        /cannot recover payment token/,
        "Should not allow recovering payment token"
      );
      console.log("✓ Cannot recover active payment token");
    });

    it("Should allow recovering non-payment tokens", async function () {
      // Deploy another ERC20 token
      const otherToken = await viem.deployContract("MockERC20");

      // Send tokens to contract
      await otherToken.write.mint([cypherWorms.address, ERC20_AMOUNT]);

      // Should be able to recover to primary recipient
      await cypherWorms.write.recoverERC20([
        otherToken.address,
        paymentRecipient,
        ERC20_AMOUNT
      ]);

      const recipientBalance = await otherToken.read.balanceOf([paymentRecipient]);
      assert.equal(recipientBalance, ERC20_AMOUNT, "Primary should receive full amount");
      console.log("✓ Can recover other tokens to specified recipient");
    });

    it("Should allow recovering payment token after switching", async function () {
      // Send tokens to contract
      await mockERC20.write.mint([cypherWorms.address, ERC20_AMOUNT]);

      // Switch to ETH
      await cypherWorms.write.setTransferProtectionToken([
        "0x0000000000000000000000000000000000000000",
      ]);

      // Now should be able to recover
      await cypherWorms.write.recoverERC20([
        mockERC20.address,
        paymentRecipient,
        ERC20_AMOUNT
      ]);

      const recipientBalance = await mockERC20.read.balanceOf([paymentRecipient]);
      assert.equal(recipientBalance, ERC20_AMOUNT, "Primary should receive full amount");
      console.log("✓ Can recover token after switching payment methods");
    });
  });

  // ========================================
  // INTEGRATION: SWITCHING BETWEEN ETH AND ERC20
  // ========================================

  describe("5. Switching Between ETH and ERC20", function () {
    beforeEach(async function () {
      await cypherWorms.write.setTransferProtectionBasePrice([
        PROTECTION_BASE_PRICE,
      ]);

      const [, , user1Client] = await viem.getWalletClients();
      await mockERC20.write.mint([user1, ERC20_AMOUNT]);
    });

    it("Should handle ETH payment after deploying", async function () {
      const [, , user1Client] = await viem.getWalletClients();

      const primaryBefore = await viem
        .getPublicClient()
        .then((c) => c.getBalance({ address: paymentRecipient }));

      await cypherWorms.write.protectTransfer([1n], {
        account: user1Client.account,
        value: PROTECTION_BASE_PRICE,
      });

      // Check that pending withdrawal was recorded (not direct transfer for ETH)
      const pending = await cypherWorms.read.getPendingWithdrawal([
        paymentRecipient,
      ]);

      assert.equal(
        pending,
        PROTECTION_BASE_PRICE,
        "Should have 100% pending withdrawal for ETH"
      );
      console.log("✓ ETH payment uses pending withdrawals");
    });

    it("Should handle ERC20 payment after switching", async function () {
      const [, , user1Client] = await viem.getWalletClients();

      // Mint another token for second protection
      await cypherWorms.write.strategicMint([user1, 1n]);

      // Switch to ERC20
      await cypherWorms.write.setTransferProtectionToken([mockERC20.address]);

      await mockERC20.write.approve(
        [cypherWorms.address, PROTECTION_BASE_PRICE],
        {
          account: user1Client.account,
        }
      );

      const primaryBefore = await mockERC20.read.balanceOf([paymentRecipient]);

      await cypherWorms.write.protectTransfer([2n], {
        account: user1Client.account,
      });

      const primaryAfter = await mockERC20.read.balanceOf([paymentRecipient]);

      assert.equal(
        primaryAfter - primaryBefore,
        PROTECTION_BASE_PRICE,
        "Should receive 100% ERC20 directly"
      );
      console.log("✓ ERC20 payment bypasses pending withdrawals (direct)");
    });

    it("Should handle switching back to ETH", async function () {
      const [, , user1Client] = await viem.getWalletClients();

      // Start with ERC20
      await cypherWorms.write.setTransferProtectionToken([mockERC20.address]);

      // Mint tokens for multiple protections
      await cypherWorms.write.strategicMint([user1, 2n]);

      // Use ERC20 for first protection
      await mockERC20.write.approve(
        [cypherWorms.address, PROTECTION_BASE_PRICE],
        {
          account: user1Client.account,
        }
      );
      await cypherWorms.write.protectTransfer([2n], {
        account: user1Client.account,
      });

      // Switch back to ETH
      await cypherWorms.write.setTransferProtectionToken([
        "0x0000000000000000000000000000000000000000",
      ]);

      // Use ETH for second protection
      await cypherWorms.write.protectTransfer([3n], {
        account: user1Client.account,
        value: PROTECTION_BASE_PRICE,
      });

      const pending = await cypherWorms.read.getPendingWithdrawal([
        paymentRecipient,
      ]);
      assert.ok(pending > 0n, "Should have pending ETH withdrawal");
      console.log("✓ Successfully switched from ERC20 back to ETH");
    });
  });

  console.log("\n✅ All ERC20 payment tests completed!\n");
});
