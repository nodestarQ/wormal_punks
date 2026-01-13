import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import DisplayModule from "./Display.js";

const CypherWormsModule = buildModule("CypherWormsModule", (m) => {
  // Get payment recipient from deployment config or use default
  // This can be an EOA initially, or a splitter contract address
  const paymentRecipient = m.getParameter(
    "paymentRecipient",
    "0x0000000000000000000000000000000000000000" // Will be replaced with actual address
  );

  // Import Display deployment
  const { display } = m.useModule(DisplayModule);

  const specialEnd = m.library("SpecialEnd", { after: [display] });
  const preReveal = m.library("PreReveal", { after: [display] });
  const special = m.library("Special", { 
    after: [specialEnd, preReveal],
    libraries: {
      SpecialEnd: specialEnd,
    },
  });

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

  m.call(cypherWorms, "setupRoyalties", []);

  return { cypherWorms, display, preReveal, special, specialEnd };
});

export default CypherWormsModule;
