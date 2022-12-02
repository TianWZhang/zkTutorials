pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib-matrix/circuits/matMul.circom"; 

template SystemOfEquations(n) { // n is the number of variables in the system of equations
    signal input x[n]; // this is the solution to the system of equations
    signal input A[n][n]; // this is the coefficient matrix
    signal input b[n]; // this are the constants in the system of equations
    signal output out; // 1 for correct solution, 0 for incorrect solution

    component matmul = matMul(n,n,1);
    component isEquals[n + 1];
    for(var i = 0; i < n; i++){
      matmul.b[i][0] <== x[i];
      for(var j = 0; j < n; j++){
        matmul.a[i][j] <== A[i][j];
      }
    }
    var correct = 1;
    for(var i = 0; i < n; i++){
      isEquals[i] = IsEqual();
      isEquals[i].in[0] <== matmul.out[i][0];
      isEquals[i].in[1] <== b[i];
      correct += isEquals[i].out;
    }

    isEquals[n] = IsEqual();
    isEquals[n].in[0] <== correct;
    isEquals[n].in[1] <== n;
    out <== isEquals[n].out;

}

component main {public [A, b]} = SystemOfEquations(3);