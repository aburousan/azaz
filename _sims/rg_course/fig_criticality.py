"""Part 3: what a critical point looks like, and what the flow does to it."""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from common import *
from ising2d import wolff, block, KC

CMAP = mpl.colors.ListedColormap(["#f4f4f4", "#1c1c1c"])


def show(ax, s, title=None, fs=10):
    ax.imshow((s > 0).astype(float), cmap=CMAP, interpolation="nearest")
    ax.set_xticks([]); ax.set_yticks([])
    for sp in ax.spines.values():
        sp.set_edgecolor(GREY); sp.set_linewidth(0.8)
    if title:
        ax.set_title(title, fontsize=fs, pad=5)


# ------------------------------------------------ 1. three temperatures
def snapshots(L=256, nsw=9000):
    fig, axes = plt.subplots(1, 3, figsize=(10.2, 3.7))
    cases = [(0.90 * KC, r"$T > T_c$   (hot)"),
             (1.00 * KC, r"$T = T_c$   (critical)"),
             (1.10 * KC, r"$T < T_c$   (cold)")]
    for ax, (K, lab) in zip(axes, cases):
        s = wolff(L, K, nsw, seed=11)
        show(ax, s, lab, fs=11)
    fig.tight_layout()
    save(fig, "ising_snapshots.svg")


# ----------------------------------- 2. blocking: the self-similarity picture
def self_similar(L=256, nsw=12000):
    rows = [(0.93 * KC, r"$T>T_c$"), (1.00 * KC, r"$T=T_c$"), (1.07 * KC, r"$T<T_c$")]
    fig, axes = plt.subplots(3, 4, figsize=(9.6, 7.4))
    for r, (K, lab) in enumerate(rows):
        s = wolff(L, K, nsw, seed=23)
        for c in range(4):
            show(axes[r, c], s,
                 title=(f"${s.shape[0]}^2$" if r == 0 else None), fs=10)
            if c == 0:
                axes[r, c].set_ylabel(lab, fontsize=12, labelpad=8)
            if c < 3:
                s = block(s, 2)
    for c in range(1, 4):
        axes[0, c].set_title(rf"after {c} blocking step{'s' if c > 1 else ''}"
                             "\n" rf"${256 // 2**c}^2$", fontsize=9.5, pad=5)
    axes[0, 0].set_title(r"the original $256^2$", fontsize=9.5, pad=5)
    fig.tight_layout()
    save(fig, "self_similar.svg")


# ------------------------------- 3. generic flow: critical surface, two axes
def fixed_point_flows():
    fig, ax = plt.subplots(figsize=(7.4, 5.4))

    # A caricature flow with one relevant direction (t) and one irrelevant (u).
    def vel(t, u):
        return 1.0 * t, -0.9 * (u - 0.9 * t**2 / (1 + t**2) * np.sign(t) * 0)

    T, U = np.meshgrid(np.linspace(-1.5, 1.5, 19), np.linspace(-0.2, 1.7, 15))
    dT, dU = 1.0 * T, -0.9 * (U - 0.0)
    ax.quiver(T, U, dT, dU, color=GREY, alpha=0.55, width=0.0035,
              scale=26, headwidth=4)

    ax.axvline(0, color=BLUE, lw=2.2)
    ax.text(0.06, 1.72, "critical surface: every microscopic\n"
                        "theory sitting exactly at $T_c$",
            color=BLUE, fontsize=9.5, va="top")

    ax.plot(0, 0, "o", color=RED, ms=11, zorder=6)
    ax.annotate("fixed point", xy=(0, 0), xytext=(0.30, 0.45), color=RED,
                fontsize=11, arrowprops=dict(arrowstyle="-|>", color=RED, lw=1.3,
                                             mutation_scale=12))

    # t > 0 is T > T_c: the hot, disordered side. t < 0 is the ordered side.
    for t0, c in [(0.10, GREEN), (-0.10, ORANGE)]:
        ts, us = [t0], [1.45]
        for _ in range(220):
            ts.append(ts[-1] * np.exp(0.018))
            us.append(us[-1] * np.exp(-0.9 * 0.018))
        ax.plot(ts, us, color=c, lw=1.9)
        ax.add_patch(FancyArrowPatch((ts[150], us[150]), (ts[165], us[165]),
                                     arrowstyle="-|>", mutation_scale=14,
                                     color=c, lw=1.9))
    ax.text(0.80, 0.02, "disordered phase\n" r"($T>T_c$)", color=GREEN, fontsize=10)
    ax.text(-1.45, 0.02, "ordered phase\n" r"($T<T_c$)", color=ORANGE, fontsize=10)
    ax.plot([0], [1.45], "o", color=PURPLE, ms=7, zorder=6)
    ax.annotate("start exactly on the surface\nand you flow into the fixed point",
                xy=(0, 1.45), xytext=(-1.48, 1.02), color=PURPLE, fontsize=9.5,
                arrowprops=dict(arrowstyle="-|>", color=PURPLE, lw=1.2,
                                mutation_scale=11))

    ax.set_xlabel(r"relevant coupling  $t \propto (T-T_c)$:  grows under the flow")
    ax.set_ylabel(r"irrelevant coupling $u$" "\n" "(dies under the flow)")
    ax.set_xlim(-1.55, 1.55); ax.set_ylim(-0.25, 1.75)
    ax.set_xticks([0]); ax.set_xticklabels(["0"]); ax.set_yticks([0])
    ax.set_yticklabels(["0"])
    fig.tight_layout()
    save(fig, "fixed_point_flows.svg")


# ------------------------------------------------- 4. universality, cartooned
def universality():
    fig, ax = plt.subplots(figsize=(8.4, 4.4))
    starts = [(-1.30, 1.55, "an Ising magnet"),
              (-0.55, 1.75, "a liquid at its\ncritical point"),
              (0.55, 1.75, "a binary alloy"),
              (1.30, 1.50, "a lattice gas")]
    cols = [BLUE, GREEN, ORANGE, PURPLE]
    for (x0, y0, lab), c in zip(starts, cols):
        xs = np.linspace(x0, 0, 60)
        ys = y0 * (np.abs(xs) / abs(x0)) ** 0.75 if x0 != 0 else np.zeros_like(xs)
        ax.plot(xs, ys, color=c, lw=2.0)
        ax.plot(x0, y0, "o", color=c, ms=8)
        ax.text(x0, y0 + 0.13, lab, color=c, fontsize=9.5, ha="center", va="bottom")
        k = 40
        ax.add_patch(FancyArrowPatch((xs[k], ys[k]), (xs[k + 3], ys[k + 3]),
                                     arrowstyle="-|>", mutation_scale=15,
                                     color=c, lw=2.0))
    ax.plot(0, 0, "o", color=RED, ms=13, zorder=6)
    ax.text(0, -0.16, "one fixed point\n" r"$\Rightarrow$ one set of exponents "
                      r"$\nu,\ \beta,\ \gamma,\ \eta$",
            ha="center", va="top", color=RED, fontsize=11)
    ax.text(0, 2.22, "four completely different microscopic systems",
            ha="center", fontsize=11, style="italic", color=GREY)
    ax.set_xlim(-1.9, 1.9); ax.set_ylim(-0.75, 2.35)
    bare(ax); ax.set_aspect("auto")
    save(fig, "universality.svg")


# ------------------------------------- 5. the 2D Migdal-Kadanoff map, cobwebbed
def mk_cobweb():
    R = lambda k: np.arctanh(np.tanh(2 * k) ** 2)
    from scipy.optimize import brentq
    kstar = brentq(lambda k: R(k) - k, 0.05, 1.0)
    yt = np.log((R(kstar + 1e-6) - R(kstar - 1e-6)) / 2e-6) / np.log(2)

    fig, ax = plt.subplots(figsize=(6.4, 5.4))
    k = np.linspace(0, 0.9, 600)
    ax.plot(k, R(k), color=BLUE, lw=2.1, label=r"$K'=\mathrm{artanh}(\tanh^2 2K)$")
    ax.plot(k, k, color=GREY, lw=1.1, ls="--", label=r"$K'=K$")

    for k0, c, lab in [(kstar - 0.012, GREEN, "just hotter than $T_c$"),
                       (kstar + 0.012, ORANGE, "just colder than $T_c$")]:
        kk = k0
        for _ in range(8):
            kn = R(kk)
            ax.plot([kk, kk], [kk, kn], color=c, lw=1.1)
            ax.plot([kk, kn], [kn, kn], color=c, lw=1.1)
            kk = kn
            if not (0 < kk < 0.9):
                break
        ax.plot([], [], color=c, lw=1.1, label=lab)

    ax.plot(kstar, kstar, "o", color=RED, ms=9, zorder=6)
    ax.annotate(rf"$K^* = {kstar:.4f}$" "\n" rf"$y_t = {yt:.4f}$,  $\nu = {1/yt:.3f}$",
                xy=(kstar, kstar), xytext=(0.40, 0.14), color=RED, fontsize=10,
                arrowprops=dict(arrowstyle="-|>", color=RED, lw=1.2, mutation_scale=11))
    ax.set_xlabel(r"$K$"); ax.set_ylabel(r"$K'$")
    ax.set_xlim(0, 0.9); ax.set_ylim(0, 0.9)
    ax.legend(frameon=False, fontsize=9, loc="upper left")
    ax.set_title("an approximate 2D recursion has an unstable fixed point", fontsize=11)
    fig.tight_layout()
    save(fig, "mk_cobweb.svg")
    print(f"   MK: K* = {kstar:.6f}, y_t = {yt:.6f}, nu = {1/yt:.6f}")


if __name__ == "__main__":
    import sys
    if "--flows-only" in sys.argv:
        fixed_point_flows(); raise SystemExit
    fixed_point_flows()
    universality()
    mk_cobweb()
    snapshots()
    self_similar()
