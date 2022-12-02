import { ContractReceipt, Transaction } from "ethers";
import { TransactionDescription, TransactionTypes } from "ethers/lib/utils";
import { ethers } from "hardhat";
import { DiamondCutFacet } from "../typechain-types";
import { getSelectors, FacetCutAction } from "./libraries/diamond";

export async function upgradeDiamond() {
  const accounts = await ethers.getSigners();
  const contractOwner = accounts[0];

  const DIAMOND_INIT_ADDRESS = "0x3FCfD3C91550A2dc6EFee086ad55F07A75075b93";
  const diamondInit = await ethers.getContractAt(
    "DiamondInit",
    DIAMOND_INIT_ADDRESS
  );

  console.log("Deploying facets");
  const FacetNames = ["UpgradeTreasuryAddressFacet"];
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

  const DIAMOND_ADDRESS = "0x9eae3E4aF957137C0079DA73baa3484318e92BE2";
  const diamondCut = await ethers.getContractAt("IDiamondCut", DIAMOND_ADDRESS);

  let tx;
  let receipt: ContractReceipt;

  let functionCall = diamondInit.interface.encodeFunctionData("init");
  tx = await diamondCut.diamondCut(cut, DIAMOND_INIT_ADDRESS, functionCall);
  console.log("Diamond cut tx: ", tx.hash);
  receipt = await tx.wait();
  if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`);
  }

  console.log("Completed diamond cut");
}

if (require.main === module) {
  upgradeDiamond()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
}

exports.upgradeDiamond = upgradeDiamond;
