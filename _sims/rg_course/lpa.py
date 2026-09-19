"""Functional RG in the local potential approximation (LPA) for the Ising class.

Part 6 follows two couplings (mass and quartic) and expands in epsilon = 4 - d.
Here we instead follow the whole potential U(rho), keep M Taylor coefficients
about its minimum and work directly in d = 3. No epsilon expansion is used.

The Wetterich equation with the Litim regulator gives, in dimensionless form,

    dot u = -d u + (d-2) rho u' + c / (1 + u' + 2 rho u''),   c = K_d / d,
    rho = phi^2 / 2,    K_d = 2 / ((4 pi)^(d/2) Gamma(d/2)).

Everything below is exact Taylor arithmetic in x = rho - kappa, so the only
approximation is the truncation at order M.
"""
from math import factorial, pi
import numpy as np
from scipy.optimize import fsolve
from scipy.special import gamma as Gamma


def Kd(d):
    return 2.0 / ((4 * pi) ** (d / 2) * Gamma(d / 2))


def series_inverse(D, M):
    """1/D as a truncated series, given D as coefficients of x^0..x^M."""
    E = np.zeros(M + 1)
    E[0] = 1.0 / D[0]
    for k in range(1, M + 1):
        E[k] = -sum(D[j] * E[k - j] for j in range(1, k + 1)) / D[0]
    return E


def rhs_series(y, d, M):
    """Taylor coefficients (in x = rho - kappa) of the right-hand side."""
    kap, lams = y[0], y[1:]                      # u = sum_{n=2}^M lam_n x^n / n!
    c = Kd(d) / d
    u = np.zeros(M + 1); up = np.zeros(M + 1); upp = np.zeros(M + 1)
    for i, n in enumerate(range(2, M + 1)):
        u[n] += lams[i] / factorial(n)
        up[n - 1] += lams[i] / factorial(n - 1)
        if n >= 2:
            upp[n - 2] += lams[i] / factorial(n - 2)
    # rho * f  shifts: rho = kappa + x
    def times_rho(f):
        out = kap * f.copy()
        out[1:] += f[:-1]
        return out
    D = np.zeros(M + 1); D[0] = 1.0
    D += up + 2 * times_rho(upp)
    inv = series_inverse(D, M)
    return -d * u + (d - 2) * times_rho(up) + c * inv


def flow(y, d, M):
    """Flow of (kappa, lambda_2 .. lambda_M), with t = ln k (towards the UV).

    The couplings are defined at the moving minimum, lambda_n = u^(n)(kappa(t)),
    so their total time derivative picks up an advective piece:
        d/dt lambda_n = (d/dt u^(n))|_kappa + lambda_{n+1} * d(kappa)/dt.
    """
    R = rhs_series(y, d, M)
    lams = y[1:]
    dot_kappa = -R[1] / lams[0]        # keeps u'(kappa) = 0 as kappa moves
    dot_lams = []
    for i, n in enumerate(range(2, M + 1)):
        adv = lams[i + 1] * dot_kappa if (i + 1) < len(lams) else 0.0
        dot_lams.append(R[n] * factorial(n) + adv)
    return np.concatenate(([dot_kappa], dot_lams))


def solve(d, M, guess):
    y, info, flag, msg = fsolve(lambda z: flow(z, d, M), guess, full_output=True, xtol=1e-13)
    res = np.max(np.abs(flow(y, d, M)))
    n = len(y); J = np.zeros((n, n)); f0 = flow(y, d, M)
    for j in range(n):
        h = 1e-7 * max(1.0, abs(y[j])); dy = np.zeros(n); dy[j] = h
        J[:, j] = (flow(y + dy, d, M) - f0) / h
    # With t = ln k, a perturbation behaves as exp(-theta t), so the critical
    # exponents are theta = -(eigenvalues of J). theta > 0 is relevant.
    theta = np.sort(-np.linalg.eigvals(J).real)[::-1]
    return y, res, theta


if __name__ == "__main__":
    print(f"d = 3:  K_3 = {Kd(3):.6f},  c = K_3/3 = {Kd(3)/3:.6f}\n")
    guess = np.array([0.05, 10.0])
    for M in range(2, 10):
        if M > 2:
            guess = np.concatenate((y, [0.0]))
        y, res, ev = solve(3, M, guess)
        th = ev
        rel = [t for t in th if t > 1e-9]
        irr = [t for t in th if t < -1e-9]
        nu = 1 / max(rel) if rel else float("nan")
        omega = -max(irr) if irr else float("nan")
        print(f"M={M}: kappa={y[0]:+.5f} lam2={y[1]:+.4f} residual={res:.1e} "
              f"theta={np.round(th[:3],4)}  ->  nu = {nu:.4f}, omega = {omega:.4f}")
