//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {PoseidonT3} from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        //initialize a Merkle tree of 8 with blank leaves
        hashes = new uint256[](15);
        hashes[14] = root;
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        hashes[index] = hashedLeaf;
        if (index % 2 == 0) {
            hashes[8 + index / 2] = PoseidonT3.poseidon(
                [hashedLeaf, hashes[index + 1]]
            );
            if (index % 4 == 0) {
                hashes[12 + index / 4] = PoseidonT3.poseidon(
                    [hashes[8 + index / 2], hashes[9 + index / 2]]
                );
            } else {
                hashes[12 + index / 4] = PoseidonT3.poseidon(
                    [hashes[7 + index / 2], hashes[8 + index / 2]]
                );
            }

            root = PoseidonT3.poseidon([hashes[12], hashes[13]]);
            hashes[14] = root;
        } else {
            hashes[8 + index / 2] = PoseidonT3.poseidon(
                [hashes[index - 1], hashedLeaf]
            );
            if (index % 4 == 1) {
                hashes[12 + index / 4] = PoseidonT3.poseidon(
                    [hashes[8 + index / 2], hashes[9 + index / 2]]
                );
            } else {
                hashes[12 + index / 4] = PoseidonT3.poseidon(
                    [hashes[7 + index / 2], hashes[8 + index / 2]]
                );
            }
            root = PoseidonT3.poseidon([hashes[12], hashes[13]]);
            hashes[14] = root;
        }
        index++;
        return root;
    }

    function verify(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[1] memory input
    ) public view returns (bool) {
        //verify an inclusion proof and check that the proof root matches current root
        return verifyProof(a, b, c, input) && (input[0] == root);
    }
}
