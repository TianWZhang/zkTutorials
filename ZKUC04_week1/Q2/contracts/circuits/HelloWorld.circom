pragma circom 2.0.0;

/*This circuit template checks that c is the multiplication of a and b.*/  

template Multiplier2 () {  

   // Declaration of signals.  
   signal input a;  
   signal input b;  
   signal output c;  

   // Constraints.  
   c <== a * b;  
}

component main = Multiplier2();


// node generate_witness.js HelloWorld.wasm input.json witness.wtns

// snarkjs groth16 fullprove input.json HelloWorld.wasm ../circuit_final.zkey ../proof.json ../public.json

// cd ..
// snarkjs groth16 verify verification_key.json public.json proof.json