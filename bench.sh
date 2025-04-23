#!/bin/bash

# Paramètres : taille min, taille max, pas
MIN=100
MAX=2000
STEP=100

# Lire les arguments : mode et éventuellement block size
MODE=$1
BLOCK_SIZE=$2
EXTRA_ARG=""

if [ "$MODE" == "blocked" ]; then
  if [ -z "$BLOCK_SIZE" ]; then
    echo "Erreur : veuillez spécifier la taille de bloc. Exemple : ./bench.sh blocked 64"
    exit 1
  fi
  EXTRA_ARG="blocked $BLOCK_SIZE"
fi

OUTPUT_FILE="benchmark_results.txt"
BUILD_DIR="./build"

# Compilation une seule fois
cmake -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release -DKokkos_ENABLE_OPENMP=ON
cmake --build "$BUILD_DIR"

# Config OpenMP
export OMP_NUM_THREADS=$(lscpu -p | egrep -v '^#' | sort -u -t, -k 2,4 | wc -l)
export OMP_PROC_BIND=true
export OMP_PLACES=cores

echo "# Taille Temps(s)" > "$OUTPUT_FILE"

for (( size=$MIN; size<=$MAX; size+=$STEP ))
do
    echo "➡️ Taille: $size x $size"
    # Exécute le binaire et récupère UNIQUEMENT la ligne contenant "duration: "
    TIME=$(./build/src/top.matrix_product $size $size $size $EXTRA_ARG | grep -oP '[0-9]+\.[0-9]+')
    echo "$size $TIME" >> "$OUTPUT_FILE"
done

echo "Benchmark terminé. Résultats dans $OUTPUT_FILE"




















