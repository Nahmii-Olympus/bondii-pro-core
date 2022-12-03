import { ethers } from "hardhat";

async function main() {
    const [kiwi_labs, kiwi, bondii, farmii] = await ethers.getSigners();

  const BOND_ONE = "0x4dda2a30c977ca2620311fd1f79ef7075f666cf9";
  const BOND_TWO = "0x48344c64265853c250ba1342682bea2d0d0a8284";
  const BOND_THREE = "0x707f6894782cc32fefb22ad583a1665e5434e77f";
  const BOND_FOUR = "0x259ca7662afd95c83bfc91c3b1620be754a2fb33";


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
