//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NftWallet721 is ERC721Enumerable, Ownable {
    mapping(string => uint256) private _ipfsHash2token;
    mapping(uint256 => string) private _token2ipfsHash;
    uint256 _localTokenId = 1;

    constructor() ERC721("NftWallet721", "NW") {}

    function mint(address to, string memory ipfsHash) public virtual onlyOwner {
        require(_ipfsHash2token[ipfsHash] == 0, "already mint");

        uint256 tokenId = _localTokenId;

        _ipfsHash2token[ipfsHash] = tokenId;
        _token2ipfsHash[tokenId] = ipfsHash;

        _mint(to, tokenId);

        _localTokenId += 1;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        string memory ipfsHash = _token2ipfsHash[tokenId];

        return
            string(
                abi.encodePacked("https://ipfs.moralis.io:2053/ipfs/", ipfsHash)
            );
    }
}
