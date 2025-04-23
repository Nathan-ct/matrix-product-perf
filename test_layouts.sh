#!/bin/bash

# Compilation parameters
SOURCE=src/main.cpp
EXEC=matrix_product_test

# Matrix size for testing
MATRIX_SIZE=1000

# Kokkos paths
KOKKOS_INCLUDE="/home/nathan/Documents/TOP/TOP-25/lab3/matrix-product/build/_deps/kokkos-src/core/src"
KOKKOS_LIB="/home/nathan/Documents/TOP/TOP-25/lab3/matrix-product/build/_deps/kokkos-src/core/src"  

# Different layout options
LAYOUTS=("Kokkos::LayoutRight" "Kokkos::LayoutLeft")

# Clean previous
rm -f $EXEC results_layouts.txt

for A in "${LAYOUTS[@]}"; do
  for B in "${LAYOUTS[@]}"; do
    for C in "${LAYOUTS[@]}"; do
      echo "Testing A=$A, B=$B, C=$C"

      # Compile with specific layouts
      c++ -O3 -std=c++17 -I$KOKKOS_INCLUDE -L$KOKKOS_LIB -lkokkos -ldl \
        -DLA=A_LAYOUT="$A" -DLAYOUT_B="$B" -DLAYOUT_C="$C" \
        $SOURCE -o $EXEC

      # Run
      RUNTIME=$(./$EXEC $MATRIX_SIZE $MATRIX_SIZE $MATRIX_SIZE)

      # Save result
      echo "$A $B $C $RUNTIME" >> results_layouts.txt
    done
  done
done

echo "All layouts tested. Results saved in results_layouts.txt"
