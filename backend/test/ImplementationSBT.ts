import {
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";
import { ImplementationSBT, SBTMinimalProxyFactory } from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { ContractTransactionResponse } from "ethers";


const getGas = async (tx: ContractTransactionResponse) => {
  const receipt = await hre.ethers.provider.getTransactionReceipt(tx.hash);
  return receipt!.gasUsed.toString();
};


describe("Human Pass", function () {
  let masterContract: ImplementationSBT;
  let factory: SBTMinimalProxyFactory;
  let owner: HardhatEthersSigner, addr1: HardhatEthersSigner, addr2: HardhatEthersSigner;

  const deployFixture = async () => {
    [owner, addr1, addr2] = await hre.ethers.getSigners();

    let ImplementationSBT = await hre.ethers.getContractFactory("ImplementationSBT");
    masterContract = (await ImplementationSBT.deploy()) as ImplementationSBT;

    let SBTMinimalProxyFactory = await hre.ethers.getContractFactory("SBTMinimalProxyFactory");
    factory = (await SBTMinimalProxyFactory.deploy(masterContract.getAddress())) as SBTMinimalProxyFactory;

    return { masterContract, factory, owner, addr1, addr2 }
  }

  describe("Initialization", function () {

    it("Should deploy the implementation contract and factory", async function () {
      const { masterContract, factory } = await loadFixture(deployFixture);
      expect(masterContract.getAddress).to.exist;
      expect(factory.getAddress).to.exist;
    });

    it("Should measure gas costs of deploying contracts and creating a clone", async function () {
      const { masterContract, factory } = await loadFixture(deployFixture);

      const masterContractGasUsed = Number(await getGas(masterContract.deploymentTransaction()!));
      console.log("Gas cost for deploying ImplementationSBT:", masterContractGasUsed);

      const tx = await factory.createNewClone();
      const proxyGasUsed = Number(await getGas(tx));
      console.log("Gas cost for creating a clone:", proxyGasUsed);

      const gasSavings = (100 - (proxyGasUsed / masterContractGasUsed) * 100).toFixed(2);
      console.log("Gas cost savings with minimal proxy:", `${gasSavings}%`);

      expect(proxyGasUsed).to.be.lessThan(masterContractGasUsed);
    });
  });

});
