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

# ------------------------------------------- 3. the angular distribution of
# e- e+ -> mu- mu+ in QED: the (1 + cos^2 theta) shape every course derives.
from sage.all import var as _var, pi as _pi
qed = QED()
P = process('e- e+ -> mu- mu+', model=qed, massless=['e', 'mu'])
dsig = P.dsigma_dcos().simplify_full()
GEV2_TO_PB = 3.8937937e8                      # hbar^2 c^2 in pb GeV^2
alpha_em = 1/137.035999

def dsig_pb(ct, rs=10.0):
    v = dsig.subs({P.cos_theta: ct, P.sqrt_s: rs})
    v = P.numeric(v, alpha=alpha_em) if hasattr(P, "numeric") else v
    return float(v)*GEV2_TO_PB

cts = [i/200.0 for i in range(-200, 201)]
try:
    ys = [dsig_pb(c) for c in cts]
    import matplotlib.pyplot as _plt
    from feynsage.plotting import STYLE, PALETTE
    import matplotlib as _mpl
    with _mpl.rc_context(STYLE):
        f, ax = _plt.subplots(figsize=(5.0, 3.0))
        ax.plot(cts, ys, color=PALETTE[0], label=r'feynsage')
        shape = [ys[200]*(1 + c**2)/1.0 for c in cts]   # normalised at cos=0
        ax.plot(cts, shape, '--', color=PALETTE[1], lw=1.1, label=r'$\propto 1+\cos^2\theta$')
        ax.set_xlabel(r'$\cos\theta$')
        ax.set_ylabel(r'$\mathrm{d}\sigma/\mathrm{d}\cos\theta$  [pb]')
        ax.set_title(r'$e^-e^+ \to \mu^-\mu^+$ in QED at $\sqrt{s}=10$ GeV', loc='left')
        ax.legend(fontsize=8)
        f.tight_layout()
    save(f, "ee_mumu_angle.svg")
    print("total from the curve (pb):", sum(ys)*(cts[1]-cts[0]))
except Exception as e:
    print("angular plot failed:", type(e).__name__, e)
