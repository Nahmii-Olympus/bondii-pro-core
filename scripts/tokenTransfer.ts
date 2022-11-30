import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Signer that would be making changes: " + deployer.address);

  const KiwiLabsPayoutToken = "0xFdc78DA8Bbd584C6f6E14468c77b6f09105CA63f";
  const KiwiLabsPrincipalToken = "0xaDBA987955Eac146f1983062100046be46e632fA";

  const KiwiPayoutToken = "0x9e92DE115F6c5a66c77062434Fa4F787Fd32daa9";
  const KiwiPrincipalToken = "0xE9d590484Cf0e68FF30bb5589658CD9B6cEd096f";

  const BondiiPayoutToken = "0x0519C43Cdf9B75Ba0a265B3330655A0cAF6D4ED3";
  const BondiiPrincipalToken = "0x1d4657f5dD44ff59E14973862e0749978B74A7c0";

  const FarmiiPayoutToken = "0xD410219f5C87247d3F109695275A70Da7805f1b1";
  const FarmiiPrincipalToken = "0x5C8f5D80FD653a885832dF5c1f09978C81A8cDC4";

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
