+++
title = "feynsage: Feynman Integrals in SageMath, a Tutorial"
hascode = true
date = Date(2026, 10, 11)
rss = "A hands-on tutorial for feynsage, a SageMath package for Feynman integrals. Written for someone who has just started QFT: the tadpole with the bubble, the conventions that trip everyone up, tensor reduction, Dirac traces in textbook notation with FORM underneath, the branch cut of the bubble checked against the exact formula, then a full one-loop QED self-energy compared with Peskin. Every output on this page was produced by running the code."
rss_title = "feynsage: Feynman Integrals in SageMath"
rss_pubdate = Date(2026, 10, 11)

tags = ["physics", "qft", "sagemath", "feynman-integrals", "code", "tutorial"]
+++

\newcommand{\dd}{\mathrm d}

\toc

# **\col{#3c568e}{feynsage}**: Feynman Integrals in SageMath

Loop integrals are where a first QFT course usually starts hurting. The diagram takes a minute to draw, then the integral behind it takes an afternoon, a table of integrals, with three sign conventions you have to keep straight.

[feynsage](https://github.com/aburousan/feynsage) is a SageMath package that does those integrals. You write the integral in ordinary notation, it gives back an exact answer you can read.

This page is for someone who has just started QFT. You should know what a Feynman diagram is, you should have seen a propagator. You do not need to have done a loop integral by hand, you do not need to know Package-X, FORM or Kira.

**Everything printed on this page is real output.** Each block was run, the answer captured, then typeset. Nothing here is typed from memory.

## Installing it

```bash
git clone https://github.com/aburousan/feynsage.git
cd feynsage
./install.sh          # add --test to run the whole test suite afterwards
```

The script finds SageMath and FORM, or installs them. It works on macOS, Linux, Windows through WSL. Then start Sage and bring everything in:

```python
from feynsage import *
```

## Five minutes in: the tadpole

The simplest loop integral in any textbook is the one with a single propagator going round in a circle, called the tadpole. In feynsage it is `A0`:

```python
A0('m')
```

$$ m^{2} {\left(\frac{1}{\epsilon} + \log\left(\frac{\mu^{2}}{m^{2}}\right) + 1\right)} $$

Read it as three pieces. The $1/\epsilon$ is the ultraviolet divergence, the part that renormalisation has to remove. The logarithm carries the scale $\mu$ that dimensional regularisation forced in. The $+1$ is the leftover constant that depends on your conventions, which is exactly why conventions get their own section below.

Next, two propagators, the bubble. At zero external momentum with two equal masses:

```python
B0(0, 'm', 'm')
```

$$ \frac{1}{\epsilon} + \log\left(\frac{\mu^{2}}{m^{2}}\right) $$

Now switch the momentum on. Let $s$ be the squared momentum flowing in:

```python
s = var('s')
B0(s, 'm', 'm')
```

$$ \frac{1}{\epsilon} + \Lambda(s; m, m) + \log\left(\frac{\mu^{2}}{m^{2}}\right) + 2 $$

The new object $\Lambda(s; m, m)$ is the only place the momentum enters. feynsage keeps it as a named function instead of writing the logarithms out, because the whole physics of the bubble sits inside it. We come back to it in a moment.

\note{
**A name you will meet.** In the printed output $\Lambda$ appears as `DiscB`. It is the standard discontinuity function of the bubble. Keeping it unexpanded makes answers short and readable. When you want it written out in logarithms, ask for `explicit(...)`.
}

## The conventions, before you compare with a book

This is the section to read twice. Almost every "feynsage disagrees with my textbook" turns out to be one of these.

\defn{
**The arguments are masses, not masses squared.** `A0('m')` means the mass is $m$. This follows Package-X, where `PVA[0,m]` also takes the mass. So `A0('m^2')` does not mean $A_0(m^2)$, it means a particle of mass $m^2$, which returns $m^4(\dots)$. If an answer comes out with the wrong power, check this first.

**The dimension is $d = 4 - 2\epsilon$.** feynsage normalises every loop integral as
$$ \mu^{2\epsilon}\,e^{\epsilon\gamma_E}\,\frac{1}{i\pi^{d/2}}\int \dd^d\ell $$
so the $\gamma_E$ with the $\log 4\pi$ that come with dimensional regularisation are already absorbed. What you see is the $\overline{\rm MS}$ answer.

**Peskin uses $d = 4 - \epsilon$.** This is the big one. Peskin defines $\epsilon = 4 - d$, so his poles are $2/\epsilon$ where feynsage writes $1/\epsilon$. Comparing the two directly gives a factor of two and a wasted evening. The physics is the same, the letter $\epsilon$ is not.

**The metric is $(+,-,-,-)$** with the propagator denominator written $q^2 - m^2 + i0$. There is a Euclidean mode if you want it, switched on with `euclidean=True`.

**One exception to the mass rule.** The inert canonical functions `PaVeA0`, `PaVeB0`, `PaVeC0`, `PaVeD0`, with `pave(kind, args)`, take **squared** masses, the opposite of `A0` and friends. You meet them only when you ask for `masters=True`, so it will not bite you today, but it is worth knowing before it does.
}

## The bubble has a branch cut that you can watch open

Here is the first result worth staring at. Take the bubble with $m = \mu = 1$, throw the pole away, keep the finite part:

```python
finite_part(B0(s, 1, 1), 1)
```

$$ \Lambda(s; 1, 1) + 2 $$

\note{
**Careful with this one.** The second argument of `finite_part` is the **value of $\mu$**, not an order in $\epsilon$. Passing `0` puts $\mu = 0$ into a logarithm and the answer comes back as $-\infty$. I made exactly this mistake while writing this page.
}

Now evaluate it along the real $s$ axis and plot the two parts:

~~~
<figure>
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/blogs/feynsage/b0_cut.svg" alt="Real and imaginary parts of the one-loop bubble against s, with the threshold at s = 4 m squared">
  <p>The finite part of \(B_0(s;m,m)\) with \(m=\mu=1\). Below \(s=4m^2\) the function is real. At \(s = 4m^2\) an imaginary part switches on, which is the point where the two internal particles can be made for real instead of staying virtual. The dashed line is the exact formula \(\pi\sqrt{1-4m^2/s}\), sitting on top of what feynsage computed.</p>
</figure>
~~~

That threshold is not a numerical accident, it is the optical theorem. The imaginary part of a loop amplitude is the rate for actually producing the particles inside the loop, so it has to vanish until there is enough energy to make them. Above $s = 4m^2$ the exact answer is $\pi\sqrt{1 - 4m^2/s}$.

Check it rather than believing it:

```python
for x in (5, 9, 16, 100):
    print(x, CC(DiscB(x, 1, 1)).imag(), RR(pi*sqrt(1 - 4/x)))
```

| $s/m^2$ | feynsage | $\pi\sqrt{1-4m^2/s}$ | equal |
|---|---|---|---|
| 5 | 1.4049629462081452 | 1.4049629462081452 | yes |
| 9 | 2.3416049103469088 | 2.3416049103469088 | yes |
| 16 | 2.720699046351327 | 2.7206990463513265 | yes |
| 100 | 3.078119592388474 | 3.0781195923884734 | yes |

Agreement to the last digit at the first two points, to one unit in the last place at the others, which is ordinary floating point.

## Tensor integrals, which is the part nobody enjoys by hand

Real diagrams have loop momenta in the numerator. A fermion loop gives you $\ell^\mu \ell^\nu$ upstairs, which cannot depend on any direction after integration, so it has to collapse onto $g^{\mu\nu}$ with $p^\mu p^\nu$. Doing that by hand is a page of algebra.

```python
loop('l^mu l^nu', ['l', 'm'], ['l + p', 'm'], kin={'p^2': 's'})
```

The three arguments are the numerator, then one list per propagator giving its momentum with its mass, then the kinematics. The answer comes back split by tensor structure:

$$ \begin{aligned} g^{\mu\nu} &:\quad \frac{1}{\epsilon}\left(\frac{1}{2}  m^{2} - \frac{1}{12}  s\right) + \left(\frac{1}{3}  m^{2} - \frac{1}{12}  s\right)\,\Lambda(s; m, m) \\ & \quad + \left(\frac{1}{2}  m^{2} - \frac{1}{12}  s\right)\,\log\left(\frac{\mu^{2}}{m^{2}}\right) + \frac{7}{6}  m^{2} - \frac{2}{9}  s \\[6pt] p^{\mu} p^{\nu} &:\quad \frac{1}{3\,\epsilon} - \frac{m^{2} - s}{3  s}\,\Lambda(s; m, m) \\ & \quad + \frac{1}{3}\,\log\left(\frac{\mu^{2}}{m^{2}}\right) - \frac{12  m^{2} - 13  s}{18  s} \end{aligned} $$

Two coefficients, each a Laurent series in $\epsilon$. In Passarino-Veltman language these are $B_{00}$ with $B_{11}$, already reduced.

## Dirac traces, in the notation you already write

Traces of gamma matrices are the other thing that eats an afternoon. feynsage lets you write them the way the textbook does. FORM does the algebra underneath, you never write FORM code. This is the one part of the page that needs FORM actually installed, which `install.sh` handles for you.

```python
p, q = momenta('p q')
mu, nu = lorentz_indices('mu nu')
dirac_trace(slash(p)*gamma(mu)*slash(q)*gamma(nu))
```

$$ 4 \, p^{\nu} q^{\mu} + 4 \, p^{\mu} q^{\nu} - 4 \, \left(p \cdot q\right) g^{\mu \nu} $$

That is the identity every QFT course proves in week one,
$$ \mathrm{tr}\!\left(\not p\,\gamma^\mu \not q\,\gamma^\nu\right) = 4\left(p^\mu q^\nu + p^\nu q^\mu - g^{\mu\nu}\,p\cdot q\right) $$
Try one you would not want to do by hand:

```python
dirac_trace(slash(p)*slash(q)*slash(p)*slash(q))
```

$$ 8 \, \left(p \cdot q\right)^{2} - 4 \, p^{2}\,q^{2} $$

Both took under three hundredths of a second.

## Numbers, when you want numbers

The scalar triangle and box come in closed form, so you can ask for as many digits as you like:

```python
C0(0, 0, 5, 1, 1, 1).n(digits=30)
```

$$ -0.894334511878058104884677471495 - 0.604708613771114783376341265398\,i $$

It is complex because these kinematics sit above threshold, which is the same physics as the branch cut above.

## A real calculation: the photon self-energy in QED

Now put it together. We build the one-loop QED photon self-energy from scratch, contract it, pull out the divergence, then compare with a book.

```python
qed = QED(muons=False, taus=False)
p = momenta('pp_'); P2 = var('P2_')

se = topologies(1, 1, 1, exclude=('tadpoles', 'wf'))      # one loop, one in, one out
dA = insert_fields(se, ['A'], ['A'], qed)                 # put a photon on each leg
gM = sum(dA.loop_amplitude([p], [p],
         lambda n, e: n*T.metric(e[0], e[1]), {'pp_^2': 'P2_'}))
Pi2 = gM/((3 - 2*eps)*P2)
uv_part(Pi2).simplify_full()
```

$$ -\frac{e^{2}}{12\,\pi^{2}} $$

So $\Pi_2(q^2)$ has the divergence
$$ \Pi_2 = -\frac{e^2}{12\pi^2}\,\frac{1}{\epsilon} + \text{finite} $$
feynsage drew the diagram, inserted the fields, did the Dirac algebra, did the loop integral, then handed back the pole, in about a tenth of a second.

\note{
**Does it agree with Peskin?** Peskin and Schroeder give the photon self-energy in equation (7.90) on page 252, with the transverse structure $\Pi^{\mu\nu} = (q^2 g^{\mu\nu} - q^\mu q^\nu)\Pi_2(q^2)$.

The pole looks different at first sight, by a factor of two. It is the convention, not the physics. Peskin defines $\epsilon = 4 - d$ while feynsage uses $d = 4 - 2\epsilon$, so one $\epsilon$ is twice the other. Put them in the same convention, they agree. The package's own test suite checks this in `tests/test_books.sage`, along with the electron self-energy against (10.41) on page 333 with the QCD beta function against (16.73) on page 527.
}

## Diagrams

feynsage draws the graphs it works with, so you can check you built the one you meant.

~~~
<div class="mfig" style="--w:620px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/blogs/feynsage/diag_bubble.svg" alt="The one-loop bubble diagram with Feynman parameters marked">
  <p>`diagram("bubble")` then `draw_graph(g)`. The labels \(x_1\) with \(x_2\) are the Feynman parameters of the two propagators, which is what the parametric representation integrates over.</p>
</div>
~~~

The same works for `"triangle"` with `"box"`, which are the graphs behind `C0` with `D0`.

## Where to go after this

This page stops at one loop, which is already enough for most of a first course. feynsage goes further: integral families from strings, IBP reduction with symmetries found by itself, master integrals, Mellin-Barnes, sector decomposition, differential equations, Goncharov polylogarithms, diagrams generated from a model the way FeynArts does it.

- The repository, with the full reference: [github.com/aburousan/feynsage](https://github.com/aburousan/feynsage)
- A longer step-by-step tutorial with real computations ships inside it, at `docs/tutorial/feynsage_tutorial.pdf`
- The Dirac algebra page, `docs/dirac_algebra.md`, if traces are what you came for
- Many functions explain themselves. Pass `explain=True` to the one-loop functions such as `A0` or `loop`, or call `info(f)` on a function, to have it print what the output means.

One honest word about scale. feynsage is built for small and medium problems where every step stays exact, can be checked, explains itself. For very large reductions, millions of equations with several scales, Kira and FIRE are the right tools and will stay that way.

~~~
<button onclick="window.history.back()">Go Back</button>
~~~

{{comments}}
