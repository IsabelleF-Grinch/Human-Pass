"use client";
import { factoryAbi, factoryAddress } from "@/constants";
import { useEffect } from "react";
import { useAccount, useReadContract } from "wagmi";

export const useContract = () => {
  const { address: userAddress, isConnected } = useAccount();

  const {
    data: deployer,
    isError: deployerError,
    isLoading: deployerLoading,
  } = useReadContract({
    address: factoryAddress,
    abi: factoryAbi,
    functionName: "deployer",
  });

  //init data and synchronise the store
  useEffect(() => {
    if (!deployer !== undefined) {
      console.log(deployer);
    }
  }, [deployer]);

  const userRole = deployer === userAddress ? "admin" : undefined;

  const isLoading = deployerLoading;
  const isError = deployerError;

  return { isLoading, isError, isConnected, userRole };
};
