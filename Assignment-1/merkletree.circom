pragma circom 2.0.0;

include "node_modules/circomlib/circuits/mimc.circom";

// Calculate next layer of the tree
template branch(height) {
  var items = 1 << height;
  // input values
  signal input vals[items * 2];
  // output values
  signal output outs[items];

  component hash[items];
  for(var i = 0; i < items; i++) {
    hash[i] = MultiMiMC7(2,91);
    hash[i].in[0] <== vals[i * 2];
    hash[i].in[1] <== vals[i * 2 + 1];
    hash[i].k <== 0;
    hash[i].out ==> outs[i];
  }
}

// merkle tree construction from values
template merkleProof(levels) {
  signal input leaves[1 << levels];
  signal output root;

  component layers[levels];
  for(var level = levels - 1; level >= 0; level--) {
    layers[level] = branch(level);
    for(var i = 0; i < (1 << (level + 1)); i++) {
      layers[level].vals[i] <== level == levels - 1 ? leaves[i] : layers[level + 1].outs[i];
    }
  }
  root <== levels > 0 ? layers[0].outs[0] : leaves[0];
}

component main{public [leaves]} = merkleProof(3);
