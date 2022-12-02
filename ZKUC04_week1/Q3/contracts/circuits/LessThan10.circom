pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";

template LessThan10() {
    signal input in;
    signal output out;

    // n = 32 is the number of bits the input have
    component lt = LessThan(32); 

    lt.in[0] <== in;
    lt.in[1] <== 10;
    // log(lt.out);
    lt.out === 1;
    out <== lt.out;
}

/* 
  template LessThan(n) {
    assert(n <= 252);
    signal input in[2];
    signal output out;

    component n2b = Num2Bits(n+1);

    n2b.in <== in[0]+ (1<<n) - in[1];

// out = 1 <=> n-th bit of 2^n + in[0] - in[1] is 0 <=> 2^n + in[0] - in[1] < 2^n
    out <== 1-n2b.out[n];
}


template LessEqThan(n) {
    signal input in[2];
    signal output out;

    component lt = LessThan(n);

    lt.in[0] <== in[0];
    lt.in[1] <== in[1]+1;
    lt.out ==> out;
} 
*/

component main = LessThan10();