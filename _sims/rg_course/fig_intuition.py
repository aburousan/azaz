"""Figures for Part 1 (why scale) and Part 2 (block spins, the 1D chain)."""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Rectangle, FancyArrowPatch
from common import *

rng = np.random.default_rng(7)

# ---------------------------------------------------------------- 1. the ladder
def scale_ladder():
    fig, ax = plt.subplots(figsize=(9.6, 3.5))
    rows = [
        ("quarks & gluons", r"$\gtrsim 1\ \mathrm{GeV}$",      r"$10^{-16}\,\mathrm{m}$", PURPLE),
        ("protons & neutrons", r"$\sim 1\ \mathrm{MeV}$",      r"$10^{-15}\,\mathrm{m}$", BLUE),
        ("nuclei & electrons", r"$\sim 1\ \mathrm{eV}$",       r"$10^{-10}\,\mathrm{m}$", TEAL),
        ("atoms & molecules", r"$\sim 10^{-2}\ \mathrm{eV}$",  r"$10^{-9}\,\mathrm{m}$",  GREEN),
        ("a fluid, a magnet", r"$\ll$ everything",             r"$10^{-3}\,\mathrm{m}$",  ORANGE),
    ]
    for i, (what, energy, length, c) in enumerate(rows):
        y = -i * 1.0
        ax.add_patch(FancyBboxPatch((0, y - 0.3), 3.5, 0.6, boxstyle="round,pad=0.06",
                                    fc="none", ec=c, lw=1.5))
        ax.text(1.75, y, what, ha="center", va="center", fontsize=11, color=c)
        ax.text(4.1, y, energy, ha="left", va="center", fontsize=10)
        ax.text(7.0, y, length, ha="left", va="center", fontsize=10)
        if i < len(rows) - 1:
            ax.add_patch(FancyArrowPatch((1.75, y - 0.33), (1.75, y - 0.67),
                                         arrowstyle="-|>", mutation_scale=13,
                                         lw=1.3, color=GREY))
    ax.text(4.1, 0.75, "typical energy", fontsize=10, style="italic", color=GREY)
    ax.text(7.0, 0.75, "typical size", fontsize=10, style="italic", color=GREY)
    ax.text(1.75, 0.75, "the right variables", fontsize=10, style="italic",
            color=GREY, ha="center")
    ax.annotate("", xy=(9.6, -4.3), xytext=(9.6, 0.4),
                arrowprops=dict(arrowstyle="-|>", lw=1.6, color=INK, mutation_scale=14))
    ax.text(9.85, -2.0, "coarse-graining", rotation=-90, va="center",
            fontsize=10.5, style="italic")
    ax.set_xlim(-0.3, 10.4); ax.set_ylim(-4.7, 1.1)
    bare(ax); ax.set_aspect("auto")
    save(fig, "scale_ladder.svg")


# --------------------------------------------------- 2. majority-rule blocking
def blocking_cartoon():
    fig, axes = plt.subplots(1, 3, figsize=(10.2, 3.6))
    s = rng.choice([-1, 1], size=(9, 9), p=[0.42, 0.58])

    def draw(ax, grid, cell, title, hl=None):
        n = grid.shape[0]
        for i in range(n):
            for j in range(n):
                spin_arrow(ax, j * cell, -i * cell, grid[i, j] > 0,
                           color=RED if grid[i, j] > 0 else BLUE,
                           L=0.62 * cell, lw=1.4 * cell)
        if hl:
            for bi in range(0, n, 3):
                for bj in range(0, n, 3):
                    ax.add_patch(Rectangle((bj * cell - cell / 2, -(bi + 2) * cell - cell / 2),
                                           3 * cell, 3 * cell, fc="none",
                                           ec=GREY, lw=1.0, ls="--"))
        ax.set_xlim(-cell, n * cell); ax.set_ylim(-n * cell, cell)
        bare(ax); ax.set_title(title, fontsize=11, pad=8)

    draw(axes[0], s, 1.0, r"$9\times9$ spins", hl=True)

    blocked = np.sign(s.reshape(3, 3, 3, 3).sum(axis=(1, 3)))
    blocked[blocked == 0] = 1
    draw(axes[1], blocked, 3.0, r"majority of each $3\times3$ block")

    b2 = np.sign(blocked.sum())
    axes[2].set_xlim(-4, 4); axes[2].set_ylim(-4, 4)
    spin_arrow(axes[2], 0, 0, b2 > 0, color=RED if b2 > 0 else BLUE, L=3.2, lw=4.2)
    bare(axes[2]); axes[2].set_title("majority again", fontsize=11, pad=8)

    fig.subplots_adjust(wspace=0.05)
    save(fig, "blocking_cartoon.svg")


# ------------------------------------------------------- 3. 1D decimation
def decimation_1d():
    fig, ax = plt.subplots(figsize=(9.4, 3.0))
    n, dx = 9, 1.0
    up = [1, 1, -1, 1, -1, -1, 1, -1, 1]

    for i in range(n):
        x = i * dx
        keep = (i % 2 == 0)
        spin_arrow(ax, x, 0, up[i] > 0, color=INK if keep else GREY,
                   L=0.5, lw=1.7 if keep else 1.2, alpha=1.0 if keep else 0.45)
        ax.text(x, -0.62, rf"$s_{{{i+1}}}$", ha="center", fontsize=9.5,
                color=INK if keep else GREY, alpha=1.0 if keep else 0.5)
        if i < n - 1:
            ax.plot([x + 0.16, x + dx - 0.16], [0, 0], color=BLUE, lw=1.4, zorder=0)
    ax.text(4.0, 0.55, r"$K$ on every bond", ha="center", color=BLUE, fontsize=10.5)

    for i in range(1, n, 2):
        ax.plot([i * dx - 0.2, i * dx + 0.2], [0.3, -0.3], color=RED, lw=1.4)
        ax.plot([i * dx - 0.2, i * dx + 0.2], [-0.3, 0.3], color=RED, lw=1.4)
    ax.text(8.6, 0.0, "sum over\nthese", color=RED, fontsize=9.5, va="center")

    ax.annotate("", xy=(4.0, -1.35), xytext=(4.0, -0.95),
                arrowprops=dict(arrowstyle="-|>", lw=1.6, color=INK, mutation_scale=13))

    y = -2.1
    for j, i in enumerate(range(0, n, 2)):
        x = j * 2 * dx
        spin_arrow(ax, x, y, up[i] > 0, color=INK, L=0.5, lw=1.7)
        ax.text(x, y - 0.62, rf"$s'_{{{j+1}}}$", ha="center", fontsize=9.5)
        if j < 4:
            ax.plot([x + 0.16, x + 2 * dx - 0.16], [y, y], color=GREEN, lw=2.2, zorder=0)
    ax.text(4.0, y + 0.55, r"$K' = \mathrm{artanh}\,(\tanh^2 K)$  on every bond",
            ha="center", color=GREEN, fontsize=10.5)
    ax.text(4.0, y - 1.15, "same chain, half as many spins, twice the lattice spacing",
            ha="center", fontsize=10, style="italic", color=GREY)

    ax.set_xlim(-0.8, 10.2); ax.set_ylim(-3.5, 1.1)
    bare(ax); ax.set_aspect("auto")
    save(fig, "decimation_1d.svg")


# ------------------------------------------- 4. the flow on the K line + cobweb
def flow_1d():
    R = lambda k: np.arctanh(np.tanh(k) ** 2)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10.4, 4.1),
                                   gridspec_kw={"width_ratios": [1, 1.05]})

    # --- left: the map and its cobweb
    k = np.linspace(0, 3.0, 500)
    ax1.plot(k, R(k), color=BLUE, lw=2.0, label=r"$K' = R(K)$")
    ax1.plot(k, k, color=GREY, lw=1.1, ls="--", label=r"$K' = K$")

    kk = 2.6
    for _ in range(7):
        kn = R(kk)
        ax1.plot([kk, kk], [kk, kn], color=RED, lw=1.1)
        ax1.plot([kk, kn], [kn, kn], color=RED, lw=1.1)
        kk = kn
    ax1.plot([], [], color=RED, lw=1.1, label="iterating the map")
    ax1.plot(0, 0, "o", color=INK, ms=7, zorder=5)
    ax1.annotate(r"$K^*=0$ (stable)", xy=(0.02, 0.02), xytext=(0.45, 0.32),
                 fontsize=9.5,
                 arrowprops=dict(arrowstyle="-|>", lw=1.0, color=INK,
                                 mutation_scale=10))
    ax1.set_xlabel(r"$K = J/k_BT$"); ax1.set_ylabel(r"$K'$")
    ax1.set_xlim(0, 3); ax1.set_ylim(0, 3)
    ax1.legend(frameon=False, fontsize=9, loc="upper left")
    ax1.set_title("the 1D Ising recursion", fontsize=11)

    # --- right: the flow drawn on the coupling axis
    ax2.plot([-0.12, 1.12], [0, 0], color=INK, lw=1.4)
    ax2.plot(0, 0, "o", color=INK, ms=11, zorder=5)
    ax2.plot(1, 0, "o", color="none", mec=INK, mew=1.8, ms=11, zorder=5)
    for x0 in [0.16, 0.34, 0.52, 0.70, 0.88]:
        ax2.annotate("", xy=(x0 - 0.10, 0), xytext=(x0, 0),
                     arrowprops=dict(arrowstyle="-|>", lw=1.7, color=RED,
                                     mutation_scale=14))
    ax2.text(0, -0.30, r"$K^*=0$" "\n" r"$T=\infty$, disordered" "\n" "attractive",
             ha="center", va="top", fontsize=10)
    ax2.text(1, -0.30, r"$K^*=\infty$" "\n" r"$T=0$, ordered" "\n" "repulsive",
             ha="center", va="top", fontsize=10)
    ax2.text(0.5, 0.20, "every finite temperature flows to disorder",
             ha="center", fontsize=10.5, color=RED, style="italic")
    ax2.text(0.5, 0.42, "coupling-constant space of the 1D chain",
             ha="center", fontsize=10.5)
    ax2.set_xlim(-0.22, 1.22); ax2.set_ylim(-1.0, 0.6)
    bare(ax2); ax2.set_aspect("auto")

    fig.tight_layout()
    save(fig, "flow_1d.svg")


if __name__ == "__main__":
    scale_ladder()
    blocking_cartoon()
    decimation_1d()
    flow_1d()
