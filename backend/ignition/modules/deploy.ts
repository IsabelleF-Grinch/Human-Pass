// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const SBTDeploymentModule = buildModule("SBTDeploymentModule", (m) => {

  const implementationSBT = m.contract("ImplementationSBT");

  const sbtMinimalProxyFactory = m.contract("SBTMinimalProxyFactory", [
    implementationSBT,
  ]);

  return { implementationSBT, sbtMinimalProxyFactory };
});

export default SBTDeploymentModule;