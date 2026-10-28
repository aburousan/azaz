+++
title = "feynsage: a Tutorial for Someone Starting QFT"
hascode = true
date = Date(2026, 10, 28)
rss = "A tutorial for feynsage, a SageMath package for QFT calculations, in the order a first course actually goes: gamma matrices and traces first, then a full scattering cross section for electron positron to muon pair, then loops at the end. Every object is explained before it is used and every output on the page is captured from a real run."
rss_title = "feynsage: a Tutorial for Someone Starting QFT"
rss_pubdate = Date(2026, 10, 28)

tags = ["physics", "qft", "sagemath", "feynman-integrals", "code", "tutorial"]
+++

\newcommand{\dd}{\mathrm d}

\toc

# **\col{#3c568e}{feynsage}**: a Tutorial for Someone Starting QFT

~~~
<figure>
  <img class="cv-img" loading="lazy" decoding="async" src="/assets/Physics/blogs/feynsage/cover_drawing.jpg" alt="Drawing of Richard Feynman" style="max-width:520px">
  <p>Drawing made by me.</p>
</figure>
~~~

In a first QFT course the calculations arrive in a fixed order. First you learn to take traces of gamma matrices. Then you square an amplitude, average over spins, turn it into a cross section you could compare with an experiment. Loops come later, once the easy things are safe.

[feynsage](https://github.com/aburousan/feynsage) is a SageMath package that does these calculations. This page follows that same order.

**Who this is for.** You have met the Dirac equation, you have seen a Feynman diagram, you know that a cross section is what an experiment measures. You do not need to have taken a single trace by hand, because we start there.

**Everything on this page is real output.** Each block was run, the answer captured, then typeset.

## Installing it

```bash
git clone https://github.com/aburousan/feynsage.git
cd feynsage
./install.sh          # add --test to run the test suite afterwards
```

The script finds SageMath with FORM, or installs them. Then, inside Sage:

```python
from feynsage import *
```

## What else is in there

This page uses a small corner of the package. The functions fall into a few groups, so you know what to look for when you need it.

| what you want | functions |
|---|---|
| closed formulas | `tadpole`, `bubble_equal_mass`, `bubble_massless`, `expand_eps` |
| one-loop functions | `A0`, `B0`, `C0`, `D0`, `loop`, `PVB`, `PVC`, `PVD`, `finite_part` |
| families with IBP reduction | `family`, `.ibp`, `ibp_reduce`, `.UF`, `reduce_ff`, `symmetries` |
| graphs | `graph`, `diagram`, `.U`, `.F`, `.spanning_trees`, `.two_forests`, `.plot` |
| Dirac traces | `momenta`, `lorentz_indices`, `gamma`, `slash`, `gamma5`, `dirac_trace`, `contract`, `epsilon` |
| whole processes | `process`, `.squared`, `.dsigma_dcos`, `.sigma`, `.width` |
| pictures | `draw_graph`, `draw_panels`, `draw_sectors`, `quick_plot`, `curves` |

`info(f)` prints what any one of them computes with what its output means, so you can explore without the reference open.

\note{
**One trap worth knowing early.** The package uses two different normalisations, each in its own place.

The closed formulas with the integral families use the Euclidean measure, $\int \dd^Dk/\pi^{D/2}$, with propagators written $k^2+m^2$.

`A0`, `B0`, `C0`, `D0` instead follow Package-X in Minkowski space, $\mu^{2\epsilon}e^{\epsilon\gamma_E}\int \dd^Dk/(i\pi^{D/2})$, so their numbers can be compared directly with Package-X with LoopTools.

Both are right, they answer different questions. Mixing them in one calculation is not.
}

# Part 1: gamma matrices and traces

## What these objects are

The Dirac equation describes a spin one-half particle such as an electron. To write it down you need four matrices, $\gamma^0,\gamma^1,\gamma^2,\gamma^3$, each one a $4\times4$ matrix. They are called **gamma matrices** or Dirac matrices.

You almost never need the matrices themselves. Everything follows from one rule, the anticommutation relation
$$ \gamma^\mu\gamma^\nu + \gamma^\nu\gamma^\mu = 2g^{\mu\nu} $$
Two more pieces of notation. A **slash** is a momentum contracted with the gammas,
$$ \not p \equiv p_\mu\gamma^\mu $$
and the **trace** of a matrix is the sum of its diagonal entries, written $\mathrm{tr}$.

\defn{
**Why traces appear at all.** This is the part that is usually left unsaid.

An amplitude $\mathcal M$ for a process with electrons carries spinors $u(p)$ with gamma matrices between them. What an experiment measures is not $\mathcal M$ but $|\mathcal M|^2$, usually averaged over the spins you did not prepare, summed over the spins you did not measure.

Doing that sum over spins uses the identity $\sum_s u(p)\bar u(p) = \not p + m$. Once you put it in, the spinors are gone, every term becomes a string of gamma matrices with its ends joined. A string of matrices with its ends joined is a trace.

So: spin sum in, trace out. That is why a QFT course spends a week on trace identities before computing anything physical.
}

## Taking traces

In feynsage you declare your momenta with your indices, then write the trace the way the book writes it. FORM does the algebra underneath, you never see it.

```python
p, q = momenta('p q')
mu, nu, rho, sigma_ = lorentz_indices('mu nu rho sigma_')
```

Start with the simplest one, the trace of the identity matrix. It is a $4\times4$ matrix, so:

```python
dirac_trace(one())
```

$$ 4 $$

Two gammas:

```python
dirac_trace(gamma(mu)*gamma(nu))
```

$$ 4 \, g^{\mu \nu} $$

An odd number of them gives nothing at all:

```python
dirac_trace(gamma(mu)*gamma(nu)*gamma(rho))
```

$$ 0 $$

Four gammas, the identity that takes half a page by hand:

```python
dirac_trace(gamma(mu)*gamma(nu)*gamma(rho)*gamma(sigma_))
```

$$ 4 \, g^{\mu \sigma} g^{\nu \rho} - 4 \, g^{\mu \rho} g^{\nu \sigma} + 4 \, g^{\mu \nu} g^{\rho \sigma} $$

Those four results are exactly the trace theorems Peskin and Schroeder collect in equation (5.5) on page 134, which is the box a first course asks you to memorise. Now with momenta in them:

```python
dirac_trace(slash(p)*slash(q))
```

$$ 4 \, \left(p \cdot q\right) $$

```python
dirac_trace(slash(p)*gamma(mu)*slash(q)*gamma(nu))
```

$$ 4 \, p^{\nu} q^{\mu} + 4 \, p^{\mu} q^{\nu} - 4 \, \left(p \cdot q\right) g^{\mu \nu} $$

Each of these came back in under three hundredths of a second. The last one is the trace you meet in the first real calculation of the course, which is where we go next.

# Part 2: a cross section you could measure

## The process

Take the reaction an electron-positron collider actually does:
$$ e^- e^+ \to \mu^- \mu^+ $$
An electron meets a positron, they annihilate into a photon, the photon turns into a muon with an antimuon. It is the standard first calculation because it has exactly one diagram in QED, no complications.

\defn{
**$s$, $t$ and $u$, if nobody has defined them yet.** Call the incoming momenta $p_1,p_2$ with the outgoing ones $p_3,p_4$. Three combinations describe the whole kinematics:
$$ s=(p_1+p_2)^2, \qquad t=(p_1-p_3)^2, \qquad u=(p_1-p_4)^2 $$
$s$ is the total energy squared in the centre of mass, so $\sqrt{s}$ is the collider energy. $t$ with $u$ carry the scattering angle. feynsage will print answers in these variables.
}

Set the process up. We ask for pure QED, so only the photon is exchanged, with the electron and muon masses set to zero since the collider energy is far above both:

```python
qed = QED()
P = process('e- e+ -> mu- mu+', model=qed, massless=['e', 'mu'])
len(P.diagrams)
```

$$ 1 $$

One diagram, as expected.

## The squared amplitude

```python
P.squared()
```

$$ \frac{2 \, \left(e^{4} t^{2} + e^{4} u^{2}\right)}{s^{2}} $$

That is $|\mathcal M|^2$, already averaged over the two initial spins, summed over the final ones. Written tidily,
$$ \overline{|\mathcal M|^2} = \frac{2e^4\left(t^2+u^2\right)}{s^2} $$
This is Peskin's equation (5.10) on page 135, taken with the muon mass set to zero. feynsage built the diagram, put in the spin sums, took the traces of Part 1, contracted the indices, then averaged, in two hundredths of a second.

## Where the shape comes from: one spin state at a time

Before the cross section, one more thing feynsage can do that makes the answer less mysterious.

The $|\mathcal M|^2$ above was averaged over spins, so the spin information is gone. Ask instead for a single spin state. For a massless fermion the spin along the direction of motion is called **helicity**, either $+1$ or $-1$:

```python
for he in (1, -1):
    for hm in (1, -1):
        P.squared(helicities={'e-': he, 'e+': -he, 'mu-': hm, 'mu+': -hm}).factor()
```

| electron | muon | result |
|---|---|---|
| $+$ | $+$ | $e^{4}\left(\cos\theta + 1\right)^{2}$ |
| $+$ | $-$ | $e^{4}\left(\cos\theta - 1\right)^{2}$ |
| $-$ | $+$ | $e^{4}\left(\cos\theta - 1\right)^{2}$ |
| $-$ | $-$ | $e^{4}\left(\cos\theta + 1\right)^{2}$ |

These are Peskin's equations (5.21) to (5.24) on page 143.

Look at what the table says. Each single helicity state gives a *lopsided* answer, $(1+\cos\theta)^2$ throwing everything forwards or $(1-\cos\theta)^2$ throwing it backwards. Neither is symmetric. Only when you average the four of them,
$$ \tfrac14\left[2(1+\cos\theta)^2 + 2(1-\cos\theta)^2\right] = 1+\cos^2\theta $$
does the familiar shape appear. The $1+\cos^2\theta$ you plot is the sum of two lopsided pieces, not a basic fact about the process.

\note{
**What is missing from the table is also physics.** Every row above has the electron with the positron in *opposite* helicity states. Ask for the same helicity on both:

```python
P.squared(helicities={'e-': +1, 'e+': +1, 'mu-': +1, 'mu+': -1}).factor()
```

$$ 0 $$

All four such combinations give exactly zero, as do the ones where the two muons come out with the same helicity. The reason is angular momentum. The photon carries spin one along the beam, so it cannot be made by a pair whose spins cancel, nor can it decay into one. feynsage is reporting a selection rule here, not only an algebraic result.
}

## Turning it into a cross section

A squared amplitude is not yet something you can measure. You must divide by the flux, integrate over the directions the muons can come out in. The useful quantity is the **differential cross section** $\dd\sigma/\dd\cos\theta$, which says how much of the scattering goes into each angle, with $\theta$ the angle between the incoming electron with the outgoing muon.

```python
P.dsigma_dcos()
```

$$ \frac{e^{4} \cos\theta^{2} + e^{4}}{32 \, \pi \sqrt{s}^{2}} $$

Read the shape off it: the answer is proportional to $1+\cos^2\theta$. Using $e^2 = 4\pi\alpha$ this is
$$ \frac{\dd\sigma}{\dd\cos\theta} = \frac{\pi\alpha^2}{2s}\left(1+\cos^2\theta\right) $$
This is Peskin's equation (5.14) on page 137, written there as $\dd\sigma/\dd\Omega = (\alpha^2/4E_{\rm cm}^2)(1+\cos^2\theta)$. The two agree: the solid angle brings a factor $2\pi$, since nothing depends on the azimuth, with $E_{\rm cm}^2 = s$.

More muons come out along the beam than across it, in that particular shape. It is a real prediction that experiments have confirmed many times.

~~~
<figure>
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/blogs/feynsage/ee_mumu_angle.svg" alt="Differential cross section against cos theta for electron positron into muon pair">
  <p>The angular distribution at \(\sqrt{s}=10\) GeV, in picobarns. The solid curve is what feynsage computed, the dashed one is the shape \(1+\cos^2\theta\) normalised at the middle. They lie on top of each other.</p>
</figure>
~~~

Now integrate over all angles to get one number:

```python
P.sigma(sqrt_s=10, unit='pb')
```

$$ 868.5447687569202 $$

\defn{
**What a picobarn is.** Cross sections have units of area, because the classical picture is the size of the target. The unit is the **barn**, $10^{-28}\,\mathrm{m}^2$, which is enormous by nuclear standards, named from "as big as a barn door". A picobarn is $10^{-12}$ of that.

So the answer says: at a collider running at $\sqrt{s}=10$ GeV, the effective target area for making a muon pair is about 869 pb.
}

Check it against the textbook. In the high-energy limit the total cross section is
$$ \sigma = \frac{4\pi\alpha^2}{3s} $$
which is the formula on Peskin page 137, where the text notes that dimensional analysis fixes everything except the factor $4\pi/3$. Put the numbers in by hand:

```python
float(4*pi*(1/137.035999084)^2/(3*10^2)*0.3893793721e9)
```

$$ 868.5447687569203 $$

against feynsage's $868.5447687569202$. The two agree in all sixteen digits but the last, which is rounding. The $0.3893793721\times10^{9}$ is the number of picobarns in one $\mathrm{GeV}^{-2}$.

That is a complete calculation, from naming a reaction to a number with units, in four lines.

## The diagram itself

feynsage draws what it built, so you can check you set up the process you meant:

```python
from feynsage.diagram_plot import draw_diagrams
draw_diagrams(P.diagrams, ncols=1, size=2.6)
```

~~~
<div class="mfig" style="--w:330px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/blogs/feynsage/qed_tree.svg" alt="Tree level Feynman diagram for electron positron into muon pair">
  <p>The electron with the positron meet, make a photon, the photon makes the muon pair. Arrows run along the fermion lines, the wavy line is the photon.</p>
</div>
~~~

# Part 3: the same process at one loop

Everything so far was **tree level**, which means no closed loops. The next order in perturbation theory adds one loop to every diagram. Ask feynsage for them:

```python
L = P.loop_diagrams()
len(L)
```

$$ 7 $$

```python
draw_diagrams(L, ncols=4, size=2.3)
```

~~~
<figure>
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/blogs/feynsage/qed_oneloop.svg" alt="The seven one-loop QED diagrams for electron positron into muon pair">
  <p>All seven one-loop diagrams of this process in QED, drawn by feynsage. (1) and (2) are the boxes, one crossed. (3) corrects the electron vertex, (4) the muon vertex. (5), (6) and (7) put a fermion loop inside the photon line, with an electron, a muon then a tau going round.</p>
</figure>
~~~

The picture already tells you the structure of the calculation. The seven split into three kinds:

- **Vertex corrections**, (3) and (4): the photon is emitted after the incoming pair has already exchanged one, which changes the strength of the coupling at the vertex.
- **Vacuum polarisation**, (5) to (7): the photon spends part of its life as a charged pair. This is the one that makes the electric charge depend on energy.
- **Boxes**, (1) and (2): a photon crosses between the electron side with the muon side, so the two halves are no longer independent.

## The one-loop correction

The quantity that corrects the cross section is the interference between the tree amplitude with the one-loop one. `virtual()` computes it:

```python
V = P.virtual()
```

It comes back as a Laurent series in $\epsilon$. Take it relative to the tree result, at ninety degrees, where $t = u = -s/2$:

```python
ratio = (V/P.squared()).subs({t: -s/2, u: -s/2}).simplify_full()
pole_parts(ratio)
```

The coefficient of $1/\epsilon^2$ is

$$ -\frac{e^{2}}{4 \pi^{2}} $$

which is $-\alpha/\pi$, since $e^2 = 4\pi\alpha$. The coefficient of $1/\epsilon$ is

$$ \frac{e^{2}\left(2\log(-s) - 2\log\mu^{2} - 1\right)}{8\pi^{2}} $$

\defn{
**Two kinds of infinity, which are not the same.** A beginner meets both here for the first time, so it is worth separating them.

The $1/\epsilon$ pole from the vertex with the self-energy diagrams is **ultraviolet**. It comes from the loop momentum going to infinity. Renormalisation removes it: you rewrite the answer in terms of the charge you actually measure, the infinity goes with the bare charge.

The $1/\epsilon^2$ is **infrared**, which is a different illness. It comes from the loop photon going soft, with energy heading to zero, or collinear with a massless fermion. No renormalisation can remove it, because nothing is wrong with the theory at short distance here.

The cure is physical. A detector cannot tell $\mu^-\mu^+$ from $\mu^-\mu^+$ plus a photon too soft to register. So the measurable quantity is the sum of the two. Add the rate for emitting a real soft photon, its infrared divergence cancels this one exactly. That cancellation is the Bloch-Nordsieck theorem. The double pole above is not a failure, it is one half of a sum that is finite.
}

## What survives: the charge depends on energy

Of the three kinds of diagram, the vacuum polarisation leaves a mark you can measure. Isolate it by computing the photon self-energy on its own:

```python
qed = QED(muons=False, taus=False)
p = momenta('pp_'); P2 = var('P2_')
se = topologies(1, 1, 1, exclude=('tadpoles', 'wf'))
dA = insert_fields(se, ['A'], ['A'], qed)
gM = sum(dA.loop_amplitude([p], [p],
         lambda n, e: n*T.metric(e[0], e[1]), {'pp_^2': 'P2_'}))
Pi2 = gM/((3 - 2*eps)*P2)
uv_part(Pi2).simplify_full()
```

$$ -\frac{e^{2}}{12 \pi^{2}} $$

So the photon self-energy carries the ultraviolet pole
$$ \Pi_2 = -\frac{e^2}{12\pi^2}\,\frac{1}{\epsilon} + \text{finite} $$
This is Peskin's equation (7.90) on page 252, converted to the $d = 4-2\epsilon$ convention. Peskin defines $\epsilon = 4-d$, so his pole is twice this one. The physics is identical, the letter is not.

That single number is why the fine structure constant is not constant. Absorbing the pole into the charge leaves behind a logarithm of the energy, so the charge you measure grows as you probe harder: $1/137$ at low energy, about $1/128$ at the mass of the $Z$. The whole running of the coupling in QED comes out of this one coefficient.

# Part 4: loop integrals by themselves

Behind every diagram in Part 3 sits an integral over the momentum running round the loop, which is not fixed by the incoming particles:
$$ \int \frac{\dd^4\ell}{(2\pi)^4}\;\frac{1}{(\ell^2-m^2)\left((\ell+p)^2-m^2\right)} $$
These integrals are the hard part of QFT. Many of them come out infinite, which is what renormalisation exists to handle.

feynsage knows the standard ones by name. The simplest, one propagator in a circle, is called the tadpole:

```python
A0('m')
```

$$ m^{2} \left(\frac{1}{\epsilon} + \log\left(\frac{\mu^{2}}{m^{2}}\right) + 1\right) $$

The $1/\epsilon$ is the infinity, held in a form you can cancel later. $\mu$ is a reference energy that the method needs. With two propagators you get the bubble, which depends on the momentum $s$ flowing through:

```python
s = var('s')
B0(s, 'm', 'm')
```

$$ \frac{1}{\epsilon} + \Lambda(s; m, m) + \log\left(\frac{\mu^{2}}{m^{2}}\right) + 2 $$

$\Lambda$, printed as `DiscB`, holds all the dependence on $s$.

## Why the bubble has an imaginary part

Here is the one loop result worth seeing even on a first pass. Take the finite part of the bubble, evaluate it along the real $s$ axis:

~~~
<figure>
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/blogs/feynsage/b0_cut.svg" alt="Real and imaginary parts of the one loop bubble against s">
  <p>The finite part of \(B_0(s;m,m)\) with \(m=\mu=1\). Below \(s=4m^2\) it is real. At \(s=4m^2\) an imaginary part switches on, which is exactly the energy needed to make the two particles inside the loop real instead of virtual. The dashed line is \(\pi\sqrt{1-4m^2/s}\), sitting on what feynsage computed.</p>
</figure>
~~~

The threshold is the optical theorem: the imaginary part of a loop is the rate for actually producing what is inside it, so it must be zero until there is enough energy. Checked at four points:

| $s/m^2$ | feynsage | $\pi\sqrt{1-4m^2/s}$ |
|---|---|---|
| 5 | 1.4049629462081452 | 1.4049629462081452 |
| 9 | 2.3416049103469088 | 2.3416049103469088 |
| 16 | 2.720699046351327 | 2.7206990463513265 |
| 100 | 3.078119592388474 | 3.0781195923884734 |

## The conventions, before you compare with a book

\defn{
**The arguments are masses, not masses squared.** `A0('m')` means a particle of mass $m$, following Package-X. So `A0('m^2')` describes a particle of mass $m^2$ and returns $m^4(\dots)$. If a power looks wrong, check this first. (The inert functions `PaVeA0`, `PaVeB0` and friends are the exception: those take squared masses.)

**The dimension is $d=4-2\epsilon$.** Loop integrals are normalised as
$$ \mu^{2\epsilon}e^{\epsilon\gamma_E}\frac{1}{i\pi^{d/2}}\int \dd^d\ell $$
so the $\gamma_E$ with the $\log 4\pi$ are absorbed. You get the $\overline{\rm MS}$ answer.

**Peskin uses $d=4-\epsilon$.** His poles are $2/\epsilon$ where feynsage writes $1/\epsilon$. Compare the two directly, you find a factor of two that is not physics.

**The metric is $(+,-,-,-)$**, with the propagator denominator $q^2-m^2+i0$.
}

## Where to go next

feynsage goes a long way past this page: tensor reduction of loop integrals, integral families, IBP reduction with symmetries found by itself, master integrals, Mellin-Barnes, sector decomposition, differential equations, diagrams generated from a model the way FeynArts does it.

- The repository with the full reference: [github.com/aburousan/feynsage](https://github.com/aburousan/feynsage)
- A longer tutorial ships inside it at `docs/tutorial/feynsage_tutorial.pdf`
- `docs/dirac_algebra.md` if traces are what you came for
- Many functions explain themselves. Pass `explain=True` to the one-loop functions such as `A0`, or call `info(f)` on a function, to have it print what the output means.

One honest word on scale. feynsage is built for small and medium problems, where every step stays exact, can be checked, explains itself. For very large reductions with millions of equations, Kira with FIRE are the right tools.

~~~
<button onclick="window.history.back()">Go Back</button>
~~~

{{comments}}
