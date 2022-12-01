import { ethers } from "hardhat";

async function main() {
    const [kiwi_labs, kiwi, bondii, farmii] = await ethers.getSigners();

  const BOND_ONE = "0xb1a10c237c3e58bca1a364b29c490d0841878d4d";
  const BOND_TWO = "0x753a05f136797819715fc3063aaedafff5ecc74f";
  const BOND_THREE = "0x8ba8ba5662a85b429bab961de4994aad74dd885b";
  const BOND_FOUR = "0x71e302878b2714c2f9b64a70001aa6835629dd33";


  const bondOne = await ethers.getContractAt("BondiiProBond", BOND_ONE);
  const bondTwo = await ethers.getContractAt("BondiiProBond", BOND_TWO);
  const bondThree = await ethers.getContractAt("BondiiProBond", BOND_THREE);
  const bondFour = await ethers.getContractAt("BondiiProBond", BOND_FOUR);

  console.log("Setting Bond terms");

  await (await bondOne.setBondTerms('0', '46200', "0x0eE5D566BF57e8449809dc32D4B92BB2575b5848")).wait();
  await (await bondTwo.connect(kiwi).setBondTerms('0', '46200', "0x86f515845c3451742d1dB85B77Fd53f83fA1D393")).wait();
  await (await bondThree.connect(bondii).setBondTerms('0', '46200', "0x5E15fAD1aFf0FF891d5165E27c19e974F660F600")).wait();
  await (await bondFour.connect(farmii).setBondTerms('0', '46200', "0x8Af5405ab3C84E7aE6928f4848739E2950D0cD05")).wait();
  
  console.log("Started Init");

  await (await bondOne.connect(kiwi_labs).initializeBond("500000", "46200", "1476000", "4", "60000000000000000000", "30000000000000000000", "0x0eE5D566BF57e8449809dc32D4B92BB2575b5848")).wait();
  await (await bondTwo.connect(kiwi).initializeBond("500000", "46200", "1476000", "4", "60000000000000000000", "30000000000000000000", "0x86f515845c3451742d1dB85B77Fd53f83fA1D393")).wait();
  await (await bondThree.connect(bondii).initializeBond("500000", "46200", "1476000", "4", "60000000000000000000", "30000000000000000000", "0x5E15fAD1aFf0FF891d5165E27c19e974F660F600")).wait();
  await (await bondFour.connect(farmii).initializeBond("500000", "46200", "1476000", "4", "60000000000000000000", "30000000000000000000", "0x8Af5405ab3C84E7aE6928f4848739E2950D0cD05")).wait();

  console.log("DONE")

}

main()
  .then(() => process.exit())
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
