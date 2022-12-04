import { ContractReceipt, Transaction } from "ethers";
import { TransactionDescription, TransactionTypes } from "ethers/lib/utils";
import { ethers } from "hardhat";
import { DiamondCutFacet } from "../typechain-types";
import { getSelectors, FacetCutAction } from "./libraries/diamond";

export async function changeTreasuryAddress() {
  const accounts = await ethers.getSigners();
  const contractOwner = accounts[0];

  const DIAMOND_ADDRESS = "0x9eae3E4aF957137C0079DA73baa3484318e92BE2";

  const changeTreasuryAddress = await ethers.getContractAt(
    "UpgradeTreasuryAddressFacet",
    DIAMOND_ADDRESS
  );

    await (await changeTreasuryAddress.changeTreasuryOwnerAddress(
      "0x63ca9fb2f99da854a4296539708c76cf09ba310d",
      "0x79A123e40100560f90De9574aBED7CF07cE0a9e6"
    )).wait();

    await (await changeTreasuryAddress.changeTreasuryOwnerAddress(
      "0xa72652da12ff644539bb66b83d3b2b5cadd17503",
      "0x79A123e40100560f90De9574aBED7CF07cE0a9e6"
    )).wait();

    await (await changeTreasuryAddress.changeTreasuryOwnerAddress(
      "0x19f3a1bc9b5d0a4a244067dac8d1ac8cbd9b82a2",
      "0x79A123e40100560f90De9574aBED7CF07cE0a9e6"
    )).wait();

  console.log("Completed diamond cut");
}

if (require.main === module) {
  changeTreasuryAddress()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
}

exports.changeTreasuryAddress = changeTreasuryAddress;
