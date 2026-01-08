import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const DisplayModule = buildModule("DisplayModule", (m) => {
  // Deploy all data libraries sequentially to avoid nonce conflicts
  const AccData = m.library("AccData");
  const BodyData = m.library("BodyData", { after: [AccData] });
  const EyeData = m.library("EyeData", { after: [BodyData] });
  const HeadData = m.library("HeadData", { after: [EyeData] });
  
  // Deploy functional libraries sequentially after data libraries
  const AccLib = m.library("AccLib", { after: [HeadData] });
  const BackgroundLib = m.library("BackgroundLib", { after: [AccLib] });
  const BodyLib = m.library("BodyLib", { after: [BackgroundLib] });
  const EyeLib = m.library("EyeLib", { after: [BodyLib] });
  const HeadEndLib = m.library("HeadEndLib", { after: [EyeLib] });
  const HeadStartLib = m.library("HeadStartLib", { after: [HeadEndLib] });

  // Deploy Attributes library with its dependencies
  const Attributes = m.library("Attributes", {
    after: [HeadStartLib],
    libraries: {
      AccData,
      BackgroundLib,
      BodyData,
      EyeData,
      HeadData,
    },
  });

  // Now deploy Display with explicit library linking
  const display = m.contract("Display", [], {
    libraries: {
      AccLib,
      Attributes,
      BackgroundLib,
      BodyLib,
      EyeLib,
      HeadEndLib,
      HeadStartLib,
    },
  });

  return {
    display,
    AccData,
    AccLib,
    Attributes,
    BackgroundLib,
    BodyData,
    BodyLib,
    EyeData,
    EyeLib,
    HeadData,
    HeadEndLib,
    HeadStartLib,
  };
});

export default DisplayModule;
