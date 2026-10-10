# Plots for the feynsage tutorial. Everything here is computed by feynsage itself.
import sys, os
sys.path.insert(0, os.path.expanduser("~/Coding/sage/feynsage"))
from feynsage import *
from feynsage.plotting import curves, draw_graph
from sage.all import var, CC, fast_callable, SR

OUT = os.path.expanduser("~/Coding/julia/azaz/_assets/Physics/blogs/feynsage")
os.makedirs(OUT, exist_ok=True)
PREVIEW = os.environ.get("FS_PREVIEW")          # set it to also drop opaque PNGs for eyeballing
if PREVIEW:
    os.makedirs(PREVIEW, exist_ok=True)

def save(fig, name):
    fig.savefig(os.path.join(OUT, name), transparent=True)
    if PREVIEW:
        fig.savefig(os.path.join(PREVIEW, name.replace(".svg", ".png")), dpi=130, facecolor="white")
    print("wrote", name)

# ---------------------------------------------------------------- 1. the bubble
# B0(s, m, m) with m = 1: real part, and the imaginary part that switches on at s = 4 m^2.
s = var('s')
# finite_part(expr, mu_value): the second argument is the VALUE of mu, not an order.
Bfin = finite_part(B0(s, 1, 1), 1)          # = DiscB(s,1,1) + 2
from sage.all import pi as PI, sqrt as SQRT, RR

def val(x, part):
    try:
        z = CC(Bfin.subs({s: x}))
    except Exception:
        return float('nan')
    return float(z.real()) if part == 're' else float(z.imag())

def im_exact(x):
    return float(RR(PI*SQRT(1 - 4/x))) if x > 4 else 0.0

fig = curves([lambda x: val(x, 're'), lambda x: val(x, 'im'), im_exact], (-4, 16),
             labels=[r'$\mathrm{Re}\,B_0$', r'$\mathrm{Im}\,B_0$',
                     r'$\pi\sqrt{1-4m^2/s}$'],
             xlabel=r'$s/m^2$', title=r'$B_0(s;m,m)$, finite part, $m=\mu=1$',
             figsize=(5.2, 3.1))
ax = fig.axes[0]
ax.lines[2].set_linestyle('--'); ax.lines[2].set_linewidth(1.1)
ax.axvline(4, color='0.45', lw=1.0, ls=':')
ax.annotate('threshold\n$s=4m^2$', xy=(4.1, 0.25), xytext=(7.0, -0.95), fontsize=8,
            color='0.35', arrowprops=dict(arrowstyle='->', color='0.55', lw=0.9))
save(fig, "b0_cut.svg")

# ------------------------------------------------- 2. the diagrams we talk about
for name, spec in (("bubble", "bubble"), ("triangle", "triangle"), ("box", "box")):
    try:
        g = diagram(spec)
        f = draw_graph(g, figsize=(2.5, 2.5))
        save(f, f"diag_{name}.svg")
    except Exception as e:
        print("diagram", spec, "failed:", type(e).__name__, e)
