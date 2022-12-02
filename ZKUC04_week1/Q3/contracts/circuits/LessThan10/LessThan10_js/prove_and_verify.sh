#!/bin/bash

node generate_witness.js LessThan10.wasm input.json witness.wtns

snarkjs groth16 fullprove input.json LessThan10.wasm ../circuit_final.zkey ../proof.json ../public.json

cd ..
snarkjs groth16 verify verification_key.json public.json proof.json