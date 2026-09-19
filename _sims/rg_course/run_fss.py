"""One (L, K) point of the finite-size-scaling run.  Usage: run_fss.py L K_index"""
import sys, os
import numpy as np
from mc_exponents import run, observables, KC

L = int(sys.argv[1]); ik = int(sys.argv[2])
KGRID = np.linspace(KC - 0.03, KC + 0.03, 13)
K = KGRID[ik]
NSEED = 8
N_MEAS, N_SKIP = 30000, 4

U = np.empty(NSEED); X = np.empty(NSEED); M = np.empty(NSEED)
for s in range(NSEED):
    ma, m2, m4 = run(L, K, n_meas=N_MEAS, n_skip=N_SKIP, seed=1000 * L + 37 * ik + s)
    U[s], X[s], M[s] = observables(ma, m2, m4, L)

os.makedirs("fss", exist_ok=True)
np.savez(f"fss/L{L}_k{ik}.npz", L=L, K=K, U=U, chi=X, mabs=M,
         n_meas=N_MEAS, n_skip=N_SKIP)
print(f"L={L:4d} K={K:.5f}  U={U.mean():.4f}+-{U.std(ddof=1)/np.sqrt(NSEED):.4f} "
      f"chi={X.mean():.3f}  |m|={M.mean():.4f}", flush=True)
