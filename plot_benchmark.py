import numpy as np
import matplotlib.pyplot as plt

data = np.loadtxt("benchmark_results.txt")

sizes = data[:, 0]
times = data[:, 1]

plt.figure(figsize=(8, 5))
plt.plot(sizes, times, marker='o')
plt.xlabel("Taille de la matrice (N x N)")
plt.ylabel("Temps d'exécution (secondes)")
plt.title("Temps d'exécution vs Taille de matrice")
plt.grid(True)
plt.tight_layout()
plt.savefig("benchmark_plot.png")
plt.show()
