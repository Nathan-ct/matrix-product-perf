import numpy as np
import matplotlib.pyplot as plt

data = np.loadtxt("strong_scaling_results.txt")

threads = data[:, 0]
times = data[:, 1]

# Optionnel : Calcul speedup
speedup = times[0] / times

plt.figure(figsize=(10, 5))

plt.subplot(1, 2, 1)
plt.plot(threads, times, marker='o')
plt.xlabel("Nombre de threads")
plt.ylabel("Temps d'exécution (s)")
plt.title("Strong Scaling: Temps vs Threads")
plt.grid(True)

plt.subplot(1, 2, 2)
plt.plot(threads, speedup, marker='o')
plt.xlabel("Nombre de threads")
plt.ylabel("Speedup")
plt.title("Speedup idéal vs réel")
plt.grid(True)

plt.tight_layout()
plt.savefig("strong_scaling_plot.png")
plt.show()
