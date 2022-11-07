import { ethers } from "hardhat";

async function main() {
  const NftWallet721 = await ethers.getContractFactory("NftWallet721");
  const nftWallet721 = await NftWallet721.deploy();
  await nftWallet721.deployed();
  console.log("NftWallet721 deployed to:", nftWallet721.address);

  const NftWallet1155 = await ethers.getContractFactory("NftWallet1155");
  const nftWallet1155 = await NftWallet1155.deploy();
  await nftWallet1155.deployed();
  console.log("NftWallet1155 deployed to:", nftWallet1155.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
