"""Part 6: the functional-RG (LPA) answer in d = 3, as the truncation grows.

Numbers come from lpa_hp.py (mpmath, 40 digits).  They are hard-coded here so
the figure can be redrawn without re-running the solve.
"""
import numpy as np
import matplotlib.pyplot as plt
from common import *

M = np.arange(2, 14)
nu = np.array([0.500000, 0.728992, 0.650574, 0.644691, 0.649847, 0.650031,
               0.649481, 0.649519, 0.649576, 0.649565, 0.649560, 0.649561])
om = np.array([0.333333, 1.074990, 0.598864, 0.644426, 0.661194, 0.656254,
               0.655182, 0.655797, 0.655796, 0.655720, 0.655744, 0.655754])

fig, axes = plt.subplots(1, 2, figsize=(10.4, 3.8))

ax = axes[0]
ax.axhline(0.5, color=GREY, lw=1.0, ls=":")
ax.axhline(0.583, color=ORANGE, lw=1.2, ls="--")
ax.axhline(0.6300, color=GREEN, lw=1.4)
ax.axhline(0.649562, color=BLUE, lw=1.0, ls="-.")
ax.plot(M, nu, "o-", color=BLUE, ms=5, lw=1.3, zorder=5)
ax.set_xlabel("$M$, number of couplings kept")
ax.set_ylabel(r"$\nu$")
ax.set_ylim(0.47, 0.76)
ax.set_xticks(M[::2])
for y, t, c, dy in ((0.5, "mean field", GREY, 0.008),
                    (0.583, r"one loop at $\epsilon=1$: 0.583", ORANGE, 0.008),
                    (0.6300, "true 3D Ising: 0.6300", GREEN, -0.021),
                    (0.649562, "LPA limit: 0.6496", BLUE, 0.008)):
    ax.text(5.6, y + dy, t, fontsize=8.6, color=c, va="bottom", ha="left")
ax.set_title(r"(a) $\nu$ in $d=3$, no $\epsilon$ expansion", fontsize=11)

ax = axes[1]
ax.axhline(0.655746, color=BLUE, lw=1.0, ls="-.")
ax.plot(M, om, "s-", color=PURPLE, ms=4.5, lw=1.3)
ax.set_xlabel("$M$, number of couplings kept")
ax.set_ylabel(r"$\omega$")
ax.set_xticks(M[::2])
ax.set_ylim(0.25, 1.15)
ax.text(5.6, 0.655746 - 0.075, "LPA limit: 0.6557", fontsize=8.6,
        color=BLUE, ha="left")
ax.set_title(r"(b) the correction-to-scaling exponent $\omega$", fontsize=11)

for ax in axes:
    for s in ("top", "right"):
        ax.spines[s].set_visible(False)
    ax.tick_params(labelsize=9)

fig.tight_layout()
save(fig, "lpa_convergence.svg")
