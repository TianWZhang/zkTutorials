#!/bin/bash

node generate_witness.js RangeProof.wasm input.json witness.wtns

snarkjs groth16 fullprove input.json RangeProof.wasm ../circuit_final.zkey ../proof.json ../public.json

cd ..
snarkjs groth16 verify verification_key.json public.json proof.json