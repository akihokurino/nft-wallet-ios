//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NftWallet1155 is Context, ERC1155, Ownable {
    mapping(string => uint256) private _ipfsHash2token;
    mapping(uint256 => string) private _token2ipfsHash;
    uint256 _localTokenId = 1;

    string public name = "NftWallet1155";
    string public symbol = "NW";

    constructor() ERC1155("") {}

    function mint(
        address to,
        string memory ipfsHash,
        uint256 amount
    ) public virtual onlyOwner {
        require(_ipfsHash2token[ipfsHash] == 0, "already mint");

        uint256 tokenId = _localTokenId;

        _ipfsHash2token[ipfsHash] = tokenId;
        _token2ipfsHash[tokenId] = ipfsHash;

        _mint(to, tokenId, amount, "");

        _localTokenId += 1;
    }

    function uri(uint256 tokenId)
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
