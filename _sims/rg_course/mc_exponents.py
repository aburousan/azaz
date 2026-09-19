"""Measure the 2D Ising exponents properly, instead of quoting Migdal-Kadanoff.

Part 4 gets K_c and nu from a one-coupling approximation that is about 30 per
cent off.  Here the same quantities are measured by finite-size scaling of
Wolff cluster simulations, which is how anyone would really do it:

  * the Binder cumulant U = 1 - <m^4>/(3<m^2>^2) is dimensionless at K_c, so
    curves for different L cross there,
  * its slope grows as dU/dK ~ L^(1/nu),
  * the susceptibility at K_c grows as chi ~ L^(gamma/nu),
  * the magnetisation at K_c falls as <|m|> ~ L^(-beta/nu).

Exact answers to compare with: K_c = 0.4406868, nu = 1, gamma/nu = 7/4,
beta/nu = 1/8.
"""
import numpy as np

try:
    import numba
except ImportError:                                     # pragma: no cover
    numba = None

KC = 0.5 * np.log(1.0 + np.sqrt(2.0))


def _kernel(s, K, n_eq, n_meas, n_skip, seed):
    np.random.seed(seed)
    L = s.shape[0]
    padd = 1.0 - np.exp(-2.0 * K)
    stack = np.empty((L * L, 2), dtype=np.int64)
    m2 = np.empty(n_meas); m4 = np.empty(n_meas); ma = np.empty(n_meas)
    total = n_eq + n_meas * n_skip
    got = 0
    for step in range(total):
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
        if step >= n_eq and (step - n_eq) % n_skip == 0 and got < n_meas:
            m = 0.0
            for i in range(L):
                for j in range(L):
                    m += s[i, j]
            m /= L * L
            ma[got] = abs(m); m2[got] = m * m; m4[got] = m * m * m * m
            got += 1
    return ma, m2, m4


kernel = numba.njit(cache=True)(_kernel) if numba else _kernel


def run(L, K, n_meas=20000, n_skip=4, n_eq=None, seed=0):
    """One chain. Returns (<|m|>, <m^2>, <m^4>) plus the raw series."""
    if n_eq is None:
        n_eq = max(2000, 40 * L)
    rng = np.random.default_rng(seed)
    s = rng.choice(np.array([-1, 1]), size=(L, L)).astype(np.int64)
    ma, m2, m4 = kernel(s, K, n_eq, n_meas, n_skip, seed)
    return ma, m2, m4


def observables(ma, m2, m4, L):
    U = 1.0 - m4.mean() / (3.0 * m2.mean() ** 2)
    chi = L * L * (m2.mean() - ma.mean() ** 2)
    return U, chi, ma.mean()
