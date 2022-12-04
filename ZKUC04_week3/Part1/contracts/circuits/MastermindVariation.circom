pragma circom 2.0.0;

//implement a variation of mastermind from https://en.wikipedia.org/wiki/Mastermind_(board_game)#Variation as a circuit

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";

template MastermindVariation() {
    // Public inputs
    signal input pubGuessA;
    signal input pubGuessB;
    signal input pubGuessC;
    signal input pubGuessD;
    signal input pubGuessE;
    signal input pubGuessF;
    signal input pubNumHit;
    signal input pubNumBlow;
    signal input pubSolnHash;

    // Private inputs
    signal input privSolnA;
    signal input privSolnB;
    signal input privSolnC;
    signal input privSolnD;
    signal input privSolnE;
    signal input privSolnF;
    signal input privSalt;

    // Output
    signal output solnHashOut;

    var guess[6] = [pubGuessA, pubGuessB, pubGuessC, pubGuessD, pubGuessE, pubGuessF];
    var soln[6] =  [privSolnA, privSolnB, privSolnC, privSolnD, privSolnE, privSolnF];
    var j = 0;
    var k = 0;
    component lessThan[12];
    component equalGuess[15];
    component equalSoln[15];
    var equalIdx = 0;

    // Create a constraint that the solution and guess digits are all less than 10.
    for (j=0; j<6; j++) {
        lessThan[j] = LessThan(4);
        lessThan[j].in[0] <== guess[j];
        lessThan[j].in[1] <== 10;
        lessThan[j].out === 1;
        lessThan[j+6] = LessThan(4);
        lessThan[j+6].in[0] <== soln[j];
        lessThan[j+6].in[1] <== 10;
        lessThan[j+6].out === 1;
        for (k=j+1; k<6; k++) {
            // Create a constraint that the solution and guess digits are unique. no duplication.
            equalGuess[equalIdx] = IsEqual();
            equalGuess[equalIdx].in[0] <== guess[j];
            equalGuess[equalIdx].in[1] <== guess[k];
            equalGuess[equalIdx].out === 0;
            equalSoln[equalIdx] = IsEqual();
            equalSoln[equalIdx].in[0] <== soln[j];
            equalSoln[equalIdx].in[1] <== soln[k];
            equalSoln[equalIdx].out === 0;
            equalIdx += 1;
        }
    }

    // Count hit & blow
    var hit = 0;
    var blow = 0;
    component equalHB[36];

    for (j=0; j<6; j++) {
        for (k=0; k<6; k++) {
            equalHB[6*j+k] = IsEqual();
            equalHB[6*j+k].in[0] <== soln[j];
            equalHB[6*j+k].in[1] <== guess[k];
            blow += equalHB[6*j+k].out;
            if (j == k) {
                hit += equalHB[6*j+k].out;
                blow -= equalHB[6*j+k].out;
            }
        }
    }

    // Create a constraint around the number of hit
    component equalHit = IsEqual();
    equalHit.in[0] <== pubNumHit;
    equalHit.in[1] <== hit;
    equalHit.out === 1;
    
    // Create a constraint around the number of blow
    component equalBlow = IsEqual();
    equalBlow.in[0] <== pubNumBlow;
    equalBlow.in[1] <== blow;
    equalBlow.out === 1;

    // Verify that the hash of the private solution matches pubSolnHash
    component poseidon = Poseidon(7);
    poseidon.inputs[0] <== privSalt;
    poseidon.inputs[1] <== privSolnA;
    poseidon.inputs[2] <== privSolnB;
    poseidon.inputs[3] <== privSolnC;
    poseidon.inputs[4] <== privSolnD;
    poseidon.inputs[5] <== privSolnE;
    poseidon.inputs[6] <== privSolnF;

    solnHashOut <== poseidon.out;
    pubSolnHash === solnHashOut;
 }

 component main {public [pubGuessA, pubGuessB, pubGuessC, pubGuessD, pubGuessE, pubGuessF, pubNumHit, pubNumBlow, pubSolnHash]} = MastermindVariation();