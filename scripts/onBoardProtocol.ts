import { ethers } from "hardhat";

async function main() {
  const [kiwi_labs, kiwi, bondii, farmii] = await ethers.getSigners();
  const DIAMOND_ADDRESS = "0x9eae3E4aF957137C0079DA73baa3484318e92BE2";

  const PolyBond = await ethers.getContractAt("OnBoardingFacet", DIAMOND_ADDRESS);
  
  console.log("Deploying components for Kiwi protocol");
  await (await PolyBond.connect(kiwi_labs).createBondTreasuryStaking(
    "0xD90bE8d98f56b8B6B1Cc22f42bc990290032bC49",
    "0xD90bE8d98f56b8B6B1Cc22f42bc990290032bC49",
    kiwi_labs.address,
    "0xD90bE8d98f56b8B6B1Cc22f42bc990290032bC49",
    "864000",
    kiwi_labs.address
  )).wait();

  console.log("DONE");



  console.log("Deploying components for Kiwi protocol");
  await (await PolyBond.connect(kiwi).createBondTreasuryStaking(
    "0x7DC7a2e041e1a03E1A378AEC5FFAC25D6C3E0795",
    "0x7DC7a2e041e1a03E1A378AEC5FFAC25D6C3E0795",
    kiwi_labs.address,
    "0x7DC7a2e041e1a03E1A378AEC5FFAC25D6C3E0795",
    "864000",
    kiwi.address
  )).wait();


  console.log("DONE");



  console.log("Deploying components for BONDII protocol");
  console.log(bondii.address);
  await (await PolyBond.connect(bondii).createBondTreasuryStaking(
    "0x5FB8d67252bA547C11edafFF83721C776108e2f9",
    "0x5FB8d67252bA547C11edafFF83721C776108e2f9",
    kiwi_labs.address,
    "0x5FB8d67252bA547C11edafFF83721C776108e2f9",
    "864000",
    bondii.address
  )).wait();


  console.log("DONE");

  console.log("Deploying components for BONDII protocol");
  await (await PolyBond.connect(farmii).createBondTreasuryStaking(
    "0xDd06e25CD5Ef89d744Bc8c0A723688ddbb00aDE7",
    "0xDd06e25CD5Ef89d744Bc8c0A723688ddbb00aDE7",
    kiwi_labs.address,
    "0xDd06e25CD5Ef89d744Bc8c0A723688ddbb00aDE7",
    "864000",
    farmii.address
  )).wait();

  console.log("DONE");


  console.log(kiwi_labs.address);
  console.log(kiwi.address);
  console.log(bondii.address);
  console.log(farmii.address);
}

main()
  .then(() => process.exit())
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
