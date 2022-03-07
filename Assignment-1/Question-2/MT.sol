// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.1;

contract MerkleTree {
    mapping(uint32 => bytes32) public node;
    bytes32 public root;
    uint32 public levels;
    uint32 public next;
    uint32 internal maxLeaf;

    constructor(uint32 _levels) {
        levels = _levels;
        maxLeaf = uint32(2)**levels;
    }

    function addLeaf(bytes32 hashedLeaf) internal {
        require(next != maxLeaf, "Merkle Tree Full");
        node[next] = hashedLeaf; 
        updateTree(next);
        next++;
    }

    function updateTree(uint32 newLeafIndex) internal {
        uint32 nodeIndex = newLeafIndex; 
        bytes32 left;
        bytes32 right;
        uint32 offset; 
        uint32 nodeLevelIndex; 

        for (uint32 i = levels; i > 0; i--) {
            if (next % 2 == 0) {
                left = node[nodeIndex];
                right = node[nodeIndex+1];
            } else {
                left = node[nodeIndex-1];
                right = node[nodeIndex];
            }

            nodeLevelIndex = nodeIndex - offset;

            offset += uint32(2)**i;
            nodeIndex = nodeLevelIndex / 2 + offset;

            node[nodeIndex] = keccak256(abi.encodePacked(left, right));
        }

        root = node[nodeIndex]; 
    }

    function checkLeafExists(
        bytes32[] memory proof,
        bytes32 hashedLeaf,
        uint index
    ) public view returns (bool) {
        bytes32 hash = hashedLeaf;

        for (uint i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, proofElement));
            } else {
                hash = keccak256(abi.encodePacked(proofElement, hash));
            }

            index = index / 2;
        }

        return hash == root;
    }
}
