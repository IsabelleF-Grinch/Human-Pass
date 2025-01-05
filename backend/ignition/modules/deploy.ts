// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

require('dotenv').config()

const ADDRESS_ADMIN = process.env.ADDRESS_ADMIN;

const SBTDeploymentModule = buildModule("SBTDeploymentModule", (m) => {
  const addressAdmin = m.getParameter("addressAdmin", ADDRESS_ADMIN);

  const implementationSBT = m.contract("ImplementationSBT", [addressAdmin]);

  const sbtMinimalProxyFactory = m.contract("SBTMinimalProxyFactory", [
    implementationSBT,
  ]);

  return { implementationSBT, sbtMinimalProxyFactory };
});

export default SBTDeploymentModule;