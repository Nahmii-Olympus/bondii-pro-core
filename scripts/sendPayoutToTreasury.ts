import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Signer that would be making changes: " + deployer.address);

  const KiwiLabsPayoutToken = "0xD90bE8d98f56b8B6B1Cc22f42bc990290032bC49";
  const KiwiLabsTreasury = "0x01b5ae984ea55345aeae4023dfd1fd7b2192acd0";

  const KiwiPayoutToken = "0x7DC7a2e041e1a03E1A378AEC5FFAC25D6C3E0795";
  const KiwiTreasury = "0x63ca9fb2f99da854a4296539708c76cf09ba310d";

  const BondiiPayoutToken = "0x5FB8d67252bA547C11edafFF83721C776108e2f9";
  const BondiiTreasury = "0xa72652da12ff644539bb66b83d3b2b5cadd17503";

  const FarmiiPayoutToken = "0xDd06e25CD5Ef89d744Bc8c0A723688ddbb00aDE7";
  const FarmiiTreasury = "0x19f3a1bc9b5d0a4a244067dac8d1ac8cbd9b82a2";

  const sendAmount = ethers.utils.parseEther("1000");

  // KIWII LABS
  console.log("Sending KiwiLabsPayoutToken");
  const KiwiLabsPayoutTokenSend = await ethers.getContractAt(
    "BondPayoutToken",
    KiwiLabsPayoutToken
  );
  await (
    await KiwiLabsPayoutTokenSend.transfer(KiwiLabsTreasury, sendAmount)
  ).wait();
  console.log("KiwiLabsPayoutToken Sent");
  console.log("-=----=----=----=----=-");

  // KIWII
  console.log("Sending KiwiPayoutToken");
  const KiwiPayoutTokenSend = await ethers.getContractAt(
    "BondPayoutToken",
    KiwiPayoutToken
  );
  await (await KiwiPayoutTokenSend.transfer(KiwiTreasury, sendAmount)).wait();
  console.log("KiwiPayoutToken Sent");
  console.log("-=----=----=----=----=-");

  // BONDII
  console.log("Sending BondiiPayoutToken");
  const BondiiPayoutTokenSend = await ethers.getContractAt(
    "BondPayoutToken",
    BondiiPayoutToken
  );
  await (
    await BondiiPayoutTokenSend.transfer(BondiiTreasury, sendAmount)
  ).wait();
  console.log("BondiiPayoutToken Sent");
  console.log("-=----=----=----=----=-");

  // FARMII
  console.log("Sending FarmiiPayoutToken");
  const FarmiiPayoutTokenSend = await ethers.getContractAt(
    "BondPayoutToken",
    FarmiiPayoutToken
  );
  await (
    await FarmiiPayoutTokenSend.transfer(FarmiiTreasury, sendAmount)
  ).wait();
  console.log("FarmiiPayoutToken Sent");
  console.log("-=----=----=----=----=-");
}

main()
  .then(() => process.exit())
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
