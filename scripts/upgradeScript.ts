import { ContractReceipt, Transaction } from "ethers";
import { TransactionDescription, TransactionTypes } from "ethers/lib/utils";
import { ethers } from "hardhat";
import { DiamondCutFacet } from "../typechain-types";
import { getSelectors, FacetCutAction } from "./libraries/diamond";




export async function upgradeDiamond() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];

    const DIAMOND_ADDRESS = "0x9eae3E4aF957137C0079DA73baa3484318e92BE2";
    const diamondCut = await ethers.getContractAt("DiamondCutFacet", DIAMOND_ADDRESS);

    console.log("Deploying facets");
    const FacetNames = [
      "UpgradeTreasuryAddressFacet"
    ];
    const cut = [];
    for (const FacetName of FacetNames) {
      const Facet = await ethers.getContractFactory(FacetName);
      const facet = await Facet.deploy();
      await facet.deployed();
      console.log(`${FacetName} deployed: ${facet.address}`);
      cut.push({
        facetAddress: facet.address,
        action: FacetCutAction.Add,
        functionSelectors: getSelectors(facet),
      });
    }

    let tx;
    let receipt: ContractReceipt;
    tx = await diamondCut.diamondCut(cut, "0x", "");
    console.log("Diamond cut tx: ", tx.hash);
    receipt = await tx.wait();
    if (!receipt.status) {
      throw Error(`Diamond upgrade failed: ${tx.hash}`);
    }

    console.log("Completed diamond cut");
}