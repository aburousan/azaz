# Re-computes every result printed in the feynsage tutorial page and compares it
# with what is published. Run this after upgrading feynsage.
#     sage verify_page.sage
import sys, os
sys.path.insert(0, os.path.expanduser("~/Coding/sage/feynsage"))
from feynsage import *
from feynsage.models import QED, EL
from feynsage.qft import tensors as T
from sage.all import latex, var, pi, CC, RR, sqrt

checks = []
def chk(name, cond): checks.append((name, bool(cond)))

mu_, nu_, rho_, sig_ = lorentz_indices('mu nu rho sigma_')
p, q = momenta('p q')
chk('tr(1) = 4',            str(dirac_trace(one())) == '4')
chk('tr(g g) = 4 g^{mn}',   latex(dirac_trace(gamma(mu_)*gamma(nu_))) == r'4 \, g^{\mu \nu}')
chk('tr(g g g) = 0',        str(dirac_trace(gamma(mu_)*gamma(nu_)*gamma(rho_))) == '0')
chk('tr(p/ q/) = 4 p.q',    latex(dirac_trace(slash(p)*slash(q))) == r'4 \, \left({p} \cdot {q}\right)')

P = process('e- e+ -> mu- mu+', model=QED(), massless=['e', 'mu'])
chk('one tree diagram',     len(P.diagrams) == 1)
chk('|M|^2 = 2 e^4 (t^2+u^2)/s^2', str(P.squared().factor()) == '2*(t^2 + u^2)*EL^4/s^2')
chk('sigma(10 GeV) in pb',  repr(P.sigma(sqrt_s=10, unit='pb')) == '868.5447687569202')
chk('helicity (+,+)',       str(P.squared(helicities={'e-':1,'e+':-1,'mu-':1,'mu+':-1}).factor())
                            == 'EL^4*(cos_theta + 1)^2')
chk('same helicity vanishes', str(P.squared(helicities={'e-':1,'e+':1,'mu-':1,'mu+':-1}).factor()) == '0')

chk('seven one-loop diagrams', len(P.loop_diagrams()) == 7)
s, t, u = P.s, P.t, P.u
p2, _ = pole_parts((P.virtual()/P.squared()).subs({t: -s/2, u: -s/2}).simplify_full())
chk('double pole = -e^2/(4 pi^2)', (p2.simplify_full() + EL**2/(4*pi**2)).simplify_full() == 0)

qed2 = QED(muons=False, taus=False)
pp = momenta('pp_'); P2 = var('P2_')
se = topologies(1, 1, 1, exclude=('tadpoles', 'wf'))
dA = insert_fields(se, ['A'], ['A'], qed2)
gM = sum(dA.loop_amplitude([pp], [pp], lambda n, e: n*T.metric(e[0], e[1]), {'pp_^2': 'P2_'}))
chk('photon self-energy pole = -e^2/(12 pi^2)',
    (uv_part(gM/((3 - 2*eps)*P2)) + EL**2/(12*pi**2)).simplify_full() == 0)

sv = var('s')
chk('A0(m)',        str(A0('m')) == 'm^2*(1/eps + log(mu^2/m^2) + 1)')
chk('B0(0,m,m)',    str(B0(0, 'm', 'm')) == '1/eps + log(mu^2/m^2)')
chk('finite part',  str(finite_part(B0(sv, 1, 1), 1)) == 'DiscB(s, 1, 1) + 2')
for x, published in ((5, 1.4049629462081452), (9, 2.3416049103469088),
                     (16, 2.720699046351327), (100, 3.078119592388474)):
    im = float(CC(DiscB(x, 1, 1)).imag())
    chk(f'Im B0(s={x}) as published', abs(im - published) < 1e-14)
    chk(f'Im B0(s={x}) = pi sqrt(1-4m^2/s)', abs(im - float(RR(pi*sqrt(1 - 4/x)))) < 1e-12)

bad = 0
for name, res in checks:
    print(('  ok   ' if res else '  WRONG ') + name)
    bad += 0 if res else 1
print(f"\n{len(checks)} published results checked, {bad} wrong")
sys.exit(1 if bad else 0)
