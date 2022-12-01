import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Signer that would be making changes: " + deployer.address);

  const KiwiLabsPayoutToken = "0xD90bE8d98f56b8B6B1Cc22f42bc990290032bC49";
  const KiwiLabsPrincipalToken = "0x0eE5D566BF57e8449809dc32D4B92BB2575b5848";

  const KiwiPayoutToken = "0x7DC7a2e041e1a03E1A378AEC5FFAC25D6C3E0795";
  const KiwiPrincipalToken = "0x86f515845c3451742d1dB85B77Fd53f83fA1D393";

  const BondiiPayoutToken = "0x5FB8d67252bA547C11edafFF83721C776108e2f9";
  const BondiiPrincipalToken = "0x5E15fAD1aFf0FF891d5165E27c19e974F660F600";

  const FarmiiPayoutToken = "0xDd06e25CD5Ef89d744Bc8c0A723688ddbb00aDE7";
  const FarmiiPrincipalToken = "0x8Af5405ab3C84E7aE6928f4848739E2950D0cD05";

  const RecieverAddress = "0x7A3E0DFf9B53fA0d3d1997903A48677399b22ce7";
  const sendAmount = ethers.utils.parseEther("1000");

  // KIWII LABS
  console.log("Sending KiwiLabsPayoutToken");
  const KiwiLabsPayoutTokenSend = await ethers.getContractAt(
    "BondPayoutToken",
    KiwiLabsPayoutToken
  );
  await (
    await KiwiLabsPayoutTokenSend.transfer(RecieverAddress, sendAmount)
  ).wait();
  console.log("KiwiLabsPayoutToken Sent");
  console.log("-=----=----=----=----=-");

  console.log("Sending KiwiLabsPrincipalToken");
  const KiwiLabsPrincipalTokenSend = await ethers.getContractAt(
    "BondPrincipalToken",
    KiwiLabsPrincipalToken
  );
  await (
    await KiwiLabsPrincipalTokenSend.transfer(RecieverAddress, sendAmount)
  ).wait();
  console.log("KiwiLabsPrincipalToken Sent");
  console.log("-=----=----=----=----=-");

  // KIWII
  console.log("Sending KiwiPayoutToken");
  const KiwiPayoutTokenSend = await ethers.getContractAt(
    "BondPayoutToken",
    KiwiPayoutToken
  );
  await (
    await KiwiPayoutTokenSend.transfer(RecieverAddress, sendAmount)
  ).wait();
  console.log("KiwiPayoutToken Sent");
  console.log("-=----=----=----=----=-");

  console.log("Sending KiwiPrincipalToken");
  const KiwiPrincipalTokenSend = await ethers.getContractAt(
    "BondPrincipalToken",
    KiwiPrincipalToken
  );
  await (
    await KiwiPrincipalTokenSend.transfer(RecieverAddress, sendAmount)
  ).wait();
  console.log("KiwiPrincipalToken Sent");
  console.log("-=----=----=----=----=-");

  // BONDII
  console.log("Sending BondiiPayoutToken");
  const BondiiPayoutTokenSend = await ethers.getContractAt(
    "BondPayoutToken",
    BondiiPayoutToken
  );
  await (
    await BondiiPayoutTokenSend.transfer(RecieverAddress, sendAmount)
  ).wait();
  console.log("BondiiPayoutToken Sent");
  console.log("-=----=----=----=----=-");

  console.log("Sending BondiiPrincipalToken");
  const BondiiPrincipalTokenSend = await ethers.getContractAt(
    "BondPrincipalToken",
    BondiiPrincipalToken
  );
  await (
    await BondiiPrincipalTokenSend.transfer(RecieverAddress, sendAmount)
  ).wait();
  console.log("BondiiPrincipalToken Sent");
  console.log("-=----=----=----=----=-");

  // FARMII
  console.log("Sending FarmiiPayoutToken");
  const FarmiiPayoutTokenSend = await ethers.getContractAt(
    "BondPayoutToken",
    FarmiiPayoutToken
  );
  await (
    await FarmiiPayoutTokenSend.transfer(RecieverAddress, sendAmount)
  ).wait();
  console.log("FarmiiPayoutToken Sent");
  console.log("-=----=----=----=----=-");

  console.log("Sending FarmiiPrincipalToken");
  const FarmiiPrincipalTokenSend = await ethers.getContractAt(
    "BondPrincipalToken",
    FarmiiPrincipalToken
  );
  await (
    await FarmiiPrincipalTokenSend.transfer(RecieverAddress, sendAmount)
  ).wait();
  console.log("FarmiiPrincipalToken Sent");
  console.log("-=----=----=----=----=-");
}

main()
  .then(() => process.exit())
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
