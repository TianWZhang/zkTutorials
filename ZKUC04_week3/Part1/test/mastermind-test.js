const { expect, assert } = require("chai");
const { ethers } = require("hardhat");
const { groth16 } = require("snarkjs");

const wasm_tester = require("circom_tester").wasm;

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString(
  "21888242871839275222246405745257275088548364400416034343698204186575808495617"
);
const Fr = new F1Field(exports.p);

describe("MastermindVariation", function () {
  this.timeout(100000000);
  let Verifier;
  let verifier;
  const INPUT = {
    pubGuessA: 1,
    pubGuessB: 2,
    pubGuessC: 3,
    pubGuessD: 4,
    pubGuessE: 5,
    pubGuessF: 6,
    pubNumHit: 1,
    pubNumBlow: 5,
    pubSolnHash:
      "10727664726187582085134051142421255562990626603200006470276324486327681102325",

    privSolnA: 2,
    privSolnB: 6,
    privSolnC: 3,
    privSolnD: 7,
    privSolnE: 4,
    privSolnF: 1,
    privSalt: 19981015,
  };

  beforeEach(async function () {
    Verifier = await ethers.getContractFactory("Verifier");
    verifier = await Verifier.deploy();
    await verifier.deployed();
  });

  it("Circuit should play mastermind game correctly", async function () {
    const circuit = await wasm_tester(
      "contracts/circuits/MastermindVariation.circom"
    );

    //log = true
    const witness = await circuit.calculateWitness(INPUT, true);

    console.log(witness);

    // assert(Fr.eq(Fr.e(witness[0]), Fr.e(1))); //Fr.e(1) = 1n
    // assert(Fr.eq(Fr.e(witness[1]), Fr.e(6))); //Fr.e(6) = 6n
  });

  it("Should return true for correct proof", async function () {
    const { proof, publicSignals } = await groth16.fullProve(
      INPUT,
      "contracts/circuits/MastermindVariation_js/MastermindVariation.wasm",
      "contracts/circuits/circuit_final.zkey"
    );

    console.log(publicSignals);

    const calldata = await groth16.exportSolidityCallData(proof, publicSignals);

    const argv = calldata
      .replace(/["[\]\s]/g, "")
      .split(",")
      .map((x) => BigInt(x).toString());
    console.log(argv.length);

    const a = [argv[0], argv[1]];
    const b = [
      [argv[2], argv[3]],
      [argv[4], argv[5]],
    ];
    const c = [argv[6], argv[7]];
    const Input = argv.slice(8);

    expect(await verifier.verifyProof(a, b, c, Input)).to.be.true;
  });

  it("Should return false for invalid proof", async function () {
    let a = [0, 0];
    let b = [
      [0, 0],
      [0, 0],
    ];
    let c = [0, 0];
    let d = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    expect(await verifier.verifyProof(a, b, c, d)).to.be.false;
  });
});
