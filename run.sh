

#!/bin/bash

# Chemin vers le dossier du projet
PROJECT_DIR=$(pwd)
BUILD_DIR="$PROJECT_DIR/build"

# Dimensions des matrices (tu peux les passer en argument)
M=${1:-1000}
N=${2:-1000}
K=${3:-1000}

# Fichier où on va stocker le résultat
OUTPUT_FILE="results_${M}x${N}x${K}.txt"

echo "Configuration et compilation..."
cmake -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release -DKokkos_ENABLE_OPENMP=ON
cmake --build "$BUILD_DIR"

echo "Configuration OpenMP..."
export OMP_NUM_THREADS=$(lscpu -p | egrep -v '^#' | sort -u -t, -k 2,4 | wc -l)
export OMP_PROC_BIND=true
export OMP_PLACES=cores

echo "Exécution avec M=$M, N=$N, K=$K"
"$BUILD_DIR/src/top.matrix_product" "$M" "$N" "$K" > "$OUTPUT_FILE"

echo "Résultat sauvegardé dans : $OUTPUT_FILE"
