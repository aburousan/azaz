"""Part 7: why the sign of the QCD beta function is what it is.

Panel (a) is ordinary QED screening: the induced dipoles turn their negative
end towards the charge, so the cloud hides it.  Panel (b) is the non-Abelian
case worked out pictorially in Peskin section 16.7: the induced dipole points
*towards* the source, so the cloud amplifies it.  Panel (c) is the arithmetic
of the one-loop coefficient, with the gluon split into the piece that behaves
like QED and the piece that does not.
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, FancyArrowPatch
from common import *


def dipole(ax, x, y, ang, inward_sign, L=0.70):
    """A small +/- pair at (x,y); inward_sign=-1 puts the minus end inward."""
    ux, uy = np.cos(ang), np.sin(ang)
    # the "inner" end sits closer to the origin
    xi, yi = x - ux * L / 2, y - uy * L / 2
    xo, yo = x + ux * L / 2, y + uy * L / 2
    ax.plot([xi, xo], [yi, yo], color=GREY, lw=1.0, zorder=1)
    inner, outer = ("$-$", "$+$") if inward_sign < 0 else ("$+$", "$-$")
    ci = BLUE if inner == "$-$" else RED
    co = RED if outer == "$+$" else BLUE
    for (px, py), txt, c in (((xi, yi), inner, ci), ((xo, yo), outer, co)):
        ax.add_patch(Circle((px, py), 0.19, fc="white", ec=c, lw=1.2, zorder=2))
        ax.text(px, py, txt, ha="center", va="center", fontsize=10.5,
                color=c, zorder=3)


def cloud(ax, sign, title, sub):
    bare(ax)
    ax.add_patch(Circle((0, 0), 0.30, fc=RED, ec="none", alpha=0.85, zorder=4))
    ax.text(0, 0, "$+$", ha="center", va="center", color="white",
            fontsize=13, zorder=5)
    for k in range(6):
        a = 2 * np.pi * k / 6 + np.pi / 6
        dipole(ax, 1.30 * np.cos(a), 1.30 * np.sin(a), a, sign)
    ax.set_xlim(-2.35, 2.35); ax.set_ylim(-2.95, 2.55)
    ax.text(0, 2.30, title, ha="center", va="center", fontsize=11.5)
    ax.text(0, -2.55, sub, ha="center", va="center", fontsize=9.0, color=GREY,
            linespacing=1.45)


fig = plt.figure(figsize=(11.0, 3.9))
gs = fig.add_gridspec(1, 3, width_ratios=[1, 1, 1.15], wspace=0.34)

a = fig.add_subplot(gs[0, 0])
cloud(a, -1, "(a) QED: screening",
      "minus ends inward: the cloud hides it\nso the charge looks weaker from far away")

b = fig.add_subplot(gs[0, 1])
cloud(b, +1, "(b) QCD: antiscreening",
      "plus ends inward: the cloud adds to it\nso the charge looks stronger from far away")

# ------------------------------------------------- (c) the coefficient
c = fig.add_subplot(gs[0, 2])
labels = ["gluons\n(magnetic)", "gluons\n(electric)", "quarks\n($n_f=6$)", "total"]
vals = [12 / 3 * 3, -1 / 3 * 3, -2 / 3 * 6, 11 - 2 / 3 * 6]
cols = [GREEN, RED, RED, BLUE]
xs = np.arange(4)
c.bar(xs, vals, color=cols, width=0.62, alpha=0.9)
for x, v in zip(xs, vals):
    c.text(x, v + (0.45 if v > 0 else -0.75), f"{v:+.2f}".rstrip("0").rstrip("."),
           ha="center", fontsize=9.5)
c.axhline(0, color=INK, lw=1.0)
c.set_xticks(xs); c.set_xticklabels(labels, fontsize=8.6)
c.set_ylabel(r"contribution to $b_0$", fontsize=9.5)
c.set_ylim(-6.5, 14.5)
c.set_title(r"(c) $b_0=\frac{11}{3}N-\frac{2}{3} n_f$ , with $N=3$", fontsize=10.5, pad=8)
c.tick_params(labelsize=9)
for s in ("top", "right"):
    c.spines[s].set_visible(False)

save(fig, "qcd_screening.svg")
