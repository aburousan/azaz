"""Extra figures for the detailed calculations in Parts 5 and 6."""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, FancyArrowPatch
from common import *


# -------------------------- Part 5: free correlator, and the Ginzburg ratio
def correlator_ginzburg():
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.6, 3.8))
    R = np.linspace(0.3, 30, 400)
    for xi, c in [(3, GREEN), (10, ORANGE), (np.inf, RED)]:
        G = np.exp(-R / xi) / (4 * np.pi * R) if np.isfinite(xi) else 1 / (4 * np.pi * R)
        a1.plot(R, G, color=c, lw=2, label=(rf"$\xi={xi:g}$" if np.isfinite(xi) else r"$\xi=\infty$ (critical)"))
    a1.set_yscale("log"); a1.set_xlabel(r"distance $R$"); a1.set_ylabel(r"$\langle\phi(R)\phi(0)\rangle$")
    a1.set_title(r"free correlator in 3D: $e^{-R/\xi}/4\pi R$", fontsize=11)
    a1.legend(frameon=False, fontsize=9.5); a1.set_ylim(1e-7, 0.5)

    t = np.logspace(-4, -0.3, 200)
    for d, c in [(3, RED), (4, INK), (5, BLUE)]:
        a2.plot(t, t**((d - 4) / 2), color=c, lw=2, label=rf"$d={d}$: $R\propto|t|^{{{(d-4)/2:g}}}$")
    a2.axhline(1, color=GREY, ls=":", lw=1)
    a2.set_xscale("log"); a2.set_yscale("log")
    a2.set_xlabel(r"distance from $T_c$:  $|t|$"); a2.set_ylabel(r"fluctuations / mean field")
    a2.set_title("Ginzburg ratio: when mean field fails", fontsize=11)
    a2.text(1.5e-4, 2.5, "fluctuations win:\nmean field fails", color=RED, fontsize=9.5)
    a2.text(3e-3, 0.012, "mean field is safe", color=BLUE, fontsize=9.5)
    a2.legend(frameon=False, fontsize=9.5, loc="upper right")
    fig.tight_layout()
    save(fig, "correlator_ginzburg.svg")


# --------------------- Part 6: where the 72 comes from, drawn as contractions
def wick_72():
    """The two ways to join the fast legs of two vertices. Each vertex has two
    slow legs (green, pointing out) and two fast stubs (red, labelled); the
    stubs are joined straight across (A) or crossed (B). Both give the same
    bubble, so the count doubles."""
    fig, axes = plt.subplots(1, 2, figsize=(8.8, 3.3))
    X, Y = (-1.4, 0.0), (1.4, 0.0)
    stubsX = {"1": (-0.8, 0.35), "2": (-0.8, -0.35)}
    stubsY = {"1'": (0.8, 0.35), "2'": (0.8, -0.35)}
    for ax, crossed in zip(axes, (False, True)):
        for (cx, cy), side in ((X, -1), (Y, 1)):
            for dy in (0.6, -0.6):
                ax.plot([cx, cx + side * 0.8], [cy, cy + dy], color=GREEN, lw=2.2)
            ax.add_patch(Circle((cx, cy), 0.09, fc=INK, ec=INK, zorder=5))
        for lab, (sx, sy) in stubsX.items():
            ax.plot([X[0], sx], [X[1], sy], color=RED, lw=2.2)
            ax.text(sx - 0.05, sy + (0.12 if sy > 0 else -0.28), lab, color=RED, fontsize=11, ha="center")
        for lab, (sx, sy) in stubsY.items():
            ax.plot([Y[0], sx], [Y[1], sy], color=RED, lw=2.2)
            ax.text(sx + 0.05, sy + (0.12 if sy > 0 else -0.28), lab, color=RED, fontsize=11, ha="center")
        pairs = ([("1", "1'"), ("2", "2'")] if not crossed else [("1", "2'"), ("2", "1'")])
        for i, (u, v) in enumerate(pairs):
            (x0, y0), (x1, y1) = stubsX[u], stubsY[v]
            ax.plot([x0, x1], [y0, y1], color=RED, lw=1.8, ls="-" if i == 0 else "--")
        ax.set_title("pairing A: 1 to 1′, 2 to 2′" if not crossed else
                     "pairing B: 1 to 2′, 2 to 1′ (crossed)", fontsize=10.5)
        ax.text(-2.25, 0.72, "slow", color=GREEN, fontsize=9)
        ax.text(1.95, 0.72, "slow", color=GREEN, fontsize=9)
        ax.set_xlim(-2.5, 2.5); ax.set_ylim(-1.0, 1.05); bare(ax)
    fig.text(0.5, 0.03, r"choose 2 slow legs out of 4 at each vertex: $\binom{4}{2}\times\binom{4}{2}=36$ ways;"
             r"   then 2 pairings of the fast legs:   $36\times2=72$", ha="center", fontsize=10.5)
    fig.tight_layout(rect=(0, 0.09, 1, 1))
    save(fig, "wick_72.svg")


# ------------------------------- Part 6: all the exponents against the truth
def exponent_bars():
    names = [r"$\nu$", r"$\alpha$", r"$\beta$", r"$\gamma$", r"$\delta/4$", r"$\eta\times10$"]
    mf    = [0.5, 0.0, 0.5, 1.0, 3 / 4, 0.0]
    one   = [0.5 + 1 / 12, 1 / 6, 1 / 2 - 1 / 6, 1 + 1 / 6, 4 / 4, 0.0]
    ising = [0.6300, 0.1101, 0.3265, 1.2371, 4.7898 / 4, 0.0363 * 10]
    x = np.arange(len(names)); w = 0.26
    fig, ax = plt.subplots(figsize=(7.2, 3.6))
    ax.bar(x - w, mf, w, color=GREY, label="mean field")
    ax.bar(x, one, w, color=BLUE, label=r"one loop, $\epsilon=1$")
    ax.bar(x + w, ising, w, color=RED, label="3D Ising (bootstrap)")
    ax.set_xticks(x); ax.set_xticklabels(names, fontsize=12)
    ax.set_ylabel("value")
    ax.set_title("all the exponents: mean field, one loop, and the real 3D values", fontsize=11)
    ax.legend(frameon=False, fontsize=9.5, ncol=3, loc="upper left")
    ax.set_ylim(0, 1.55)
    fig.tight_layout()
    save(fig, "exponent_bars.svg")


if __name__ == "__main__":
    correlator_ginzburg(); wick_72(); exponent_bars()
