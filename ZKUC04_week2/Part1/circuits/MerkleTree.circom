pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template DepthArray(d) { // compute the d-1 depth of the merkle tree with given the d depth of the merkle tree
    signal input depthD[2**d];
    signal output depthDMinusOne[2**(d-1)];
    component hashes[2**(d-1)];
    for (var j =0; j < 2**(d-1); j++){
        hashes[j] = Poseidon(2);
        hashes[j].inputs[0] <== depthD[j*2];
        hashes[j].inputs[1] <== depthD[j*2+1];
        depthDMinusOne[j] <== hashes[j].out;
    }
}

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;
    component components[n];
    components[0] = DepthArray(n);
    components[0].depthD <== leaves;
    var i;
    for (i = 1; i < n; i++) {
        components[i] = DepthArray(n-i);
        components[i].depthD <== components[i-1].depthDMinusOne;
    }
    root <== components[n-1].depthDMinusOne[0];
}



template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root;

    component hashes[n];
    hashes[0] = Poseidon(2);
    
    hashes[0].inputs[0] <== leaf - path_index[0] * (leaf - path_elements[0]);
    hashes[0].inputs[1] <== path_elements[0] - path_index[0] * (path_elements[0] - leaf);
    for(var i = 1; i < n; i++) {
      hashes[i] = Poseidon(2);
      hashes[i].inputs[0] <== hashes[i-1].out - path_index[i] * (hashes[i-1].out - path_index[i]);
      hashes[i].inputs[1] <== path_elements[i] - path_index[i] * (path_elements[i] - hashes[i-1].out);
    }
    root <== hashes[n-1].out;
 
}