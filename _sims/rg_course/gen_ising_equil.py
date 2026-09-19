"""Equilibrated 2D Ising samples for the course figures, run on hercules.

At L = 256 a random start needs a few times 10^4 Wolff clusters before the
nearest-neighbour agreement at K_c reaches its exact value 1/sqrt(2); the
first versions of the figures used ~10^4 and were not fully equilibrated.
Here every sample gets 80 000 clusters, and the K_c samples are checked
against 1/sqrt(2) before anything is plotted.
"""
import numpy as np, sys, time
from multiprocessing import Pool
from ising2d import wolff_fast, block, KC, nn_agreement

L, NCL = 256, 80000
TEMPS = {"hot93": 0.93, "crit": 1.00, "cold107": 1.07,     # K = f*KC for the blocking figure
         "hot90": 0.90, "cold110": 1.10}                    # extra ones for the snapshots
NSAMP = 16

def one(args):
    tag, f, seed = args
    s = wolff_fast(L, f * KC, NCL, seed=seed)
    ag = []
    b = s.copy()
    for c in range(4):
        ag.append(nn_agreement(b))
        if c < 3:
            b = block(b, 2)
    return tag, seed, s.astype(np.int8), np.array(ag)

if __name__ == "__main__":
    jobs = [(tag, f, 1000 * k + i) for k, (tag, f) in enumerate(TEMPS.items()) for i in range(NSAMP)]
    t = time.time()
    with Pool(6) as pool:
        res = pool.map(one, jobs)
    out = {}
    for tag in TEMPS:
        rows = [r for r in res if r[0] == tag]
        ag = np.array([r[3] for r in rows])
        out[f"{tag}_snapshot"] = rows[0][2]
        out[f"{tag}_agree_mean"] = ag.mean(0)
        out[f"{tag}_agree_err"] = ag.std(0) / np.sqrt(len(rows))
        print(tag, "agreement per blocking level:", np.round(ag.mean(0), 4), "+-", np.round(ag.std(0) / np.sqrt(len(rows)), 4))
    np.savez_compressed("ising_equil.npz", **out)
    print(f"done in {time.time()-t:.0f}s; exact 1/sqrt2 = {1/np.sqrt(2):.4f}")
