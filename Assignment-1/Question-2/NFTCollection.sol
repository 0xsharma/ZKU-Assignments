// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.1;

import "@openzeppelin/contracts@4.5.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.5.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.5.0/utils/Counters.sol";
import "./merkleTree.sol";

contract ZKMint is ERC721, ERC721URIStorage, MerkleTree {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => bytes) private _tokenURIs;

    constructor(
        string memory collectionName,
        string memory collectionSymbol,
        uint32 merkleTreeLevels
    ) ERC721(collectionName, collectionSymbol) MerkleTree(merkleTreeLevels) {}

    function _setTokenURI(uint256 tokenId, bytes memory _tokenURI) internal {
        _tokenURIs[tokenId] = _tokenURI;
    }

    function safeMint(
        address to,
        string memory name,
        string memory description
    ) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "',
            name,
            '",',
            '"description": "',
            description,
            '"',
            "}"
        );

        _setTokenURI(tokenId, dataURI);

        addLeaf(keccak256(abi.encodePacked(msg.sender, to, tokenId, dataURI)));
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        require(_exists(tokenId), "ZKMint: Token does not exist");
        return string(_tokenURIs[tokenId]);
    }
}
