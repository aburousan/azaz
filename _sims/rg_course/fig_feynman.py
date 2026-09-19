"""Feynman diagrams drawn by hand for Parts 1 and 2: the propagator series,
the tadpole with its momenta labelled, the counting behind its 1/2, the pixel
picture of coarse-graining, and the bubble with momentum conservation."""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, FancyArrowPatch, Rectangle, Arc
from common import *


def line(ax, x0, y0, x1, y1, c=INK, lw=1.8, **kw):
    ax.plot([x0, x1], [y0, y1], color=c, lw=lw, solid_capstyle="round", **kw)


def arrow_on(ax, x0, y0, x1, y1, c=INK, t=0.55, label=None, off=(0, 0.16), fs=11):
    """A small momentum arrow placed along a line segment."""
    xm, ym = x0 + t * (x1 - x0), y0 + t * (y1 - y0)
    dx, dy = (x1 - x0) * 0.08, (y1 - y0) * 0.08
    ax.add_patch(FancyArrowPatch((xm - dx, ym - dy), (xm + dx, ym + dy),
                                 arrowstyle="-|>", mutation_scale=13, color=c, lw=0))
    if label:
        ax.text(xm + off[0], ym + off[1], label, color=c, fontsize=fs, ha="center", va="bottom")


def vertex(ax, x, y, c=INK, r=0.075):
    ax.add_patch(Circle((x, y), r, fc=c, ec=c, zorder=5))


def tadpole(ax, x, y, s=1.0, c=RED):
    """A loop sitting on top of a vertex at (x, y)."""
    ax.add_patch(Circle((x, y + 0.42 * s), 0.42 * s, fc="none", ec=c, lw=1.8))
    vertex(ax, x, y)


# --------------------------------------------- 1. the full propagator series
def propagator_series():
    fig, ax = plt.subplots(figsize=(9.2, 2.9))
    y = 0
    # full propagator as a thick line with a shaded blob
    line(ax, 0, y, 1.6, y, lw=4.2)
    ax.text(0.8, y + 0.28, "the full,\nreal propagator", ha="center", va="bottom", fontsize=9.5,
            color=GREY)
    ax.text(1.95, y, "=", fontsize=18, ha="center", va="center")
    # free line
    line(ax, 2.3, y, 3.6, y)
    ax.text(2.95, y - 0.45, "free", ha="center", fontsize=9.5, color=GREY)
    ax.text(3.95, y, "+", fontsize=18, ha="center", va="center")
    # one tadpole
    line(ax, 4.3, y, 5.9, y); tadpole(ax, 5.1, y, 0.8)
    ax.text(5.1, y - 0.45, "one loop", ha="center", fontsize=9.5, color=GREY)
    ax.text(6.25, y, "+", fontsize=18, ha="center", va="center")
    # two tadpoles in a row
    line(ax, 6.6, y, 8.9, y); tadpole(ax, 7.35, y, 0.7); tadpole(ax, 8.15, y, 0.7)
    ax.text(7.75, y - 0.45, "two loops in a row", ha="center", fontsize=9.5, color=GREY)
    ax.text(9.3, y, "+ ...", fontsize=16, ha="left", va="center")
    ax.set_xlim(-0.2, 10.2); ax.set_ylim(-0.8, 1.4)
    bare(ax); ax.set_aspect("equal")
    save(fig, "propagator_series.svg")


# --------------------------------------- 2. the tadpole, every label shown
def tadpole_detail():
    fig, ax = plt.subplots(figsize=(6.2, 3.9))
    line(ax, -2.2, 0, 0, 0); line(ax, 0, 0, 2.2, 0)
    arrow_on(ax, -2.2, 0, 0, 0, label=r"$p$", off=(0, -0.42))
    arrow_on(ax, 0, 0, 2.2, 0, label=r"$p$", off=(0, -0.42))
    ax.add_patch(Circle((0, 1.0), 1.0, fc="none", ec=RED, lw=2.0))
    ax.add_patch(FancyArrowPatch((0.05, 2.0), (-0.12, 2.0), arrowstyle="-|>",
                                 mutation_scale=14, color=RED, lw=0))
    ax.text(0, 2.12, r"loop momentum $k$: any value at all", color=RED, ha="center",
            fontsize=10.5)
    vertex(ax, 0, 0, r=0.1)
    ax.annotate(r"one vertex: coupling $\lambda_0/4!$", xy=(0.08, -0.05), xytext=(0.9, -0.95),
                fontsize=10.5, arrowprops=dict(arrowstyle="-|>", lw=1.0, color=INK,
                                               mutation_scale=10))
    ax.text(0, 1.0, r"$\dfrac{1}{k^2+m_0^2}$", color=RED, ha="center", va="center", fontsize=12)
    ax.text(-2.1, 0.35, "particle in", fontsize=9.5, color=GREY)
    ax.text(2.1, 0.35, "particle out", fontsize=9.5, color=GREY, ha="right")
    ax.set_xlim(-2.4, 2.4); ax.set_ylim(-1.25, 2.5)
    bare(ax)
    save(fig, "tadpole_detail.svg")


# ------------------------------------ 3. where the 1/2 comes from: counting
def tadpole_counting():
    fig, axes = plt.subplots(1, 3, figsize=(9.6, 3.2))
    legs = {1: (-0.9, 0.9), 2: (0.9, 0.9), 3: (-0.9, -0.9), 4: (0.9, -0.9)}

    ax = axes[0]
    for n, (x, y) in legs.items():
        line(ax, 0, 0, x, y)
        ax.text(1.18 * x, 1.18 * y, str(n), ha="center", va="center", fontsize=12, color=BLUE)
    vertex(ax, 0, 0, r=0.09)
    ax.set_title(r"the $\phi^4$ vertex has 4 legs", fontsize=10.5)
    ax.text(0, -1.55, r"coupling written as $\lambda_0/4!$", ha="center", fontsize=10)

    ax = axes[1]
    for n, (x, y) in legs.items():
        c = ORANGE if n in (1, 2) else GREY
        line(ax, 0, 0, x, y, c=c, lw=2.2 if n in (1, 2) else 1.4)
        ax.text(1.18 * x, 1.18 * y, str(n), ha="center", va="center", fontsize=12, color=c)
    vertex(ax, 0, 0, r=0.09)
    ax.set_title("pick a leg for the incoming line (4 ways)\nthen one for the outgoing (3 ways)",
                 fontsize=10)
    ax.text(0, -1.55, r"$4\times3 = 12$ choices", ha="center", fontsize=10.5, color=ORANGE)

    ax = axes[2]
    line(ax, -1.2, -0.6, 0, 0); line(ax, 0, 0, 1.2, -0.6)
    ax.add_patch(Circle((0, 0.55), 0.55, fc="none", ec=RED, lw=2.0))
    vertex(ax, 0, 0, r=0.09)
    ax.set_title("the last two legs have only one\nway to join each other: the loop",
                 fontsize=10)
    ax.text(0, -1.55, r"$\dfrac{12}{4!} = \dfrac{12}{24} = \dfrac{1}{2}$", ha="center",
            fontsize=12, color=RED)
    for a in axes:
        a.set_xlim(-1.6, 1.6); a.set_ylim(-1.9, 1.5); bare(a)
    fig.tight_layout()
    save(fig, "tadpole_counting.svg")


# ------------------------------- 4. coarse-graining as lowering resolution
def pixel_blocking():
    rng = np.random.default_rng(3)
    n = 16
    x, y = np.meshgrid(np.linspace(-1, 1, n), np.linspace(-1, 1, n))
    img = np.exp(-((x + 0.25)**2 + (y - 0.2)**2) * 3) + 0.6 * np.exp(-((x - 0.5)**2 + (y + 0.45)**2) * 6)
    img = img + 0.35 * rng.standard_normal((n, n))
    fig, axes = plt.subplots(1, 3, figsize=(8.4, 3.1))
    for k, ax in enumerate(axes):
        b = 2**k
        im = img.reshape(n // b, b, n // b, b).mean(axis=(1, 3))
        ax.imshow(im, cmap="Greys", interpolation="nearest", vmin=-0.3, vmax=1.2)
        ax.set_xticks([]); ax.set_yticks([])
        for s in ax.spines.values():
            s.set_edgecolor(GREY)
        ax.set_title(["the original: 16×16", "each 2×2 → one average: 8×8",
                      "again: 4×4"][k], fontsize=10)
    fig.tight_layout()
    save(fig, "pixel_blocking.svg")


# --------------------------------- 5. momentum conservation around a bubble
def bubble_momenta():
    fig, ax = plt.subplots(figsize=(6.4, 3.3))
    line(ax, -2.4, 0.7, -1.0, 0); line(ax, -2.4, -0.7, -1.0, 0)
    line(ax, 1.0, 0, 2.4, 0.7); line(ax, 1.0, 0, 2.4, -0.7)
    arrow_on(ax, -2.4, 0.7, -1.0, 0, label=r"$p_1$", off=(0, 0.1))
    arrow_on(ax, -2.4, -0.7, -1.0, 0, label=r"$p_2$", off=(0, -0.45))
    th = np.linspace(0, np.pi, 100)
    ax.plot(np.cos(th), 0.75 * np.sin(th), color=RED, lw=2)
    ax.plot(np.cos(th), -0.75 * np.sin(th), color=RED, lw=2)
    ax.add_patch(FancyArrowPatch((-0.1, 0.75), (0.12, 0.75), arrowstyle="-|>",
                                 mutation_scale=13, color=RED, lw=0))
    ax.add_patch(FancyArrowPatch((-0.1, -0.75), (0.12, -0.75), arrowstyle="-|>",
                                 mutation_scale=13, color=RED, lw=0))
    ax.text(0, 0.85, r"$k$", color=RED, ha="center", fontsize=12)
    ax.text(0, -1.18, r"$p_1+p_2-k$", color=RED, ha="center", fontsize=12)
    vertex(ax, -1.0, 0); vertex(ax, 1.0, 0)
    ax.text(0, 1.45, "at each dot, momentum in = momentum out.\n"
                     r"That fixes the bottom line, but $k$ itself is free.",
            ha="center", fontsize=10, color=GREY)
    ax.set_xlim(-2.6, 2.6); ax.set_ylim(-1.5, 2.1)
    bare(ax)
    save(fig, "bubble_momenta.svg")


if __name__ == "__main__":
    propagator_series(); tadpole_detail(); tadpole_counting()
    pixel_blocking(); bubble_momenta()


# ------------------------------- 6. what a Feynman parameter does, visually
def feynman_parameter():
    """1/(AB) is the area under 1/[xA+(1-x)B]^2 for x from 0 to 1. The blend
    runs from 1/B^2 at x=0 to 1/A^2 at x=1; the area is exactly 1/(AB)."""
    A, B = 1.0, 3.0
    x = np.linspace(0, 1, 400)
    f = 1 / (x * A + (1 - x) * B)**2
    area = np.trapezoid(f, x)
    fig, ax = plt.subplots(figsize=(5.6, 3.6))
    ax.fill_between(x, 0, f, color=BLUE, alpha=0.18)
    ax.plot(x, f, color=BLUE, lw=2.2)
    ax.axhline(1 / (A * B), color=RED, ls="--", lw=1.4)
    ax.text(0.03, 1 / (A * B) + 0.03, rf"height $1/AB = {1/(A*B):.3f}$", color=RED, fontsize=10)
    ax.text(0.52, 0.12, f"shaded area = {area:.3f}", color=BLUE, fontsize=11, ha="center")
    ax.plot([0], [1 / B**2], "o", color=INK, ms=6); ax.plot([1], [1 / A**2], "o", color=INK, ms=6)
    ax.annotate(r"$x=0$: only $B$", xy=(0, 1 / B**2), xytext=(0.08, 0.55), fontsize=10,
                arrowprops=dict(arrowstyle="-|>", lw=1, color=INK, mutation_scale=10))
    ax.annotate(r"$x=1$: only $A$", xy=(1, 1 / A**2), xytext=(0.55, 0.85), fontsize=10,
                arrowprops=dict(arrowstyle="-|>", lw=1, color=INK, mutation_scale=10))
    ax.set_xlabel(r"Feynman parameter $x$")
    ax.set_ylabel(r"$1/[xA+(1-x)B]^2$")
    ax.set_title(rf"$A={A:g},\ B={B:g}$: the blend's area is exactly $1/(AB)$", fontsize=11)
    ax.set_xlim(0, 1); ax.set_ylim(0, 1.08)
    fig.tight_layout()
    save(fig, "feynman_parameter.svg")
    print(f"   area = {area:.6f}, 1/(AB) = {1/(A*B):.6f}")


def ctcross(ax, x, y, r=0.16, c=RED):
    """A counterterm vertex: a circle with a cross, as in Ling-Fong Li's notes."""
    ax.add_patch(Circle((x, y), r, fc="white", ec=c, lw=1.8, zorder=6))
    d = r * 0.7
    ax.plot([x - d, x + d], [y - d, y + d], color=c, lw=1.6, zorder=7)
    ax.plot([x - d, x + d], [y + d, y - d], color=c, lw=1.6, zorder=7)


# ---------------------------- 7. counterterm vertices (the extra Feynman rules)
def counterterm_rules():
    fig, axes = plt.subplots(1, 2, figsize=(8.0, 2.6))
    ax = axes[0]
    line(ax, -1.2, 0, 1.2, 0); ctcross(ax, 0, 0)
    ax.text(0, -0.55, r"$-(\delta_Z\,p^2+\delta_m)$", ha="center", fontsize=12)
    ax.set_title("two-leg counterterm:\nfixes the mass and the field's size", fontsize=10)
    ax.set_xlim(-1.4, 1.4); ax.set_ylim(-0.95, 0.6); bare(ax)
    ax = axes[1]
    for sx, sy in [(-0.9, 0.7), (-0.9, -0.7), (0.9, 0.7), (0.9, -0.7)]:
        line(ax, sx, sy, 0, 0)
    ctcross(ax, 0, 0)
    ax.text(0, -1.05, r"$-\delta_\lambda$", ha="center", fontsize=12)
    ax.set_title("four-leg counterterm:\nfixes the coupling", fontsize=10)
    ax.set_xlim(-1.4, 1.4); ax.set_ylim(-1.35, 0.95); bare(ax)
    fig.tight_layout()
    save(fig, "counterterm_rules.svg")


# ------------------ 8. two bubbles in a row, and their counterterm partners
def two_loop_chain():
    fig, axes = plt.subplots(1, 3, figsize=(9.6, 2.6))

    def legs(ax, x0, x1):
        for sy in (0.55, -0.55):
            line(ax, x0 - 0.8, sy, x0, 0)
            line(ax, x1, 0, x1 + 0.8, sy)

    def bubble(ax, xa, xb):
        cx, r = (xa + xb) / 2, (xb - xa) / 2
        ax.add_patch(Arc((cx, 0), 2 * r, 1.1 * r, theta1=0, theta2=360, ec=BLUE, lw=1.8))

    ax = axes[0]
    legs(ax, -1.2, 1.2); bubble(ax, -1.2, 0); bubble(ax, 0, 1.2)
    for xv in (-1.2, 0, 1.2):
        vertex(ax, xv, 0)
    ax.text(0, -0.95, r"$\lambda^3\,\Gamma(p)^2$", ha="center", fontsize=12)
    ax.set_title("two bubbles in a row", fontsize=10)

    # replacing a bubble (a 4-point piece) by the 4-leg counterterm: the
    # crossed dot takes the place of that bubble's far vertex, so every
    # vertex keeps exactly four lines
    ax = axes[1]
    legs(ax, -0.6, 0.6); bubble(ax, -0.6, 0.6)
    vertex(ax, -0.6, 0); ctcross(ax, 0.6, 0)
    ax.text(0, -0.95, r"$-\lambda^3\,\Gamma(0)\,\Gamma(p)$", ha="center", fontsize=12)
    ax.set_title("right bubble replaced\nby its counterterm", fontsize=10)

    ax = axes[2]
    legs(ax, -0.6, 0.6); bubble(ax, -0.6, 0.6)
    ctcross(ax, -0.6, 0); vertex(ax, 0.6, 0)
    ax.text(0, -0.95, r"$-\lambda^3\,\Gamma(0)\,\Gamma(p)$", ha="center", fontsize=12)
    ax.set_title("left bubble replaced\nby its counterterm", fontsize=10)

    for a in axes:
        a.set_xlim(-2.2, 2.2); a.set_ylim(-1.25, 0.95); bare(a)
    fig.tight_layout()
    save(fig, "two_loop_chain.svg")


# ------------------------------------------- 9. a nested divergence, boxed
def nested_divergence():
    """A two-loop four-point diagram in phi^4 with a divergent bubble (V2-V3)
    sitting inside a divergent whole. Every vertex has exactly four lines."""
    fig, ax = plt.subplots(figsize=(5.2, 3.2))
    V1, V2, V3 = (-0.9, 0.0), (0.9, 0.8), (0.9, -0.8)
    line(ax, -2.0, 0.6, *V1); line(ax, -2.0, -0.6, *V1)          # two outside legs at V1
    line(ax, *V1, *V2); line(ax, *V1, *V3)                        # V1 to V2 and V3
    ax.add_patch(Arc((0.9, 0), 0.7, 1.6, theta1=-90, theta2=90, ec=RED, lw=1.8))
    ax.add_patch(Arc((0.9, 0), 0.7, 1.6, theta1=90, theta2=270, ec=RED, lw=1.8))
    line(ax, *V2, 2.1, 0.8); line(ax, *V3, 2.1, -0.8)            # one outside leg each
    for v in (V1, V2, V3):
        vertex(ax, *v)
    ax.add_patch(Rectangle((0.4, -1.05), 1.0, 2.1, fc="none", ec=RED, ls="--", lw=1.2))
    ax.add_patch(Rectangle((-1.3, -1.3), 3.0, 2.6, fc="none", ec=GREY, ls="--", lw=1.2))
    ax.text(1.45, -0.2, "inner\nbubble", color=RED, fontsize=9)
    ax.text(-1.28, 1.36, "the whole diagram", color=GREY, fontsize=9.5)
    ax.set_xlim(-2.2, 2.3); ax.set_ylim(-1.5, 1.65); bare(ax)
    save(fig, "nested_divergence.svg")
