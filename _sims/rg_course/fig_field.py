"""Parts 4-7: the Wilsonian shell, power counting, phi^4 at one loop,
the Wilson-Fisher fixed point, running couplings and effective field theory."""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, Wedge, FancyArrowPatch, FancyBboxPatch, Arc
from common import *


# ------------------------------------------------------- 1. the momentum shell
def momentum_shell():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10.0, 4.4))

    ax1.add_patch(Wedge((0, 0), 1.0, 0, 360, width=0.18, fc=RED, alpha=0.30, ec="none"))
    ax1.add_patch(Circle((0, 0), 1.0, fc="none", ec=INK, lw=1.6))
    ax1.add_patch(Circle((0, 0), 0.82, fc="none", ec=GREEN, lw=1.6, ls="--"))
    rng = np.random.default_rng(4)
    th = rng.uniform(0, 2 * np.pi, 160); r = 0.82 * np.sqrt(rng.random(160))
    ax1.plot(r * np.cos(th), r * np.sin(th), ".", color=GREEN, ms=3.2, alpha=0.8)
    th2 = rng.uniform(0, 2 * np.pi, 90)
    r2 = np.sqrt(rng.uniform(0.82**2, 1.0, 90))
    ax1.plot(r2 * np.cos(th2), r2 * np.sin(th2), ".", color=RED, ms=3.6)

    ax1.annotate("", xy=(1.0, 0), xytext=(0, 0),
                 arrowprops=dict(arrowstyle="-|>", lw=1.3, color=INK, mutation_scale=11))
    ax1.text(0.50, 0.06, r"$\Lambda$", fontsize=12)
    ax1.annotate("", xy=(-0.82 * 0.707, -0.82 * 0.707), xytext=(0, 0),
                 arrowprops=dict(arrowstyle="-|>", lw=1.3, color=GREEN, mutation_scale=11))
    ax1.text(-0.66, -0.46, r"$\Lambda/b$", fontsize=12, color=GREEN)
    ax1.text(0, 1.14, r"the shell $\Lambda/b<|k|<\Lambda$: integrate these out",
             ha="center", color=RED, fontsize=10)
    ax1.text(0, -1.30, r"the inside: keep these, they are the slow modes $\phi_{\rm s}$",
             ha="center", color=GREEN, fontsize=10)
    ax1.set_xlim(-1.35, 1.35); ax1.set_ylim(-1.45, 1.35)
    bare(ax1)
    ax1.set_title("momentum space", fontsize=11)

    # --- right: the three steps of one RG step
    steps = [("1.  integrate out the shell",
              r"$e^{-S'[\phi_{\rm s}]}=\int\!\mathrm{D}\phi_{\rm f}\,e^{-S[\phi_{\rm s}+\phi_{\rm f}]}$", RED),
             ("2.  rescale momenta", r"$k' = b\,k$,  so the cutoff is $\Lambda$ again", BLUE),
             ("3.  rescale the field", r"$\phi' = \zeta^{-1}\phi_{\rm s}$,  to restore "
                                       r"$\frac{1}{2}(\partial\phi)^2$", GREEN)]
    for i, (t, eq, c) in enumerate(steps):
        y = 0.78 - i * 0.33
        ax2.add_patch(FancyBboxPatch((0.02, y - 0.115), 0.96, 0.22,
                                     boxstyle="round,pad=0.015", fc="none", ec=c, lw=1.4))
        ax2.text(0.06, y + 0.045, t, fontsize=10.5, color=c, va="center")
        ax2.text(0.06, y - 0.055, eq, fontsize=10.5, va="center")
        if i < 2:
            ax2.add_patch(FancyArrowPatch((0.5, y - 0.125), (0.5, y - 0.205),
                                          arrowstyle="-|>", mutation_scale=12,
                                          color=GREY, lw=1.2))
    ax2.text(0.5, -0.20, "the result is a new action of the same form,\n"
                         "with shifted couplings: one RG step",
             ha="center", fontsize=10, style="italic", color=GREY)
    ax2.set_xlim(0, 1); ax2.set_ylim(-0.42, 1.0)
    bare(ax2); ax2.set_aspect("auto")
    fig.tight_layout()
    save(fig, "momentum_shell.svg")


# -------------------------------------------------------- 2. power counting
def power_counting():
    fig, ax = plt.subplots(figsize=(9.6, 4.2))
    ops = [(r"$\phi^2$",       2, 2,  "mass term",            RED),
           (r"$\phi^3$",       3, 1,  "cubic",                RED),
           (r"$\phi^4$",       4, 0,  "the quartic coupling", ORANGE),
           (r"$\phi^6$",       6, -2, "six-point",            BLUE),
           (r"$(\partial\phi)^2\phi^2$", 6, -2, "derivative", BLUE),
           (r"$\phi^8$",       8, -4, "eight-point",          BLUE)]
    for i, (sym, dim, gdim, name, c) in enumerate(ops):
        y = -i * 0.55
        ax.text(0.0, y, sym, fontsize=14, va="center", color=c)
        ax.text(1.5, y, rf"$[\mathrm{{O}}] = {dim}$", fontsize=11, va="center")
        ax.text(3.4, y, rf"$[g] = {gdim}$", fontsize=11, va="center")
        verdict = ("RELEVANT: grows at long distances" if gdim > 0 else
                   "MARGINAL: loops decide" if gdim == 0 else
                   "IRRELEVANT: fades at long distances")
        ax.text(5.2, y, verdict, fontsize=10.5, va="center", color=c)
    ax.text(0.0, 0.62, r"operator", fontsize=10, style="italic", color=GREY)
    ax.text(1.5, 0.62, "its dimension", fontsize=10, style="italic", color=GREY)
    ax.text(3.4, 0.62, "its coupling", fontsize=10, style="italic", color=GREY)
    ax.text(5.2, 0.62, "what the flow does to it", fontsize=10, style="italic", color=GREY)
    ax.text(0.0, -3.35, r"in $d=4$:  $[\phi]=1$, and $[g_n]=4-n$ for $g_n\phi^n$",
            fontsize=11)
    ax.set_xlim(-0.3, 10.2); ax.set_ylim(-3.7, 0.95)
    bare(ax); ax.set_aspect("auto")
    save(fig, "power_counting.svg")


# --------------------------------------------------- 3. the one-loop diagrams
def phi4_diagrams():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(9.6, 3.6))

    # tadpole: mass correction
    ax1.plot([-1.0, 0], [-0.55, 0], color=INK, lw=1.5)
    ax1.plot([1.0, 0], [-0.55, 0], color=INK, lw=1.5)
    ax1.add_patch(Circle((0, 0.42), 0.42, fc="none", ec=RED, lw=1.7))
    ax1.plot(0, 0, "o", color=INK, ms=7)
    ax1.text(0.55, 0.42, "a fast mode,\nrunning round\nthe loop",
             color=RED, fontsize=9.5, va="center")
    ax1.text(0, -1.05, r"$\delta m^2 \;\propto\; +\lambda$", ha="center", fontsize=13)
    ax1.set_title("the tadpole: corrects the mass", fontsize=11)
    ax1.set_xlim(-1.5, 2.0); ax1.set_ylim(-1.5, 1.2); bare(ax1)

    # bubble: coupling correction
    for sx, sy in [(-1.0, 0.55), (-1.0, -0.55)]:
        ax2.plot([sx, -0.42], [sy, 0], color=INK, lw=1.5)
    for sx, sy in [(1.0, 0.55), (1.0, -0.55)]:
        ax2.plot([sx, 0.42], [sy, 0], color=INK, lw=1.5)
    ax2.add_patch(Arc((0, 0), 0.84, 0.84, theta1=0, theta2=180, ec=RED, lw=1.7))
    ax2.add_patch(Arc((0, 0), 0.84, 0.84, theta1=180, theta2=360, ec=RED, lw=1.7))
    ax2.plot(-0.42, 0, "o", color=INK, ms=7); ax2.plot(0.42, 0, "o", color=INK, ms=7)
    ax2.text(0, -1.05, r"$\delta\lambda \;\propto\; -\lambda^2$", ha="center", fontsize=13)
    ax2.text(0, 0.68, "two fast modes;  3 channels $s,t,u$",
             color=RED, fontsize=9.5, ha="center")
    ax2.set_title("the bubble: corrects the coupling", fontsize=11)
    ax2.set_xlim(-1.6, 1.6); ax2.set_ylim(-1.55, 1.2); bare(ax2)
    fig.tight_layout()
    save(fig, "phi4_diagrams.svg")


# ------------------------------------- 4. the coupling flow and the (r,u) plane
def wf_flow():
    """Left: the one-loop beta function of the quartic coupling, which is where
    the Wilson-Fisher fixed point actually comes from. Right: the same story in
    the (r, u) plane, with trajectories integrated numerically."""
    from scipy.integrate import solve_ivp
    Kd = 1 / (8 * np.pi**2)
    beta = lambda u, eps: eps * u - 1.5 * Kd * u**2

    fig, (axA, axB) = plt.subplots(1, 2, figsize=(10.8, 4.6))

    # ---------------- A: beta_u against u
    u = np.linspace(0, 95, 500)
    for eps, c, ls in [(0.0, INK, "-"), (0.5, TEAL, "--"), (1.0, RED, "-")]:
        axA.plot(u, beta(u, eps), color=c, ls=ls, lw=2.0,
                 label=rf"$\epsilon={eps:g}$" + (r"  ($d=4$)" if eps == 0 else
                                                 r"  ($d=3$)" if eps == 1 else ""))
        if eps > 0:
            us = 16 * np.pi**2 * eps / 3
            axA.plot(us, 0, "o", color=c, ms=9, zorder=6)
    axA.axhline(0, color=GREY, lw=1.0)
    axA.plot(0, 0, "o", color=INK, ms=9, zorder=6)

    # flow arrows: dl > 0 is towards the infrared
    for u0 in (14, 34, 70, 88):
        b = beta(u0, 1.0)
        axA.annotate("", xy=(u0 + np.sign(b) * 7, -2.1), xytext=(u0, -2.1),
                     arrowprops=dict(arrowstyle="-|>", lw=1.5, color=RED,
                                     mutation_scale=12))
    axA.text(50, -5.4, r"arrows: which way $\tilde u$ moves towards the infrared"
                       "\n" r"(for $\epsilon=1$)", ha="center", fontsize=9, color=RED)
    axA.annotate(r"$u^* = \frac{16\pi^2\epsilon}{3}$", xy=(52.6, 0),
                 xytext=(60, 5.0), color=RED, fontsize=12,
                 arrowprops=dict(arrowstyle="-|>", color=RED, lw=1.2, mutation_scale=11))
    axA.annotate("Gaussian", xy=(0, 0), xytext=(6, 6.2), color=INK, fontsize=10,
                 arrowprops=dict(arrowstyle="-|>", color=INK, lw=1.1, mutation_scale=10))
    axA.set_xlabel(r"$\tilde u = \lambda\,\Lambda^{d-4}$")
    axA.set_ylabel(r"$\dfrac{d\tilde u}{d\ell} = \epsilon\tilde u "
                   r"- \dfrac{3K_4}{2}\tilde u^2$")
    axA.set_xlim(0, 95); axA.set_ylim(-8, 9)
    axA.legend(frameon=False, fontsize=9.5, loc="upper right")
    axA.set_title(r"where the fixed point comes from", fontsize=11.5)

    # ---------------- B: the (r, u) plane in d = 3
    eps = 1.0
    # The trajectories below integrate the full one-loop equations, so the
    # critical surface has to start from the fixed point of *those* equations,
    # not from the leading-order formulas (which differ at O(eps^2)).
    from scipy.optimize import fsolve
    rstar, ustar = fsolve(lambda y: [2 * y[0] + Kd * y[1] / (2 * (1 + y[0])),
                                     eps * y[1] - 1.5 * Kd * y[1]**2 / (1 + y[0])**2],
                          [-1 / 6, 16 * np.pi**2 / 3], xtol=1e-13)
    print(f"   one-loop flow in d=3: fixed point r*={rstar:.5f}, u*={ustar:.4f}")

    def rhs(l, y, sgn):
        r, u = y
        r = np.clip(r, -0.95, 10.0)
        return [sgn * (2 * r + Kd * u / (2 * (1 + r))),
                sgn * (eps * u - 1.5 * Kd * u**2 / (1 + r)**2)]

    def traj(r0, u0, lmax=6.0, sgn=1.0):
        sol = solve_ivp(rhs, [0, lmax], [r0, u0], args=(sgn,), rtol=1e-9,
                        atol=1e-11, max_step=0.01, dense_output=False)
        return sol.y[0], sol.y[1]

    RMAX, UMAX = 0.30, 85.0
    rc, uc = [], []
    # seed along the stable (irrelevant) eigenvector of the linearised flow
    h = 1e-7
    f0 = np.array(rhs(0, [rstar, ustar], 1.0))
    J = np.column_stack([(np.array(rhs(0, [rstar + h, ustar], 1.0)) - f0) / h,
                         (np.array(rhs(0, [rstar, ustar + h], 1.0)) - f0) / h])
    w, V = np.linalg.eig(J)
    v = np.real(V[:, np.argmin(np.real(w))])
    v = v / np.hypot(v[0] / RMAX, v[1] / UMAX)          # unit length in plot units
    print(f"   eigenvalues at the fixed point: {np.sort(np.real(w))}")
    for d in (+1, -1):
        r, u = traj(rstar + d * 1e-4 * v[0], ustar + d * 1e-4 * v[1], lmax=14.0, sgn=-1.0)
        m = (np.abs(r) < RMAX) & (u > 0) & (u < UMAX)
        axB.plot(r[m], u[m], color=BLUE, lw=2.5, zorder=4)
        rc += list(r[m]); uc += list(u[m])
    axB.plot([], [], color=BLUE, lw=2.5, label="critical surface")

    rc, uc = np.asarray(rc), np.asarray(uc)
    o = np.argsort(uc); rc, uc = rc[o], uc[o]
    for u0 in (18, 32, 45, 60, 72, 80):
        if not (uc.min() <= u0 <= uc.max()):
            continue
        r0 = float(np.interp(u0, uc, rc))
        for dr, c in ((-0.020, GREEN), (0.020, ORANGE)):
            r, u = traj(r0 + dr, u0, lmax=4.0)
            m = (np.abs(r) < RMAX) & (u > 0) & (u < UMAX)
            if m.sum() > 8:
                rr, uu = r[m], u[m]
                axB.plot(rr, uu, color=c, lw=1.0, alpha=0.9, zorder=2)
                k = min(len(rr) - 2, 40)
                axB.add_patch(FancyArrowPatch((rr[k], uu[k]), (rr[k + 1], uu[k + 1]),
                                              arrowstyle="-|>", mutation_scale=11,
                                              color=c, lw=1.0, zorder=2))

    axB.plot(0, 0, "o", color=INK, ms=11, zorder=6)
    axB.text(0.015, 2.5, "Gaussian", color=INK, fontsize=10)
    axB.plot(rstar, ustar, "o", color=RED, ms=12, zorder=7)
    axB.annotate("Wilson-Fisher", xy=(rstar, ustar), xytext=(-0.285, ustar + 22),
                 color=RED, fontsize=11,
                 arrowprops=dict(arrowstyle="-|>", color=RED, lw=1.3, mutation_scale=12))
    axB.text(0.02, 66, "green: falls off to the\ndisordered phase\n"
                       "orange: to the ordered one", fontsize=8.8, color=GREY)
    axB.set_xlabel(r"$\tilde r = m^2/\Lambda^2$")
    axB.set_ylabel(r"$\tilde u = \lambda\,\Lambda^{d-4}$")
    axB.set_xlim(-RMAX, RMAX); axB.set_ylim(0, UMAX)
    axB.legend(frameon=False, fontsize=9.5, loc="lower right")
    axB.set_title(r"the flow in $d=3$", fontsize=11.5)

    fig.tight_layout()
    save(fig, "wf_flow.svg")


# ------------------------------------ 5. epsilon expansion against the truth
def epsilon_exponents():
    eps = np.linspace(0, 2, 200)
    nu1 = 0.5 + eps / 12
    fig, ax = plt.subplots(figsize=(6.8, 4.6))
    ax.plot(eps, nu1, color=BLUE, lw=2.0,
            label=r"$\nu = \frac{1}{2} + \frac{\epsilon}{12}$  (first order)")
    ax.plot(eps, 1 / (2 - eps / 3), color=GREEN, lw=2.0, ls="--",
            label=r"$\nu = 1/(2-\epsilon/3)$  (unexpanded)")
    known = [(0, 0.5, r"$d=4$: mean field, exact"),
             (1, 0.6300, r"$d=3$: 0.6300 (conformal bootstrap)"),
             (2, 1.0, r"$d=2$: 1 (Onsager, exact)")]
    for e, v, lab in known:
        ax.plot(e, v, "o", color=RED, ms=9, zorder=5)
        off = {0: (0.02, 0.07), 1: (0.35, -0.10), 2: (-0.05, 0.07)}[e]
        ax.annotate(lab, xy=(e, v), xytext=(e + off[0], v + off[1]), color=RED,
                    fontsize=9.5, ha="left" if e < 1.5 else "right",
                    arrowprops=dict(arrowstyle="-", lw=0.8, color=RED) if e == 1 else None)
    ax.set_xlabel(r"$\epsilon = 4-d$"); ax.set_ylabel(r"$\nu$")
    ax.set_xlim(-0.08, 2.15); ax.set_ylim(0.42, 1.18)
    ax.legend(frameon=False, fontsize=9.5, loc="upper left")
    ax.set_title(r"the $\epsilon$ expansion, pushed past where it should work",
                 fontsize=11)
    fig.tight_layout()
    save(fig, "epsilon_exponents.svg")


# ------------------------------------------------- 6. the running couplings
def running_couplings():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10.4, 4.3))

    # QED: alpha^-1 falls as mu rises (charge grows)
    mu = np.logspace(-3, 3, 400)                       # GeV
    me, al0 = 0.000510999, 1 / 137.035999
    # exact one-loop (Uehling) vacuum polarisation at spacelike Q^2 = mu^2,
    # not the large-Q asymptotic form, which is wrong for mu near m_e
    x = np.linspace(0, 1, 4001)[:, None]
    integrand = x * (1 - x) * np.log1p(x * (1 - x) * (mu[None, :] / me) ** 2)
    P = (2 * al0 / np.pi) * np.trapezoid(integrand, x[:, 0], axis=0)
    ax1.plot(mu, 1 / (al0 / (1 - P)), color=BLUE, lw=2.1)
    ax1.set_xscale("log")
    ax1.set_xlabel(r"momentum scale  $\mu$  [GeV]")
    ax1.set_ylabel(r"$1/\alpha_{\rm eff}$")
    ax1.set_title("QED: the charge grows at short distance", fontsize=11)
    ax1.axvline(91.1876, color=GREY, ls=":", lw=1.1)
    ax1.text(91.1876 * 1.25, 136.3, r"$m_Z$", fontsize=10, color=GREY)
    ax1.text(1.3e-3, 132.0, "electron loop only;\nincluding every charged particle\n"
                            r"brings $1/\alpha(m_Z)$ down to 127.95",
             fontsize=8.8, color=GREY)
    ax1.set_ylim(131, 137.6)

    # QCD
    b0 = 11 - 2 * 5 / 3
    mus = np.logspace(np.log10(1.5), 4, 400)
    asr = 0.1180 / (1 + (b0 * 0.1180 / (2 * np.pi)) * np.log(mus / 91.1876))
    ax2.plot(mus, asr, color=RED, lw=2.1)
    ax2.set_xscale("log")
    ax2.set_xlabel(r"momentum scale  $\mu$  [GeV]")
    ax2.set_ylabel(r"$\alpha_s$")
    ax2.set_title("QCD: the charge dies at short distance", fontsize=11)
    ax2.plot(91.1876, 0.1180, "o", color=INK, ms=7)
    ax2.annotate(r"$\alpha_s(m_Z)=0.1180$", xy=(91.1876, 0.1180),
                 xytext=(200, 0.245), fontsize=9.5,
                 arrowprops=dict(arrowstyle="-|>", lw=1.1, color=INK, mutation_scale=11))
    ax2.annotate("below ~1 GeV the coupling is\nno longer small: confinement,\n"
                 "and one loop stops working", xy=(1.6, 0.28), xytext=(4.0, 0.31),
                 fontsize=9, color=GREY,
                 arrowprops=dict(arrowstyle="-|>", lw=1.0, color=GREY, mutation_scale=10))
    ax2.set_ylim(0.05, 0.40)
    fig.tight_layout()
    save(fig, "running_couplings.svg")


# ------------------------------------------- 7. screening vs antiscreening
def screening():
    """Heuristic pictures only (the honest version is the sign of the beta
    function). QED: the vacuum is a dielectric of virtual pairs, each one
    turned so its negative end faces the positive test charge. QCD: the colour
    charge is smeared over a cloud of gluons that are themselves coloured."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(9.8, 4.9))

    ax1.plot(0, 0, "o", color=RED, ms=22, zorder=6)
    ax1.text(0, 0, "+", color="white", fontsize=15, ha="center", va="center", zorder=7)
    for ring, n in ((0.55, 8), (0.95, 12)):
        for a in np.linspace(0, 2 * np.pi, n, endpoint=False) + ring:
            ux, uy = np.cos(a), np.sin(a)
            xm, ym = (ring - 0.09) * ux, (ring - 0.09) * uy     # minus end, inward
            xp, yp = (ring + 0.09) * ux, (ring + 0.09) * uy     # plus end, outward
            ax1.plot([xm, xp], [ym, yp], color=GREY, lw=1.0, zorder=3)
            ax1.plot(xm, ym, "o", color=BLUE, ms=7.5, zorder=4)
            ax1.text(xm, ym, "−", color="white", fontsize=8, ha="center",
                     va="center", zorder=5)
            ax1.plot(xp, yp, "o", color=RED, ms=7.5, zorder=4)
            ax1.text(xp, yp, "+", color="white", fontsize=7, ha="center",
                     va="center", zorder=5)
    ax1.set_title("QED: screening", fontsize=11.5, color=BLUE)
    ax1.text(0, -1.45, "virtual pairs turn their negative ends inward.\n"
                       "From far away you see a smaller charge;\n"
                       "come closer and you see more of it,\n"
                       "so the coupling grows at short distance.",
             ha="center", va="top", fontsize=9.5)
    ax1.set_xlim(-1.35, 1.35); ax1.set_ylim(-2.45, 1.3); bare(ax1)

    rng = np.random.default_rng(5)
    r = np.abs(rng.normal(0, 0.55, 700)); a = rng.uniform(0, 2 * np.pi, 700)
    ax2.scatter(r * np.cos(a), r * np.sin(a), s=9, color=GREEN, alpha=0.30,
                edgecolors="none", zorder=2)
    ax2.plot(0, 0, "o", color=GREEN, ms=15, zorder=6)
    ax2.text(0, 0, "g", color="white", fontsize=10, ha="center", va="center",
             style="italic", zorder=7)
    ax2.set_title("QCD: antiscreening", fontsize=11.5, color=GREEN)
    ax2.text(0, -1.45, "the colour charge is smeared over a cloud\n"
                       "of gluons that carry colour themselves.\n"
                       "Come close and you are inside the cloud,\n"
                       "so you see less: the coupling shrinks.",
             ha="center", va="top", fontsize=9.5)
    ax2.set_xlim(-1.35, 1.35); ax2.set_ylim(-2.45, 1.3); bare(ax2)
    fig.tight_layout()
    save(fig, "screening.svg")


# ------------------------------------------------ 8. Fermi theory as an EFT
def fermi_eft():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(9.2, 3.5))

    for sx, sy in [(-1.1, 0.75), (-1.1, -0.75)]:
        ax1.plot([sx, -0.5], [sy, 0], color=INK, lw=1.5)
    for sx, sy in [(1.1, 0.75), (1.1, -0.75)]:
        ax1.plot([sx, 0.5], [sy, 0], color=INK, lw=1.5)
    xs = np.linspace(-0.5, 0.5, 220)
    ax1.plot(xs, 0.09 * np.sin(2 * np.pi * xs / 0.145), color=BLUE, lw=1.6)
    ax1.plot(-0.5, 0, "o", color=INK, ms=6); ax1.plot(0.5, 0, "o", color=INK, ms=6)
    ax1.text(0, 0.30, r"$W$,  mass $m_W$", color=BLUE, fontsize=10.5, ha="center")
    ax1.text(0, -1.25, r"$\frac{g^2}{q^2-m_W^2}$", ha="center", fontsize=12)
    ax1.set_title(r"the true theory, at any $q$", fontsize=11)
    ax1.set_xlim(-1.6, 1.6); ax1.set_ylim(-1.8, 1.2); bare(ax1)

    ax2.add_patch(FancyArrowPatch((-1.6, 0), (-1.15, 0), arrowstyle="-|>",
                                  mutation_scale=14, color=GREY, lw=1.4))
    ax2.text(-1.38, 0.18, r"$q^2\ll m_W^2$", fontsize=10, ha="center", color=GREY)
    for sx, sy in [(-0.9, 0.75), (-0.9, -0.75), (0.9, 0.75), (0.9, -0.75)]:
        ax2.plot([sx, 0], [sy, 0], color=INK, lw=1.5)
    ax2.plot(0, 0, "o", color=RED, ms=10)
    ax2.text(0, -1.25, r"$\approx -\frac{g^2}{m_W^2}\;\propto\;G_F$,   "
                       r"$[G_F]=-2$: irrelevant", ha="center", fontsize=12)
    ax2.set_title("the effective theory: a contact term", fontsize=11)
    ax2.set_xlim(-1.75, 1.45); ax2.set_ylim(-1.8, 1.2); bare(ax2)
    fig.tight_layout()
    save(fig, "fermi_eft.svg")


if __name__ == "__main__":
    momentum_shell(); power_counting(); phi4_diagrams()
    wf_flow(); epsilon_exponents(); running_couplings()
    screening(); fermi_eft()


# ------------------------------------------------ 9. Wick rotation contour
def wick_rotation():
    """The Feynman i-epsilon puts the poles of 1/(k0^2 - E^2 + i eps) in the
    second and fourth quadrants, so the real-axis contour can be swung
    anticlockwise onto the imaginary axis without crossing either one
    (Peskin & Schroeder Fig. 6.1, Das Fig. 4.2)."""
    fig, ax = plt.subplots(figsize=(6.2, 5.2))
    ax.annotate("", xy=(2.3, 0), xytext=(-2.3, 0),
                arrowprops=dict(arrowstyle="-|>", lw=1.1, color=GREY, mutation_scale=11))
    ax.annotate("", xy=(0, 2.3), xytext=(0, -2.3),
                arrowprops=dict(arrowstyle="-|>", lw=1.1, color=GREY, mutation_scale=11))
    ax.text(2.25, -0.22, r"Re $k^0$", fontsize=10, ha="right", color=GREY)
    ax.text(0.1, 2.2, r"Im $k^0$", fontsize=10, color=GREY)

    ax.plot([1.2], [-0.18], "x", color=RED, ms=11, mew=2.4)
    ax.plot([-1.2], [0.18], "x", color=RED, ms=11, mew=2.4)
    ax.text(1.2, -0.48, r"$+E_k - i\varepsilon$", ha="center", color=RED, fontsize=10)
    ax.text(-1.2, 0.34, r"$-E_k + i\varepsilon$", ha="center", color=RED, fontsize=10)

    ax.plot([-2.0, 2.0], [0.03, 0.03], color=BLUE, lw=2.2)
    ax.add_patch(FancyArrowPatch((0.6, 0.03), (0.9, 0.03), arrowstyle="-|>",
                                 mutation_scale=14, color=BLUE, lw=2.2))
    ax.text(-1.95, -0.35, "Minkowski\n(real $k^0$)", color=BLUE, fontsize=9.5)

    ax.plot([0.03, 0.03], [-2.0, 2.0], color=GREEN, lw=2.2)
    ax.add_patch(FancyArrowPatch((0.03, 0.9), (0.03, 1.2), arrowstyle="-|>",
                                 mutation_scale=14, color=GREEN, lw=2.2))
    ax.text(0.15, -1.9, r"Euclidean: $k^0 = i k^4$", color=GREEN, fontsize=9.5)

    for th1, th2 in ((0, 90), (180, 270)):
        ax.add_patch(Arc((0, 0), 2.6, 2.6, theta1=th1 + 8, theta2=th2 - 8,
                         ec=ORANGE, lw=1.5, ls="--"))
    ax.add_patch(FancyArrowPatch((1.30 * np.cos(np.radians(60)), 1.30 * np.sin(np.radians(60))),
                                 (1.30 * np.cos(np.radians(75)), 1.30 * np.sin(np.radians(75))),
                                 arrowstyle="-|>", mutation_scale=12, color=ORANGE, lw=1.5))
    ax.text(1.05, 1.25, "rotate\nanticlockwise:\nno pole is crossed",
            color=ORANGE, fontsize=9.5)
    ax.set_xlim(-2.4, 2.4); ax.set_ylim(-2.3, 2.4)
    bare(ax)
    save(fig, "wick_rotation.svg")


# -------------------------------------- 10. one integral, three regulators
def three_regulators():
    """I(m) = int d^4k/(2pi)^4 1/(k^2+m^2)^2 with a hard cutoff, Pauli-Villars
    and dimensional regularisation. Each is infinite as its regulator is
    removed; they differ by an m-independent constant, so differences of
    I at two masses agree exactly. Formulas verified in Wolfram (verify9)."""
    m = np.logspace(-1, 1, 300)
    c = 1 / (16 * np.pi**2)
    L, M, eps, mu = 30.0, 30.0, 0.35, 1.0
    cut = c * (np.log1p(L**2 / m**2) - L**2 / (L**2 + m**2))
    pv = c * np.log(M**2 / m**2)
    dr = c * (2 / eps - np.euler_gamma + np.log(4 * np.pi) - np.log(m**2 / mu**2))

    fig, (a1, a2) = plt.subplots(1, 2, figsize=(10.4, 4.1))
    for y, lab, col, ls in [(cut, rf"hard cutoff, $\Lambda={L:g}$", BLUE, "-"),
                            (pv, rf"Pauli-Villars, $M={M:g}$", GREEN, "--"),
                            (dr, rf"dim. reg., $\epsilon={eps:g}$", RED, "-.")]:
        a1.plot(m, y, color=col, ls=ls, lw=2, label=lab)
        k0 = np.argmin(abs(m - 1.0))
        a2.plot(m, y - y[k0], color=col, ls=ls, lw=2.6 if col == BLUE else 2, label=lab)
    a1.set_xscale("log"); a2.set_xscale("log")
    a1.set_xlabel(r"$m$"); a2.set_xlabel(r"$m$")
    a1.set_ylabel(r"$I(m)$")
    a2.set_ylabel(r"$I(m) - I(1)$")
    a1.set_title("the raw integral depends on the regulator", fontsize=11)
    a2.set_title("differences don't: the curves lie on top", fontsize=11)
    a1.legend(frameon=False, fontsize=9)
    a2.legend(frameon=False, fontsize=9)
    fig.tight_layout()
    save(fig, "three_regulators.svg")
