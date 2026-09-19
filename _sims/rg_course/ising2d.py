"""A 2D Ising model, sampled with the Wolff cluster algorithm.

The cluster algorithm matters here: near the critical point single-spin
Metropolis slows to a crawl (critical slowing down, which is itself an RG
statement), and the pictures we want are exactly the critical ones.
"""
import numpy as np

KC = 0.5 * np.log(1.0 + np.sqrt(2.0))       # exact square-lattice K_c = 0.4407


def wolff(L, K, nsweeps, seed=0, state=None):
    """Return a configuration after `nsweeps` Wolff cluster moves."""
    rng = np.random.default_rng(seed)
    s = state if state is not None else rng.choice([-1, 1], size=(L, L))
    padd = 1.0 - np.exp(-2.0 * K)
    for _ in range(nsweeps):
        i0, j0 = rng.integers(L), rng.integers(L)
        sign = s[i0, j0]
        stack = [(i0, j0)]
        s[i0, j0] = -sign
        while stack:
            i, j = stack.pop()
            for di, dj in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                ni, nj = (i + di) % L, (j + dj) % L
                if s[ni, nj] == sign and rng.random() < padd:
                    s[ni, nj] = -sign
                    stack.append((ni, nj))
    return s


def block(s, b=2):
    """Majority rule on b x b blocks; ties broken by a fixed alternating sign
    so the rule stays deterministic and unbiased between up and down."""
    L = s.shape[0] // b * b
    t = s[:L, :L].reshape(L // b, b, L // b, b).sum(axis=(1, 3))
    out = np.sign(t)
    ties = out == 0
    if ties.any():
        idx = np.argwhere(ties)
        out[ties] = np.where((idx[:, 0] + idx[:, 1]) % 2 == 0, 1, -1)
    return out.astype(int)


try:
    import numba

    @numba.njit(cache=True)
    def _wolff_numba(s, K, nclusters, seed):
        np.random.seed(seed)
        L = s.shape[0]
        padd = 1.0 - np.exp(-2.0 * K)
        stack = np.empty((L * L, 2), dtype=np.int64)
        for _ in range(nclusters):
            i0 = np.random.randint(L); j0 = np.random.randint(L)
            sign = s[i0, j0]
            s[i0, j0] = -sign
            top = 0
            stack[top, 0] = i0; stack[top, 1] = j0; top += 1
            while top > 0:
                top -= 1
                i = stack[top, 0]; j = stack[top, 1]
                for di, dj in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    ni = (i + di) % L; nj = (j + dj) % L
                    if s[ni, nj] == sign and np.random.random() < padd:
                        s[ni, nj] = -sign
                        stack[top, 0] = ni; stack[top, 1] = nj; top += 1
        return s

    def wolff_fast(L, K, nclusters, seed=0, state=None):
        """Same algorithm as wolff(), compiled with numba."""
        rng = np.random.default_rng(seed)
        s = state.copy() if state is not None else rng.choice(np.array([-1, 1]), size=(L, L))
        return _wolff_numba(s.astype(np.int64), K, nclusters, seed)
except ImportError:
    wolff_fast = wolff


def nn_agreement(s):
    """Average of s_i s_j over nearest-neighbour pairs (periodic)."""
    return 0.5 * (np.mean(s * np.roll(s, 1, 0)) + np.mean(s * np.roll(s, 1, 1)))
