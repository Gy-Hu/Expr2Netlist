#!/bin/bash

# Define the Haskell source file and the output binary
HASKELL_SRC="expr2eqn.hs"
OUTPUT_BIN="EqnGenerator"
INPUT_EXPR="a && b"  # The expression to pass to the program
OUTPUT_FILE="output.eqn"  # The file to save the EQN to

# Check if the Haskell compiler (GHC) is installed
if ! command -v ghc &> /dev/null
then
    echo "GHC could not be found. Please install GHC to compile Haskell programs."
    exit 1
fi

# Compile the Haskell program if the binary doesn't exist or if the source is newer than the binary
if [ ! -f "$OUTPUT_BIN" ] || [ "$HASKELL_SRC" -nt "$OUTPUT_BIN" ]; then
    echo "Compiling $HASKELL_SRC..."
    ghc -o $OUTPUT_BIN $HASKELL_SRC
    if [ $? -ne 0 ]; then
        echo "Compilation failed."
        exit 1
    fi
fi

# Run the program with the input expression and output file as arguments using a heredoc
echo "Running the Equation Generator with expression '$INPUT_EXPR'..."
./$OUTPUT_BIN <<EOF
$INPUT_EXPR
$OUTPUT_FILE
EOF

echo "EQN saved to $OUTPUT_FILE"

# End of script
