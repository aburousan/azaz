"""The two Ising figures, redrawn from equilibrated samples (ising_equil.npz,
made on hercules by gen_ising_equil.py). Each panel carries the measured
nearest-neighbour agreement, averaged over 16 independent samples, so the
flow can be read as a number and not only by eye."""
import numpy as np
import matplotlib.pyplot as plt
from common import *
from ising2d import block

D = np.load("ising_equil.npz")
# For the two critical panels, show a sample with a small net magnetisation so
# that both colours are visible. Only the picture is picked this way; every
# number printed in the figures comes from the unbiased set of 16 samples.
try:
    B = np.load("ising_crit_balanced.npz")
    CRIT_PIC = B["snapshot"].astype(int)
    print(f"balanced critical snapshot: |m| = {float(B['m']):.3f}, agreement {float(B['agree']):.4f}")
except FileNotFoundError:
    CRIT_PIC = None
CMAP = mpl.colors.ListedColormap(["#f4f4f4", "#1c1c1c"])


def panel(ax, s):
    ax.imshow((s > 0).astype(float), cmap=CMAP, interpolation="nearest")
    ax.set_xticks([]); ax.set_yticks([])
    for sp in ax.spines.values():
        sp.set_edgecolor(GREY); sp.set_linewidth(0.8)


def self_similar():
    rows = [("hot93", r"$T>T_c$", "flows to noise\n(the hot fixed point)", GREEN),
            ("crit", r"$T=T_c$", "stays the same\n(the critical fixed point)", RED),
            ("cold107", r"$T<T_c$", "flows to one colour\n(the cold fixed point)", ORANGE)]
    fig, axes = plt.subplots(3, 4, figsize=(10.2, 8.2))
    heads = ["original: 256×256\n1 pixel = 1 spin", "blocked once: 128×128\n1 pixel = 4 spins",
             "blocked twice: 64×64\n1 pixel = 16 spins", "blocked 3 times: 32×32\n1 pixel = 64 spins"]
    for r, (tag, lab, fate, col) in enumerate(rows):
        s = D[f"{tag}_snapshot"].astype(int)
        if tag == "crit" and CRIT_PIC is not None:
            s = CRIT_PIC.copy()
        m, e = D[f"{tag}_agree_mean"], D[f"{tag}_agree_err"]
        for c in range(4):
            ax = axes[r, c]
            panel(ax, s)
            ax.set_xlabel(f"agreement {m[c]:.2f}", fontsize=9.5, color=col, labelpad=3)
            if r == 0:
                ax.set_title(heads[c], fontsize=9.5, pad=6)
            if c == 0:
                ax.set_ylabel(lab, fontsize=13, labelpad=8)
            if c < 3:
                s = block(s, 2)
        axes[r, 3].text(1.06, 0.5, fate, transform=axes[r, 3].transAxes, fontsize=10,
                        color=col, va="center", ha="left")
    fig.text(0.5, 0.005, "coarse-graining (zooming out) →", ha="center", fontsize=11.5,
             color=INK, style="italic")
    fig.tight_layout(rect=(0, 0.02, 0.86, 1))
    save(fig, "self_similar.svg")


def snapshots():
    fig, axes = plt.subplots(1, 3, figsize=(10.2, 3.9))
    for ax, (tag, lab) in zip(axes, [("hot90", r"$T > T_c$   (hot)"), ("crit", r"$T = T_c$   (critical)"),
                                     ("cold110", r"$T < T_c$   (cold)")]):
        pic = CRIT_PIC if (tag == "crit" and CRIT_PIC is not None) else D[f"{tag}_snapshot"]
        panel(ax, pic)
        ax.set_title(lab, fontsize=11)
        ax.set_xlabel(f"neighbour agreement {D[f'{tag}_agree_mean'][0]:.3f}", fontsize=9.5)
    fig.tight_layout()
    save(fig, "ising_snapshots.svg")


if __name__ == "__main__":
    for tag in ["hot93", "crit", "cold107", "hot90", "cold110"]:
        print(tag, np.round(D[f"{tag}_agree_mean"], 4), "+-", np.round(D[f"{tag}_agree_err"], 4))
    self_similar(); snapshots()
