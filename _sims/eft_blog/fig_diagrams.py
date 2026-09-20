"""Feynman diagrams for the EFT blog: the three channels, Compton off a charged
scalar, and W exchange collapsing to Fermi's contact interaction.
"""
import numpy as np
import matplotlib.pyplot as plt
from common import *


def line(ax, a, b, color=INK, lw=1.6, arrow=False):
    ax.plot([a[0], b[0]], [a[1], b[1]], color=color, lw=lw, solid_capstyle="round", zorder=2)
    if arrow:
        mx, my = (a[0]+b[0])/2, (a[1]+b[1])/2
        dx, dy = b[0]-a[0], b[1]-a[1]
        n = np.hypot(dx, dy)
        ax.annotate("", xy=(mx+dx/n*0.12, my+dy/n*0.12), xytext=(mx, my),
                    arrowprops=dict(arrowstyle="-|>", color=color, lw=lw, mutation_scale=10))


def wiggle(ax, a, b, n=6, amp=0.10, color=RED, lw=1.7):
    t = np.linspace(0, 1, 300)
    x = a[0] + (b[0]-a[0])*t
    y = a[1] + (b[1]-a[1])*t
    dx, dy = b[0]-a[0], b[1]-a[1]
    L = np.hypot(dx, dy)
    px, py = -dy/L, dx/L                      # unit normal
    off = amp*np.sin(2*np.pi*n*t)
    ax.plot(x + px*off, y + py*off, color=color, lw=lw, zorder=2)


def dot(ax, xy, color=INK, ms=6):
    ax.plot([xy[0]], [xy[1]], "o", color=color, ms=ms, zorder=4)


def label(ax, xy, txt, dx=0, dy=0, fs=10, color=INK):
    ax.text(xy[0]+dx, xy[1]+dy, txt, fontsize=fs, color=color,
            ha="center", va="center", zorder=5)


# ===================================================== 1. the three channels
def channels():
    fig, axes = plt.subplots(1, 3, figsize=(11.6, 3.6))

    # ---- s channel: 1,2 merge on the left; 3,4 emerge on the right
    ax = axes[0]; bare(ax)
    L, R = (-0.55, 0), (0.55, 0)
    line(ax, (-1.35, 0.75), L); line(ax, (-1.35, -0.75), L)
    line(ax, R, (1.35, 0.75)); line(ax, R, (1.35, -0.75))
    wiggle(ax, L, R, n=5)
    dot(ax, L); dot(ax, R)
    label(ax, (-1.45, 0.75), "$1$"); label(ax, (-1.45, -0.75), "$2$")
    label(ax, (1.45, 0.75), "$3$"); label(ax, (1.45, -0.75), "$4$")
    label(ax, (0, 0.30), r"$q = p_1+p_2$", fs=9.5, color=RED)
    ax.set_title(r"$s$ channel: $(12)(34)$", fontsize=11)
    ax.text(0, -1.35, r"$s=(p_1+p_2)^2$", ha="center", fontsize=10.5)

    # ---- t channel: 1 -> 3 on top, 2 -> 4 below, heavy line vertical
    ax = axes[1]; bare(ax)
    T, B = (0, 0.5), (0, -0.5)
    line(ax, (-1.2, 1.15), T); line(ax, T, (1.2, 1.15))
    line(ax, (-1.2, -1.15), B); line(ax, B, (1.2, -1.15))
    wiggle(ax, B, T, n=4)
    dot(ax, T); dot(ax, B)
    label(ax, (-1.32, 1.15), "$1$"); label(ax, (1.32, 1.15), "$3$")
    label(ax, (-1.32, -1.15), "$2$"); label(ax, (1.32, -1.15), "$4$")
    label(ax, (0.62, 0), r"$q = p_1-p_3$", fs=9.5, color=RED)
    ax.set_title(r"$t$ channel: $(13)(24)$", fontsize=11)
    ax.text(0, -1.75, r"$t=(p_1-p_3)^2$", ha="center", fontsize=10.5)

    # ---- u channel: same, outgoing legs swapped so the lines cross
    ax = axes[2]; bare(ax)
    T, B = (0, 0.5), (0, -0.5)
    line(ax, (-1.2, 1.15), T); line(ax, T, (1.2, -1.15))
    line(ax, (-1.2, -1.15), B); line(ax, B, (1.2, 1.15))
    wiggle(ax, B, T, n=4)
    dot(ax, T); dot(ax, B)
    label(ax, (-1.32, 1.15), "$1$"); label(ax, (1.32, -1.15), "$4$")
    label(ax, (-1.32, -1.15), "$2$"); label(ax, (1.32, 1.15), "$3$")
    label(ax, (-0.74, 0), r"$q = p_1-p_4$", fs=9.5, color=RED)
    ax.set_title(r"$u$ channel: $(14)(23)$", fontsize=11)
    ax.text(0, -1.75, r"$u=(p_1-p_4)^2$", ha="center", fontsize=10.5)

    for ax in axes:
        ax.set_xlim(-1.9, 1.9); ax.set_ylim(-2.0, 1.75)
    fig.tight_layout()
    save(fig, "eft_channels.svg")


def strike(ax, cx=0.0, cy=0.05, w=1.0, h=0.82):
    """A grey X over a diagram that vanishes."""
    ax.plot([cx-w, cx+w], [cy+h, cy-h], color=GREY, lw=2.2, alpha=0.45, zorder=6)
    ax.plot([cx-w, cx+w], [cy-h, cy+h], color=GREY, lw=2.2, alpha=0.45, zorder=6)


# ============================================ 2. Compton off a charged scalar
def compton():
    fig, axes = plt.subplots(1, 3, figsize=(11.6, 3.5))

    def scalar_in_out(ax, v1, v2):
        line(ax, (-1.5, -0.7), v1, arrow=True)
        line(ax, v1, v2, arrow=True)
        line(ax, v2, (1.5, -0.7), arrow=True)

    # (a) absorb then emit
    ax = axes[0]; bare(ax)
    v1, v2 = (-0.5, -0.7), (0.5, -0.7)
    scalar_in_out(ax, v1, v2)
    wiggle(ax, (-0.95, 0.95), v1, n=4)
    wiggle(ax, v2, (0.95, 0.95), n=4)
    dot(ax, v1); dot(ax, v2)
    label(ax, (-1.15, 1.05), r"$k$", color=RED); label(ax, (1.15, 1.05), r"$k'$", color=RED)
    strike(ax)
    ax.set_title("(a) absorb, then emit", fontsize=10.5)
    ax.text(0, 1.55, r"$(2p+k)\cdot\varepsilon = 0$", ha="center", fontsize=10, color=GREY)

    # (b) emit then absorb
    ax = axes[1]; bare(ax)
    scalar_in_out(ax, v1, v2)
    wiggle(ax, v1, (-0.95, 0.95), n=4)
    wiggle(ax, (0.95, 0.95), v2, n=4)
    dot(ax, v1); dot(ax, v2)
    label(ax, (-1.15, 1.05), r"$k'$", color=RED); label(ax, (1.15, 1.05), r"$k$", color=RED)
    strike(ax)
    ax.set_title("(b) emit, then absorb", fontsize=10.5)
    ax.text(0, 1.55, r"$(2p-k')\cdot\varepsilon' = 0$", ha="center", fontsize=10, color=GREY)

    # (c) the seagull
    ax = axes[2]; bare(ax)
    v = (0, -0.7)
    line(ax, (-1.5, -0.7), v, arrow=True); line(ax, v, (1.5, -0.7), arrow=True)
    wiggle(ax, (-0.95, 0.95), v, n=4); wiggle(ax, v, (0.95, 0.95), n=4)
    dot(ax, v, color=BLUE, ms=9)
    label(ax, (-1.15, 1.05), r"$k$", color=RED); label(ax, (1.15, 1.05), r"$k'$", color=RED)
    ax.set_title("(c) the seagull", fontsize=10.5)
    ax.text(0, 1.55, r"$2ie^2 g^{\mu\nu}$  survives", ha="center", fontsize=10, color=BLUE)

    for ax in axes:
        ax.set_xlim(-1.85, 1.85); ax.set_ylim(-1.75, 1.95)
    fig.tight_layout()
    save(fig, "eft_compton.svg")


# ================================= 3. W exchange collapsing to Fermi's vertex
def fermi():
    fig, axes = plt.subplots(1, 2, figsize=(9.6, 3.5))

    ax = axes[0]; bare(ax)
    T, B = (0, 0.45), (0, -0.45)
    line(ax, (-1.25, 1.1), T, arrow=True); line(ax, T, (1.25, 1.1), arrow=True)
    line(ax, B, (-1.25, -1.1), arrow=True); line(ax, B, (1.25, -1.1), arrow=True)
    wiggle(ax, B, T, n=4)
    dot(ax, T); dot(ax, B)
    label(ax, (-1.42, 1.1), "$d$"); label(ax, (1.42, 1.1), "$u$")
    label(ax, (-1.45, -1.1), r"$\bar\nu_e$"); label(ax, (1.42, -1.1), "$e^-$")
    label(ax, (0.42, 0), "$W$", fs=10.5, color=RED)
    ax.set_title("what happens", fontsize=11)
    ax.text(0, -1.7, r"$\dfrac{1}{q^2-m_W^2}$", ha="center", fontsize=11)

    ax = axes[1]; bare(ax)
    v = (0, 0)
    for end in ((-1.25, 1.1), (1.25, 1.1), (-1.25, -1.1), (1.25, -1.1)):
        line(ax, v, end)
    dot(ax, v, color=BLUE, ms=10)
    label(ax, (-1.42, 1.1), "$d$"); label(ax, (1.42, 1.1), "$u$")
    label(ax, (-1.45, -1.1), r"$\bar\nu_e$"); label(ax, (1.42, -1.1), "$e^-$")
    ax.set_title(r"what you can see, at $q^2\ll m_W^2$", fontsize=11)
    ax.text(0, -1.7, r"$-\dfrac{G_F}{\sqrt{2}}$", ha="center", fontsize=11, color=BLUE)

    for ax in axes:
        ax.set_xlim(-1.9, 1.9); ax.set_ylim(-2.0, 1.7)
    fig.tight_layout()
    save(fig, "eft_fermi.svg")


if __name__ == "__main__":
    channels(); compton(); fermi()
