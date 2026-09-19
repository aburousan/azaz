"""High-precision version of lpa.py, used to check how far the truncation
converges.  Same flow equation, mpmath instead of float64.
"""
from mpmath import mp, mpf, pi, gamma, matrix, factorial, findroot, eig
import lpa

mp.dps = 40


def Kd(d):
    return 2 / ((4 * pi) ** (mpf(d) / 2) * gamma(mpf(d) / 2))


def rhs_series(y, d, M):
    kap = y[0]; lams = y[1:]
    c = Kd(d) / d
    u = [mpf(0)] * (M + 1); up = [mpf(0)] * (M + 1); upp = [mpf(0)] * (M + 1)
    for i, n in enumerate(range(2, M + 1)):
        u[n] += lams[i] / factorial(n)
        up[n - 1] += lams[i] / factorial(n - 1)
        upp[n - 2] += lams[i] / factorial(n - 2)

    def times_rho(f):
        out = [kap * v for v in f]
        for k in range(M, 0, -1):
            out[k] += f[k - 1]
        return out

    rupp = times_rho(upp)
    D = [up[k] + 2 * rupp[k] for k in range(M + 1)]
    D[0] += 1
    E = [mpf(0)] * (M + 1)
    E[0] = 1 / D[0]
    for k in range(1, M + 1):
        E[k] = -sum(D[j] * E[k - j] for j in range(1, k + 1)) / D[0]
    rup = times_rho(up)
    return [-mpf(d) * u[k] + (mpf(d) - 2) * rup[k] + c * E[k] for k in range(M + 1)]


def flow(y, d, M):
    R = rhs_series(y, d, M)
    lams = y[1:]
    dot_kappa = -R[1] / lams[0]
    out = [dot_kappa]
    for i, n in enumerate(range(2, M + 1)):
        adv = lams[i + 1] * dot_kappa if (i + 1) < len(lams) else mpf(0)
        out.append(R[n] * factorial(n) + adv)
    return out


def solve(d, M, guess):
    f = lambda *a: flow(list(a), d, M)
    sol = findroot(f, tuple(guess), tol=mpf(10) ** (-30))
    y = [sol[i] for i in range(M)]
    n = len(y)
    J = matrix(n, n)
    f0 = flow(y, d, M)
    h = mpf(10) ** (-18)
    for j in range(n):
        yp = list(y); yp[j] += h
        fp = flow(yp, d, M)
        for i in range(n):
            J[i, j] = (fp[i] - f0[i]) / h
    ev = eig(J, left=False, right=False)
    th = sorted([-e.real for e in ev], reverse=True)
    return y, max(abs(v) for v in f0), th


if __name__ == "__main__":
    print(f"d=3, mp.dps={mp.dps}\n")
    print(f"{'M':>3} {'kappa':>12} {'lambda_2':>12} {'nu':>10} {'omega':>10} "
          f"{'omega_2':>10} {'residual':>10}")
    y = None
    for M in range(2, 15):
        guess = [mpf('0.03'), mpf('7.5')] if y is None else list(y) + [mpf(0)]
        try:
            y, res, th = solve(3, M, guess)
        except Exception as e:
            print(f"{M:3d}  failed: {type(e).__name__}")
            break
        rel = [t for t in th if t > 0]
        irr = sorted([t for t in th if t < 0], reverse=True)
        nu = 1 / max(rel) if rel else mpf('nan')
        om = -irr[0] if irr else mpf('nan')
        om2 = -irr[1] if len(irr) > 1 else mpf('nan')
        print(f"{M:3d} {mp.nstr(y[0],6):>12} {mp.nstr(y[1],6):>12} "
              f"{mp.nstr(nu,6):>10} {mp.nstr(om,6):>10} {mp.nstr(om2,6):>10} "
              f"{mp.nstr(res,3):>10}")
