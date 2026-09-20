+++
title = "Renormalisation Group IV: Fixed Points and Universality"
hascode = true
date = Date(2026, 9, 19)
rss = "Part 4 of the renormalisation group course. What a critical point looks like, why it is a fixed point of the RG, relevant and irrelevant directions as a ball on a mountain ridge, critical exponents from one number, universality as a river basin and the exact 2D critical temperature from a mirror symmetry. Then the exponents are measured properly, by finite-size scaling of Wolff cluster simulations: the Binder crossing gives K_c to 0.02 per cent where the pencil method is 31 per cent off. With a live 2D Ising simulation you can coarse-grain."
rss_title = "Renormalisation Group IV: Fixed Points and Universality"
rss_pubdate = Date(2026, 9, 19)

tags = ["physics", "statistical-mechanics", "renormalization", "ising", "critical-phenomena", "course"]
+++

\newcommand{\dd}{\mathrm d}

~~~
<link rel="stylesheet" href="/assets/Physics/courses/RG/rg.css">
<script defer src="/assets/Physics/courses/RG/rg.js"></script>
~~~

\toc

# Renormalisation Group IV: Fixed Points and Universality

> *Part 4 of eight. previous: [Block spins](/Pages/Physics/courses/RG/03_block_spins/) · [Course home](/Pages/Physics/courses/RG/Main_page/) · [Glossary](/Pages/Physics/courses/RG/glossary/) · next: [Wilson's shells](/Pages/Physics/courses/RG/05_wilson/)*

A line of spins never becomes a magnet. A flat sheet of spins does: below a critical temperature $T_c$ most of them line up. Right at $T_c$ something strange happens and this part is about what.

## What a critical point looks like

~~~
<div class="mfig" style="--w:560px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/ising_snapshots.svg" alt="2D Ising configurations above, at and below the critical temperature">
  <p>Three snapshots of a simulated 256×256 Ising magnet, with how often neighbouring spins agree printed underneath. Hot: small islands, short-range order. Cold: one colour nearly everywhere. Critical: islands inside lakes inside islands, at every size up to the whole box, with the agreement sitting at the exact value \(1/\sqrt2=0.707\).</p>
</div>
~~~

At $T_c$ there is no typical size of island. There are small ones, medium ones and huge ones, all at once. In the language of Part 3, the correlation length is infinite.

\analogy{
You can actually see this in a real fluid. Heat a sealed tube of carbon dioxide towards its liquid-gas critical point and the clear fluid suddenly turns milky. This is called **critical opalescence**. Tong explains it: the regions of slightly-higher and slightly-lower density grow bigger and bigger, until they are as large as the wavelength of light and then they scatter it. You are looking at a diverging correlation length with your own eyes.
}

Near $T_c$ the correlation length follows a power law,

$$ \xi \propto |T-T_c|^{-\nu}, $$

and other quantities do too. The heat capacity goes like $|T-T_c|^{-\alpha}$, the magnetisation below $T_c$ like $(T_c-T)^{\beta}$ and the magnetic susceptibility like $|T-T_c|^{-\gamma}$. (The **susceptibility** $\chi=\partial m/\partial h$ is just how much magnetisation you get for a small applied field: near $T_c$ a feather touch produces a big response, which is why it diverges.) The numbers $\nu,\alpha,\beta,\gamma$ are called **critical exponents**. Before the RG, two facts about them were a complete mystery:

1. They are usually not simple fractions. For a 3D magnet, $\nu=0.6300$ and $\beta=0.3265$. Nothing in the energy formula looks anything like these numbers. Tong suggests thinking of them as new mathematical constants, like $\pi$ or $e$, only more subtle.
2. They are **universal**. A magnet, the liquid-gas critical point of water and a metal alloy sorting itself onto its lattice all have *the same* exponents, even though the atoms involved have nothing in common.

Both facts come from one picture.

## Why the critical point is a fixed point

Recall the rule from Part 3: one coarse-graining step with scale factor $b$ changes the couplings, $K\to K'$ and divides the correlation length (in lattice units) by $b$. At $T_c$, $\xi=\infty$ and $\infty/b$ is still $\infty$. So **the critical point flows to a point with infinite correlation length** and that has to be a fixed point $K^*$. It can't be $K=0$ or $K=\infty$, where $\xi=0$. It's a genuinely new fixed point.

You can see this directly by coarse-graining the snapshots:

~~~
<div class="mfig" style="--w:540px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/self_similar.svg" alt="Three rounds of 2x2 majority blocking above, at and below T_c">
  <p>Three rounds of 2×2 majority voting, with the neighbour agreement printed under each panel (averaged over 16 independent simulations). Hot (top row): the picture flows towards noise, the \(K=0\) fixed point, with the number falling from 0.58 to 0.23. Cold (bottom row): it flows to one colour, the \(K=\infty\) fixed point, with the number climbing from 0.82 to 0.98. At \(T_c\) (middle row) the number stays near \(1/\sqrt2=0.707\), the exact Ising value: that is the new fixed point. For the critical row the picture shown is a sample with a small net magnetisation, so both colours are visible; the numbers come from the unbiased set of samples.</p>
</div>
~~~

\note{
**How to read this figure.** Each little square is a snapshot of a simulated magnet: a grid of spins, each pointing up or down, shown as the two colours.

- **Going right** is one coarse-graining step each time. Every 2×2 block of spins is replaced by one spin pointing the way the majority of the four point. So one pixel stands for 1 spin in the first column, then 4, then 16, then 64. Moving right is stepping back from the magnet: you see it from 2, 4, then 8 times further away.
- **Each row** is one temperature, held fixed. The row is the RG flow: it shows what that magnet turns into when you keep zooming out.
- **The number under each panel** is how often neighbouring spins agree, averaged over 16 independent simulations. It's the flow written as a number instead of a picture. Hot rows fall towards 0 (no agreement, pure noise), cold rows climb towards 1 (everything agrees) and the critical row barely moves. For the exact 2D Ising model at $T_c$ this number is $1/\sqrt2=0.707$, which is what the simulation gives.

The grid is finite, so by the last column it is down to 32×32, small enough that one colour can win by luck. Each picture is also a single snapshot, so "looks the same" is a statement about the *kind* of picture, not the exact pattern.
}

\analogy{
Tong has a nice way to say what happens at $T_c$. When you zoom out, the small islands shrink away to nothing, but new islands come into view from larger scales to replace them. The picture changes in detail but stays the same *kind* of picture. It's like looking at a fern, where every leaf is made of smaller leaves shaped like the whole fern, or at an alpona drawn at a Bengali doorstep, where the same motif repeats at every size.
}

Now try it live. This simulation runs in your browser:

~~~
<div id="rg-ising" style="--w:720px"></div>
~~~

Set $T/T_c=1.05$ and watch. The first panel still looks roughly critical, but by the third blocking the noise has won. Move to $0.97$ and the opposite happens. The closer you are to $T_c$, the more blocking steps it takes before you can tell which way the flow is going. That delay is the long correlation length, seen through the RG.

## Linearising the flow: relevant and irrelevant

Near a fixed point, small deviations grow or shrink by the same factor at every step. With one coupling, write $K=K^*+\delta K$ and expand the map to first order:

$$ \delta K' = R'(K^*)\,\delta K \;\equiv\; b^{\,y}\,\delta K. $$

(The slope $R'(K^*)$ is written as $b^{y}$ because that is the only form that survives doing two steps in a row: two steps of size $b$ must equal one step of size $b^2$ and $b^yb^y=(b^2)^y$. Note this $b$ is the zoom factor, nothing to do with the cutoff $\Lambda$ of Parts 1 and 2.)

There are three cases:

\defn{
- $y>0$: $\delta K$ **grows** step by step. The coupling is **relevant**: a tiny push away from the fixed point becomes huge at large scales.
- $y<0$: $\delta K$ **shrinks**. The coupling is **irrelevant**: its effect fades away at large scales.
- $y=0$: **marginal**. The first-order analysis can't decide and you need the next order. This case is the drama of Parts 6 and 7.
}

\analogy{
Picture a ball sitting exactly on a saddle point of a mountain pass. Along the ridge, the ground slopes *down towards* the saddle, so if you nudge the ball along the ridge it rolls back: that's an irrelevant direction. Across the ridge, the ground falls away steeply on both sides, so a tiny nudge sends the ball rolling off into one valley or the other: that's a relevant direction. The two valleys are the ordered and disordered phases.
}

\puja{
Being single during Puja is a textbook *relevant* perturbation. On Panchami it's tiny and nobody notices. Every day it grows until by Dashami it's the only thing your relatives want to talk about. Relevant couplings always win at long distances. Here that means the family WhatsApp group.
}

Temperature has to be relevant at a critical point, because being slightly off $T_c$ is exactly what makes the system flow away. Write $t=(T-T_c)/T_c$ and call its exponent $y_t$. Since coarse-graining divides lengths by $b$ and multiplies $t$ by $b^{y_t}$,

$$ \xi(t) = b\,\xi(b^{y_t}t). $$

This works for any $b$, so choose $b=|t|^{-1/y_t}$, which makes the argument on the right equal to $\pm1$:

$$ \xi(t) = |t|^{-1/y_t}\,\xi(\pm1) \quad\Longrightarrow\quad \boxed{\;\nu = \frac1{y_t}.\;} $$

**A critical exponent is one over the growth rate of the flow near the fixed point.** It belongs to the fixed point, not to the atoms you started with. That's why $\nu$ doesn't have to be a nice fraction: it's whatever the slope of a complicated map happens to be.

\note{
**Reading alongside.** [Tong's notes](https://davidtong.org/teaching/statistical-field-theory/), §3.1 and §3.2, cover this from the field theory side: operators as "eigenstates" of the RG, each with its own scaling. Das, §14.2, lists the critical exponents and the relations between them.
}

## Many couplings and universality

Real coarse-graining creates new couplings: bonds between next-nearest neighbours, four-spin terms and so on. So the RG really acts on an enormous space of couplings $\{K_1,K_2,\dots\}$, which Tong calls "theory space". Near a fixed point you linearise just as before. Each independent direction comes with its own $b^{y_i}$.

The crucial fact is that **only a few directions are relevant**. For the Ising fixed point there are exactly two: temperature $t$ and magnetic field $h$. The infinitely many others are all irrelevant.

~~~
<div class="mfig" style="--w:520px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/fixed_point_flows.svg" alt="Flow near a fixed point with one relevant and one irrelevant direction">
  <p>The flow near a fixed point, with one relevant coupling across and one irrelevant one up. The <b>critical surface</b> (blue line) is every starting theory that flows <i>into</i> the fixed point. Start slightly off it and you first head towards the fixed point, then peel away to one phase or the other.</p>
</div>
~~~

The irrelevant directions make up the **critical surface**: the set of all microscopic systems that are exactly critical. A real magnet, with its messy crystal structure, sits somewhere on this surface when it's tuned to $T_c$. So does a liquid at its critical point, once you match up "density" with "magnetisation". Under the flow they all slide into the *same* fixed point and forget everything about where they started except the relevant directions.

~~~
<div class="mfig" style="--w:520px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/universality.svg" alt="Different microscopic systems flowing to one fixed point">
  <p>Four very different systems flowing to one fixed point. The exponents belong to the destination, so everything that arrives there shares them.</p>
</div>
~~~

\analogy{
Think of the Ganga basin. Rain that falls on a Himalayan slope, a field in Bihar or a rooftop in Kolkata ends up in the same place, the Bay of Bengal. Tong calls the critical surface exactly that: the **basin of attraction** of the fixed point. What decides the basin isn't the details. It's a few coarse facts: the dimension of space, the symmetry (up/down here) and whether forces are short-ranged.
}

\otaku{
*Fullmetal Alchemist* fans know the law of equivalent exchange: to gain something, something of equal value must be lost. Coarse-graining is the RG version. You give up every microscopic detail and in return you get something just as valuable: the universal exponents, the same for magnets and fluids. The alchemy only works at a fixed point, though.
}

This is **universality**. Two systems are in the same **universality class** when they flow to the same fixed point. Measurements on fluids such as xenon and sulfur hexafluoride near their critical points give $\beta\approx0.32$ to $0.33$, matching the 3D Ising value of $0.3265$.

It also explains why reaching a critical point needs exactly two knobs, temperature and field: you need one knob per relevant direction. As Tong points out, an experimenter can easily turn the thermostat, but has no knob for the $\phi^4$ strength or the next-neighbour bonds. Luckily those are irrelevant, so nobody needs to tune them.

## All the exponents from two numbers

Here's a simple way to see why exponents are linked. Near $T_c$, the spins inside one correlation length move together, like one coherent block (Tong's picture). In a box of size $L$ there are $(L/\xi)^d$ such blocks and each one carries roughly the same free energy. So the free energy per site scales like $\xi^{-d}\propto|t|^{d\nu}$. Its second derivative, the heat capacity, then goes like $|t|^{d\nu-2}$, which gives $\alpha=2-d\nu$.

To make this exact, follow the free energy through one RG step. After the step, each new site stands for a block of $b^d$ old sites and the total free energy doesn't change (coarse-graining keeps the physics). So the free energy *per site* before the step is $b^{-d}$ times the free energy per site after it and after the step $t$ and $h$ have become $b^{y_t}t$ and $b^{y_h}h$. That gives

$$ f(t,h) = b^{-d}\,f(b^{y_t}t,\ b^{y_h}h), $$

and taking derivatives gives every exponent in terms of $y_t$ and $y_h$ (exercise 4.2 derives $\beta$):

$$ \nu=\frac1{y_t},\quad \alpha = 2-\frac{d}{y_t},\quad \beta=\frac{d-y_h}{y_t},\quad \gamma=\frac{2y_h-d}{y_t},\quad \delta=\frac{y_h}{d-y_h},\quad \eta=d+2-2y_h. $$

Six exponents from two numbers means four relations between them and they hold automatically:

$$ \alpha+2\beta+\gamma=2\ \ (\text{Rushbrooke}),\qquad \gamma=\beta(\delta-1)\ \ (\text{Widom}),\qquad \gamma=\nu(2-\eta)\ \ (\text{Fisher}),\qquad d\nu=2-\alpha\ \ (\text{Josephson}). $$

Experimenters found these relations before anyone could explain them. Checking them in Wolfram:

```mathematica
al = 2 - d/yt; be = (d - yh)/yt; ga = (2 yh - d)/yt;
de = yh/(d - yh); nu = 1/yt; eta = d + 2 - 2 yh;
Simplify[{al + 2 be + ga - 2, ga - be (de - 1), ga - nu (2 - eta), d nu - (2 - al)}]
(* {0, 0, 0, 0} *)
{nu, al, be, ga, de, eta} /. {d -> 2, yt -> 1, yh -> 15/8}
(* {1, 0, 1/8, 7/4, 15, 1/4}  : Onsager's exact 2D Ising exponents *)
```

For the 2D Ising model, Onsager's exact solution corresponds to $y_t=1$ and $y_h=15/8$.

## Finding the 2D critical temperature

### A mirror trick gives it exactly

Das (§15.4) shows a beautiful argument due to Kramers and Wannier. The 2D Ising partition function at a hot coupling $K$ can be rewritten *exactly* as the partition function at a cold coupling $K^*$, where

$$ \sinh 2K\,\sinh 2K^* = 1. $$

\analogy{
It's like a mirror placed along the temperature axis. Every hot temperature has a cold twin with the same physics, reflected. If the magnet has exactly one transition, it can't be anywhere except on the mirror itself, because otherwise its reflection would be a second transition.
}

On the mirror, $K=K^*$, so $\sinh^2 2K_c=1$, which gives $K_c=\tfrac12\ln(1+\sqrt2)=0.4407$. (Wolfram: `Solve[Sinh[2 K]^2 == 1 && K > 0, K, Reals]` gives $\tfrac12\operatorname{arsinh}1 = 0.440687$.) This is the exact answer, but the trick only tells you *where* the transition is, not its exponents.

### A rough RG recursion gets the structure

Can we get the exponents with a pencil? Not exactly, because majority voting in 2D creates infinitely many couplings. The simplest approximation that keeps just one coupling is the **Migdal-Kadanoff** scheme. On the square lattice with $b=2$, first move half the bonds onto their neighbours, which leaves one-dimensional chains with doubled coupling $2K$. Then decimate those chains exactly as in Part 3. The result is

$$ K' = \operatorname{artanh}\!\big(\tanh^2 2K\big) = \tfrac12\ln\cosh 4K. $$

Unlike the 1D map, this one crosses the diagonal:

~~~
<div class="mfig" style="--w:440px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/mk_cobweb.svg" alt="Migdal-Kadanoff recursion with an unstable fixed point">
  <p>Start a tiny step to either side of \(K^*\) and the steps run away in opposite directions, to the hot fixed point or the cold one. So \(K^*\) is a fixed point where temperature is relevant: a phase transition.</p>
</div>
~~~

Solving numerically (with Wolfram's `FindRoot` and checked in Python and JavaScript): $K^*=0.3047$, $R'(K^*)=1.6786$, so $y_t=\log_2 1.6786=0.7472$ and $\nu=1.338$.

Compare with the exact answers: $K_c=0.4407$ and $\nu=1$. The rough scheme gets the *structure* right (there is a fixed point and temperature is relevant there) but the numbers are off by about 30%.

You could live with 30%. Finding out about it is the harder part, because bond moving is not the first term of anything. There is no second term to compute, no small quantity being expanded, so no way to put an error bar on the answer without already knowing it. A number with no error bar is still a guess, however confident it looks.

There are better ways to get the numbers. One is to solve the model exactly, which Onsager managed in 1944. That works for this model alone. Another is Wilson's momentum-space method, which has a genuinely small quantity to expand in: that is Parts 5 and 6. The third is to measure the exponents by simulating the model, which is where the rest of this part goes, because it runs on exactly the scaling laws built above.

## Measuring the exponents

### The trick: at $T_c$, the box itself is the ruler

Away from $T_c$ the correlation length $\xi$ is finite, so a simulation in a box of side $L$ behaves like the infinite system as long as $L\gg\xi$. At $T_c$ that breaks down, because $\xi$ is infinite. There is then nothing left to set a scale except $L$ itself, so every quantity has to be a pure power of $L$. That is the scaling hypothesis of this part with the rescaling factor $b$ replaced by the box size, so the powers that show up are the same exponents.

\analogy{
Photograph a crowd at the maidan with no buildings in the shot. Nothing in the picture tells you whether it covers ten metres or a hundred, so the only length in the photograph is the frame itself. At $T_c$ the magnet is that crowd. Every measurement you make is a statement about the frame.
}

This gives three measurements, from the same simulation.

**1. Where $K_c$ is: the Binder cumulant.** Build the dimensionless ratio

$$ U=1-\frac{\langle m^4\rangle}{3\,\langle m^2\rangle^2}. $$

\defn{
**Why this particular combination?** $\langle m^2\rangle$ and $\langle m^4\rangle$ each depend on the box size, but the ratio $\langle m^4\rangle/\langle m^2\rangle^2$ has the units cancel out. It is not a size, it is a *shape*: it measures how the magnetisation is spread out, not how big it is. Deep in the hot phase $m$ wanders around zero like a Gaussian, where $\langle m^4\rangle=3\langle m^2\rangle^2$ exactly, so $U\to0$. Deep in the cold phase $m$ sits at $\pm m_0$ with almost no spread, so $\langle m^4\rangle=\langle m^2\rangle^2$ and $U\to\tfrac23$. In between it has to climb from one to the other.

At $K_c$ there is no scale left, so a shape cannot depend on the box size. Every $L$ must give the same $U$ there. Plot $U$ against $K$ for several box sizes: away from $K_c$ the curves separate, at $K_c$ they must meet. The meeting point locates $K_c$ with no fitting at all. It was Binder's idea in 1981.
}

**2. How fast the flow runs: the slope at the crossing.** Off the critical point, $U$ depends on $L$ only through the combination $L/\xi\sim L\,|t|^{\nu}$, so $U$ is a function of $L^{1/\nu}t$. Differentiating in $t$ at the crossing brings down one factor of $L^{1/\nu}$:

$$ \left.\frac{\dd U}{\dd K}\right|_{K_c}\propto L^{1/\nu}. $$

So the slopes of those curves, plotted against $L$ on log axes, give $1/\nu$ as a straight line. No approximation has been made anywhere.

**3. The other exponents.** The same argument on the susceptibility and the magnetisation at $K_c$:

$$ \chi\big|_{K_c}\propto L^{\gamma/\nu},\qquad \langle|m|\rangle\big|_{K_c}\propto L^{-\beta/\nu}. $$

### What comes out

The simulations use the Wolff cluster algorithm, because near $T_c$ flipping one spin at a time is hopelessly slow. Seven box sizes from $L=8$ to $L=64$, thirteen temperatures around $K_c$, eight independent chains at each point with 30,000 measurements per chain. That is a few core-hours on a shared machine, small enough to repeat on a laptop.

~~~
<figure>
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/ising_fss.svg" alt="Binder cumulant crossing, slope scaling and susceptibility scaling for the 2D Ising model">
  <p>(a) The Binder cumulant for seven box sizes. Away from \(K_c\) the curves fan out, at \(K_c\) they pass through one point, which is the dashed line at the exact answer. Nothing was fitted to put it there. (b) The slope of those curves at \(K_c\), against \(L\). The straight line has gradient \(1/\nu\). (c) The susceptibility at \(K_c\), whose gradient is \(\gamma/\nu\).</p>
</figure>
~~~

The crossings march towards the exact value as the boxes grow:

| pair $(L,2L)$ | crossing $K_\times$ |
|---|---|
| $(8,16)$ | 0.44182 |
| $(12,24)$ | 0.44111 |
| $(16,32)$ | 0.44104 |
| $(24,48)$ | 0.44083 |
| $(32,64)$ | 0.44076 |
| exact | **0.440687** |

Collecting everything, side by side with the pencil method:

| | Migdal-Kadanoff | measured here | exact |
|---|---|---|---|
| $K_c$ | 0.3047, off by $-31\%$ | $0.44076\pm0.00008$, off by $+0.02\%$ | 0.440687 |
| $\nu$ | 1.338, off by $+34\%$ | $0.96\pm0.04$, off by $-4\%$ | 1 |
| $\gamma/\nu$ | not available | $1.763\pm0.005$ | 1.75 |
| $\beta/\nu$ | not available | $0.128\pm0.002$ | 0.125 |
| $U$ at $K_c$ | not available | $0.6101\pm0.0006$ | 0.61069 |

\note{
**About those error bars.** The $\pm$ on $K_c$, $\gamma/\nu$ and $\beta/\nu$ comes from resampling the eight independent chains at every point. For $\nu$ that recipe gives $\pm0.011$, which is too optimistic: fitting the slope pair by pair instead gives values scattered between $0.93$ and $1.04$, so a couple of per cent is the honest uncertainty and that is what the table quotes. The leftover is not noise but the finite boxes themselves, whose corrections die away only as a power of $L$. Bigger boxes shrink it, with no change to the method.

None of that is available to the one-coupling scheme, which has no chains to resample and no box size to grow, so its 30% stays where it is.
}

\analogy{
Migdal-Kadanoff is the shopkeeper who weighs your rice by lifting the bag and saying "about two kilos". Finite-size scaling is a balance: slower, but you can read the scatter off the pointer and buy a better balance tomorrow. Both of them are useful and only one of them can be checked.
}

\puja{
The Binder crossing is the moment in the evening when every pandal, big or small, feels equally crowded. Before it the small ones are still comfortable. After it only the big ones are still moving. Notice what the crossing actually measures: a shape, not a size, so it does not care how large your group is, only how tightly it is coupled. A couple moves as one lump at every scale, which is why they look the same in a lane pandal as in Deshapriya Park. Our single readers move as one lump too, so you are exactly as universal. You also clear the barricade in half the time.
}

Notice what has *not* happened here. Nobody worked out a recursion for $K$, nobody had to guess which couplings to keep, nobody moved a bond. The scaling laws of this part were assumed, then the exponents in them were measured. That the answers come out at the exact values is a test of the RG picture itself, not of any particular approximation scheme.

That said, measurement alone does not explain *why* a magnet and a boiling liquid share these numbers. For that we still need a fixed point we can actually calculate at, which is what Wilson's momentum-space method gives and what we build next.

## Exercises

\prob{
**4.1.** For the Migdal-Kadanoff map $R(K)=\tfrac12\ln\cosh4K$, show that $R'(K)=2\tanh 4K$, so $y_t = 1+\log_2\tanh(4K^*)$. With $K^*=0.304689$, evaluate $y_t$.
}
\soln{
$R'(K)=\tfrac12\cdot\frac{4\sinh4K}{\cosh4K}=2\tanh4K$. Then $y_t=\log_2R'(K^*)=1+\log_2\tanh(4K^*)$. With $4K^*=1.218756$, $\tanh(1.218756)=0.839287$, so $y_t=1+\log_2(0.839287)=1-0.25277=0.74724$ and $\nu=1/y_t=1.338$, as quoted above.
}

\prob{
**4.2.** Starting from $f(t,h)=b^{-d}f(b^{y_t}t,b^{y_h}h)$, derive $\beta=(d-y_h)/y_t$. (Hint: the magnetisation is $m=-\partial f/\partial h$ at $h=0$. Then choose $b$ the same way as in the derivation of $\nu$.)
}
\soln{
Differentiate both sides with respect to $h$: $m(t,h)=b^{-d+y_h}m(b^{y_t}t,b^{y_h}h)$. Set $h=0$ and choose $b=|t|^{-1/y_t}$: $m(t,0)=|t|^{(d-y_h)/y_t}m(\pm1,0)$. Below $T_c$, $m\propto|t|^\beta$, so $\beta=(d-y_h)/y_t$. For 2D Ising, $(2-15/8)/1=1/8$.
}

\prob{
**4.3.** A liquid-gas critical point is reached by tuning temperature *and* pressure. Why exactly two knobs? What plays the role of the magnetic field?
}
\soln{
The Ising fixed point has two relevant directions, so you need to tune two things to land on the critical surface. For a fluid, "magnetisation" is $\rho-\rho_c$, the difference between the density and its critical value. The "field" is how far the pressure (or chemical potential) is from the line where liquid and gas coexist. Tuning pressure onto that line sets $h=0$ and tuning temperature to $T_c$ sets $t=0$. Liquid and gas aren't perfectly symmetric the way up and down spins are, but that difference is an irrelevant coupling, which is why a fluid still ends up in the Ising class.
}

\prob{
**4.4.** Check the Kramers-Wannier mirror: show that $\sinh 2K\sinh 2K^*=1$ maps small $K$ (hot) to large $K^*$ (cold). Then show that $K_c=\tfrac12\ln(1+\sqrt2)$ satisfies $\sinh 2K_c=1$.
}
\soln{
If $K\to0$ then $\sinh 2K\to0$, so $\sinh2K^*=1/\sinh2K\to\infty$ and $K^*\to\infty$. Hot maps to cold and the other way round. For $K_c$: $e^{2K_c}=1+\sqrt2$ and $e^{-2K_c}=1/(1+\sqrt2)=\sqrt2-1$, so $\sinh2K_c=\tfrac12\big[(1+\sqrt2)-(\sqrt2-1)\big]=1$.
}

\prob{
**4.5.** In the widget, find the temperature at which the third blocked panel stops looking like the original. Why does this temperature move closer to $T_c$ when you add more blocking steps?
}
\soln{
After $n$ steps you are looking at scale $2^n$. The blocked picture looks critical as long as $2^n$ is smaller than the correlation length $\xi\propto|t|^{-\nu}$, because below $\xi$ the system can't "tell" it's off $T_c$. So you notice the difference once $|t|\sim2^{-n/\nu}=2^{-n}$ in 2D, where $\nu=1$. Each extra blocking step halves the window around $T_c$ where the picture still looks critical. On a 128×128 box the window can't get smaller than about $|t|\sim1/128$, which is why the widget looks critical over a narrow band rather than at one single point.
}


\prob{
**4.6.** *The two ends of the Binder cumulant.* Take $U=1-\langle m^4\rangle/3\langle m^2\rangle^2$. (a) Deep in the hot phase the magnetisation of a large box is a sum of many nearly independent pieces, so $m$ is Gaussian about zero. Using $\langle m^4\rangle=3\langle m^2\rangle^2$ for a Gaussian, find $U$. (b) Deep in the cold phase $m$ sits at $+m_0$ or $-m_0$ with negligible spread. Find $U$ there. (c) Explain in one sentence why a quantity with these two limits must cross the same value for every box size at $K_c$.
}
\soln{
(a) For a Gaussian with zero mean, $\langle m^4\rangle=3\langle m^2\rangle^2$ exactly, so $U=1-1=0$.

(b) With $m=\pm m_0$ and no spread, $\langle m^2\rangle=m_0^2$ and $\langle m^4\rangle=m_0^4$, so $U=1-\tfrac13=\tfrac23$.

(c) $U$ is a ratio built so that the units of $m$ cancel, so it is a shape rather than a size. At $K_c$ the correlation length is infinite, so the only length in the problem is $L$ itself, so a shape has nothing left to depend on. Every box size must give the same number there, which is why the curves meet. (The number is not universal across *all* models, since it depends on the shape of the box and the boundary conditions, but for a square with periodic edges in this universality class it is $0.61069$, which the simulation above returns as $0.6101\pm0.0006$.)
}

\coursenav{/Pages/Physics/courses/RG/03_block_spins/}{Part 3: Block spins}{/Pages/Physics/courses/RG/05_wilson/}{Part 5: Wilson's shells}

{{comments}}
