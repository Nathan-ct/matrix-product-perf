#!/bin/bash

# Taille du problème fixe
MATRIX_SIZE=1000
OUTPUT_FILE="strong_scaling_results.txt"

# Lire l'argument "blocked" s'il est passé
MODE=$1
BLOCK_SIZE=$2
EXTRA_ARG=""
OUTPUT_SUFFIX="naive"

if [ "$MODE" == "blocked" ]; then
  EXTRA_ARG="blocked"
  OUTPUT_SUFFIX="blocked $BLOCK_SIZE"
fi

# Compilation (si pas encore fait)
cmake -B build -DCMAKE_BUILD_TYPE=Release -DKokkos_ENABLE_OPENMP=ON
cmake --build build

# Début du fichier de sortie avec l'en-tête
echo "# Threads Temps(s)" > "$OUTPUT_FILE"

# Liste des threads à tester
for n_threads in 1 2 4 8 16
do
    echo "Threads: $n_threads"
    export OMP_NUM_THREADS=$n_threads
    export OMP_PROC_BIND=true
    export OMP_PLACES=cores

    # Exécute le binaire avec taille fixe et le mode choisi
    # Nous utilisons `grep` et `sed` pour extraire le temps pur de la sortie
    RAW_OUTPUT=$(./build/src/top.matrix_product $MATRIX_SIZE $MATRIX_SIZE $MATRIX_SIZE $EXTRA_ARG)

    # Extraction du temps pur du texte (ici on extrait tout ce qui est après "Naive duration: " ou "Blocked duration: ")
    TIME=$(echo $RAW_OUTPUT | sed -E 's/.*[[:space:]]([0-9]+\.[0-9]+)[[:space:]]seconds/\1/')

    # Affichage du temps sous le format demandé
    echo "$n_threads $TIME" >> "$OUTPUT_FILE"
done

echo "Strong scaling terminé. Résultats dans $OUTPUT_FILE"
