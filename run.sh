#!/bin/bash

# Define the Haskell source file, the output binary, and default output file
HASKELL_SRC="expr2eqn.hs"
OUTPUT_BIN="EqnGenerator"
OUTPUT_FILE="output.eqn"  # Default EQN save path

# Ask the user for the expression
read -p "Enter the expression: " INPUT_EXPR

# Check if the Haskell compiler (GHC) is installed
if ! command -v ghc &> /dev/null; then
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

# Choose optimization tool
echo "Choose the optimization tool:"
echo "1) ABC"
echo "2) SIS"
read -p "Select an option (1/2): " TOOL_CHOICE

BLIF_PATH=""  # Initialize BLIF_PATH variable

# Start timing the optimization process
START_TIME=$(date +%s%3N)

case $TOOL_CHOICE in
    1)
        echo "Optimizing with ABC..."
        abc -f scripts/abc_opt.script
        BLIF_PATH="ABC_opt.blif"  # Set BLIF path for ABC
        ;;
    2)
        echo "Optimizing with SIS..."
        # Run the SIS script with the specified commands and then quit
        ./logic-synthesis-SIS/build/bin/sis <<EOF
read_eqn $OUTPUT_FILE
sweep; eliminate -1
simplify -m nocomp
eliminate -1
sweep; eliminate 5 
simplify -m nocomp
resub -a
fx
resub -a; sweep
eliminate -1; sweep
full_simplify -m nocomp
write_blif sis_opt.blif
write_eqn sis_opt.eqn
quit
EOF
        echo "Running ABC mapping post SIS optimization..."
        abc -f scripts/abc_map.script
        BLIF_PATH="sis_opt.blif"  # Set BLIF path for SIS
        ;;
    *)
        echo "Invalid option selected."
        exit 1
        ;;
esac

# End timing the optimization process
END_TIME=$(date +%s%3N)

# Calculate the time taken in milliseconds
TIME_TAKEN=$((END_TIME - START_TIME))

# Display the area cost
echo "Calculating the area cost..."
AREA_COST=$(./OpenTimer/bin/ot-shell -i scripts/print_area.conf | tail -n 1)  # Capture only the last line

# Assuming the path to the netlist is known and fixed
NETLIST_PATH="opt.v"

echo "Optimization and area calculation completed."

echo "Area Cost: $AREA_COST"  # Displaying the area cost
# echo "EQN saved to $OUTPUT_FILE"
echo "Saved netlist path: $NETLIST_PATH"
echo "BLIF file path: $BLIF_PATH"  # Print the BLIF path based on the optimization tool selected
echo "EQN file path: $OUTPUT_FILE"
echo "Time taken for optimization: $TIME_TAKEN ms"

# End of script
