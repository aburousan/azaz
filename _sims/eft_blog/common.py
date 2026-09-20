"""Shared setup for the effective-field-theory blog figures.

Everything is drawn black-on-transparent so the site's dark mode can invert the
line art (see `html.dark-mode img.math-diagram` in _css/dark-mode.css) without
leaving a white plate behind the plot. Colours survive that filter because it
also rotates the hue by 180 degrees.
"""
import os
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np

ASSETS = os.path.join(os.path.dirname(__file__), "..", "..",
                      "_assets", "Physics", "blogs", "eft")
os.makedirs(ASSETS, exist_ok=True)

mpl.rcParams.update({
    "svg.fonttype": "path",        # no font dependency on the reader's machine
    "figure.facecolor": "none",
    "axes.facecolor": "none",
    "savefig.facecolor": "none",
    "savefig.transparent": True,
    "font.family": "serif",
    "font.serif": ["DejaVu Serif"],
    "mathtext.fontset": "dejavuserif",
    "axes.edgecolor": "#1c1c1c",
    "axes.labelcolor": "#1c1c1c",
    "text.color": "#1c1c1c",
    "xtick.color": "#1c1c1c",
    "ytick.color": "#1c1c1c",
    "axes.linewidth": 1.1,
    "font.size": 11,
})

# A palette that stays legible after invert + hue-rotate.
BLUE   = "#1f4e9c"
RED    = "#c0392b"
GREEN  = "#1e8449"
ORANGE = "#d35400"
PURPLE = "#6c3483"
TEAL   = "#117a8b"
GREY   = "#7a7a7a"
INK    = "#1c1c1c"


# Set RG_PREVIEW to a directory to also drop opaque PNGs there, for eyeballing
# the figures without opening each SVG.
PREVIEW = os.environ.get("RG_PREVIEW")


def save(fig, name):
    path = os.path.join(ASSETS, name)
    fig.savefig(path, bbox_inches="tight", pad_inches=0.05, transparent=True)
    if PREVIEW:
        os.makedirs(PREVIEW, exist_ok=True)
        fig.savefig(os.path.join(PREVIEW, name.replace(".svg", ".png")),
                    bbox_inches="tight", pad_inches=0.05, dpi=110,
                    facecolor="white", transparent=False)
    plt.close(fig)
    print("wrote", os.path.relpath(path))


def bare(ax):
    """Strip an axes down to a bare drawing canvas."""
    ax.set_xticks([]); ax.set_yticks([])
    for s in ax.spines.values():
        s.set_visible(False)
    ax.set_aspect("equal")


def spin_arrow(ax, x, y, up, color=INK, L=0.34, lw=1.6, alpha=1.0):
    """One Ising spin drawn as a short arrow."""
    d = L if up else -L
    ax.annotate("", xy=(x, y + d / 2), xytext=(x, y - d / 2),
                arrowprops=dict(arrowstyle="-|>", lw=lw, color=color,
                                alpha=alpha, mutation_scale=11))
