
#include <cassert>
#include <cstdlib>
#include <chrono>
#include <iostream>
#include <Kokkos_Core.hpp>
#include <fmt/core.h>
#include <cmath>

using MatrixR = Kokkos::View<double**, Kokkos::LayoutRight>; 
using MatrixL = Kokkos::View<double**, Kokkos::LayoutLeft>;  

template <class MatrixType>
auto matrix_init(MatrixType& M) -> void {
  static_assert(2 == MatrixType::rank(), "View must be of rank 2");

  Kokkos::parallel_for("init", M.extent(0), KOKKOS_LAMBDA(int i) {
    for (int j = 0; j < int(M.extent(1)); ++j) {
      M(i, j) = drand48();
    }
  });
}

template <class AMatrixType, class BMatrixType, class CMatrixType>
auto matrix_product(double alpha, AMatrixType const& A, BMatrixType const& B, double beta, CMatrixType& C) -> void {
  static_assert(AMatrixType::rank() == 2 && BMatrixType::rank() == 2 && CMatrixType::rank() == 2, "Views must be of rank 2");
  assert(A.extent(0) == C.extent(0));
  assert(B.extent(1) == C.extent(1));
  assert(A.extent(1) == B.extent(0));

  Kokkos::parallel_for("dgemm_kernel", A.extent(0), KOKKOS_LAMBDA(int i) {
    for (int j = 0; j < int(B.extent(1)); ++j) {
      double acc = 0.0;
      for (int k = 0; k < int(A.extent(1)); ++k) {
        acc += alpha * A(i, k) * B(k, j);
      }
      C(i, j) = beta * C(i, j) + acc;
    }
  });
}

template <class AMatrixType, class BMatrixType, class CMatrixType>
auto matrix_product_blocked(double alpha, AMatrixType const& A, BMatrixType const& B, double beta, CMatrixType& C, int blockSize) -> void {
  int M = C.extent(0);
  int N = C.extent(1);
  int K = A.extent(1);

  Kokkos::parallel_for("blocked_dgemm", 
    Kokkos::MDRangePolicy<Kokkos::Rank<2>>({0, 0}, {M, N}, {blockSize, blockSize}),
    KOKKOS_LAMBDA(int i, int j) {
      double acc = 0.0;
      for (int kk = 0; kk < K; kk++) {
        acc += alpha * A(i, kk) * B(kk, j);
      }
      C(i, j) = beta * C(i, j) + acc;
    });
}

template <class MatrixType1, class MatrixType2>
bool compare_matrices(MatrixType1 const& A, MatrixType2 const& B, double tol = 1e-6) {
  bool same = true;
  Kokkos::parallel_reduce(A.extent(0), KOKKOS_LAMBDA(int i, bool& local_same) {
    for (int j = 0; j < int(A.extent(1)); ++j) {
      if (fabs(A(i, j) - B(i, j)) > tol) {
        local_same = false;
        return;
      }
    }
  }, Kokkos::LAnd<bool>(same));
  return same;
}

auto main(int argc, char* argv[]) -> int {
  if (argc < 4) {
    fmt::print("Usage: {} <M> <N> <K> [blocked] [block_size]\n", argv[0]);
    return -1;
  }

  int m = std::atoi(argv[1]);
  int n = std::atoi(argv[2]);
  int k = std::atoi(argv[3]);

  bool use_blocked = argc >= 5 && std::string(argv[4]) == "blocked";
  int blockSize = (argc >= 6) ? std::atoi(argv[5]) : 64;  // Valeur par défaut : 64

  srand48(42);

  Kokkos::initialize(argc, argv);
  {
    auto A = MatrixR("A", m, k);
    auto B = MatrixL("B", k, n);
    auto C = MatrixR("C", m, n);

    matrix_init(A);
    matrix_init(B);
    matrix_init(C);

    double alpha = drand48();
    double beta = drand48();

    Kokkos::fence();
    auto start = std::chrono::high_resolution_clock::now();

    if (use_blocked) {
      // Passe la taille de bloc à la version blocked
      matrix_product_blocked(alpha, A, B, beta, C, blockSize);
    } else {
      matrix_product(alpha, A, B, beta, C);
    }

    Kokkos::fence();
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> duration = end - start;

    std::cout << (use_blocked ? "Blocked " : "Naive ") 
              << "duration: " << duration.count() 
              << " seconds\n";
  }
  Kokkos::finalize();
  return 0;
}



















