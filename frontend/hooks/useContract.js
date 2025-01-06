"use client";
import { factoryAbi, factoryAddress } from "@/constants";
import { useEffect } from "react";
import {
  useAccount,
  useReadContract,
  useWaitForTransactionReceipt,
  useWriteContract,
} from "wagmi";

export const useContract = () => {
  const { address: userAddress, isConnected } = useAccount();
  const {
    data: hash,
    isPending,
    error: txError,
    writeContract,
  } = useWriteContract();

  const {
    isLoading: isTxConfirming,
    isSuccess: isTxConfirmed,
    error: receiptError,
  } = useWaitForTransactionReceipt({
    hash,
  });

  //READ
  const {
    data: deployer,
    isError: deployerError,
    isLoading: deployerLoading,
  } = useReadContract({
    address: factoryAddress,
    abi: factoryAbi,
    functionName: "deployer",
  });

  //CREATE CLONE
  const createClone = async () => {
    try {
      writeContract({
        address: factoryAddress,
        abi: factoryAbi,
        functionName: "createNewClone",
      });
    } catch (error) {
      console.error("Transaction Error:", error);
      alert("Failed to send transaction: ", error.message);
    }
  };

  useEffect(() => {
    if (!deployer !== undefined) {
      console.log(deployer);
    }
  }, [deployer]);

  useEffect(() => {
    if (isPending) {
      alert("Tx is pending... 🫣");
    }
    if (isTxConfirmed) {
      alert("Tx is confirmed 😁!", `Transaction Hash : ${hash}`);
    }
    if (txError) {
      alert("Tx is failed 🥴!", `Error content txError: ${txError?.message}`);
    }
    if (receiptError) {
      alert(
        "Tx is not received 🥴!",
        `Error content receiptError: ${receiptError?.message}`
      );
    }
  }, [isPending, isTxConfirmed, txError, receiptError]);

  const userRole = deployer === userAddress ? "admin" : undefined;

  const isLoading = deployerLoading;
  const isError = deployerError;

  return {
    isLoading,
    isError,
    isConnected,
    userRole,
    isTxConfirming,
    isTxConfirmed,
    createClone,
  };
};
