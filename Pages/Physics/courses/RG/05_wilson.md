+++
title = "Renormalisation Group V: Wilson's Momentum Shells"
hascode = true
date = Date(2026, 9, 19)
rss = "Part 5 of the renormalisation group course. From spins to a smooth field, Wilson's three-step RG in momentum space explained as filtering music and zooming out, the free-field (Gaussian) fixed point, power counting and why four dimensions is special."
rss_title = "Renormalisation Group V: Wilson's Momentum Shells"
rss_pubdate = Date(2026, 9, 19)

tags = ["physics", "qft", "renormalization", "statistical-mechanics", "course"]
+++

\newcommand{\dd}{\mathrm d}

\toc

# Renormalisation Group V: Wilson's Momentum Shells

> *Part 5 of eight. previous: [Fixed points and universality](/Pages/Physics/courses/RG/04_fixed_points/) · [Course home](/Pages/Physics/courses/RG/Main_page/) · [Glossary](/Pages/Physics/courses/RG/glossary/) · next: [The Wilson-Fisher point](/Pages/Physics/courses/RG/06_wilson_fisher/)*

Coarse-graining in real space (voting in blocks) gave us the right ideas but rough numbers. Wilson's move was to coarse-grain in *momentum* space instead. There, "throw away small details" becomes "throw away the fastest wiggles" and perturbation theory gives controlled answers. This part sets up the machinery on a free field, where everything is exact. Part 6 switches on the interaction.

## From spins to a smooth field

Block-spin a magnet enough times and each block spin is an average over thousands of original spins. At that point it's better to treat it as a smooth number, the local magnetisation $\phi(\mathbf x)$, rather than as $\pm1$.

\analogy{
Look at a newspaper photo under a magnifying glass and you see separate black dots. Step back and you see smooth shades of grey. The field $\phi(\mathbf x)$ is the "shade of grey" description of the magnet: the average of many spins, smooth enough to use calculus on.
}

What's the most general formula for the energy of such a field? Landau and Ginzburg's answer was to write down everything the symmetry allows, as a series in powers of $\phi$ and its slope and keep the first few terms. The up/down symmetry $\phi\to-\phi$ rules out odd powers, which leaves

$$ S[\phi] = \int\dd^dx\left[\tfrac12(\nabla\phi)^2 + \tfrac12 r\,\phi^2 + \frac{u}{4!}\phi^4\right], $$

where $r$ is proportional to $T-T_0$ and changes sign near the transition. The partition function becomes $Z=\int\mathcal D\phi\,e^{-S[\phi]}$.

\analogy{
Tong reminds us that this "path integral" isn't mysterious: it's just one ordinary integral over $\phi$ for every little box of space, all done together. Infinitely many ordinary integrals, nothing more.
}

This is exactly the Euclidean $\phi^4$ theory from Part 1, with $r=m^2$ and $u=\lambda$. **A statistical field theory in $d$ dimensions and a quantum field theory in $d$ spacetime dimensions are the same mathematical object**, as Part 2 showed with the Wick rotation. That's why a course about magnets is also a course about particles.

The underlying lattice spacing $a$ means no wave on the field can be shorter than $a$. In momentum language, the field only has components with $|\mathbf k|<\Lambda\sim\pi/a$. That's the cutoff and here it's completely physical: it's the size of the atoms.

\note{
**Reading alongside.** [Tong's notes](https://davidtong.org/teaching/statistical-field-theory/) build this action from the Ising model in §1.3 and do the free field in §3.3. Peskin & Schroeder §12.1 is the particle physicist's version of this same section.
}

## The field as a sum of waves

Wilson's method works with the **waves** that make up the field, so let's set that up carefully. Any field can be written as a sum (an integral) of waves, each with a wavevector $\mathbf k$:

$$ \phi(\mathbf x)=\int\frac{\dd^dk}{(2\pi)^d}\,e^{i\mathbf k\cdot\mathbf x}\,\phi(\mathbf k). $$

Since $\phi(\mathbf x)$ is real, $\phi(-\mathbf k)=\phi(\mathbf k)^*$. A large $|\mathbf k|$ is a short, fast wiggle and a small $|\mathbf k|$ is a long, slow swell. Each wave is called a **mode**.

\analogy{
It's like the equaliser on a music system. Instead of the sound wave itself, it shows how much bass, midrange and treble there is. Writing $\phi$ in terms of $\phi(\mathbf k)$ is looking at the field on the equaliser: one slider per wavevector.
}

Now rewrite the free part of the action in terms of the waves. Take the stiffness term first. Each $\nabla$ acting on $e^{i\mathbf k\cdot\mathbf x}$ just brings down $i\mathbf k$, so

$$ \int\dd^dx\,(\nabla\phi)^2 = \int\frac{\dd^dk}{(2\pi)^d}\frac{\dd^dk'}{(2\pi)^d}\,(i\mathbf k)\cdot(i\mathbf k')\,\phi(\mathbf k)\phi(\mathbf k')\int\dd^dx\,e^{i(\mathbf k+\mathbf k')\cdot\mathbf x}. $$

The last integral is the key fact about waves: adding up $e^{i(\mathbf k+\mathbf k')\cdot\mathbf x}$ over all of space gives zero unless the two waves exactly cancel, $\mathbf k'=-\mathbf k$. Precisely, $\int\dd^dx\,e^{i(\mathbf k+\mathbf k')\cdot\mathbf x}=(2\pi)^d\,\delta^d(\mathbf k+\mathbf k')$. The delta function removes the $\mathbf k'$ integral and sets $\mathbf k'=-\mathbf k$, so $(i\mathbf k)\cdot(i\mathbf k') = (i\mathbf k)\cdot(-i\mathbf k)=k^2$ and $\phi(\mathbf k)\phi(-\mathbf k)=|\phi(\mathbf k)|^2$. The mass term works the same way without the $k$'s. Together:

$$ S_0=\int\dd^dx\left[\tfrac12(\nabla\phi)^2+\tfrac12r\phi^2\right] = \int\frac{\dd^dk}{(2\pi)^d}\;\tfrac12\,(k^2+r)\,|\phi(\mathbf k)|^2. $$

This is a big simplification. In position space, neighbouring points are tied together by the stiffness term. In wave language, **every mode is on its own**: the action is a separate sum over modes, with no mode talking to any other.

The $\phi^4$ term is different. Written in waves, it contains four modes at once, $\phi(\mathbf k_1)\phi(\mathbf k_2)\phi(\mathbf k_3)\phi(\mathbf k_4)$, with the same kind of delta function forcing $\mathbf k_1+\mathbf k_2+\mathbf k_3+\mathbf k_4=0$. So the interaction lets modes with different wavevectors affect each other, as long as their wavevectors add to zero. That's the only reason coarse-graining is ever hard.

## One RG step, in three moves

Split every wave in the field into slow and fast parts:

$$ \phi(\mathbf x) = \phi_{\rm s}(\mathbf x) + \phi_{\rm f}(\mathbf x), \qquad \phi_{\rm s}:\ |\mathbf k|<\Lambda/b,\qquad \phi_{\rm f}:\ \Lambda/b<|\mathbf k|<\Lambda. $$

The subscripts are nothing clever: ${\rm s}$ for slow, ${\rm f}$ for fast. (Most books write $\phi_<$ with $\phi_>$ instead, meaning below the shell with above it. Same split, harder to read at a glance.) The fast part $\phi_{\rm f}$ lives in a thin **shell** in momentum space, just below the cutoff.

~~~
<div class="mfig" style="--w:620px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/momentum_shell.svg" alt="The momentum shell and the three steps of a Wilsonian RG step">
  <p>One RG step. Integrate out the fast modes in the shell (red), stretch momenta so the cutoff is back at \(\Lambda\), then rescale the field so its stiffness term looks the same as before. What's left over is a change in the couplings.</p>
</div>
~~~

**Move 1: coarse-grain.** Integrate out the shell. That defines a new action for the slow modes alone:
$$ e^{-S'[\phi_{\rm s}]} = \int\mathcal D\phi_{\rm f}\,e^{-S[\phi_{\rm s}+\phi_{\rm f}]}. $$
Any question about long-distance physics gets the same answer from $S'$ as from $S$. We've changed the description, not the physics.

\analogy{
Think of an old radio in a Kolkata tea stall playing a Rabindrasangeet song. It can't reproduce the treble, which is like a low-pass filter that removes the high notes. You still recognise the tune perfectly. The treble is gone, but if the instruments were interacting (say, two high notes beating together to make a low hum), that low hum stays in the bass. So the bass you're left with isn't quite the original bass: the treble has left its fingerprints on it. Integrating out the fast modes is the same. They're gone, but their effect on the slow modes stays, as shifted couplings. Tong adds that this step is just averaging: you treat the fast modes as random noise and average over it.
}

**Move 2: zoom out.** The new theory has cutoff $\Lambda/b$, so it can't be compared directly with the old one. Tong calls them "apples and oranges". So stretch momenta, $\mathbf k'=b\mathbf k$ (equivalently, shrink lengths, $\mathbf x'=\mathbf x/b$), which puts the cutoff back at $\Lambda$. This is exactly "stepping back from the picture": everything looks smaller.

**Move 3: fix the contrast.** Rescale the field, $\phi'=\zeta^{-1}\phi_{\rm s}$, choosing $\zeta$ so that the stiffness term $\tfrac12(\nabla\phi)^2$ keeps its standard form. Without this step the stiffness would just drift and we'd never find a fixed point.

\analogy{
When you shrink a photo on your phone, it can come out darker or washed out, so you adjust the brightness to make it look normal again. Rescaling the field is that brightness adjustment. It doesn't change what's in the picture, it just makes pictures at different zoom levels comparable.
}

After the three moves, the action has the same form with new couplings $(r',u',\dots)$. That's the RG map, now for a field.

## The free field: the Gaussian fixed point

Switch the interaction off, $u=0$. In momentum space the action is then a sum over separate waves that don't talk to each other,

$$ S = \int_{|\mathbf k|<\Lambda}\frac{\dd^dk}{(2\pi)^d}\,\tfrac12(k^2+r)\,|\phi(\mathbf k)|^2, $$

\analogy{
It's like a guitar with strings that don't touch. Removing the high strings has no effect at all on the low ones. So Move 1 does nothing here except produce a constant.
}

Now Moves 2 and 3. Put $\mathbf k=\mathbf k'/b$, so $\dd^dk=b^{-d}\dd^dk'$ and $k^2=b^{-2}k'^2$ and set $\phi_{\rm s}(\mathbf k'/b)=\zeta\,\phi'(\mathbf k')$:

$$ S' = \int_{|\mathbf k'|<\Lambda}\frac{\dd^dk'}{(2\pi)^d}\,\tfrac12\, b^{-d}\zeta^2\big(b^{-2}k'^2 + r\big)|\phi'(\mathbf k')|^2. $$

To keep the coefficient of $k'^2$ equal to one we need $\zeta^2=b^{d+2}$ and then

$$ \boxed{\; r' = b^2 r.\;} $$

So $r=0$ is a fixed point: the free, massless field. It's called the **Gaussian fixed point**, because the weight $e^{-S}$ is a Gaussian. It has one relevant direction, $r$, with $y_r=2$, so $\nu=1/y_r=\tfrac12$. That's exactly the **mean-field** value.

\puja{
The Gaussian fixed point is the **free** theory: no interactions, no coupling, nobody to hold hands with at Maddox Square. Single readers, this one is about you. The good news is that it's a fixed point, so you look exactly the same at every scale. Nobody can ever say you've changed.
}

\analogy{
Tong describes mean-field theory as each spin feeling only the *average* pull of its neighbours, ignoring the fact that the neighbours jiggle. Near the Gaussian fixed point that's a good approximation. It works best when each spin has lots of neighbours, because many jiggles average out, which is why mean field gets better in higher dimensions.
}

## Averaging over the free field, one mode at a time

To integrate out the fast modes in Part 6, we'll need averages like $\langle\phi(\mathbf k)\phi(\mathbf k')\rangle$ over the free weight $e^{-S_0}$. Since every mode is on its own, each one is just an ordinary Gaussian integral.

Take one variable $x$ with weight $e^{-ax^2/2}$. Its normalisation is $Z(a)=\int\dd x\,e^{-ax^2/2}=\sqrt{2\pi/a}$. Differentiating with respect to $a$ brings down $-x^2/2$, so

$$ \langle x^2\rangle = \frac{\int x^2e^{-ax^2/2}\dd x}{\int e^{-ax^2/2}\dd x} = -2\,\frac{\dd\ln Z}{\dd a} = -2\cdot\left(-\frac{1}{2a}\right) = \frac1a. $$

For the mode with wavevector $\mathbf k$, the "$a$" is $k^2+r$. Different modes are independent, so their average is zero unless they're the same mode (really $\mathbf k$ and $-\mathbf k$, since $\phi(-\mathbf k)=\phi(\mathbf k)^*$):

$$ \boxed{\;\langle\phi(\mathbf k)\phi(\mathbf k')\rangle = (2\pi)^d\,\delta^d(\mathbf k+\mathbf k')\;\frac1{k^2+r}\equiv(2\pi)^d\,\delta^d(\mathbf k+\mathbf k')\,G(k).\;} $$

This $G(k)$ is the **propagator** from Part 1, now found as a simple average. The delta function says different modes don't know about each other.

### Wick's theorem: averages of more fields

Three words are about to be used over and over, so here is what each one means.

\defn{
**Average.** The bracket $\langle A\rangle$ means "add up $A$ over every possible shape of the field, weighting each shape by $e^{-S_0}$, then divide by the total weight":
$$ \langle A\rangle=\frac{1}{Z_0}\int\mathcal D\phi\;A\;e^{-S_0[\phi]},\qquad Z_0=\int\mathcal D\phi\;e^{-S_0[\phi]}. $$
It is an ordinary weighted average. Think of a class average where better answers count for more.

**Gaussian.** A weight is called Gaussian when the thing in the exponent is quadratic in the variables, so squares only. Our $S_0$ is quadratic, so the free theory is Gaussian. Everything below is a property of that bell-shaped weight. No quantum mechanics is involved.

**Contraction.** To *contract* two fields means to take that pair out of the list and replace it by its propagator $G$. A *pairing* is one complete way of contracting the whole list with nobody left over. Those two words are the entire vocabulary of the theorem.
}

What about four fields? For one Gaussian variable, the same differentiation trick gives $\langle x^4\rangle=3/a^2=3\langle x^2\rangle^2$. The 3 has a simple meaning: it's the number of ways to split four things into two pairs. For many Gaussian variables:

$$ \langle x_1x_2x_3x_4\rangle = \langle x_1x_2\rangle\langle x_3x_4\rangle + \langle x_1x_3\rangle\langle x_2x_4\rangle + \langle x_1x_4\rangle\langle x_2x_3\rangle. $$

This is **Wick's theorem**. The average of any product of Gaussian variables is the sum over all ways of pairing them up, each pair giving a propagator. Averages of an odd number of fields are zero, because there's always one left over with no partner.

**Why it's true.** The trick is to add a *source*: an extra term $Jx$ in the exponent, where $J$ is just a number we are free to choose. Complete the square, $-\tfrac a2x^2+Jx=-\tfrac a2\big(x-\tfrac Ja\big)^2+\tfrac{J^2}{2a}$, then shift the integration variable by $J/a$. The shifted integral is the same one as before, so it cancels against the denominator:

$$ \big\langle e^{Jx}\big\rangle=\frac{\int\dd x\;e^{-ax^2/2+Jx}}{\int\dd x\;e^{-ax^2/2}}=e^{J^2/2a}=e^{J^2\langle x^2\rangle/2}. $$

Now expand both sides in powers of $J$. On the left, $\sum_n J^n\langle x^n\rangle/n!$. On the right, only even powers survive, since the exponent carries $J^2$. Matching the coefficient of $J^{2n}$:

$$ \frac{\langle x^{2n}\rangle}{(2n)!}=\frac1{n!}\left(\frac{\langle x^2\rangle}{2}\right)^{n} \qquad\Longrightarrow\qquad \langle x^{2n}\rangle=\frac{(2n)!}{2^n\,n!}\,\langle x^2\rangle^n=(2n-1)!!\;\langle x^2\rangle^n. $$

Two things drop out at once.

- **Odd averages vanish.** The right-hand side has no odd powers of $J$, so there is nothing for $\langle x\rangle$, $\langle x^3\rangle$, $\langle x^5\rangle$ to match. They are all zero.
- **The number is the number of pairings.** $(2n-1)!!$ means $1\cdot3\cdot5\cdots(2n-1)$, the double factorial. It counts pairings directly: the first field picks a partner in $2n-1$ ways, the first of the ones still free picks in $2n-3$ ways, down to the last pair with one way. Four fields give $3$, six give $5\cdot3=15$, eight give $105$. So the combinatorial factor in the formula *is* the count of pairings, not a coincidence.

Nothing there used more than one variable. Give each variable its own source and the same completion of the square gives $\big\langle e^{\sum_iJ_ix_i}\big\rangle=\exp\big(\tfrac12\sum_{i,j}J_iJ_j\langle x_ix_j\rangle\big)$, whose expansion is the sum over pairings with one propagator per pair. That is all we need here, because $S_0$ is diagonal in momentum: the free field literally *is* a pile of independent Gaussian variables, one per mode. Wick's theorem for fields is the one-variable result applied mode by mode.

\analogy{
Think of a dance where everyone must have exactly one partner. Four dancers can be paired in 3 ways, six dancers in $5\times3=15$ ways and so on. Wick's theorem says a Gaussian average is just "add up every possible way of pairing the dancers". An odd number of dancers means somebody sits out and the whole average is zero.
}

\puja{
Pandal hopping in a group of four: the only question is who walks with whom. Three possible arrangements, which is exactly $\langle x^4\rangle=3\langle x^2\rangle^2$. With five in the group somebody walks alone the whole evening, so that average is zero. Every single reader has now understood Wick's theorem at a deeper level than intended.
}

(Checked in Wolfram: $\langle x^2\rangle=1/a$, $\langle x^4\rangle=3\langle x^2\rangle^2$, the generating function $\langle e^{Jx}\rangle=e^{J^2/2a}$, the moments $\langle x^{2n}\rangle=(2n-1)!!/a^n$ up to $n=4$ and the vanishing of the odd ones. Tong §3.4 proves the operator form of the same statement, where the fields do not commute. In this course the fields are ordinary numbers inside an integral, so the argument above is the whole proof.)

## What the free field looks like: its correlation function

Go back to position space. How strongly is the field at one point related to the field a distance $R$ away? Transform $G(k)$ back:

$$ \langle\phi(\mathbf x)\phi(0)\rangle = \int\frac{\dd^dk}{(2\pi)^d}\,\frac{e^{i\mathbf k\cdot\mathbf x}}{k^2+r}. $$

In three dimensions, use spherical coordinates with $\mathbf x$ along the $z$ axis. The angular integral gives $\int_{-1}^1 e^{ikR\cos\theta}\,\dd(\cos\theta)=\frac{2\sin kR}{kR}$ and what's left is a standard integral:

$$ \langle\phi(\mathbf x)\phi(0)\rangle = \frac{1}{2\pi^2R}\int_0^\infty\frac{k\sin kR}{k^2+r}\,\dd k = \frac{e^{-R/\xi}}{4\pi R},\qquad \xi=\frac1{\sqrt r}. $$

(Checked in Wolfram.) Far away, the correlation dies off exponentially over the **correlation length** $\xi=r^{-1/2}$. Since $r\propto T-T_c$, this gives $\xi\propto|T-T_c|^{-1/2}$, so $\nu=\tfrac12$, as found above.

\analogy{
Tong's picture: the correlation function is how the rubber sheet responds if you poke it at one point. Away from the critical point, the dent heals over a distance $\xi$. At the critical point ($r=0$) the dent never fully heals, it just fades slowly like $1/R$. A poke is felt everywhere.
}

~~~
<div class="mfig" style="--w:640px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/correlator_ginzburg.svg" alt="The free correlation function in 3D and the Ginzburg ratio">
  <p>Left: the free correlator in 3D for three correlation lengths. At the critical point it becomes a pure power, \(1/4\pi R\). Right: the Ginzburg ratio, which measures how big fluctuations are compared with the mean-field magnetisation (explained below). Only for \(d>4\) does it stay small near \(T_c\).</p>
</div>
~~~

At the critical point the correlator is a pure power law, $1/R^{d-2}$ in $d$ dimensions. Critical correlations are usually written as $1/R^{d-2+\eta}$, so the free field has $\eta=0$. Real 3D magnets have $\eta=0.036$, which is small but not zero. That tiny difference comes from interactions and it first appears at two loops (Part 6).

## Scaling dimensions: power counting is an RG fact

In real space the same rescaling reads $\mathbf x'=\mathbf x/b$ and $\phi'(\mathbf x')=b^{(d-2)/2}\phi(\mathbf x)$ (exercise 5.1). The number $(d-2)/2$ is the **scaling dimension** of $\phi$ at the Gaussian fixed point. It's the same as the mass dimension $[\phi]$ from Part 1, now showing up as an RG growth rate.

Add any term $g_n\int\dd^dx\,\phi^n$ and ask how $g_n$ changes when you zoom out. Since $\dd^dx=b^d\dd^dx'$ and $\phi^n=b^{-n(d-2)/2}\phi'^n$,

$$ g_n' = b^{\,y_n}g_n,\qquad y_n = d-n\,\frac{d-2}{2} = [g_n]. $$

So near the Gaussian fixed point, **how a coupling grows under the RG is just its mass dimension**. Positive dimension means relevant, zero means marginal, negative means irrelevant. Terms with derivatives work the same way, with each derivative costing one unit.

The same counting works for a magnetic field, which enters the action as $-h\int\dd^dx\,\phi$. That's the case $n=1$: $y_h=d-\frac{d-2}{2}=\frac{d+2}{2}$. So at the free fixed point the two relevant couplings are temperature, with $y_t=2$ and field, with $y_h=\frac{d+2}2$. Put these into the exponent formulas of Part 4 with $d=4$: $\nu=\tfrac12$, $\gamma=\frac{2y_h-d}{y_t}=1$, $\beta=\frac{d-y_h}{y_t}=\tfrac12$, $\delta=\frac{y_h}{d-y_h}=3$ and $\eta=d+2-2y_h=0$. These are exactly the mean-field (Landau) exponents. (Above four dimensions the formulas for $\beta$ and $\delta$ need extra care, because the irrelevant $u$ still controls the size of the magnetisation. This is a subtle point, discussed in Tong §3.3.2.)

~~~
<div class="mfig" style="--w:560px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/power_counting.svg" alt="Power counting of phi^n operators in four dimensions">
  <p>Power counting in four dimensions. The quartic coupling sits right on the boundary (marginal). Anything with more fields or more derivatives is irrelevant.</p>
</div>
~~~

\analogy{
Irrelevant couplings are like the fine print on a billboard. Up close you can read every word. Step back and it becomes a grey smudge long before the big headline does. The headline is the relevant and marginal couplings: they're what you can still read from far away.
}

This is why you only ever write a few terms in a Lagrangian. An irrelevant coupling $g$ with $[g]=-p$ affects things at energy $E$ in the combination $gE^p$, which is suppressed by $(E/\Lambda)^p$ if $g\sim\Lambda^{-p}$. By the time you coarse-grain down to the scales where you measure things, only the relevant and marginal couplings are left. So the theory you see at low energy is *forced* to be simple. "Renormalisable" theories, the ones with only non-negative-dimension couplings, aren't a lucky choice by nature. They're what *any* theory looks like from far enough away. Part 8 comes back to this.

## Why four dimensions is special

Apply the formula to the quartic coupling: $y_4=4-d$.

- **$d>4$**: $u$ is irrelevant at the Gaussian point. A critical system flows to the free theory and the mean-field exponents ($\nu=\tfrac12$ and friends) are exactly right.
- **$d=4$**: $u$ is marginal. The simple counting can't decide, so we need loops. Part 6 shows $u$ is *marginally irrelevant*: it dies away, but only very slowly, like a logarithm.
- **$d<4$**: $u$ is **relevant**. The Gaussian point now has a second unstable direction, so a critical system can't flow into it. It must flow somewhere else, to a fixed point with $u^*\neq0$, whose exponents differ from mean field. That's why $\nu$ for real 3D magnets is $0.63$, not $0.5$.

\analogy{
Tong points out that an experimenter controls the temperature, but has no knob for $u$, which is set by the messy atomic details. If $u$ is irrelevant ($d>4$), that doesn't matter, because the system drives itself to the free fixed point. If $u$ is relevant ($d<4$), the system drives itself somewhere else entirely and the mean-field predictions fail. That's the whole reason real magnets don't follow mean-field theory.
}

Four is called the **upper critical dimension** of the Ising class. Wilson and Fisher's idea was to work in $d=4-\epsilon$ dimensions, where the new fixed point sits at a small coupling $u^*$ of size $\epsilon$, so perturbation theory can handle it. That's Part 6.

\note{
If you read Melo's notes alongside this course, they use dimensionless couplings $g_2=m^2/\Lambda^2$ and $g_4=\lambda\Lambda^{d-4}$ and write the flow as $\Lambda\,\dd g/\dd\Lambda$. Lowering $\Lambda$ means flowing towards long distances, so their $\Lambda\,\dd/\dd\Lambda$ is minus our $\dd/\dd\ell$, with $b=e^{\ell}$. The free-field result above reads $\Lambda\,\dd g_2/\dd\Lambda=-2g_2$ in their notation.
}

## The same answer from fluctuations: the Ginzburg criterion

There's a second, very physical way to see why four dimensions is special, due to Ginzburg and explained in Tong §2.2.4. Mean-field theory replaces the field by its average value. That's only fair if the fluctuations around the average are small compared with the average itself.

\analogy{
During the monsoon, a street in Kolkata might have an *average* water depth of 2 cm. But if the puddles are 30 cm deep, the average tells you nothing about whether your shoes will get wet. Mean field is the average depth. It's trustworthy only if the puddles, the fluctuations, are small compared with it.
}

Let's compare the two, below $T_c$ where $r<0$.

**The average.** Minimising the potential $\tfrac12r\phi^2+\frac{u}{4!}\phi^4$ gives $r\phi+\frac u6\phi^3=0$, so the mean-field magnetisation is $m_0^2=\frac{6|r|}{u}$.

**The fluctuations.** Add up the correlation function over one correlation volume (a ball of radius $\xi$). Inside that ball the correlator is roughly $1/R^{d-2}$ and the ball's shells have area $\propto R^{d-1}$, so
$$ \int_{|x|<\xi}\dd^dx\,\langle\phi(x)\phi(0)\rangle\sim\int_0^\xi\frac{R^{d-1}}{R^{d-2}}\,\dd R=\int_0^\xi R\,\dd R=\frac{\xi^2}{2}. $$

**The ratio.** Divide by the same volume filled with the mean field, $\xi^d m_0^2$:
$$ \text{Ratio}\sim\frac{\xi^2}{\xi^dm_0^2}=\frac{\xi^{2-d}}{m_0^2}. $$
With $\xi=|r|^{-1/2}$ and $m_0^2=6|r|/u$,
$$ \text{Ratio}\sim\frac{|r|^{(d-2)/2}}{6|r|/u}=\frac u6\,|r|^{(d-4)/2}\propto|T-T_c|^{(d-4)/2}. $$

(Checked in Wolfram.) Near the critical point $|T-T_c|\to0$, so:

- for $d>4$ the power is positive and the ratio goes to *zero*: fluctuations become negligible and mean field is exact;
- for $d<4$ the power is negative and the ratio goes to *infinity*: fluctuations swamp the average and mean field fails;
- for $d=4$ it's borderline and the answer involves logarithms.

Tong's summary is that below four dimensions mean-field theory "predicts its own demise". This is the same $d=4$ we found from power counting, reached in a completely different way.

## Exercises

\prob{
**5.1.** Show that the Fourier-space rescaling $\phi_{\rm s}(\mathbf k'/b)=\zeta\,\phi'(\mathbf k')$ with $\zeta^2=b^{d+2}$ is the same as $\phi'(\mathbf x')=b^{(d-2)/2}\phi_{\rm s}(\mathbf x)$ in real space, where $\mathbf x'=\mathbf x/b$. Use $\phi(\mathbf x)=\int\frac{\dd^dk}{(2\pi)^d}e^{i\mathbf k\cdot\mathbf x}\phi(\mathbf k)$.
}
\soln{
$\phi'(\mathbf x')=\int\frac{\dd^dk'}{(2\pi)^d}e^{i\mathbf k'\cdot\mathbf x'}\zeta^{-1}\phi_{\rm s}(\mathbf k'/b)$. Substitute $\mathbf k'=b\mathbf k$: then $\dd^dk'=b^d\dd^dk$ and $\mathbf k'\cdot\mathbf x'=\mathbf k\cdot\mathbf x$, so $\phi'(\mathbf x')=b^d\zeta^{-1}\phi_{\rm s}(\mathbf x)=b^{d-(d+2)/2}\phi_{\rm s}(\mathbf x)=b^{(d-2)/2}\phi_{\rm s}(\mathbf x)$.
}

\prob{
**5.2.** Classify $\phi^2,\phi^4,\phi^6$ as relevant, marginal or irrelevant at the Gaussian fixed point in $d=3$. In which dimension is a $\phi^3$ coupling marginal?
}
\soln{
In $d=3$, $[\phi]=\tfrac12$, so $y_n=3-n/2$: $y_2=2$ (relevant), $y_4=1$ (relevant), $y_6=0$ (marginal). For $\phi^3$: $y_3=d-3(d-2)/2=(6-d)/2$, which is zero at $d=6$. That's why $\phi^3$ theory in six dimensions is the standard toy model for percolation and for asymptotic freedom.
}

\prob{
**5.3.** Find how the coupling of $(\nabla\phi)^2\phi^2$ scales at the Gaussian fixed point in general $d$. Is it ever relevant for $d\geq2$?
}
\soln{
The term has dimension $2+4\cdot\frac{d-2}{2}=2d-2$, so $y=d-(2d-2)=2-d$. It's marginal in $d=2$ and irrelevant for every $d>2$. In $d=4$, $y=-2$, as in the figure.
}

\prob{
**5.4.** Suppose an irrelevant coupling $g_6$ has $[g_6]=-2$ and naturally $g_6\sim1/\Lambda^2$. Roughly how much is its effect suppressed at $E=100$ GeV if $\Lambda=10$ TeV? What if $\Lambda$ is the Planck scale?
}
\soln{
Its effect comes in as $g_6E^2\sim(E/\Lambda)^2$. For $\Lambda=10$ TeV that's $(0.01)^2=10^{-4}$: small, but within reach of precision experiments, which is how colliders search for new physics indirectly. For $\Lambda=1.2\times10^{19}$ GeV it's about $7\times10^{-35}$, far too small to ever measure. That's why the Standard Model can be tested so precisely without knowing anything about quantum gravity.
}

\prob{
**5.5.** Show that $\langle x^6\rangle=15\langle x^2\rangle^3$ for one Gaussian variable and check that 15 is the number of ways to split six things into three pairs.
}
\soln{
From $Z(a)=\sqrt{2\pi}\,a^{-1/2}$, each $-2\,\dd/\dd a$ brings down $x^2$. So $\langle x^6\rangle=\frac{(-2)^3}{Z}\frac{\dd^3Z}{\dd a^3}$. The derivatives of $a^{-1/2}$ give $(-\tfrac12)(-\tfrac32)(-\tfrac52)a^{-7/2}$, so $\langle x^6\rangle=(-8)(-\tfrac{15}{8})a^{-3}=15/a^3=15\langle x^2\rangle^3$. Counting pairings: the first thing can pair with any of the other 5, then the first remaining thing with any of 3 and the last two are forced: $5\times3\times1=15$. In general $2n$ things can be paired in $(2n-1)\times(2n-3)\times\dots\times1$ ways.
}

\prob{
**5.6.** Find the mean-field magnetisation below $T_c$ by minimising $V(\phi)=\tfrac12r\phi^2+\frac u{4!}\phi^4$ with $r<0$. How does it depend on $T_c-T$? Which exponent is that?
}
\soln{
$V'(\phi)=r\phi+\frac u6\phi^3=0$ gives $\phi=0$ or $\phi^2=-6r/u=6|r|/u$. For $r<0$ the nonzero solution has lower energy. Since $r\propto T-T_c$, $m_0=\sqrt{6|r|/u}\propto(T_c-T)^{1/2}$, which is the mean-field value $\beta=\tfrac12$. It agrees with the power-counting result above for $d=4$.
}

\prob{
**5.7.** Repeat the Ginzburg estimate in $d=3$, keeping the factor of $u$. Show that mean field fails once $|r|\lesssim u^2$ (up to numbers of order one). Why does a *weakly* interacting system still eventually fail?
}
\soln{
In $d=3$ the ratio is $\frac u6|r|^{-1/2}$, which is large once $|r|^{1/2}\lesssim u$, that is $|r|\lesssim u^2$. A small $u$ makes that window tiny, so weakly interacting systems follow mean field until you get *very* close to $T_c$. Mean-field superconductors are the famous example, where the window is so small it's almost never seen. But any $u>0$ gives some window, because the fluctuations grow without limit as $|r|\to0$ while the average shrinks to zero.
}

\coursenav{/Pages/Physics/courses/RG/04_fixed_points/}{Part 4: Fixed points and universality}{/Pages/Physics/courses/RG/06_wilson_fisher/}{Part 6: The Wilson-Fisher point}

{{comments}}
