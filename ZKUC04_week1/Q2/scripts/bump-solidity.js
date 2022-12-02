const fs = require("fs");
const solidityRegex = /pragma solidity \^\d+\.\d+\.\d+/;

const verifierRegex = /contract Verifier/;

let content = fs.readFileSync("./contracts/HelloWorldVerifier.sol", {
  encoding: "utf-8",
});
let bumped = content.replace(solidityRegex, "pragma solidity ^0.8.0");
bumped = bumped.replace(verifierRegex, "contract HelloWorldVerifier");
fs.writeFileSync("./contracts/HelloWorldVerifier.sol", bumped);

content = fs.readFileSync("./contracts/Multiplier3Verifier.sol", {
  encoding: "utf-8",
});
bumped = content.replace(solidityRegex, "pragma solidity ^0.8.0");
bumped = bumped.replace(verifierRegex, "contract Multiplier3Verifier");
fs.writeFileSync("./contracts/Multiplier3Verifier.sol", bumped);

let contentPlonk = fs.readFileSync(
  "./contracts/Multiplier3_plonkVerifier.sol",
  {
    encoding: "utf-8",
  }
);
let bumpedPlonk = contentPlonk.replace(solidityRegex, "pragma solidity ^0.8.0");
bumpedPlonk = bumpedPlonk.replace(
  /contract PlonkVerifier/,
  "contract Multiplier3_plonkVerifier"
);
fs.writeFileSync("./contracts/Multiplier3_plonkVerifier.sol", bumpedPlonk);
