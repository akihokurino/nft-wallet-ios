import { expect } from "chai";
import { ethers } from "hardhat";

describe("NftWallet721", function () {
  it("should mint and token url", async function () {
    const [owner] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("NftWallet721");
    const contract = await Contract.deploy();
    await contract.deployed();

    await contract.mint(owner.address, "1234");
    expect(await contract.tokenURI(1)).to.equal("ipfs://1234");

    await contract.mint(owner.address, "5678");
    expect(await contract.tokenURI(2)).to.equal("ipfs://5678");
  });
});
