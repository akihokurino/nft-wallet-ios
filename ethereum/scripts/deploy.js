// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const NftWallet721 = await hre.ethers.getContractFactory("NftWallet721");
  const nftWallet721 = await NftWallet721.deploy();
  await nftWallet721.deployed();
  console.log("NftWallet721 deployed to:", nftWallet721.address);

  const NftWallet1155 = await hre.ethers.getContractFactory("NftWallet1155");
  const nftWallet1155 = await NftWallet1155.deploy();
  await nftWallet1155.deployed();
  console.log("NftWallet1155 deployed to:", nftWallet1155.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
