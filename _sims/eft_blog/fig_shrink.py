"""The one picture the whole blog hangs on: a heavy particle exchanged between
light ones is, at low energy, a contact interaction plus a series of corrections
suppressed by powers of E/M.
"""
import numpy as np
import matplotlib.pyplot as plt
from common import *


def legs(ax, x0, y0, spread=0.52, length=0.60, left=True):
    s = -1 if left else 1
    for dy in (+spread, -spread):
        ax.plot([x0 + s * length, x0], [y0 + dy, y0], color=INK, lw=1.5,
                solid_capstyle="round")


def wiggle(ax, x1, x2, y, n=7, amp=0.11, color=RED):
    t = np.linspace(0, 1, 300)
    x = x1 + (x2 - x1) * t
    ax.plot(x, y + amp * np.sin(2 * np.pi * n * t), color=color, lw=1.8)


fig, axes = plt.subplots(1, 3, figsize=(11.4, 3.3))

# ---------------------------------------------------- 1. the full theory
ax = axes[0]; bare(ax)
legs(ax, -0.75, 0, left=True); legs(ax, 0.75, 0, left=False)
wiggle(ax, -0.75, 0.75, 0)
for x in (-0.75, 0.75):
    ax.plot([x], [0], "o", color=INK, ms=7)
ax.text(0, 0.46, r"heavy $\Phi$, mass $M$", ha="center", fontsize=10, color=RED)
ax.text(0, -0.92, r"$\dfrac{i}{q^2-M^2}$", ha="center", fontsize=12)
ax.set_xlim(-1.8, 1.8); ax.set_ylim(-1.45, 1.15)
ax.set_title("what really happens", fontsize=11)

# ------------------------------------------------- 2. the expansion itself
ax = axes[1]; bare(ax)
ax.text(0, 0.30, r"$\dfrac{1}{q^2-M^2}=-\dfrac{1}{M^2}\left(1+\dfrac{q^2}{M^2}"
                 r"+\dfrac{q^4}{M^4}+\cdots\right)$",
        ha="center", va="center", fontsize=12.5)
ax.text(0, -0.55, "only useful because $q^2 \\ll M^2$", ha="center",
        fontsize=10, color=GREY)
ax.set_xlim(-1.8, 1.8); ax.set_ylim(-1.45, 1.15)
ax.set_title("expand it, since you never had the energy", fontsize=11)

# ------------------------------------------------ 3. the effective theory
ax = axes[2]; bare(ax)
legs(ax, 0, 0, left=True); legs(ax, 0, 0, left=False)
ax.plot([0], [0], "o", color=BLUE, ms=11)
ax.text(0, 0.72, "one contact vertex", ha="center", fontsize=10, color=BLUE)
ax.text(0, -0.92, r"$\dfrac{g^2}{8M^2}\,\phi^4\;+\;$corrections",
        ha="center", fontsize=12)
ax.set_xlim(-1.8, 1.8); ax.set_ylim(-1.45, 1.15)
ax.set_title("what you can actually measure", fontsize=11)

fig.tight_layout()
save(fig, "eft_shrink.svg")
