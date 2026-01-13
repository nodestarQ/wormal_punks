import assert from "node:assert/strict";
import { describe, it, before, beforeEach } from "node:test";
import { network } from "hardhat";
import { parseEther, Address } from "viem";

describe("CypherWorms - Single Payment Recipient", async function () {
  const { viem } = await network.connect();

  let owner: Address;
  let paymentRecipient: Address;
  let user1: Address;

  let cypherWorms: any;
  let mockDisplay: any;
  let mockERC20: any;
  let preRevealLib: any;
  let specialLib: any;
  let specialEndLib: any;

  async function getTestAccounts() {
    const [acc0, acc1, acc2] = await viem.getWalletClients();
    return {
      owner: acc0.account.address,
      paymentRecipient: acc1.account.address,
      user1: acc2.account.address,
    };
  }

  before(async function () {
    const accounts = await getTestAccounts();
    owner = accounts.owner;
    paymentRecipient = accounts.paymentRecipient;
    user1 = accounts.user1;

    console.log("\n✅ Testing Single Payment Recipient System...\n");
  });

  beforeEach(async function () {
    specialEndLib = await viem.deployContract("SpecialEnd");
    preRevealLib = await viem.deployContract("PreReveal");
    specialLib = await viem.deployContract("Special", [], {
      libraries: { SpecialEnd: specialEndLib.address },
    });
    mockDisplay = await viem.deployContract("MockDisplay");
    mockERC20 = await viem.deployContract("MockERC20");

    cypherWorms = await viem.deployContract("CypherWorms", [
      mockDisplay.address,
      paymentRecipient,
    ], {
      libraries: {
        PreReveal: preRevealLib.address,
        Special: specialLib.address,
      },
    });
  });

  describe("Deployment & Configuration", function () {
    it("Should deploy with single payment recipient", async function () {
      const recipient = await cypherWorms.read.paymentRecipient();
      assert.equal(recipient.toLowerCase(), paymentRecipient.toLowerCase());
      console.log("✅ Single payment recipient configured");
    });

    it("Should update payment recipient", async function () {
      await cypherWorms.write.updatePaymentRecipient([user1]);
      const newRecipient = await cypherWorms.read.paymentRecipient();
      assert.equal(newRecipient.toLowerCase(), user1.toLowerCase());
      console.log("✅ Payment recipient updated");
    });
  });

  describe("ETH Payment - Pull Pattern", function () {
    beforeEach(async function () {
      await cypherWorms.write.setTransferProtectionBasePrice([parseEther("0.1")]);
      await cypherWorms.write.ownerMint([user1, 1n]);
    });

    it("Should add ETH payment to pending withdrawals", async function () {
      const [, , user1Client] = await viem.getWalletClients();

      await cypherWorms.write.protectTransfer([1n], {
        account: user1Client.account,
        value: parseEther("0.1"),
      });

      const pending = await cypherWorms.read.getPendingWithdrawal([paymentRecipient]);
      assert.equal(pending, parseEther("0.1"));
      console.log("✅ Payment added to pending withdrawals");
    });

    it("Should allow recipient to withdraw", async function () {
      const [, recipientClient, user1Client] = await viem.getWalletClients();
      const publicClient = await viem.getPublicClient();

      await cypherWorms.write.protectTransfer([1n], {
        account: user1Client.account,
        value: parseEther("0.1"),
      });

      const balanceBefore = await publicClient.getBalance({ address: paymentRecipient });

      await cypherWorms.write.withdraw({ account: recipientClient.account });

      const balanceAfter = await publicClient.getBalance({ address: paymentRecipient });
      const received = balanceAfter - balanceBefore;

      // Should receive ~0.1 ETH (minus gas)
      assert.ok(received > parseEther("0.09"));
      console.log("✅ Recipient withdrew ETH");
    });
  });

  describe("ERC20 Payment - Direct Transfer", function () {
    beforeEach(async function () {
      await cypherWorms.write.setTransferProtectionBasePrice([parseEther("100")]);
      await cypherWorms.write.setTransferProtectionToken([mockERC20.address]);
      await cypherWorms.write.ownerMint([user1, 1n]);

      const [, , user1Client] = await viem.getWalletClients();
      await mockERC20.write.mint([user1Client.account.address, parseEther("1000")]);
    });

    it("Should send ERC20 directly to recipient", async function () {
      const [, , user1Client] = await viem.getWalletClients();

      await mockERC20.write.approve([cypherWorms.address, parseEther("100")], {
        account: user1Client.account,
      });

      const balanceBefore = await mockERC20.read.balanceOf([paymentRecipient]);

      await cypherWorms.write.protectTransfer([1n], {
        account: user1Client.account,
      });

      const balanceAfter = await mockERC20.read.balanceOf([paymentRecipient]);
      const received = balanceAfter - balanceBefore;

      assert.equal(received, parseEther("100"));
      console.log("✅ ERC20 sent directly to recipient (no pending withdrawal)");
    });
  });

  describe("Recipient Update with Pending Funds", function () {
    beforeEach(async function () {
      await cypherWorms.write.setTransferProtectionBasePrice([parseEther("0.1")]);
      await cypherWorms.write.ownerMint([user1, 1n]);
    });

    it("Should transfer pending withdrawals to new recipient", async function () {
      const [, , user1Client] = await viem.getWalletClients();

      // Create pending withdrawal
      await cypherWorms.write.protectTransfer([1n], {
        account: user1Client.account,
        value: parseEther("0.1"),
      });

      // Update recipient
      await cypherWorms.write.updatePaymentRecipient([user1]);

      // Check new recipient has pending withdrawal
      const pending = await cypherWorms.read.getPendingWithdrawal([user1]);
      assert.equal(pending, parseEther("0.1"));

      // Old recipient should have 0
      const oldPending = await cypherWorms.read.getPendingWithdrawal([paymentRecipient]);
      assert.equal(oldPending, 0n);

      console.log("✅ Pending funds transferred to new recipient");
    });
  });
});
