"""Pick a critical snapshot with a small net magnetisation, purely so that both
colours are visible in the figure. Only the picture is chosen this way; every
number in the figure still comes from the unbiased set of 16 samples."""
import numpy as np
from multiprocessing import Pool
from ising2d import wolff_fast, KC, nn_agreement

def one(seed):
    s = wolff_fast(256, KC, 80000, seed=seed)
    return abs(s.mean()), nn_agreement(s), s.astype(np.int8), seed

if __name__ == "__main__":
    with Pool(6) as p:
        res = p.map(one, range(7000, 7012))
    res.sort(key=lambda r: r[0])
    for m, ag, _, sd in res:
        print(f"seed {sd}: |m| = {m:.3f}  agreement = {ag:.4f}")
    m, ag, s, sd = res[0]
    np.savez_compressed("ising_crit_balanced.npz", snapshot=s, m=m, agree=ag, seed=sd)
    print(f"chosen seed {sd}: |m| = {m:.3f}, agreement {ag:.4f} (exact 0.7071)")
