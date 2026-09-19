"""Part 4: the 2D Ising exponents, measured rather than approximated.

(a) the Binder cumulant crossing that locates K_c,
(b) the slope of those curves against L, whose exponent is 1/nu,
(c) the susceptibility at K_c against L, whose exponent is gamma/nu.
"""
import numpy as np
import matplotlib.pyplot as plt
from common import *
from scipy.interpolate import PchipInterpolator
from fss_analysis import load, analyse, with_errors, KC_EXACT

data = load()
data = {L: d for L, d in data.items() if len(d) == 13}   # complete grids only
common = sorted(set.intersection(*[set(d) for d in data.values()]))
data = {L: {K: d[K] for K in common} for L, d in data.items()}
base, err = with_errors(data)
Ls = base["Ls"]
Kg = base["Kg"]
cols = plt.cm.viridis(np.linspace(0.08, 0.86, len(Ls)))

fig, axes = plt.subplots(1, 3, figsize=(11.6, 3.7))

# ---------------------------------------------------------------- (a) Binder
ax = axes[0]
fine = np.linspace(Kg[0], Kg[-1], 300)
for c, L in zip(cols, Ls):
    ax.plot(Kg, base["Us"][L], "o", ms=3, color=c)
    ax.plot(fine, PchipInterpolator(Kg, base["Us"][L])(fine),
            color=c, lw=1.2, label=f"$L={L}$")
ax.axvline(KC_EXACT, color=RED, lw=1.0, ls="--")
ax.text(KC_EXACT - 0.0055, 0.30, "exact $K_c$", color=RED, fontsize=8.5, rotation=90)
ax.set_xlabel("$K$"); ax.set_ylabel("Binder cumulant $U$")
ax.set_title("(a) the curves cross at $K_c$", fontsize=10.5)
ax.legend(fontsize=7.2, frameon=False, ncol=2, loc="lower right")

# ------------------------------------------------------------------- (b) nu
ax = axes[1]
ax.loglog(Ls, base["slope"], "o", color=BLUE, ms=5)
fit = np.polyfit(np.log(Ls), np.log(base["slope"]), 1)
xs = np.array([Ls[0] * 0.85, Ls[-1] * 1.18])
ax.loglog(xs, np.exp(np.polyval(fit, np.log(xs))), color=BLUE, lw=1.2,
          label=rf"fit: $1/\nu={fit[0]:.3f}$")
ref = base["slope"][0] * (xs / Ls[0]) ** 1.0
ax.loglog(xs, ref, color=GREEN, lw=1.2, ls="--", label=r"exact: $1/\nu=1$")
ax.set_xlabel("$L$"); ax.set_ylabel(r"$|\mathrm{d}U/\mathrm{d}K|$ at $K_c$")
ax.set_xticks(Ls); ax.set_xticklabels([str(int(v)) for v in Ls])
ax.xaxis.set_minor_formatter(plt.NullFormatter())
ax.set_title(r"(b) the slope gives $\nu$", fontsize=10.5)
ax.legend(fontsize=8, frameon=False, loc="upper left")

# ------------------------------------------------------------ (c) gamma/nu
ax = axes[2]
ax.loglog(Ls, base["chi_c"], "s", color=PURPLE, ms=5)
fit2 = np.polyfit(np.log(Ls), np.log(base["chi_c"]), 1)
ax.loglog(xs, np.exp(np.polyval(fit2, np.log(xs))), color=PURPLE, lw=1.2,
          label=rf"fit: $\gamma/\nu={fit2[0]:.3f}$")
ref2 = base["chi_c"][0] * (xs / Ls[0]) ** 1.75
ax.loglog(xs, ref2, color=GREEN, lw=1.2, ls="--", label=r"exact: $7/4$")
ax.set_xlabel("$L$"); ax.set_ylabel(r"$\chi$ at $K_c$")
ax.set_xticks(Ls); ax.set_xticklabels([str(int(v)) for v in Ls])
ax.xaxis.set_minor_formatter(plt.NullFormatter())
ax.set_title(r"(c) and the susceptibility gives $\gamma$", fontsize=10.5)
ax.legend(fontsize=8, frameon=False, loc="upper left")

for ax in axes:
    for s in ("top", "right"):
        ax.spines[s].set_visible(False)
    ax.tick_params(labelsize=8.5)

fig.tight_layout()
save(fig, "ising_fss.svg")

print(f"K_c   = {base['Kc']:.5f} +- {err['Kc']:.5f}   exact {KC_EXACT:.5f}")
print(f"nu    = {base['nu']:.4f} +- {err['nu']:.4f}   exact 1")
print(f"g/nu  = {base['g_nu']:.4f} +- {err['g_nu']:.4f}   exact 1.75")
print(f"b/nu  = {base['b_nu']:.4f} +- {err['b_nu']:.4f}   exact 0.125")
print(f"U*    = {base['Ustar']:.4f} +- {err['Ustar']:.4f}   known 0.6106")
