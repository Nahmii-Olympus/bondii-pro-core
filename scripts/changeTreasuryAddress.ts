import { ContractReceipt, Transaction } from "ethers";
import { TransactionDescription, TransactionTypes } from "ethers/lib/utils";
import { ethers } from "hardhat";
import { DiamondCutFacet } from "../typechain-types";
import { getSelectors, FacetCutAction } from "./libraries/diamond";




export async function changeTreasuryAddress() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];

    const DIAMOND_ADDRESS = "0x9eae3E4aF957137C0079DA73baa3484318e92BE2";

    const changeTreasuryAddress = await ethers.getContractAt("UpgradeTreasuryAddressFacet", DIAMOND_ADDRESS)

    const changeTreasuryAddressTxn = await changeTreasuryAddress.changeTreasuryOwnerAddress("0x38a5e8ce331b7873dbbf6eaa9cb0fba8f42dde81", "0x7A3E0DFf9B53fA0d3d1997903A48677399b22ce7");
    const changeTreasuryAddressReceipt = await changeTreasuryAddressTxn.wait();
    console.log("RECIPT: ", changeTreasuryAddressReceipt);
    
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

exports.deployDiamond = changeTreasuryAddress;