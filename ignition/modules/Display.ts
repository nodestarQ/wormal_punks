import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const DisplayModule = buildModule("DisplayModule", (m) => {
  // Deploy all libraries that Display links against
  const AccData = m.contract("AccData");
  const AccLib = m.contract("AccLib");
  const BackgroundLib = m.contract("BackgroundLib");
  const BodyData = m.contract("BodyData");
  const BodyLib = m.contract("BodyLib");
  const EyeData = m.contract("EyeData");
  const EyeLib = m.contract("EyeLib");
  const HeadData = m.contract("HeadData");
  const HeadEndLib = m.contract("HeadEndLib");
  const HeadStartLib = m.contract("HeadStartLib");

  // Now deploy Display with explicit library linking
  const display = m.contract("Display", [], {
    libraries: {
      AccData,
      AccLib,
      BackgroundLib,
      BodyData,
      BodyLib,
      EyeData,
      EyeLib,
      HeadData,
      HeadEndLib,
      HeadStartLib,
    },
  });

  return {
    display,
    AccData,
    AccLib,
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
