# Everything the rewritten tutorial shows, in the order a beginner meets it.
import sys, os, time, json
sys.path.insert(0, os.path.expanduser("~/Coding/sage/feynsage"))
from feynsage import *
from sage.all import latex, var, CC, RR, pi, sqrt

OUT = []
def run(tag, code, f):
    t0 = time.time()
    try:
        v = f()
        OUT.append(dict(tag=tag, code=code, repr=str(v), tex=str(latex(v)),
                        secs=round(float(time.time()-t0), 2), ok=True))
        print(f"[ok]   {tag:24s} {float(time.time()-t0):5.2f}s")
    except Exception as e:
        OUT.append(dict(tag=tag, code=code, repr=f"{type(e).__name__}: {e}", tex=None,
                        secs=0.0, ok=False))
        print(f"[FAIL] {tag:24s} {type(e).__name__}: {e}")

mu_, nu_, rho_, sig_ = lorentz_indices('mu nu rho sigma_')
p, q = momenta('p q')

# --- traces, the first thing anyone computes
run("tr_one",   "dirac_trace(one())",                               lambda: dirac_trace(one()))
run("tr_gg",    "dirac_trace(gamma(mu)*gamma(nu))",                 lambda: dirac_trace(gamma(mu_)*gamma(nu_)))
run("tr_ggg",   "dirac_trace(gamma(mu)*gamma(nu)*gamma(rho))",      lambda: dirac_trace(gamma(mu_)*gamma(nu_)*gamma(rho_)))
run("tr_gggg",  "dirac_trace(gamma(mu)*gamma(nu)*gamma(rho)*gamma(sigma_))",
    lambda: dirac_trace(gamma(mu_)*gamma(nu_)*gamma(rho_)*gamma(sig_)))
run("tr_pq",    "dirac_trace(slash(p)*slash(q))",                   lambda: dirac_trace(slash(p)*slash(q)))
run("tr_pgqg",  "dirac_trace(slash(p)*gamma(mu)*slash(q)*gamma(nu))",
    lambda: dirac_trace(slash(p)*gamma(mu_)*slash(q)*gamma(nu_)))

# --- the first scattering process of any course
qed = QED()
P = process('e- e+ -> mu- mu+', model=qed, massless=['e', 'mu'])
run("ndiag",   "len(P.diagrams)",            lambda: len(P.diagrams))
run("msq",     "P.squared()",                lambda: P.squared().simplify_full())
run("dsig",    "P.dsigma_dcos()",            lambda: P.dsigma_dcos().simplify_full())
run("sigma10", "P.sigma(sqrt_s=10, unit='pb')", lambda: P.sigma(sqrt_s=10, unit='pb'))
run("kin",     "P.kinematics()",             lambda: P.kinematics())

# --- loops, kept for the end
s = var('s')
run("A0",      "A0('m')",                    lambda: A0('m'))
run("B0_s",    "B0(s, 'm', 'm')",            lambda: B0(s, 'm', 'm'))

with open("runs2.json", "w") as f:
    json.dump(OUT, f, indent=1, default=str)
print("\nwrote runs2.json:", sum(1 for o in OUT if o['ok']), "of", len(OUT), "ok")
