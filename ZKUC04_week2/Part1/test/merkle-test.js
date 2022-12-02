const { poseidonContract } = require("circomlibjs");
const { expect, assert } = require("chai");
const { ethers } = require("hardhat");
const { groth16 } = require("snarkjs");

describe("MerkleTree", function () {
  let merkleTree;

  beforeEach(async function () {
    const PoseidonT3 = await ethers.getContractFactory(
      poseidonContract.generateABI(2),
      poseidonContract.createCode(2)
    );
    const poseidonT3 = await PoseidonT3.deploy();
    await poseidonT3.deployed();

    const MerkleTree = await ethers.getContractFactory("MerkleTree", {
      libraries: {
        PoseidonT3: poseidonT3.address,
      },
    });
    merkleTree = await MerkleTree.deploy();
    await merkleTree.deployed();
  });

  it("Insert two new leaves and verify the first leaf in an inclusion proof", async function () {
    await merkleTree.insertLeaf(1);
    await merkleTree.insertLeaf(2);

    const node9 = (await merkleTree.hashes(9)).toString();
    const node13 = (await merkleTree.hashes(13)).toString();

    const Input = {
      leaf: "1",
      path_elements: ["2", node9, node13],
      path_index: ["0", "0", "0"],
    };
    const { proof, publicSignals } = await groth16.fullProve(
      Input,
      "circuits/circuit_js/circuit.wasm",
      "circuits/circuit_final.zkey"
    );

    // console.log(publicSignals);
    /* 
      ['20161225477920193805297228662770941887575505616671213902278034173284418545660'] 
    */

    const calldata = await groth16.exportSolidityCallData(proof, publicSignals);

    const argv = calldata
      .replace(/["[\]\s]/g, "")
      .split(",")
      .map((x) => BigInt(x).toString());
    // console.log(argv.length); //9

    const a = [argv[0], argv[1]];
    const b = [
      [argv[2], argv[3]],
      [argv[4], argv[5]],
    ];
    const c = [argv[6], argv[7]];
    const input = argv.slice(8);
    console.log(input[0]); //input[0] should be merkleTree.root
    // 20161225477920193805297228662770941887575505616671213902278034173284418545660
    console.log((await merkleTree.root()).toString());
    // 20161225477920193805297228662770941887575505616671213902278034173284418545660

    expect(await merkleTree.verify(a, b, c, input)).to.be.true;
  });

  it("Insert two new leaves and verify the second leaf with the inclusion proof", async function () {
    await merkleTree.insertLeaf(19980713);
    await merkleTree.insertLeaf(19980825);

    const node9 = (await merkleTree.hashes(9)).toString();
    const node13 = (await merkleTree.hashes(13)).toString();

    const Input = {
      leaf: "19980825",
      path_elements: ["19980713", node9, node13],
      path_index: ["1", "0", "0"],
    };
    const { proof, publicSignals } = await groth16.fullProve(
      Input,
      "circuits/circuit_js/circuit.wasm",
      "circuits/circuit_final.zkey"
    );
    const calldata = await groth16.exportSolidityCallData(proof, publicSignals);
    const argv = calldata
      .replace(/["[\]\s]/g, "")
      .split(",")
      .map((x) => BigInt(x).toString());
    const a = [argv[0], argv[1]];
    const b = [
      [argv[2], argv[3]],
      [argv[4], argv[5]],
    ];
    const c = [argv[6], argv[7]];
    const input = argv.slice(8);
    assert(await merkleTree.verify(a, b, c, input));
  });
});
