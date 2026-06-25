+++
title = "The Physics of Neutrinos: Chirality, Helicity, and Parity Violation"
date = Date(2026, 6, 25)
hascode = true
tags = ["qft", "particle-physics", "neutrino", "weak-interaction"]
+++

\toc

\newcommand{\col}[2]{~~~<span style="color:~~~#1~~~">~~~!#2~~~</span>~~~}

~~~
<script src="https://cdn.jsdelivr.net/npm/jsxgraph/distrib/jsxgraphcore.js"></script>
<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/jsxgraph/distrib/jsxgraph.css" />
~~~

# Chirality, Helicity, and Why the Weak Force is Left-Handed

\poem{
**A ghost that slips through matter’s seam,\\
The neutrino moves like a whispered dream.\\
Massless once in the old tale’s light,\\
Yet now with mass, though faint and slight.\\
Its left hand dances in nature’s art,\\
While the right stays hidden, a missing part.**\\

~~~<div style="text-align: right; font-style: italic;">&mdash; K.A.Rousan</div>~~~
}

The discovery of **neutrino oscillations** proved that neutrinos have mass, overturning the original Standard Model assumption that they were purely massless. That single fact reopens a set of beautiful, subtle questions about the weak interaction — questions about **chirality**, **helicity**, and **parity violation** that are very easy to state sloppily and surprisingly delicate to get right.

In this post we define these three ideas carefully, using the machinery of Quantum Field Theory, and follow the consequences of giving the neutrino a mass all the way down to real numbers. The punchline, stated up front:

\note{
**Chirality** and **helicity** are *different* operators that only coincide for massless particles. The weak force couples to **chirality**. For a massive neutrino these two notions disagree — but only at the level of $(m/2E)^2 \sim 10^{-17}$, which is why physicists use the words almost interchangeably. Parity violation, on the other hand, survives the neutrino mass completely intact, because it lives in the *gauge interaction*, not in the particle content.
}

## First, What *Is* the Weak Force?

Before any spinor algebra, let us get our bearings the way the early reviews did (this framing follows J. C. Taylor's 1964 *The theory of weak interactions*). Nature has four fundamental forces, and the **weak interaction** is the one responsible for **radioactive decay**. Its oldest example is the beta decay of a neutron,

$$
n \to p + e^- + \bar{\nu},
$$

together with the decays of the muon and the charged pion, $\mu^- \to e^- + \bar\nu + \nu$ and $\pi^+ \to \mu^+ + \nu$.

\note{
**Where the neutrino came from in the first place.** Beta decay is also *why* we believe in neutrinos at all. If a neutron simply decayed to $p + e^-$, the electron would carry a single, sharp energy fixed by the masses. Experiments instead found a *continuous* spectrum, the electron taking anything from nearly zero up to the maximum — as if energy were quietly leaking away. Worse, the spins did not add up: $\tfrac12$ cannot turn into $\tfrac12 + \tfrac12$ and stay half-integer. In 1930 Pauli proposed a "desperate remedy" in a letter addressed to *"Dear Radioactive Ladies and Gentlemen"*: a new, neutral, nearly massless spin-$\tfrac12$ particle that escapes the detector and balances the books. Fermi built it into a quantitative theory in 1934 and named it the **neutrino** ("little neutral one"). The missing energy and the missing spin both walk out of the apparatus carried by an $\bar\nu$ — and three decades later that same ghostly particle turned out to be the cleanest probe of parity violation in all of physics.
}

Two features *define* the weak force and make it strange:

\note{
**1. It is genuinely weak.** Its coupling constant is tiny, $g \approx 1.4\times10^{-49}\ \text{erg}\,\text{cm}^3 \approx 10^{-11}\ \text{MeV}^{-2}$. Compare the dimensionless strengths: electromagnetism has $e^2/4\pi \approx 1/137$ and the strong force $G^2/4\pi \approx 14$. Because the weak coupling is so small, weak decays are **slow** — lifetimes of $10^{-10}$ s or longer, an eternity by nuclear standards.

**2. It breaks mirror symmetry.** Unlike gravity, electromagnetism, and the strong force, the weak interaction does **not** respect **parity** (mirror reflection). This was the bombshell of 1956–57, and it is the heart of this post.
}

The modern way to package these facts is in three statements, which are exactly what we will unpack: the neutrino is **two-component** (it comes in only one handedness), the weak force couples to the **left-chiral** part of every fermion (the "$1-\gamma^5$" structure), and **lepton number** is conserved. Everything below is the careful version of those words.

## The Dirac Equation and Weyl Spinors

Spin-$\tfrac12$ particles like the electron and neutrino are described by the **Dirac equation**:

$$
(i\gamma^\mu \partial_\mu - m)\psi = 0
$$

The field $\psi$ is a 4-component spinor, and the $\gamma^\mu$ are $4\times4$ matrices obeying the Clifford algebra $\{\gamma^\mu,\gamma^\nu\} = 2\eta^{\mu\nu}$. To make "handedness" manifest, we use the **chiral (Weyl) representation**:

$$
\gamma^0 = \begin{pmatrix} 0 & I \\ I & 0 \end{pmatrix}, \qquad
\gamma^i = \begin{pmatrix} 0 & \sigma^i \\ -\sigma^i & 0 \end{pmatrix}
$$

where $\sigma^i$ are the Pauli matrices. In this basis the 4-component spinor splits cleanly into two 2-component pieces,

$$
\psi = \begin{pmatrix} \psi_L \\ \psi_R \end{pmatrix},
$$

and the Dirac equation becomes two **coupled** equations:

$$
\begin{aligned}
i(\partial_0 - \vec{\sigma}\cdot\vec{\nabla})\psi_L - m\psi_R &= 0, \\
i(\partial_0 + \vec{\sigma}\cdot\vec{\nabla})\psi_R - m\psi_L &= 0.
\end{aligned}
$$

\note{
**Crucial observation.** The mass $m$ is the *only* thing coupling $\psi_L$ and $\psi_R$. If $m=0$, the equations decouple into two independent **Weyl equations**, and left and right become entirely separate worlds.
}

## Chirality ($\gamma^5$)

Chirality is a fundamental, Lorentz-invariant property of a field. We define the chirality operator

$$
\gamma^5 = i\gamma^0\gamma^1\gamma^2\gamma^3 = \begin{pmatrix} -I & 0 \\ 0 & I \end{pmatrix},
$$

which satisfies $(\gamma^5)^2 = I$, so its eigenvalues are $\pm 1$. From it we build the **chiral projection operators**

$$
P_L = \frac{1-\gamma^5}{2} = \begin{pmatrix} I & 0 \\ 0 & 0 \end{pmatrix}, \qquad
P_R = \frac{1+\gamma^5}{2} = \begin{pmatrix} 0 & 0 \\ 0 & I \end{pmatrix}.
$$

Applied to $\psi$, these simply pick out the upper and lower blocks:

$$
P_L\psi = \begin{pmatrix}\psi_L\\0\end{pmatrix}\equiv\psi_L, \qquad
P_R\psi = \begin{pmatrix}0\\\psi_R\end{pmatrix}\equiv\psi_R.
$$

A state is **left-chiral** if $\gamma^5\psi_L = -\psi_L$ and **right-chiral** if $\gamma^5\psi_R = +\psi_R$. Because $\gamma^5$ commutes with Lorentz boosts, **chirality is Lorentz invariant** — every observer agrees on it.

We can check every one of these algebraic claims with a few lines of Julia. In the chiral basis $\gamma^5 = \mathrm{diag}(-I,+I)$, so the projectors are just integer matrices:

```julia:projectors
using LinearAlgebra
I2 = Matrix{Int}(I, 2, 2);  Z2 = zeros(Int, 2, 2)
γ5 = [-I2  Z2;  Z2  I2]                 # chiral basis:  diag(-I, +I)
Id = Matrix{Int}(I, 4, 4)
P_L = (Id - γ5) .÷ 2                     # (1 - γ5)/2
P_R = (Id + γ5) .÷ 2                     # (1 + γ5)/2

println("γ5² = I            : ", γ5^2 == Id)
println("P_L + P_R = I       : ", P_L + P_R == Id)
println("P_L is a projector  : ", P_L^2 == P_L)      # P_L² = P_L
println("P_R is a projector  : ", P_R^2 == P_R)
println("P_L P_R = 0 (orthog): ", all(P_L*P_R .== 0))
println("\ndiag(P_L) = ", diag(P_L), "   # keeps the UPPER block → ψ_L")
println("diag(P_R) = ", diag(P_R), "   # keeps the LOWER block → ψ_R")
```
\output{projectors}

Every identity comes back `true`: the projectors are complete ($P_L+P_R=1$), idempotent ($P_L^2=P_L$), and orthogonal ($P_LP_R=0$) — the algebraic fingerprint of "splitting a field into two independent halves."

## Helicity ($h$)

Helicity is the physically measurable projection of spin onto the direction of motion:

$$
h = \frac{\vec{\Sigma}\cdot\vec{p}}{2|\vec{p}|}, \qquad
\vec{\Sigma} = \begin{pmatrix}\vec{\sigma} & 0 \\ 0 & \vec{\sigma}\end{pmatrix}.
$$

Spin aligned with momentum gives $h=+\tfrac12$ (right-helical); anti-aligned gives $h=-\tfrac12$ (left-helical).

~~~
<div style="text-align:center; margin: 1.5rem 0;">
  <img class="cv-img math-diagram" src="/assets/Physics/blogs/neutrino_chirality/helicity.svg" alt="Right- and left-helical neutrinos" style="max-width:100%; height:auto; border-radius:8px;">
</div>
~~~
*Helicity is the projection of spin (red) onto momentum (black): same direction $\Rightarrow +\tfrac12$, opposite $\Rightarrow -\tfrac12$.*

Here is the catch:

\note{
**Helicity is NOT Lorentz invariant for a massive particle.** If the particle moves to the right with speed $v < c$, I can boost into a frame moving *faster* than it. In that frame its momentum points left, but its spin is unchanged — so the sign of the helicity flips.
}

~~~
<div style="text-align:center; margin: 1.5rem 0;">
  <img class="cv-img math-diagram" src="/assets/Physics/blogs/neutrino_chirality/boost.svg" alt="Helicity flips under a boost that overtakes the neutrino" style="max-width:100%; height:auto; border-radius:8px;">
</div>
~~~
*An observer who outruns the neutrino sees its momentum reversed while the spin stays fixed, flipping the helicity. This overtaking is only possible because $v<c$; for a massless particle nobody can outrun it, and helicity becomes frame-independent.*

\tip{
**Interactive — try the overtaking argument yourself.** The neutrino moves right with a fixed speed $\beta_\nu = 0.6$ and a fixed spin (red, pointing right). Drag the slider to change **your** speed $\beta_{\text{obs}}$. While you are slower than the neutrino its momentum still points right ($h=+\tfrac12$); the instant you overtake it ($\beta_{\text{obs}}>0.6$) the momentum flips and so does the helicity.
}

~~~
<div id="helicityBoard" class="jxgbox" style="width:600px;height:330px;margin:1rem auto;border:2px solid #aaa;border-radius:8px;"></div>
<script>
window.addEventListener('load', function(){
  if (typeof JXG === 'undefined' || typeof katex === 'undefined') return;
  JXG.Options.text.useKatex = true;   // render all labels with KaTeX
  const brd = JXG.JSXGraph.initBoard('helicityBoard', {
    boundingbox:[-6,4.2,6,-4.2], axis:false, showNavigation:false, showCopyright:false, keepaspectratio:false
  });
  const bnu = 0.6; // neutrino speed (fixed)
  const s = brd.create('slider',[[-4.5,3.4],[4.5,3.4],[0,0,0.95]],
    {name:'\\beta_{\\text{obs}}', snapWidth:0.01, fillColor:'#9c27b0', strokeColor:'#9c27b0'});
  const right = () => (bnu - s.Value()) >= 0;   // does momentum point right in this frame?

  // neutrino body
  brd.create('point',[0,0],{name:'\\nu',size:7,color:'#3b5bdb',fixed:true,fontSize:18,label:{offset:[-6,-18]}});
  // spin arrow (always to the right, above the particle)
  brd.create('arrow',[[-2,1.3],[2,1.3]],{strokeColor:'#e03131',strokeWidth:4,lastArrow:{type:2,size:6}});
  brd.create('text',[2.2,1.3,'\\text{spin } \\vec S \\text{ (fixed)}'],{color:'#e03131',fontSize:14});
  // momentum arrow: tail at origin, tip flips with frame
  const tip = brd.create('point',[()=> right()? 3.2 : -3.2, 0],{visible:false});
  const tail = brd.create('point',[0,0],{visible:false});
  brd.create('arrow',[tail,tip],{strokeColor:'#111',strokeWidth:4,lastArrow:{type:2,size:6}});
  brd.create('text',[()=> right()?0.9:-3.5, -0.7, ()=> '\\text{momentum } \\vec p\\ (\\text{'+(right()?'right':'left')+'})'],{fontSize:14});
  // helicity readout
  brd.create('text',[-5.6,-2.6, ()=> '\\text{Observer sees }\\ h = '+(right()?'+\\tfrac12\\ \\text{(right-helical)}':'-\\tfrac12\\ \\text{(left-helical)}')],
    {fontSize:18, strokeColor:'#9c27b0'});
  brd.create('text',[-5.6,-3.6, ()=> (s.Value()>bnu? '\\text{You overtook the neutrino — its momentum reversed!}' : '\\text{You are slower than the neutrino.}')],
    {fontSize:13,color:'#555'});
  brd.create('text',[-5.6,3.9,'\\text{Neutrino speed } \\beta_\\nu = 0.6 \\text{ (fixed). Drag your speed past it.}'],{fontSize:13,color:'#555'});
});
</script>
~~~

### Connecting Chirality and Helicity

Take a free plane-wave solution $u(p)e^{-ip\cdot x}$. In the chiral basis the spinor is

$$
u(p) = \begin{pmatrix}\sqrt{p\cdot\sigma}\,\xi \\ \sqrt{p\cdot\bar{\sigma}}\,\xi\end{pmatrix},
\qquad p\cdot\sigma = E - \vec{p}\cdot\vec{\sigma}, \quad p\cdot\bar{\sigma} = E + \vec{p}\cdot\vec{\sigma},
$$

with $\xi$ a 2-component rest-frame spinor. For a purely **left-chiral** field ($\psi_R=0$), the helicity expectation value turns out to be

$$
\langle h\rangle_L = -\frac12\,\frac{v}{c}, \qquad v = \frac{|\vec{p}|}{E}.
$$

This is the central result, and it is worth deriving without skipping steps.

\note{
**The plan.** We first compute the *chirality content of a helicity eigenstate* (since helicity is what a detector measures), then read the relation backwards. We use the chiral-basis convention where $\gamma^5 = \mathrm{diag}(-\mathbb{I}, +\mathbb{I})$, so $P_L$ keeps the upper block and $P_R$ the lower.
}

**Step 1 — build a helicity eigenstate.** Put the momentum along $z$, $\vec{p}=p\,\hat z$, so $h = \tfrac12\,\mathrm{diag}(\sigma_z,\sigma_z)$. The negative-helicity 2-spinor solves $\sigma_z\xi_- = -\xi_-$:

$$
\xi_- = \begin{pmatrix}0\\1\end{pmatrix}, \qquad \sigma_z\xi_- = -\xi_-, \qquad \xi_-^\dagger\xi_- = 1.
$$

**Step 2 — evaluate the square-root blocks.** With $\vec{p}\cdot\vec{\sigma} = p\,\sigma_z$, acting on $\xi_-$:

$$
\begin{aligned}
p\cdot\sigma\,\xi_- &= (E - p\,\sigma_z)\xi_- = (E+p)\,\xi_-, \\
p\cdot\bar\sigma\,\xi_- &= (E + p\,\sigma_z)\xi_- = (E-p)\,\xi_-.
\end{aligned}
$$

Since $\xi_-$ is an eigenvector, the square roots act as numbers, and

$$
u_-(p) = \begin{pmatrix}\sqrt{E+p}\,\xi_- \\ \sqrt{E-p}\,\xi_-\end{pmatrix}.
$$

**Step 3 — project onto each chirality.**

$$
P_L u_- = \begin{pmatrix}\sqrt{E+p}\,\xi_-\\0\end{pmatrix}, \qquad
P_R u_- = \begin{pmatrix}0\\\sqrt{E-p}\,\xi_-\end{pmatrix},
$$

so the squared norms are

$$
|P_L u_-|^2 = E+p, \qquad |P_R u_-|^2 = E-p, \qquad u_-^\dagger u_- = 2E.
$$

**Step 4 — norms become probabilities, and $v/c$ appears.**

$$
P_L = \frac{E+p}{2E}, \qquad P_R = \frac{E-p}{2E}.
$$

Using $E^2 = p^2 + m^2$ we have $\dfrac{p}{E} = \sqrt{1-(m/E)^2} = \dfrac{v}{c}$, so

$$
P_L = \frac{1+v/c}{2}, \qquad P_R = \frac{1-v/c}{2}.
$$

**Step 5 — the chirality expectation value.** Since $\gamma^5$ gives $-1$ on the upper block and $+1$ on the lower,

$$
\langle\gamma^5\rangle = \frac{(-1)(E+p) + (+1)(E-p)}{2E} = P_R - P_L = -\frac{v}{c} = 2h\,\frac{v}{c}\quad(h=-\tfrac12).
$$

**Step 6 — read it backwards.** A purely left-chiral field is the upper block alone, which receives contributions from *both* helicity spinors. The helicity is therefore distributed with

$$
P(h=-\tfrac12) = \frac{1+v/c}{2}, \qquad P(h=+\tfrac12) = \frac{1-v/c}{2},
$$

and the mean helicity of the left-chiral coupling is

$$
\langle h\rangle_L = \left(-\tfrac12\right)\frac{1+v/c}{2} + \left(+\tfrac12\right)\frac{1-v/c}{2} = -\frac12\,\frac{v}{c},
$$

exactly as claimed. The factor of two between $\langle h\rangle_L = -\tfrac12\,v/c$ and $\langle\gamma^5\rangle = -v/c$ is just the difference between helicity eigenvalues $\pm\tfrac12$ and chirality eigenvalues $\pm1$.

The two limiting cases:

* **Massless ($v=c$):** $\langle h\rangle_L = -\tfrac12$ exactly. A left-chiral state is perfectly and *exclusively* left-helical.
* **Massive neutrino ($v\approx c$):** with $m < 1$ eV and $E\sim\mathcal{O}(\text{MeV})$, we have $v/c = 1-\epsilon$ with $\epsilon\sim 10^{-14}$. The left-chiral state is overwhelmingly left-helical, with a microscopic right-helical sliver suppressed by $(m/E)$.

### Summary of values: every case spelled out

First, the two quantities are fundamentally different objects:

| Quantity | Operator | Eigenvalues | Lorentz invariant? | Conserved (free)? |
|---|---|---|---|---|
| Chirality | $\gamma^5$ | $+1$ (R), $-1$ (L) | yes | only if $m=0$ |
| Helicity | $h=\tfrac12\vec\Sigma\cdot\hat p$ | $+\tfrac12,\,-\tfrac12$ | only if $m=0$ | yes |

Next, the actual numbers. **Chirality content of a helicity eigenstate:**

| Prepared state | $P_L$ | $P_R$ | $\langle\gamma^5\rangle$ |
|---|---|---|---|
| $h=-\tfrac12$, massless | $1$ | $0$ | $-1$ |
| $h=+\tfrac12$, massless | $0$ | $1$ | $+1$ |
| $h=-\tfrac12$, massive | $\tfrac{1+v/c}{2}$ | $\tfrac{1-v/c}{2}$ | $-v/c$ |
| $h=+\tfrac12$, massive | $\tfrac{1-v/c}{2}$ | $\tfrac{1+v/c}{2}$ | $+v/c$ |

**Helicity content of a chirality eigenstate** (the mirror image, related by $L\leftrightarrow R$):

| Prepared state | $P(h{=}{-}\tfrac12)$ | $P(h{=}{+}\tfrac12)$ | $\langle h\rangle$ |
|---|---|---|---|
| Left-chiral, massless | $1$ | $0$ | $-\tfrac12$ |
| Right-chiral, massless | $0$ | $1$ | $+\tfrac12$ |
| Left-chiral, massive | $\tfrac{1+v/c}{2}$ | $\tfrac{1-v/c}{2}$ | $-\tfrac12 v/c$ |
| Right-chiral, massive | $\tfrac{1-v/c}{2}$ | $\tfrac{1+v/c}{2}$ | $+\tfrac12 v/c$ |

The four physically distinct statements: (i) a *massless* left-chiral particle is exactly and only $h=-\tfrac12$; (ii) a *massive* $h=-\tfrac12$ particle is mostly left-chiral with a right-chiral fraction $(1-v/c)/2$; (iii) a *massive* left-chiral particle is mostly $h=-\tfrac12$ with a wrong-helicity fraction $(1-v/c)/2\approx(m/2E)^2$; and (iv) everything is tied together by $\langle\gamma^5\rangle = 2h\,(v/c)$.

### Numerical reality check: why chirality $\approx$ helicity

Expanding the velocity for a relativistic particle,

$$
\frac{v}{c} = \sqrt{1-\left(\frac{m}{E}\right)^2} \approx 1 - \frac12\left(\frac{m}{E}\right)^2,
$$

the deviation of the helicity from its ideal value is

$$
\left|\langle h\rangle_L + \frac12\right| = \frac14\left(\frac{m}{E}\right)^2.
$$

More physically, when the weak vertex projects out $P_L$, the probability of producing the **wrong** (right-helical) neutrino is

$$
P_{\text{wrong}} = \frac{E-p}{2E} = \frac{m^2}{2E(E+p)} \approx \left(\frac{m}{2E}\right)^2.
$$

Anchoring to oscillation data — the atmospheric splitting $\Delta m^2_{31}\approx 2.5\times10^{-3}\,\text{eV}^2$ guarantees a mass $m\gtrsim 0.05$ eV, while KATRIN caps $m\lesssim 0.45$ eV — gives:

| Source | $E$ | $m$ | $1-v/c$ | $P_{\text{wrong}}=(m/2E)^2$ |
|---|---|---|---|---|
| Solar (pp) | $0.42$ MeV | $0.05$ eV | $7.1\times10^{-15}$ | $3.5\times10^{-15}$ |
| Reactor | $4$ MeV | $0.05$ eV | $7.8\times10^{-17}$ | $3.9\times10^{-17}$ |
| Accelerator | $1$ GeV | $0.05$ eV | $1.3\times10^{-21}$ | $6.3\times10^{-22}$ |
| KATRIN bound | $1$ MeV | $0.45$ eV | $1.0\times10^{-13}$ | $5.1\times10^{-14}$ |

Even in the most favourable case, fewer than one neutrino in $10^{13}$ carries the wrong helicity.

Let's reproduce that table in Julia — with one numerical subtlety worth seeing. The "obvious" formula $1-v/c = 1-\sqrt{1-(m/E)^2}$ suffers **catastrophic cancellation**: subtracting two numbers that agree to 16+ digits throws away all the precision. The algebraically equivalent $1-v/c = \dfrac{(m/E)^2}{1+\sqrt{1-(m/E)^2}}$ is stable.

```julia:wronghel
# (Energy E and mass m both in eV)
sources = [("Solar (pp)", 0.42e6, 0.05),
           ("Reactor",    4.0e6,  0.05),
           ("Accelerator", 1.0e9, 0.05),
           ("KATRIN max",  1.0e6,  0.45)]

naive(r)  = 1 - sqrt(1 - r^2)              # loses precision for tiny r
stable(r) = r^2 / (1 + sqrt(1 - r^2))      # algebraically identical, numerically safe

println(rpad("Source",13), rpad("1-v/c (naive)",16), rpad("1-v/c (stable)",16), "P_wrong=(m/2E)²")
for (name, E, m) in sources
    r  = m / E
    Pw = (m / (2E))^2
    println(rpad(name,13),
            rpad(string(round(naive(r),  sigdigits=2)),16),
            rpad(string(round(stable(r), sigdigits=2)),16),
            round(Pw, sigdigits=2))
end
```
\output{wronghel}

Notice the accelerator row: the naive column reads a flat **`0.0`** (all significant digits cancelled away), while the stable column correctly gives $1.3\times10^{-21}$. The physics and the numerics teach the same lesson — the wrong-helicity rate is fantastically tiny, but it is not zero.

~~~
<div style="text-align:center; margin: 1.5rem 0;">
  <img class="cv-img math-diagram" src="/assets/Physics/blogs/neutrino_chirality/decomp.svg" alt="A left-chiral neutrino decomposed into helicity components" style="max-width:100%; height:auto; border-radius:8px;">
</div>
~~~
*A left-chiral massive neutrino is a superposition dominated by the left-helical component, with a right-helical admixture of probability $(m/2E)^2$. Drawn to scale the red sliver would be invisible — that is the quantitative meaning of "chirality $\approx$ helicity."*

\tip{
**Interactive — the chirality/helicity mixing.** A particle prepared in a definite helicity $h=-\tfrac12$ splits into chirality components with probabilities $P_L=\tfrac{1+v/c}{2}$ and $P_R=\tfrac{1-v/c}{2}$. Drag the $v/c$ slider: at rest ($v=0$) the two are 50–50 (chirality is meaningless for a slow particle), while as $v\to c$ the state locks onto pure left chirality. A real neutrino sits at the far right edge, essentially on top of $P_L=1$.
}

~~~
<div id="chiralityBoard" class="jxgbox" style="width:600px;height:420px;margin:1rem auto;border:2px solid #aaa;border-radius:8px;"></div>
<script>
window.addEventListener('load', function(){
  if (typeof JXG === 'undefined' || typeof katex === 'undefined') return;
  JXG.Options.text.useKatex = true;
  const brd = JXG.JSXGraph.initBoard('chiralityBoard', {
    boundingbox:[-0.18,1.18,1.12,-0.22], axis:false, showNavigation:false, showCopyright:false
  });
  // axes
  brd.create('axis',[[0,0],[1,0]],{ticks:{insertTicks:false,ticksDistance:0.2,minorTicks:0}, withLabel:true, name:'v/c', label:{position:'rt',offset:[-10,16]}});
  brd.create('axis',[[0,0],[0,1]],{ticks:{insertTicks:false,ticksDistance:0.25,minorTicks:0}});
  // the two probability curves
  brd.create('functiongraph',[x=>(1+x)/2,0,1],{strokeColor:'#1971c2',strokeWidth:3});
  brd.create('functiongraph',[x=>(1-x)/2,0,1],{strokeColor:'#e8590c',strokeWidth:3});
  brd.create('text',[0.36,0.93,'P_L\\ \\text{(left, correct)}'],{color:'#1971c2',fontSize:14});
  brd.create('text',[0.36,0.16,'P_R\\ \\text{(right, wrong)}'],{color:'#e8590c',fontSize:14});
  // slider for v/c
  const s = brd.create('slider',[[0.05,1.12],[0.60,1.12],[0,0.6,1]],{name:'v/c', snapWidth:0.01, fillColor:'#9c27b0', strokeColor:'#9c27b0'});
  // moving markers + guide line
  brd.create('line',[()=>[s.Value(),0],()=>[s.Value(),1]],{straightFirst:false,straightLast:false,dash:2,strokeColor:'#999',strokeWidth:1});
  brd.create('point',[()=>s.Value(),()=>(1+s.Value())/2],{name:'',color:'#1971c2',size:4,fixed:true});
  brd.create('point',[()=>s.Value(),()=>(1-s.Value())/2],{name:'',color:'#e8590c',size:4,fixed:true});
  // readouts
  brd.create('text',[0.70,1.13, ()=>'P_L = '+((1+s.Value())/2).toFixed(3)],{color:'#1971c2',fontSize:15});
  brd.create('text',[0.70,1.00, ()=>'P_R = '+((1-s.Value())/2).toFixed(3)],{color:'#e8590c',fontSize:15});
});
</script>
~~~

For a typical reactor neutrino $v/c = 1 - 7.8\times10^{-17}$: it is slower than light by less than one part in $10^{16}$. (As an independent check, the SN1987A neutrinos crossed $\sim168{,}000$ light-years and arrived within hours of the photons.)

### The smoking gun: why the pion shuns the electron

All of the above could feel like bookkeeping — a $(m/2E)^2$ that is real but unmeasurably small. So it is worth meeting the one everyday process where the tiny gap between chirality and helicity is not just visible but *spectacular*: the decay of the charged pion. A $\pi^+$ can decay two ways,

$$
\pi^+ \to \mu^+ + \nu_\mu, \qquad \pi^+ \to e^+ + \nu_e .
$$

Naively the electron channel should **win in a landslide**. The electron is $\sim200$ times lighter than the muon, so there is far more phase space — more room for the decay products to fly apart — and ordinarily "more phase space" means "faster decay." Instead nature does the opposite. The electron mode is *suppressed* by a factor of about ten thousand:

$$
R_\pi \equiv \frac{\Gamma(\pi^+\to e^+\nu_e)}{\Gamma(\pi^+\to\mu^+\nu_\mu)}
= \left(\frac{m_e}{m_\mu}\right)^{\!2}\left(\frac{m_\pi^2-m_e^2}{m_\pi^2-m_\mu^2}\right)^{\!2}
\approx 1.28\times10^{-4},
$$

in beautiful agreement with the measured $(1.230\pm0.004)\times10^{-4}$ (after a small radiative correction). That factor $(m_e/m_\mu)^2$ is the very $(m/E)$ helicity–chirality mismatch from above, caught red-handed in a number you can look up in the Particle Data Group.

\tip{
**Why the lighter daughter is the *more* forbidden one.** Work in the pion rest frame. The $\pi^+$ has spin $0$, and the two daughters come out back-to-back. The weak vertex insists the neutrino be **left-chiral**; with $m_\nu\approx0$ that means **left-helical** (spin against its momentum). The antilepton $\ell^+$ flies the opposite way, and to add up to total spin $0$ it is forced to have the **same helicity** as the neutrino — i.e. the "wrong," left-helical state. But the same $V-A$ vertex wants to produce the $\ell^+$ with **right-chirality** (antiparticles couple through the right-chiral piece). A right-chiral particle is only left-helical to the tune of its mass, an admixture $\sim m_\ell/E$. So the amplitude is forced to be proportional to $m_\ell$, the rate to $m_\ell^2$ — and the **heavier** muon, being further from the massless limit, escapes the suppression far better than the electron. The pion's reluctance to make an electron *is* the statement "chirality $\neq$ helicity," writ large.
}

## Parity Violation and the Weak Force

A **parity** transformation $P$ sends $\vec{x}\to-\vec{x}$. It reverses momentum ($\vec{p}\to-\vec{p}$, a *polar* vector) but leaves spin (an *axial* vector) unchanged. Therefore **parity flips helicity**:

~~~
<div style="text-align:center; margin: 1.5rem 0;">
  <img class="cv-img math-diagram" src="/assets/Physics/blogs/neutrino_chirality/parity.svg" alt="Parity flips the helicity of a neutrino" style="max-width:100%; height:auto; border-radius:8px;">
</div>
~~~
*Parity reverses momentum but not spin, so the mirror-image neutrino is right-helical. The weak force couples only to the left-helical original, never its mirror image — that asymmetry **is** parity violation.*

On a Dirac spinor, parity is represented by $\gamma^0$, i.e. $\psi(t,\vec{x})\to\gamma^0\psi(t,-\vec{x})$. Acting on a left-chiral state,

$$
P(\psi_L) = \gamma^0\begin{pmatrix}\psi_L\\0\end{pmatrix} = \begin{pmatrix}0 & I \\ I & 0\end{pmatrix}\begin{pmatrix}\psi_L\\0\end{pmatrix} = \begin{pmatrix}0\\\psi_L\end{pmatrix} = \text{right-chiral}.
$$

So **parity flips chirality** too.

### The Weak Interaction (V−A Theory)

In 1956 Lee and Yang asked the heretical question — *has parity ever actually been tested in weak decays?* — and found that it had not. Within months Wu and collaborators answered it. They took a sample of $^{60}$Co and aligned the nuclear spins with a magnetic field at $0.02$ K (cold enough that thermal jostling did not scramble the alignment), then watched which way the beta-decay electrons came out:

\note{
**What the $^{60}$Co experiment actually saw.** The electrons emerged preferentially **opposite** to the nuclear spin, following the distribution

$$
I(\theta) \propto 1 - \frac{\vec\sigma\cdot\vec p_e}{E_e},
$$

where $\vec\sigma$ is the (aligned) nuclear spin and $\vec p_e$ the electron momentum. Here is why that single minus sign shattered a symmetry everyone had assumed: a mirror reflection (parity) reverses the momentum $\vec p_e$ but leaves the spin $\vec\sigma$ — an axial vector — untouched. So the mirror-image experiment would show electrons coming out the *other* way. Nature distinguishes the real world from its mirror image, completely and at first order. The same data imply the emitted $\bar\nu_e$ must be right-handed (and the $\nu_e$ left-handed) — later confirmed directly by Goldhaber in 1958.
}

In the Standard Model this maximal violation is built into the charged-current vertex coupling a neutrino, an electron, and the $W$-boson:

$$
\mathcal{L}_{\text{int}} \propto \bar{e}\,\gamma^\mu(1-\gamma^5)\,\nu\,W_\mu.
$$

The factor $(1-\gamma^5)$ is exactly twice the left projector, $\tfrac{1-\gamma^5}{2}\nu = \nu_L$. So:

\note{
The $W$-boson couples **exclusively** to the left-chiral part of a fermion field and completely zeroes out the right-chiral part. The weak vertex carries a built-in chiral filter.
}

\note{
**Is parity violation put in "by hand"?** Honestly — yes, in the sense that the Standard Model does not *derive* the $V-A$ structure; it is an empirical input from the 1957 Wu experiment. But it is not an arbitrary term bolted on. The one structural choice is the assignment of gauge representations: left-chiral fermions go into $SU(2)_L$ **doublets** (they carry weak isospin and couple to the $W$), while right-chiral fermions are $SU(2)_L$ **singlets** (zero isospin, no coupling). The $(1-\gamma^5)$ then *follows*. What remains genuinely open is *why* nature chose a chiral gauge group at all.
}

### The Group-Theory Argument: Singlets, Doublets, Triplets

\note{
**The one idea to hold onto.** "$SU(2)_L$" sounds intimidating, but it is a structure you already know: it is **identical to the algebra of spin** in ordinary quantum mechanics. A "weak isospin" doublet behaves exactly like a spin-$\tfrac12$ system — two states you can rotate into each other. Everything in this section is just spin-$\tfrac12$ and spin-$1$ wearing different names. The single physics input is which fields get placed in these multiplets — and *that* choice is where parity violation hides.
}

**Start from what the force actually does.** The weak interaction turns each particle into a **partner**: a $W$ boson knocks an electron into a neutrino, or a down quark into an up quark — and back again,

$$
\nu_L \leftrightarrow e_L, \qquad u_L \leftrightarrow d_L.
$$

So the natural objects are not single particles but **pairs**. Now ask the one question that fixes everything: *what transformations can mix the two members of a pair while keeping the total probability fixed* (so the result is still a valid quantum state)? Those are exactly the $2\times2$ unitary rotations; peel off the overall phase (which belongs to a separate $U(1)$) and what is left is $SU(2)$. That is the whole reason the weak force is an "$SU(2)$" theory — **it shuffles things two at a time.**

\note{
The number inside $SU(N)$ is just *how many things the force shuffles together*. The strong force shuffles quarks **three** colours at a time $\to SU(3)$; electromagnetism merely rephases a **single** field $\to U(1)$; the weak force pairs fields **two** at a time $\to SU(2)$.
}

Because $SU(2)$ is the *same* algebra as ordinary spin, $[T^a,T^b]=i\,\epsilon^{abc}\,T^c$, we can borrow all the spin vocabulary. A **multiplet** is just a family of particles that the weak rotations shuffle *among themselves*, and only three sizes ever appear — and the size is $2T+1$, exactly as a spin-$T$ object has $2T+1$ orientations:

* **Singlet** — *a loner* (size $1$). The rotations do nothing to it ($T^a=0$): it carries no weak charge and **never feels the $W$**. The right-chiral fields $\nu_R, e_R$ live here.
* **Doublet** — *a pair* (size $2$) such as $(\nu_L, e_L)$, rotated into each other exactly like the spin-up/spin-down states of a spin-$\tfrac12$ particle. Turning the lower member into the upper one *is* the emission of a $W$. The left-chiral fields live here.
* **Triplet** — *a trio* (size $3$), and here is the nice twist: the **$W$ bosons themselves** form a triplet. There are exactly three of them — $W^+, W^-, W^3$ — because $SU(2)$ has exactly three independent rotations. The charged ones are the raising/lowering combinations $W^\pm = \tfrac{1}{\sqrt2}(W^1 \mp iW^2)$ that flip a doublet's members, while $W^3$ mixes with the hypercharge boson to make the photon and the $Z$.

Up to here, *nothing has chosen a handedness* — this is all just "spin" bookkeeping. The single physical input — and the **entire content of parity violation** — is the *assignment*: nature places the **left-chiral** fermions in doublets and leaves the **right-chiral** ones as singlets,

$$
SU(2)_L \ \text{rotates}\ \begin{pmatrix}\nu_L\\ e_L\end{pmatrix}, \qquad \text{while}\ \nu_R,\ e_R\ \text{sit alone, untouched.}
$$

The mathematics never demanded "left"; that asymmetry is precisely what the 1957 Wu experiment measured.

**How the coupling is generated — step by step.** Gauge invariance has exactly one rule: replace every ordinary derivative by the **covariant derivative**

$$
D_\mu = \partial_\mu - i g\,T^a W^a_\mu ,
$$

where $T^a$ is the generator *in whatever representation the field sits in*. Plugging this into the free kinetic term $\bar\psi\,i\gamma^\mu D_\mu\psi$ splits it into a free piece plus an interaction,

$$
\bar\psi\,i\gamma^\mu D_\mu\psi
= \underbrace{\bar\psi\,i\gamma^\mu\partial_\mu\psi}_{\text{free}}
\;+\; \underbrace{g\,\bar\psi\,\gamma^\mu T^a\psi\,W^a_\mu}_{\mathcal{L}_{\text{int}}} .
$$

Now feed in the actual representations. **(1)** A right-chiral field is a *singlet*, $T^a=0$, so its entire interaction term is identically zero — $\nu_R$ and $e_R$ never appear in a weak vertex. **(2)** The left-chiral fields form the doublet $L=\binom{\nu_L}{e_L}$ with $T^a=\tfrac12\sigma^a$, so writing the interaction out with the Pauli matrices,

$$
\mathcal{L}_{\text{int}} = \tfrac{g}{2}\,\bar L\,\gamma^\mu\,\sigma^a L\;W^a_\mu .
$$

The three $\sigma^a$ do three different jobs. The combinations $\sigma^\pm=\tfrac12(\sigma^1\pm i\sigma^2)$ are the **off-diagonal** raising/lowering matrices that swap the two doublet members,

$$
\sigma^+ = \begin{pmatrix}0&1\\0&0\end{pmatrix},\qquad
\sigma^+\binom{\nu_L}{e_L} = \binom{e_L}{0},
$$

so $\sigma^\pm$ paired with $W^\pm_\mu=\tfrac1{\sqrt2}(W^1_\mu\mp iW^2_\mu)$ turn an electron into a neutrino (and back) — the **charged current**. The diagonal $\sigma^3$ paired with $W^3_\mu$ keeps each member as itself — the **neutral current**. Extracting just the charged piece,

$$
\mathcal{L}_{\text{CC}} = \frac{g}{\sqrt2}\,\bar\nu_L\,\gamma^\mu e_L\,W^+_\mu + \text{h.c.}
$$

Finally, undo the shorthand $\nu_L = P_L\nu = \tfrac{1-\gamma^5}{2}\nu$ and slide the projector through the gamma matrix (using $\gamma^\mu P_L = P_R\gamma^\mu$ and $P_L^2=P_L$) to recover the familiar $V-A$ vertex acting on the *full* Dirac fields:

$$
\mathcal{L}_{\text{CC}} = \frac{g}{\sqrt2}\,\bar\nu\,\gamma^\mu\,\frac{1-\gamma^5}{2}\,e\,W^+_\mu + \text{h.c.}
$$

**Parity violation is nothing more than the asymmetry of those representation matrices** ($T^a=\tfrac12\sigma^a$ for left, $T^a=0$ for right). The $(1-\gamma^5)$ was never written by hand — it is just the algebraic memory that only the $P_L$ halves of $\nu$ and $e$ were ever placed in the doublet.

**Electric charge ties it together.** With hypercharge $Y$ under $U(1)_Y$, the unbroken charge is $Q = T^3 + Y$. For the lepton doublet $Y=-\tfrac12$, giving $Q=0$ (neutrino) and $Q=-1$ (electron); the singlet $e_R$ has $T^3=0$, $Y=-1$, hence $Q=-1$ as well. The two electron chiralities share the same charge but live in different weak representations — which is exactly how electromagnetism stays parity-conserving while the weak force does not.

### Quantifying "maximal" violation

A generic parity-violating theory couples to the two chiralities with strengths $g_L, g_R$, and one defines the chiral asymmetry

$$
\mathcal{A} = \frac{g_L^2 - g_R^2}{g_L^2 + g_R^2}.
$$

A parity-conserving interaction (electromagnetism, QCD) has $g_L=g_R$, so $\mathcal{A}=0$. The charged-current weak interaction sets

$$
g_R = 0 \quad\Longrightarrow\quad \mathcal{A} = +1,
$$

a *complete* shut-off of one chirality — hence "maximal." The 1957 Wu experiment on polarized $^{60}$Co first measured the asymmetry; the 1958 Goldhaber experiment found the neutrino helicity to be $-1$ within errors. Modern bounds on any right-handed current sit at $g_R/g_L\lesssim10^{-2}$, consistent with the exact zero of the Standard Model.

## The Resolution: Massive Neutrinos and Parity

Now we can resolve the apparent paradox:

1. **Mass requires both chiralities.** The Dirac mass term is
$$
\mathcal{L}_{\text{mass}} = -m\bar\psi\psi = -m(\bar\psi_L\psi_R + \bar\psi_R\psi_L),
$$
which couples left to right. If neutrinos have mass, a right-chiral component $\nu_R$ **must** exist (a new sterile state, or the antineutrino itself in the Majorana case).

2. **Parity violation survives anyway.** The physical massive neutrino is a mixture of $\nu_L$ and $\nu_R$, but the weak force is oblivious to $\nu_R$. The $V-A$ vertex $\gamma^\mu(1-\gamma^5)$ projects out only the left-chiral piece; the right-chiral component ghosts through untouched.

## Giving the Neutrino Mass: Dirac vs Majorana

Before any Lagrangians, it helps to *feel* the Dirac–Majorana question physically. Both of the following are honest thought experiments that working physicists use, and both hinge on the one fact we have already established: for a **massive** neutrino, helicity is not Lorentz-invariant.

\tip{
**Thought experiment 1 — overtake the neutrino.** Produce a neutrino in the lab with helicity $-1$ (left-handed, the only kind the weak force makes). Because it is now massive it travels slower than light, so I can board a faster rocket and **overtake** it. In my frame its momentum has reversed but its spin has not: I see a $+1$ (right-handed) neutrino. The whole Dirac-vs-Majorana question is simply: *what is that right-handed thing I am now looking at?*

* If it is an inert, non-interacting state — a singlet that ignores the $W$ and $Z$ entirely — then a neutrino genuinely has **four** distinct states ($\nu_{L},\nu_R$ and their antiparticles). It is a **Dirac** particle, just like the electron.
* If instead that right-handed object behaves like an **antineutrino** (it can make an $e^+$), then flipping a neutrino's spin turned it into its own antiparticle. There are only **two** states, $\nu=\bar\nu$, and the neutrino is a **Majorana** particle.

For a *massless* neutrino nobody can overtake it, the spin can never be flipped, and the question has no meaning at all — which is exactly why it only became a real question once oscillations proved $m_\nu\neq0$.
}

\note{
**Thought experiment 2 — a neutrino in a room (after Serpico).** Imagine a massive $\nu_\mu$ sitting at rest in the middle of a room, spin pointing down. Accelerate it *upward* to high energy and let it strike the ceiling: it makes a $\mu^-$ through the ordinary charged current. Now accelerate the *same* particle *downward* and let it hit the floor. Two outcomes are conceivable. Either it produces a $\mu^+$ — in which case lepton number changed by two units ($\Delta L = -2$) and $\nu$ and $\bar\nu$ were secretly the same particle all along (**Majorana**) — or it produces *nothing at all*, the down-going state being a sterile right-handed neutrino that the weak force cannot touch (**Dirac**). One room, two floors, and the entire mystery of the neutrino's nature.
}

A closely related fact lives in a real detector. The antineutrinos from a reactor, $\bar\nu_e$, are *never* seen to drive the reaction $\bar\nu_e + {}^{37}\text{Cl}\to{}^{37}\text{Ar} + e^-$, even though the reaction itself exists in nature (it is how Davis caught *solar* neutrinos). The textbook reading is "$\nu_e$ and $\bar\nu_e$ are different particles." But notice the subtlety the chirality discussion forces on us: the $\bar\nu_e$ is right-handed and the reaction wants a left-handed neutrino, so the non-observation could *also* be a helicity suppression of order $(m_\nu/E)^2$ — exactly the loophole a Majorana neutrino would exploit. Distinguishing "truly different particles" from "same particle, wrong helicity" is precisely what neutrinoless double beta decay is built to do.

### Step 0 — why a mass term needs *both* chiralities

Everything below follows from one short calculation. A Dirac mass term is the Lorentz scalar

$$
\mathcal{L}_{\text{mass}} = -m\,\bar\psi\psi .
$$

Split the field into chiral halves, $\psi = \psi_L + \psi_R$ with $\psi_{L,R}=P_{L,R}\psi$, and expand:

$$
\bar\psi\psi = \bar\psi_L\psi_L + \bar\psi_L\psi_R + \bar\psi_R\psi_L + \bar\psi_R\psi_R .
$$

Now use the key identity $\bar\psi_L = (P_L\psi)^\dagger\gamma^0 = \psi^\dagger P_L\gamma^0 = \psi^\dagger\gamma^0 P_R = \bar\psi\,P_R$ (because $\gamma^5$ anticommutes with $\gamma^0$, so $P_L\gamma^0=\gamma^0P_R$). The "same-chirality" pieces then vanish through the orthogonality $P_RP_L=0$:

$$
\bar\psi_L\psi_L = \bar\psi\,P_R P_L\,\psi = 0, \qquad \bar\psi_R\psi_R = \bar\psi\,P_L P_R\,\psi = 0,
$$

leaving only the cross terms:

$$
\boxed{\ \bar\psi\psi = \bar\psi_L\psi_R + \bar\psi_R\psi_L\ }.
$$

A mass term is a **handshake between left and right**. A purely left-handed field cannot have a mass by itself — so to give the neutrino a mass we *must* supply a right-handed partner. There are exactly two ways to do it, and that is the whole Dirac-vs-Majorana question.

The two ways differ in whether they respect **lepton number**, so let us pin that idea down first.

\defn{
**Lepton number ($L$).** A simple bookkeeping charge carried by particles: $L=+1$ for the **leptons** — the electron $e^-$, muon $\mu^-$, tau $\tau^-$, and their neutrinos $\nu_e,\nu_\mu,\nu_\tau$ — and $L=-1$ for their **antiparticles** ($e^+,\,\bar\nu_e,\dots$); everything else (quarks, gluons, the photon, $W/Z$, Higgs) has $L=0$. Every interaction in the Standard Model **conserves** it: tally up (leptons $-$ antileptons) before and after a reaction and the total never changes. Neutron decay $n\to p + e^- + \bar\nu_e$ is a good check — it has $L=0$ on both sides, because the produced electron ($L=+1$) is always escorted by an electron *anti*neutrino ($L=-1$). A reaction with $\Delta L\neq0$ would therefore be a clean signal of physics **beyond** the Standard Model — and a *Majorana* neutrino mass is exactly such a process ($\Delta L=2$). That is precisely why the Dirac-vs-Majorana distinction below matters.
}

### Option A — Dirac mass (borrow a brand-new partner)

Introduce a new right-chiral field $\nu_R$ that is a complete **gauge singlet** (no isospin, hypercharge, or colour — a *sterile* state). The handshake $\bar\nu_L\nu_R$ is exactly what we need, but $\nu_L$ lives in the doublet $L=\binom{\nu_L}{e_L}$ ($Y=-\tfrac12$), so a bare $\bar\nu_L\nu_R$ is **not** gauge invariant. We fix that with the Higgs doublet, exactly as the electron mass is built. Using the conjugate Higgs $\tilde H = i\sigma^2 H^*$ (which carries $Y=-\tfrac12$), the combination $\bar L\,\tilde H\,\nu_R$ is a complete $SU(2)\times U(1)$ singlet:

$$
\mathcal{L}_{\text{Yuk}} = -\,y_\nu\,\bar L\,\tilde H\,\nu_R + \text{h.c.}
$$

When the Higgs gets its vacuum value $\langle H\rangle=\binom{0}{v/\sqrt2}$, then $\langle\tilde H\rangle=\binom{v/\sqrt2}{0}$, and the doublet contraction picks out the neutrino component,

$$
\bar L\,\langle\tilde H\rangle = (\bar\nu_L,\ \bar e_L)\binom{v/\sqrt2}{0} = \frac{v}{\sqrt2}\,\bar\nu_L ,
$$

so the Yukawa term collapses to a Dirac mass:

$$
\mathcal{L}_{\text{Yuk}} \;\longrightarrow\; -\,\frac{y_\nu v}{\sqrt2}\,\bar\nu_L\nu_R + \text{h.c.}
= -\,m_D\big(\bar\nu_L\nu_R + \bar\nu_R\nu_L\big), \qquad m_D = \frac{y_\nu v}{\sqrt2}.
$$

This conserves lepton number ($\nu$ and $\bar\nu$ stay distinct), but it has a **naturalness problem**. Inverting for the coupling with $v=246$ GeV and the observed scale $m_D\sim0.05$ eV,

$$
y_\nu = \frac{\sqrt2\,m_D}{v} \approx \frac{\sqrt2\,(0.05\ \text{eV})}{246\ \text{GeV}} \approx 2.9\times10^{-13}.
$$

Compared with the electron's Yukawa $y_e = \sqrt2\,m_e/v \approx 2.9\times10^{-6}$, this is a factor

$$
\frac{y_\nu}{y_e} \approx \frac{m_\nu}{m_e} \approx \frac{0.05\ \text{eV}}{0.511\ \text{MeV}} \approx 10^{-7}
$$

smaller — a number the theory does not explain.

### Option B — Majorana mass (be your own partner)

The neutrino is the **only electrically neutral elementary fermion**, and that opens a door closed to every charged particle. Recall charge conjugation, $\psi^c \equiv C\bar\psi^{\,T}$ with $C=i\gamma^2\gamma^0$. A crucial property is that it **flips chirality**,

$$
\big(P_L\psi\big)^c = P_R\,\psi^c ,
$$

so $\nu_L^c \equiv (\nu_L)^c$ transforms as a *right*-chiral field. We can therefore use it as the missing partner — **no new field at all**. The handshake of Step 0, with $\psi_R\to\nu_L^c$, is the **Majorana mass term**:

$$
\mathcal{L}_M = -\frac12\,m_M\,\overline{\nu_L^c}\,\nu_L + \text{h.c.}
$$

\tip{
**The cleanest way to see it — two-component language.** Strip away the four-component clutter and write a Dirac field as *two independent* left-handed Weyl spinors $\chi_1,\chi_2$. Its Lagrangian is then two kinetic terms tied together by a *single* mass:

$$
\mathcal{L}_{\text{Dirac}} = i\chi_1^\dagger\bar\sigma^\mu\partial_\mu\chi_1 + i\chi_2^\dagger\bar\sigma^\mu\partial_\mu\chi_2
\;-\; im\big(\chi_2^{T}\sigma^2\chi_1 - \chi_1^\dagger\sigma^2\chi_2^*\big).
$$

A **Majorana** fermion is simply what you get when the two halves are *the same field*, $\chi_2=\chi_1\equiv\chi$ — one Weyl spinor giving *itself* a mass:

$$
\mathcal{L}_{\text{Maj}} = i\chi^\dagger\bar\sigma^\mu\partial_\mu\chi
\;+\; \frac{im}{2}\big(\chi^{T}\sigma^2\chi - \chi^\dagger\sigma^2\chi^*\big),
\qquad\Longrightarrow\qquad
i\bar\sigma^\mu\partial_\mu\chi - i m\,\sigma^2\chi^* = 0 .
$$

That last equation of motion is the **Majorana equation**: the massless Weyl equation $i\bar\sigma^\mu\partial_\mu\chi=0$ plus a mass term built from $\chi$'s *own* conjugate $\sigma^2\chi^*$, which transforms as a right-handed spinor. So the "right-handed partner" demanded by Step 0 is supplied by the field itself — precisely the role $\nu_L^c$ plays in the four-component language above. Squaring it recovers Klein–Gordon, $(\partial^2+m^2)\chi=0$, confirming it really is a particle of mass $m$.
}

Two dramatic consequences follow directly. First, because the term mixes $\nu_L$ with its own conjugate, the mass eigenstate is the self-conjugate combination $\nu_M=\nu_L+\nu_L^c$ obeying $\nu_M^c=\nu_M$: the **neutrino is its own antiparticle** ($\nu=\bar\nu$). Second, $\nu_L$ carries lepton number $L=+1$ while $\nu_L^c$ carries $L=-1$, so the term changes lepton number by **two units** ($\Delta L=2$). The experimental smoking gun is **neutrinoless double beta decay** ($0\nu\beta\beta$), currently bounding the effective mass $\langle m_{\beta\beta}\rangle\lesssim 0.1$ eV.

There is a catch: $\nu_L$ is *not* a gauge singlet (it carries weak isospin and $Y=-\tfrac12$), so $m_M\,\overline{\nu_L^c}\nu_L$ is forbidden as a renormalizable term — its hypercharge does not cancel. It can only appear once two Higgs doublets soak up the quantum numbers, in the **dimension-five Weinberg operator**

$$
\mathcal{L}_5 = \frac{c}{\Lambda}\,\big(\bar L^c\,\tilde H^*\big)\big(\tilde H^\dagger L\big)
\;\xrightarrow{\ \langle H\rangle\ }\; m_M \sim \frac{c\,v^2}{\Lambda}.
$$

The lone power of $1/\Lambda$ marks it as non-renormalizable — a low-energy footprint of **new physics at the scale $\Lambda$**. And notice the bonus: a large $\Lambda$ makes $m_M$ *automatically* tiny.

### Best of both — the seesaw mechanism

That bonus is the heart of the **seesaw**. Keep the Dirac coupling $m_D$, *and* give the sterile $\nu_R$ its own Majorana mass $M$ — which is allowed with no Higgs at all, precisely because $\nu_R$ is a gauge singlet. Collecting $\nu_L$ and $\nu_R^c$ into a single two-component vector, the mass terms are

$$
\mathcal{L}_{\text{mass}} = -\frac12\,(\overline{\nu_L},\ \overline{\nu_R^c})\,\mathcal{M}\binom{\nu_L^c}{\nu_R} + \text{h.c.},
\qquad
\mathcal{M} = \begin{pmatrix} 0 & m_D \\ m_D & M \end{pmatrix}.
$$

The entries say everything: the top-left $0$ is the forbidden left-handed Majorana mass, the off-diagonal $m_D$ is the Higgs-generated Dirac mass, and the bottom-right $M$ is the allowed singlet Majorana mass. Diagonalize this symmetric $2\times2$ matrix through its characteristic equation,

$$
\det(\mathcal{M}-\lambda\,\mathbb{I}) = \lambda^2 - M\lambda - m_D^2 = 0
\quad\Longrightarrow\quad
\lambda_\pm = \frac{M \pm \sqrt{M^2 + 4m_D^2}}{2}.
$$

A quick check on the two roots: their **sum** is $\lambda_+ + \lambda_- = M$ and their **product** is $\lambda_+\lambda_- = -m_D^2$. Now take the physical hierarchy $M \gg m_D$ (the sterile partner is heavy) and expand the square root, $\sqrt{M^2+4m_D^2}\approx M\big(1+2m_D^2/M^2\big)$:

$$
m_{\text{heavy}} = \lambda_+ \approx M + \frac{m_D^2}{M}\approx M,
\qquad
m_{\text{light}} = |\lambda_-| \approx \frac{m_D^2}{M}.
$$

(The product relation gives the same thing instantly: $m_{\text{light}}\approx m_D^2/m_{\text{heavy}} = m_D^2/M$.) The observed neutrino is light **because** its partner is heavy — push one mass up and the other drops, hence "seesaw." Plugging in an electroweak-scale Dirac mass $m_D\sim100$ GeV and a grand-unification-scale $M\sim10^{15}$ GeV,

$$
m_{\text{light}} \sim \frac{(100\ \text{GeV})^2}{10^{15}\ \text{GeV}}
= \frac{10^{4}\ \text{GeV}^2}{10^{15}\ \text{GeV}}
= 10^{-11}\ \text{GeV} = 10^{-2}\ \text{eV},
$$

landing squarely in the observed range with no unnaturally small coupling. The neutrino's tiny mass becomes **evidence for physics at an enormous energy scale**.

\note{
**Either way, parity violation is untouched.** In both the Dirac and Majorana scenarios the charged current still couples only to $\nu_L$; the $\gamma^\mu(1-\gamma^5)$ vertex is unchanged. The Dirac-vs-Majorana question decides whether lepton number is conserved and whether $\nu=\bar\nu$ — but neither returns the right-chiral component to the weak force.
}

## Experimental Reality: From Weyl to Oscillations

It is worth stepping back to see how dramatically the picture has changed — and how the experiments pin down every number we have used.

### The 1964 picture: a massless, one-handed neutrino

In J. C. Taylor's 1964 review *The theory of weak interactions*, the neutrino was simply **assumed massless**, with only an upper bound $m_\nu < 200$ eV from the endpoint of tritium beta decay. A massless spin-$\tfrac12$ particle obeys the two-component **Weyl equation**

$$
(E + \vec\sigma\cdot\vec p)\,\phi = 0 \quad\Longrightarrow\quad E^2 = p^2,
$$

which forces spin and momentum to be **exactly antiparallel**: a single left circularly-polarised state. Weyl wrote this down in 1929 but it was *rejected* because it has no parity operation — and then **revived in 1957** (Lee–Yang, Landau, Salam) precisely *because* a parity-violating force wanted exactly such a one-handed object. Where the Dirac equation has four states, the massless neutrino has only two: a left-handed particle and a right-handed antiparticle.

\note{
The handedness was nailed down experimentally. The **Goldhaber experiment (1958)** measured the neutrino's helicity directly and found it to be $-1$ (left-handed) within errors — the cleanest confirmation that the weak current is purely left-handed. Taylor takes "$\nu$ and $\bar\nu$ are left- and right-handed" as an *assumption of fact*, fixed by the observed muon polarisation in $\pi^+\to\mu^+\nu$.
}

### The modern picture: neutrinos oscillate, so they have mass

That tidy massless story broke when neutrinos were seen to **oscillate** — to change flavour in flight — which is only possible if the mass eigenstates $\nu_1,\nu_2,\nu_3$ have *different* (hence nonzero) masses. Oscillation experiments do not measure the masses themselves, but the **mass-squared splittings** and the flavour mixing:

~~~
<div style="text-align:center; margin: 1.5rem 0;">
  <img class="cv-img math-diagram" src="/assets/Physics/blogs/neutrino_chirality/mass_spectrum.svg" alt="Neutrino mass-squared spectrum, normal and inverted ordering" style="max-width:100%; height:auto;">
</div>
~~~
*The two allowed orderings of the three neutrino mass states. Colours show each state's flavour content $|U_{\alpha i}|^2$. The solar splitting $\Delta m^2_{21}\approx7.5\times10^{-5}\,\text{eV}^2$ and the atmospheric splitting $|\Delta m^2_{31}|\approx2.5\times10^{-3}\,\text{eV}^2$ are measured; whether the ordering is "normal" or "inverted," and where the whole ladder sits in absolute mass, are still open.*

**How to read this diagram, piece by piece.** It packs four separate facts into one picture:

* **Each bar is a mass eigenstate.** The three horizontal bars are $\nu_1,\nu_2,\nu_3$ — the neutrinos of *definite mass* (as opposed to the *flavour* states $\nu_e,\nu_\mu,\nu_\tau$ that the weak force produces). Their height on the page is the mass-squared $m^2$. The vertical scale is **schematic, not linear** — drawn that way on purpose so the tiny solar gap is visible next to the $\sim33\times$ larger atmospheric gap.
* **The two gaps are the measured quantities.** Oscillations only ever see *differences* of $m^2$: the small gap $\Delta m^2_{21}=m_2^2-m_1^2\approx7.5\times10^{-5}\,\text{eV}^2$ (the "solar" splitting) and the large gap $|\Delta m^2_{31}|=|m_3^2-m_1^2|\approx2.5\times10^{-3}\,\text{eV}^2$ (the "atmospheric" splitting).
* **The colours are the flavour content.** The blue/green/red widths of each bar are $|U_{ei}|^2,\,|U_{\mu i}|^2,\,|U_{\tau i}|^2$ — the probabilities that, if you caught that mass state in a detector, it would interact as a $\nu_e$, $\nu_\mu$, or $\nu_\tau$ (the $U_{\alpha i}$ are the entries of the PMNS mixing matrix). Notice $\nu_1$ is mostly $\nu_e$ (blue), $\nu_3$ has almost *no* $\nu_e$ — its blue sliver is $|U_{e3}|^2\approx\sin^2\theta_{13}\approx0.02$ — and is split between $\nu_\mu$ and $\nu_\tau$, while $\nu_2$ is a near-even mix. This very mismatch between mass states and flavour states is *what makes oscillation happen*: a $\nu_e$ born in the Sun is a particular blend of $\nu_1,\nu_2,\nu_3$ that drifts out of step as it travels, re-emerging partly as $\nu_\mu$ or $\nu_\tau$.
* **"Normal" vs "inverted" is one yes/no question.** It is simply *where the odd-one-out state $\nu_3$ sits*: at the **top** (normal ordering, $\nu_3$ heaviest) or at the **bottom** (inverted, $\nu_3$ lightest). Experiments have not yet decided which. And because only the gaps are measured, the whole ladder can slide up or down — its absolute floor (the lightest mass) is unknown, pinned only from above by KATRIN ($m_\beta<0.45$ eV) and cosmology ($\sum m_\nu<0.12$ eV).

The smoking gun for all of this is the **disappearance** pattern: start with a beam of one flavour and the survival probability oscillates with $L/E$. For reactor antineutrinos,

$$
P(\bar\nu_e\to\bar\nu_e) = 1 - \sin^2 2\theta_{12}\,\sin^2\!\left(\frac{\Delta m^2_{21}\,L}{4E}\right),
$$

\note{
**A warning on the letter $L$.** Here $L$ is the **distance the neutrino travels** — the *baseline* — and $E$ is its energy; only the ratio $L/E$ matters, which is why the data is plotted against it. This $L$ has **nothing to do with lepton number** $L$ (the conserved $\pm1$ charge defined above), nor with the lepton doublet $L=\binom{\nu_L}{e_L}$ of the group-theory section. Particle physics reuses the same letter for all three; context tells them apart.
}

which the KamLAND experiment observed beautifully as a function of $L/E$:

~~~
<div style="text-align:center; margin: 1.5rem 0;">
  <img class="cv-img math-diagram" src="/assets/Physics/blogs/neutrino_chirality/oscillation.svg" alt="Reactor antineutrino survival probability versus L/E" style="max-width:100%; height:auto;">
</div>
~~~
*Reactor $\bar\nu_e$ survival probability (bold), with the idealised undamped oscillation shown faint for reference. The dips are direct evidence of interference between mass eigenstates of different mass — i.e. of neutrino mass itself. The dip depth fixes the mixing angle $\theta_{12}$ and the spacing fixes $\Delta m^2_{21}$, while the amplitude **damps toward the average at large $L/E$** once the finite energy resolution and spread of reactor baselines are folded in — exactly the shape KamLAND measured.*

Putting the experimental numbers in one place:

| Quantity | Value | Source |
|---|---|---|
| $\Delta m^2_{21}$ (solar) | $7.5\times10^{-5}\ \text{eV}^2$ | solar + KamLAND |
| $|\Delta m^2_{31}|$ (atmospheric) | $2.5\times10^{-3}\ \text{eV}^2$ | atmospheric + accelerator |
| lightest mass (from splittings) | $m \gtrsim 0.05\ \text{eV}$ | guaranteed by $\sqrt{\Delta m^2_{31}}$ |
| direct lab bound | $m_\beta < 0.45\ \text{eV}$ | KATRIN (tritium endpoint) |
| cosmological bound | $\textstyle\sum m_\nu < 0.12\ \text{eV}$ | CMB + large-scale structure |

The upshot is the whole reason this post exists: a mass of even $0.05$ eV means the right-chiral component that Taylor's massless neutrino *did not have* **must now exist** — yet, as we saw, the weak force still refuses to talk to it, and parity violation survives untouched.

## Conclusion

Before neutrino oscillations, physicists assumed parity violation happened because right-handed neutrinos simply did not exist — set $m=0$ and the right-chiral state vanishes from the universe.

Today we know the right-chiral component *does* exist, allowing the neutrino to have mass. Yet parity violation is preserved perfectly, because it is a property of the **gauge interaction** (the $W$ and $Z$ bosons), not of the particle content. The two opening questions now have clean numerical answers:

* **Why are chirality and helicity still "the same"?** Because their disagreement scales as $(m/2E)^2$, ranging from $\sim10^{-14}$ down to $\sim10^{-22}$ for real neutrinos — buried far below detector sensitivity, even though the underlying operators are genuinely different.
* **How does parity violation survive massive neutrinos?** Because it never depended on $\nu_R$ being absent. It is encoded in the $(1-\gamma^5)$ vertex with $\mathcal{A}=+1$ ($g_R=0$). The right-chiral piece exists, propagates, and supplies the mass — but it is simply never offered to the $W$. Parity violation is a statement about *who the weak force talks to*, not about *which particles exist*.

## Sources and further reading

The historical framing and the massless two-component neutrino follow J. C. Taylor, *The theory of weak interactions* (1964). The natural-language arguments above — the pion-decay suppression, the $^{60}$Co distribution, Pauli's "desperate remedy," and the room and overtaking thought experiments for Dirac vs Majorana — are drawn from two excellent pedagogical lecture sets, which are the right next step if you want the full story:

* **P. D. Serpico**, *A gentle introduction to neutrino physics* (GraSPA lectures, 2018) — the source of the room Gedanken experiment, the Fermi-theory derivation of $G$, and a wonderfully readable treatment of oscillations and matter (MSW) effects.
* **P. Lipari**, *Introduction to neutrino physics* (CERN Yellow Report lectures) — the source of the $\pi\to e\nu$ vs $\pi\to\mu\nu$ chirality argument, the two-component Weyl/Majorana mass formalism, and the seesaw in $2\times2$ matrix form.
* **Foundational experiments:** Lee–Yang (1956) on the untested status of parity; Wu *et al.* (1957) on $^{60}$Co; Goldhaber, Grodzins & Sunyar (1958) on the neutrino helicity; Reines & Cowan (1956) on first detection.

~~~
<button onclick="window.history.back()">Go Back</button>
~~~


{{comments}}
