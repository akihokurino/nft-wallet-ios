import { expect } from "chai";
import { ethers } from "hardhat";

describe("NftWallet1155", function () {
  it("should mint and token url", async function () {
    const [owner] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("NftWallet1155");
    const contract = await Contract.deploy();
    await contract.deployed();

    await contract.mint(owner.address, "1234", 1);
    expect(await contract.uri(1)).to.equal(
      "https://ipfs.moralis.io:2053/ipfs/1234"
    );

    await contract.mint(owner.address, "5678", 1);
    expect(await contract.uri(2)).to.equal(
      "https://ipfs.moralis.io:2053/ipfs/5678"
    );
  });
});
