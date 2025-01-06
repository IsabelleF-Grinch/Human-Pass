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

  describe("Minting SBT", function () {
    it("Should mint a new SBT for the minter", async function () {
      const { masterContract, addr1, owner } = await loadFixture(deployFixture);
      await masterContract.initialize(owner.address, addr1.address);

      const tokenId = 1;
      await masterContract.connect(addr1).mint(addr1.address, tokenId, 1); // BurnAuth.IssuerOnly

      expect(await masterContract.ownerOf(tokenId)).to.equal(addr1.address);
      expect(await masterContract.getTokenIdByAddress(addr1.address)).to.equal(tokenId);
    });

    it("Should fail if someone other than the minter tries to mint", async function () {
      const { masterContract, addr1, owner } = await loadFixture(deployFixture);
      await masterContract.initialize(owner.address, addr1.address);

      await expect(masterContract.connect(owner).mint(owner.address, 2, 1)).to.be.reverted;
    });

    it("Should revert if minter tries to mint for someone else", async function () {
      const { masterContract, addr1, owner } = await loadFixture(deployFixture);
      await masterContract.initialize(owner.address, addr1.address);

      await expect(masterContract.connect(addr1).mint(addr2.address, 3, 1)).to.be.revertedWith("Minter must mint for themselves");
    });
  });

  describe("Burning SBT", function () {
    it("Should allow the owner or minter (issuer) to burn if burn authorization is Both", async function () {
      const { masterContract, owner, addr2, addr1 } = await loadFixture(deployFixture);

      await masterContract.initialize(owner.address, addr1.address);

      const tokenId = 1;

      await masterContract.connect(addr1).mint(addr1.address, tokenId, 2); // BurnAuth.Both

      await expect(masterContract.connect(addr1).burn(tokenId)).to.not.be.reverted;

      await masterContract.connect(addr1).mint(addr1.address, tokenId, 2); // Remint avec Both

      await expect(masterContract.connect(owner).burn(tokenId)).to.not.be.reverted;

      await expect(masterContract.ownerOf(tokenId)).to.be.reverted;
    });

    it("Should revert if unauthorized user tries to burn", async function () {
      const { masterContract, addr1, addr2 } = await loadFixture(deployFixture);
      await masterContract.initialize(addr1.address, addr1.address);

      const tokenId = 3;
      await masterContract.connect(addr1).mint(addr1.address, tokenId, 1); // BurnAuth.IssuerOnly

      await expect(masterContract.connect(addr2).burn(tokenId)).to.be.revertedWith("Access denied: must have ADMIN or BURNER role");
    });

    it("Should revert if burn authorization is Neither", async function () {
      const { masterContract, addr1 } = await loadFixture(deployFixture);
      await masterContract.initialize(addr1.address, addr1.address);

      const tokenId = 4;
      await masterContract.connect(addr1).mint(addr1.address, tokenId, 3); // BurnAuth.Neither

      await expect(masterContract.connect(addr1).burn(tokenId)).to.be.revertedWith("Burning is not allowed for this token");
    });
  });

  describe("Admin Role Management", function () {
    it("Should transfer the admin role", async function () {
      const { masterContract, owner, addr1, addr2 } = await loadFixture(deployFixture);
      await masterContract.initialize(owner.address, addr1.address);

      await masterContract.connect(owner).transferAdminRole(addr2.address);

      expect(await masterContract.getRoleMemberCount(await masterContract.ADMIN_ROLE())).to.equal(1);
    });

    it("Should revert if a non-admin tries to transfer admin role", async function () {
      const { masterContract, addr1, addr2, owner } = await loadFixture(deployFixture);
      await masterContract.initialize(owner.address, addr1.address);

      await expect(masterContract.connect(addr2).transferAdminRole(addr2.address)).to.be.reverted;
    });
  });

  describe("Soulbound Behavior", function () {
    it("Should revert on token transfer attempts", async function () {
      const { masterContract, addr1, addr2 } = await loadFixture(deployFixture);
      await masterContract.initialize(addr1.address, addr1.address);

      const tokenId = 5;
      await masterContract.connect(addr1).mint(addr1.address, tokenId, 1);

      await expect(masterContract.connect(addr1).transferFrom(addr1.address, addr2.address, tokenId)).to.be.revertedWith("SBT: transfer not allowed");
    });
  });

});
