import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { network } from "hardhat";

describe("Sigil", async function () {
  const { viem } = await network.connect();

  it("Should return an svg string", async function () {
    const sigil = await viem.deployContract("Sigil");

    const result = await sigil.read.svg(
      ["0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8"]
    );

    assert.ok(typeof result === "string");
    assert.ok(result.startsWith("<svg"));
    assert.ok(result.endsWith("</svg>"));
    assert.ok(result.includes('viewBox="0 0 8 8"'));
    assert.ok(result.includes("<rect"));
    assert.ok(!result.includes("width=\"100%\""));
  });
});
