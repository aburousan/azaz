"""How good the expansion is, and exactly where it dies.

Plots the true heavy propagator against the first few terms of its low-energy
expansion, as a function of the energy you probe at.  This is the whole content
of "the expansion parameter is E/M": each extra term buys you accuracy only
while E stays well below M, and nothing saves you once E reaches M.
"""
import numpy as np
import matplotlib.pyplot as plt
from common import *

r = np.linspace(0.001, 1.25, 600)          # r = E/M, so q^2/M^2 = r^2
exact = 1.0 / (1.0 - r**2)                 # -M^2/(q^2-M^2) with q^2 = E^2

fig, axes = plt.subplots(1, 2, figsize=(10.6, 3.9))

ax = axes[0]
ax.plot(r, exact, color=INK, lw=2.2, label="the true propagator")
for n, col in ((0, BLUE), (1, GREEN), (2, ORANGE)):
    approx = sum(r**(2 * k) for k in range(n + 1))
    ax.plot(r, approx, color=col, lw=1.5, ls="--",
            label=f"keeping {n+1} term" + ("s" if n else ""))
ax.axvline(1.0, color=RED, lw=1.2, ls=":")
ax.text(1.02, 5.2, "$E=M$\nthe heavy particle\nis real now", color=RED, fontsize=8.5)
ax.set_xlabel("$E/M$, the energy you probe at")
ax.set_ylabel("size of the interaction")
ax.set_ylim(0, 8); ax.set_xlim(0, 1.25)
ax.legend(frameon=False, fontsize=8.5, loc="upper left")
ax.set_title("(a) the expansion, term by term", fontsize=11)

ax = axes[1]
for n, col in ((0, BLUE), (1, GREEN), (2, ORANGE)):
    approx = sum(r**(2 * k) for k in range(n + 1))
    ax.loglog(r, np.abs(approx / exact - 1) * 100 + 1e-12, color=col, lw=1.6,
              label=f"keeping {n+1} term" + ("s" if n else ""))
ax.axhline(1.0, color=GREY, lw=1.0, ls=":")
ax.text(0.0125, 1.25, "1% error", color=GREY, fontsize=8.5)
ax.set_xlabel("$E/M$")
ax.set_ylabel("error (%)")
ax.set_xlim(0.01, 1.0); ax.set_ylim(1e-6, 500)
ax.legend(frameon=False, fontsize=8.5, loc="upper left")
ax.set_title("(b) how wrong you are, on a log scale", fontsize=11)

for a in axes:
    for sp in ("top", "right"):
        a.spines[sp].set_visible(False)
    a.tick_params(labelsize=9)

fig.tight_layout()
save(fig, "eft_accuracy.svg")

# the numbers quoted in the text
for E in (0.01, 0.1, 0.3):
    ex = 1 / (1 - E**2)
    print(f"E/M={E}:  1 term {abs(1/ex-1)*100:8.4f}%   2 terms {abs((1+E**2)/ex-1)*100:8.4f}%"
          f"   3 terms {abs((1+E**2+E**4)/ex-1)*100:10.6f}%")
