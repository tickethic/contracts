import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const TickethicModule = buildModule("Tickethic", (m) => {
  // Deploy tickethic contract
  const tickethic = m.contract("Tickethic");

  return { tickethic };
});

export default TickethicModule;
