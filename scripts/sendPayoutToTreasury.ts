import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Signer that would be making changes: " + deployer.address);

  const KiwiLabsPayoutToken = "0xD90bE8d98f56b8B6B1Cc22f42bc990290032bC49";
  const KiwiLabsTreasury = "0x38a5e8ce331b7873dbbf6eaa9cb0fba8f42dde81";

  const KiwiPayoutToken = "0x7DC7a2e041e1a03E1A378AEC5FFAC25D6C3E0795";
  const KiwiTreasury = "0xce44ffe1d38c09e99b4aa01e5a1f0fa5d6088be2";

  const BondiiPayoutToken = "0x5FB8d67252bA547C11edafFF83721C776108e2f9";
  const BondiiTreasury = "0xd77a4913d4d74791309b27348dfdbf8b015dd67b";

  const FarmiiPayoutToken = "0xDd06e25CD5Ef89d744Bc8c0A723688ddbb00aDE7";
  const FarmiiTreasury = "0x75ea8bf6780d6e0309a1ea9e55da246dce3c23ea";

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
