import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import DisplayModule from "./Display.js";

const CypherWormsModule = buildModule("CypherWormsModule", (m) => {
  // Get parameters from deployment config or use defaults
  // For testnet: use fallback addresses if ENS resolution fails
  const primaryRecipient = m.getParameter(
    "primaryRecipient",
    "0x0000000000000000000000000000000000000000" // Will be replaced with actual address
  );
  
  const secondaryRecipient = m.getParameter(
    "secondaryRecipient",
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
    primaryRecipient,
    secondaryRecipient,
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
