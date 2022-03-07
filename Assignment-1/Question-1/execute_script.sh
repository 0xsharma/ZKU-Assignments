
# Compile a circuit

# --r1cs: it generates the file multiplier2.r1cs that contains the R1CS constraint system of the circuit in binary format.
# --wasm: it generates the directory multiplier2_js that contains the Wasm code (multiplier2.wasm) and other files needed to generate the witness.
# --sym : it generates the file multiplier2.sym , a symbols file required for debugging or for printing the constraint system in an annotated mode.
# --c : it generates the directory multiplier2_cpp that contains several files (multiplier2.cpp, multiplier2.dat, and other common files for every compiled program like main.cpp, MakeFile, etc) needed to compile the C code to generate the witness.

circom merkletree.circom --r1cs --wasm --sym --c

# copy generate_witness.js to root folder
cp ./merkletree_js/ .

# Computing the witness with WebAssembly
node generate_witness.js merkletree.wasm input.json witness.wtns

# First, we start a new "powers of tau" ceremony:
snarkjs powersoftau new bn128 14 pot12_0000.ptau -v

# Then, we contribute to the ceremony:
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v 

# The phase 2 is circuit-specific. Execute the following command to start the generation of this phase

snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

# Next, we generate a .zkey file that will contain the proving and verification keys together with all phase 2 contributions. Execute the following command to start a new zkey:

snarkjs groth16 setup merkletree.r1cs pot12_final.ptau merkletree_0000.zkey

# Contribute to the phase 2 of the ceremony:

snarkjs zkey contribute merkletree_0000.zkey merkletree_0001.zkey --name="0xsharma" -v

# Export the verification key:

snarkjs zkey export verificationkey merkletree_0001.zkey verification_key.json

# Generating a Proof

snarkjs groth16 prove merkletree_0001.zkey witness.wtns proof.json public.json

# Verifying a Proof
snarkjs groth16 verify verification_key.json public.json proof.json

# Verifying from a Smart Contract
snarkjs zkey export solidityverifier merkletree_0001.zkey verifier.sol
