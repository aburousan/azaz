"""Turn the finite-size-scaling data into K_c, nu, gamma/nu and beta/nu.

Method, all of it standard:
  * U_L(K) is steep, so it is never fitted across the whole window.  Every
    fit here is local: a cubic through the NLOC grid points nearest the place
    it is being evaluated.
  * Every pair (L, 2L) gives a crossing point K_x(L), found from the sign
    change of U_L - U_2L; the exact K_c is the L -> infinity limit of those.
  * 1/nu comes from the slope of the curves: dU/dK at K_c ~ L^(1/nu).
  * gamma/nu and beta/nu come from chi and <|m|> at K_c.
Error bars are bootstrapped over the 8 independent chains of each point.
"""
import glob
import numpy as np

KC_EXACT = 0.5 * np.log(1.0 + np.sqrt(2.0))
NBOOT = 400
NLOC = 5                     # grid points used by each local fit
LFIT = 16                    # smallest box allowed into the power-law fits
rng = np.random.default_rng(12345)


def load(folder="fss"):
    data = {}
    for f in sorted(glob.glob(f"{folder}/L*_k*.npz")):
        d = np.load(f)
        L = int(d["L"]); K = float(d["K"])
        data.setdefault(L, {})[K] = (d["U"], d["chi"], d["mabs"])
    return data


def curves(data, pick):
    """pick(seed_index) -> per-L arrays (K, value) for one bootstrap sample."""
    out = {}
    for L, byK in sorted(data.items()):
        Ks = np.array(sorted(byK))
        vals = np.array([pick(byK[K]) for K in Ks])
        out[L] = (Ks, vals)
    return out


def local_fit(K, y, K0, n=NLOC, deg=3):
    """Cubic through the n grid points closest to K0."""
    idx = np.argsort(np.abs(K - K0))[:n]
    idx.sort()
    return np.polyfit(K[idx], y[idx], min(deg, n - 1))


def crossing(K, yL, yM):
    """Where U_L - U_2L changes sign, by a local fit around that bracket."""
    d = yL - yM
    sgn = np.where(np.diff(np.sign(d)) != 0)[0]
    if len(sgn) == 0:
        return np.nan
    i = sgn[0]
    K0 = 0.5 * (K[i] + K[i + 1])
    pd = local_fit(K, d, K0, n=min(4, len(K)), deg=3)
    r = np.roots(pd)
    r = r[np.abs(r.imag) < 1e-9].real
    r = r[(r >= K[max(i - 1, 0)]) & (r <= K[min(i + 2, len(K) - 1)])]
    return r[0] if len(r) else K0


def analyse(data, idx=None):
    """One estimate. idx = bootstrap seed indices, or None for the plain mean."""
    def pick(t):
        U, X, M = t
        if idx is None:
            return np.array([U.mean(), X.mean(), M.mean()])
        return np.array([U[idx].mean(), X[idx].mean(), M[idx].mean()])

    Ls = np.array(sorted(data))
    Us, Xs, Ms, Kg = {}, {}, {}, None
    for L in Ls:
        byK = data[L]
        Kg = np.array(sorted(byK))
        v = np.array([pick(byK[K]) for K in Kg])
        Us[L], Xs[L], Ms[L] = v[:, 0], v[:, 1], v[:, 2]

    # 1. K_c from (L, 2L) crossings, extrapolated to infinite L
    pairs = [(L, 2 * L) for L in Ls if 2 * L in set(Ls)]
    kx = np.array([crossing(Kg, Us[a], Us[b]) for a, b in pairs])
    # The crossings drift with L, so the estimate is simply the largest pair
    # available.  No extrapolation is fitted, because the drift law involves
    # exponents we are trying to measure.
    good = np.isfinite(kx)
    Kc = kx[good][-1] if good.any() else np.nan

    # 2. nu from the slope of U at K_c.  The power laws are fitted over
    # L >= LFIT only, since the smallest boxes carry the biggest corrections.
    slope = np.array([abs(np.polyval(np.polyder(local_fit(Kg, Us[L], Kc)), Kc))
                      for L in Ls])
    big = Ls >= LFIT
    inu = np.polyfit(np.log(Ls[big]), np.log(slope[big]), 1)[0]

    # 3. gamma/nu and beta/nu at K_c
    chi_c = np.array([np.polyval(local_fit(Kg, Xs[L], Kc), Kc) for L in Ls])
    m_c = np.array([np.polyval(local_fit(Kg, Ms[L], Kc), Kc) for L in Ls])
    g_nu = np.polyfit(np.log(Ls[big]), np.log(chi_c[big]), 1)[0]
    b_nu = -np.polyfit(np.log(Ls[big]), np.log(m_c[big]), 1)[0]
    Ustar = np.mean([np.polyval(local_fit(Kg, Us[L], Kc), Kc) for L in Ls[-3:]])
    return dict(Kc=Kc, nu=1.0 / inu, g_nu=g_nu, b_nu=b_nu, Ustar=Ustar,
                Ls=Ls, kx=kx, pairs=pairs, slope=slope, chi_c=chi_c, m_c=m_c,
                Kg=Kg, Us=Us)


def with_errors(data):
    base = analyse(data)
    nseed = len(next(iter(next(iter(data.values())).values()))[0])
    keys = ("Kc", "nu", "g_nu", "b_nu", "Ustar")
    samples = {k: [] for k in keys}
    for _ in range(NBOOT):
        idx = rng.integers(0, nseed, nseed)
        try:
            r = analyse(data, idx)
        except Exception:
            continue
        for k in keys:
            samples[k].append(r[k])
    err = {k: float(np.std(samples[k], ddof=1)) for k in keys}
    return base, err


if __name__ == "__main__":
    data = load()
    print(f"sizes: {sorted(data)}   K points: {len(next(iter(data.values())))}")
    base, err = with_errors(data)
    exact = dict(Kc=KC_EXACT, nu=1.0, g_nu=1.75, b_nu=0.125, Ustar=0.6106)
    name = dict(Kc="K_c", nu="nu", g_nu="gamma/nu", b_nu="beta/nu", Ustar="U*")
    print(f"\n{'quantity':>10} {'measured':>22} {'exact':>10} {'off by':>9}")
    for k in ("Kc", "nu", "g_nu", "b_nu", "Ustar"):
        v, e, x = base[k], err[k], exact[k]
        print(f"{name[k]:>10} {v:>12.5f} +- {e:<7.5f} {x:>10.5f} "
              f"{100*(v-x)/x:>8.2f}%")
    print("\ncrossings (L, 2L):")
    for (a, b), k in zip(base["pairs"], base["kx"]):
        print(f"   ({a:3d},{b:4d})  K_x = {k:.5f}")
