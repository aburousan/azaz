+++
title = "Renormalisation Group I: Why Scale Matters"
hascode = true
date = Date(2026, 9, 19)
rss = "Part 1 of the renormalisation group course. A quantum correction to a particle's mass, worked out diagram by diagram, comes out infinite. What that is really telling us about coupling constants and the scale we look at."
rss_title = "Renormalisation Group I: Why Scale Matters"
rss_pubdate = Date(2026, 9, 19)

tags = ["physics", "qft", "renormalization", "course"]
+++

\newcommand{\dd}{\mathrm d}

\toc

# Renormalisation Group I: Why Scale Matters

> *Part 1 of eight. [Course home](/Pages/Physics/courses/RG/Main_page/) · [Glossary](/Pages/Physics/courses/RG/glossary/) · next: [Loops, infinities and cutoffs](/Pages/Physics/courses/RG/02_toolkit/)*

## A map is not wrong for leaving out your street

It's Durga Puja and you open a map on your phone to go pandal hopping. Zoomed all the way out, West Bengal fills the screen and Kolkata is a single dot. That map isn't wrong. It's just drawn for a scale at which pandals don't exist. Zoom in once and the city splits into neighbourhoods: Bagbazar, Kumartuli, Ballygunge. Zoom in again and your para appears, with the lane that leads to its pandal. One more zoom and you see the gate, the queue and the phuchka stall beside it. Every one of these maps is correct. Each one shows what matters at its own zoom level and leaves out everything smaller.

\analogy{
A physical theory is like a map. It is drawn at a certain resolution. Anything smaller than that is left out. The renormalisation group is the rulebook for redrawing the map at a different zoom level.
}

Physics works this way all the time and we rarely notice because the levels are so far apart. Nobody predicts the flow of water using quarks. We use the Navier-Stokes equation with two numbers, a density and a viscosity, measured in a lab. Those two numbers are all that survives of the molecular chaos once you average over a cubic micron.

~~~
<div class="mfig" style="--w:600px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/scale_ladder.svg" alt="Ladder of effective descriptions from quarks to fluids">
  <p>Each rung is a complete theory that works in its own range of sizes. Going down the ladder is coarse-graining: averaging away the small stuff.</p>
</div>
~~~

David Tong puts it nicely in his lecture notes. Little things affect big things, but they rarely affect *very* big things. Little things affect slightly bigger things, which affect slightly bigger things again. At each step some information about the start is lost. That is why a biologist studying how starlings flock never needs the Higgs boson.

This sounds like philosophy. It becomes a calculation the moment you work out a quantum correction in field theory, so let's work one out slowly.

\note{
**New to loop integrals?** This page walks through one calculation to show you the *problem*. If words like "loop", "Euclidean" or "cutoff" feel slippery, that's expected. [Part 2](/Pages/Physics/courses/RG/02_toolkit/) builds each of them from scratch. Read this page for the story and Part 2 for the tools.
}

## The theory we'll use

Take the simplest interacting field theory there is: one real field $\phi(x)$ that interacts with itself. We work in **Euclidean** space, which means we have swapped real time $t$ for imaginary time $\tau = it$. That one swap turns the oscillating quantum weight $e^{iS}$ into a real, decaying weight $e^{-S}$, like a Boltzmann factor, which makes every integral easier. (Part 2 shows why this is allowed.) The action is

$$ S[\phi] = \int \dd^4x \left[ \tfrac12 (\partial\phi)^2 + \tfrac12 m_0^2\phi^2 + \frac{\lambda_0}{4!}\phi^4 \right]. $$

\analogy{
Think of $\phi(x)$ as the height of a rubber sheet at each point. The first term, $(\partial\phi)^2$, is the sheet's stiffness: it costs energy for the height to change suddenly from one point to the next. The second term, $m_0^2\phi^2$, is a spring under every point pulling the sheet back to zero. The last term, $\lambda_0\phi^4$, makes those springs get stiffer when they're stretched a lot. That's the interaction: it's what lets ripples on the sheet affect each other.
}

The little $0$ on $m_0$ and $\lambda_0$ is a warning. By the end of this page you'll see that these are *not* the mass and coupling you'd measure in an experiment.

## How a particle travels: the propagator

A particle in this theory is a ripple on the sheet. The **propagator** tells you how easily a ripple with momentum $p$ travels. Without the interaction it is

$$ G_0(p) = \frac{1}{p^2+m_0^2}. $$

The mass hides in this formula. In real (not imaginary) time, the propagator blows up exactly when the particle's energy and momentum satisfy $E^2 = \mathbf p^2 + m^2$. So **the mass is where the propagator has its pole**. Keep that in mind, because the interaction is about to move the pole.

## Interactions dress the particle

With $\lambda_0\neq0$, a travelling particle can briefly create a virtual particle and swallow it again. In Feynman-diagram language this is a closed loop attached to the particle's path. The simplest one is called the **tadpole**, because of its shape.

\analogy{
Try walking across Howrah station at rush hour. You keep bumping into people, so it takes far more effort to get anywhere; you move *as if* you were much heavier. A particle moving through the quantum vacuum is always bumping into the virtual particles it creates, so it too behaves as if its mass were different. Physicists say the particle is "dressed" by its interactions.
}

The real propagator is the sum over every way the particle can travel. It can go straight, or bump once, or bump twice and so on:

~~~
<div class="mfig" style="--w:600px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/propagator_series.svg" alt="The full propagator as the free line plus one tadpole plus two tadpoles and so on">
  <p>The full propagator (thick line) is the free one, plus the particle bumping once, plus bumping twice in a row and so on forever.</p>
</div>
~~~

Call the value of one bump (one tadpole, without the two outside lines) $\Sigma$. Each bump is sandwiched between free propagators and each carries a minus sign (it comes from the $e^{-S}$ weight), so the series is

$$ G = G_0 - G_0\,\Sigma\,G_0 + G_0\,\Sigma\,G_0\,\Sigma\,G_0 - \dots = G_0\left(1 - \Sigma G_0 + (\Sigma G_0)^2-\dots\right). $$

That's a geometric series, $1-x+x^2-\dots = 1/(1+x)$ with $x=\Sigma G_0$. Summing it:

$$ G = \frac{G_0}{1+\Sigma G_0} = \frac{1}{G_0^{-1}+\Sigma} = \frac{1}{p^2 + m_0^2 + \Sigma}. $$

Look at what happened. The bumps did not change the *shape* of the propagator; they just added $\Sigma$ to $m_0^2$. The pole moved. So the mass you'd measure is

$$ \boxed{\;m^2_{\rm phys} = m_0^2 + \Sigma.\;} $$

Everything now depends on computing $\Sigma$. Let's do it in four steps.

## Computing the tadpole, step by step

~~~
<div class="mfig" style="--w:440px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/tadpole_detail.svg" alt="The tadpole diagram with its momenta and vertex labelled">
  <p>The tadpole with every label. The particle comes in with momentum \(p\) and leaves with \(p\). The loop carries a momentum \(k\) that nothing fixes, so we must add up every value of \(k\).</p>
</div>
~~~

**Step 1: the pieces.** A diagram is a product of simple pieces, called the Feynman rules. Take them on trust for now: [Part 2](/Pages/Physics/courses/RG/02_toolkit/) derives every one of them, including the minus sign and the $\tfrac12$ below, straight from the path integral. The vertex gives the coupling, $\lambda_0/4!$. The loop is one propagator, $1/(k^2+m_0^2)$. And since nothing fixes the loop momentum $k$, we integrate over all of it with $\int\dd^4k/(2\pi)^4$.

**Step 2: the symmetry factor.** How many ways can this diagram be made? The vertex $\phi^4$ has four identical legs. The incoming line can attach to any of the 4 legs and the outgoing line to any of the 3 left. The last two legs then have just one way to join up into the loop. That's $4\times3 = 12$ ways and dividing by the $4!=24$ in the coupling leaves $\tfrac{12}{24}=\tfrac12$.

~~~
<div class="mfig" style="--w:560px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/tadpole_counting.svg" alt="Counting the ways to build the tadpole from a four-legged vertex">
  <p>Where the \(\tfrac12\) comes from: 12 ways to attach the two outside lines, divided by the \(4!\) that was put into the coupling.</p>
</div>
~~~

Putting steps 1 and 2 together:

$$ \Sigma = \frac{\lambda_0}{2}\int\frac{\dd^4k}{(2\pi)^4}\,\frac{1}{k^2+m_0^2}. $$

**Step 3: use four-dimensional spherical coordinates.** The integrand only depends on the length $k=|k|$, so we can use shells, the same way you'd do a 3D integral with $\dd^3k = 4\pi k^2\,\dd k$. In four dimensions the "area" of a shell of radius $k$ is $2\pi^2k^3$, so $\dd^4k = 2\pi^2k^3\,\dd k$. The constants combine as $\frac{\lambda_0}{2}\cdot\frac{2\pi^2}{(2\pi)^4} = \frac{\lambda_0}{16\pi^2}$, leaving one ordinary integral:

$$ \Sigma = \frac{\lambda_0}{16\pi^2}\int_0^{\infty}\frac{k^3\,\dd k}{k^2+m_0^2}. $$

**Step 4: look at large $k$.** When $k$ is much bigger than $m_0$, the integrand is about $k^3/k^2 = k$. And $\int^\infty k\,\dd k$ is infinite. It grows like the square of the upper limit.

So the theory, taken at face value, predicts that the particle's measured mass is **infinite**. That's obviously wrong: particles have finite masses. Something in our reasoning has to give.

\otaku{
This is the moment Vegeta crushes his scouter in *Dragon Ball Z*: "It's over 9000!" Except our integral isn't over 9000, it's over every number you can name. Unlike Goku's power level, it's telling us the measuring device (our theory) is broken, not that the particle is strong.
}

## Stop the integral: the cutoff

Which part of the integral caused the trouble? Very large $k$. A loop momentum $k$ describes a fluctuation of size about $1/k$, so very large $k$ means fluctuations at *extremely short* distances. We integrated all the way to $k=\infty$, which means we assumed our simple theory is correct down to zero distance.

We have no right to assume that. We haven't tested nature at arbitrarily short distances. So let's be honest and stop the integral at some large momentum $\Lambda$, called the **cutoff**:

\analogy{
The cutoff $\Lambda$ is the pixel size of the map. Any detail smaller than about $1/\Lambda$ is simply not drawn. For a magnet this is literal: the atoms sit on a lattice and nothing is smaller than the spacing between them.
}

With the cutoff, the integral is finite. Write $\frac{k^3}{k^2+m^2} = k - \frac{m^2k}{k^2+m^2}$ and integrate each piece:

$$ \int_0^\Lambda \frac{k^3\,\dd k}{k^2+m_0^2} = \frac12\left[\Lambda^2 - m_0^2\ln\!\Big(1+\frac{\Lambda^2}{m_0^2}\Big)\right], $$

and so

$$ \boxed{\;\Sigma = \frac{\lambda_0}{32\pi^2}\left[\Lambda^2 - m_0^2\ln\!\Big(1+\frac{\Lambda^2}{m_0^2}\Big)\right].\;} $$

Here's the check in Wolfram Language:

```mathematica
Integrate[k^3/(k^2 + m^2), {k, 0, L}, Assumptions -> {m > 0, L > 0}]
(* (L^2 - m^2 Log[1 + L^2/m^2])/2 *)
(lam/2) (2 Pi^2/(2 Pi)^4) %  // Simplify
(* lam (L^2 - m^2 Log[1 + L^2/m^2])/(32 Pi^2) *)
```

The measured mass is now finite, $m^2_{\rm phys}=m_0^2+\Sigma$. But it depends on $\Lambda$, a number we chose ourselves. If you pick a bigger pixel size, you get a different answer. That looks like a disaster.

## What this is really telling us

There are two ways to react.

The old way says: $\Lambda$ is a trick, so choose $m_0^2$ to cancel the $\Lambda^2$ and let $\Lambda\to\infty$ at the end. That works (Part 7 shows exactly how), but it feels like cheating.

The modern way, due mostly to Kenneth Wilson around 1971, says this is not a disaster at all. It is the most important fact in the story. **The Lagrangian is a map drawn at resolution $\Lambda$.** Its numbers $m_0$ and $\lambda_0$ aren't "the" mass and "the" coupling. They're the right numbers for a description in which everything smaller than $1/\Lambda$ has already been averaged away. If you redraw the map at a different resolution, you need different numbers, chosen so that everything you can measure stays the same.

\defn{
The **renormalisation group** is the set of rules that tells you how the numbers in a theory must change when you change the resolution, so that the physics you can measure stays fixed. The path the numbers trace out as the resolution changes is called the **RG flow**.
}

\analogy{
Imagine describing the same city with a street map, then a district map, then a country map. Each map uses different symbols and leaves out different things, but they all have to agree about where the big roads go. The RG says how the symbols must change from one map to the next so that they keep agreeing.
}

So the sentence "the fine-structure constant is $1/137$" is incomplete. It's $1/137.036$ when you probe an electron very gently. At the energy of the $Z$ boson it's about $1/128$. This is a measured fact and Part 7 explains it.

\note{
The word "group" is a historical accident. Coarse-graining throws information away, so you can't undo it. As Tong says, you can integrate fields out, but you can't put them back in. Mathematically it's a *semi*group. Nobody minds.
}

## Why plain dimensional analysis isn't enough

One more idea before we set off. With $\hbar=c=1$, every quantity has a dimension that is some power of mass. The action has none and $\dd^4x$ has mass dimension $-4$, so the Lagrangian has dimension $4$. From the stiffness term $(\partial\phi)^2$ we get $[\phi]=1$ and then $[\lambda_0\phi^4]=4$ forces $[\lambda_0]=0$. **In four dimensions the coupling is a pure number.**

Here's the puzzle. If $\lambda$ is a pure number and there's no other scale around (say $m=0$), dimensional analysis says a scattering rate can't depend on the collision energy at all. Yet a one-loop calculation gives terms like $\ln(E/\Lambda)$. The cutoff, the scale we "didn't care about", sneaks back in through a logarithm.

\analogy{
Dimensional analysis is like judging a building's height from a photo with nothing else in it for scale. It works only if nothing hidden is setting the scale. Quantum fluctuations at every size quietly put a ruler back into the photo and the ruler is $\Lambda$.
}

## Two roads to the same place

The RG was discovered twice.

On the **statistical physics road** (Kadanoff 1966, Wilson 1971), people asked why systems as different as a magnet and a boiling liquid behave identically near their critical points. The answer came from literally coarse-graining a lattice. We take this road first, in Parts 3 to 6, because every step can be seen.

On the **particle physics road**, people asked how the parameters of a quantum field theory depend on the energy at which you measure them. Dmitry Shirkov tells this story in the *CERN Courier* article "Fifty years of the renormalization group". Stueckelberg and Petermann saw first, in 1951 and 1953, that the rescalings form a group, but their short note "remained unnoticed" and the longer paper was in French. Gell-Mann and Low found the energy dependence of the electric charge in 1954. Bogoliubov and Shirkov then tied these together into a practical algorithm, the "renormalization group method", in 1955 and 1956 and Callan and Symanzik wrote down its modern equation in 1970. That's Part 7.

They turn out to be the same idea. The best moment in the course comes in Part 7, when a number we find by coarse-graining in Part 6 comes back, to the digit, from a completely different calculation.

## Exercises

\prob{
**1.1.** Check the integral $\int_0^\Lambda k^3\,\dd k/(k^2+m^2) = \tfrac12[\Lambda^2-m^2\ln(1+\Lambda^2/m^2)]$. Then show that for $\Lambda\gg m$ the mass shift is roughly $\Sigma\approx \lambda_0\Lambda^2/(32\pi^2)$.
}
\soln{
Split $\frac{k^3}{k^2+m^2} = k - \frac{m^2 k}{k^2+m^2}$. The first piece gives $\Lambda^2/2$. For the second, put $v=k^2+m^2$, so $\dd v = 2k\,\dd k$, which gives $\tfrac{m^2}{2}\ln\frac{\Lambda^2+m^2}{m^2}$. When $\Lambda\gg m$, the logarithm grows much more slowly than $\Lambda^2$, so the $\Lambda^2$ term wins and $\Sigma\approx\lambda_0\Lambda^2/(32\pi^2)$.
}

\prob{
**1.2.** Can a single $\phi^4$ vertex carry *two* tadpole loops at once? Count how many legs are left after the incoming and outgoing lines are attached.
}
\soln{
After attaching the incoming and outgoing lines, only two of the four legs are left and two legs can only make one loop. A second loop at the same vertex would need two more legs, so it would need a $\phi^6$ vertex. With only $\phi^4$, "bumping twice" means two separate vertices, which is the third picture in the series.
}

\prob{
**1.3.** In $d$ spacetime dimensions, find the mass dimension of $\phi$, of $\lambda$ in $\lambda\phi^4$ and of $g_6$ in $g_6\phi^6$. In which $d$ is $\lambda$ a pure number?
}
\soln{
The action has no dimension and $[\dd^dx]=-d$, so $[\mathcal L]=d$. The stiffness term gives $2+2[\phi]=d$, so $[\phi]=(d-2)/2$. Then $[\lambda]=d-4[\phi]=4-d$ and $[g_6]=d-6[\phi]=6-2d$. So $\lambda$ is a pure number in $d=4$ and $g_6$ is one in $d=3$. These numbers come back in Parts 5 and 6.
}

\prob{
**1.4.** *A first look at "naturalness".* Suppose the cutoff is the Planck scale, $\Lambda\approx1.22\times10^{19}$ GeV and a particle with $\lambda_0=0.1$ has a measured mass of 125 GeV (like the Higgs). Estimate $\Sigma/m^2_{\rm phys}$. What must be true of $m_0^2$?
}
\soln{
$\Sigma/m^2 \approx \frac{0.1}{32\pi^2}\left(\frac{1.22\times10^{19}}{125}\right)^2 \approx 3\times10^{30}$. For the measured mass to come out at 125 GeV, $m_0^2$ must be negative and cancel $\Sigma$ to about thirty decimal places. Nothing is mathematically wrong with that, but it looks like a conspiracy, a bit like a pencil balanced on its tip. This is the hierarchy problem of the Higgs mass. Part 8 explains why the RG makes mass terms and only mass terms, this touchy.
}

\coursenav{}{}{/Pages/Physics/courses/RG/02_toolkit/}{Part 2: Loops, infinities and cutoffs}

{{comments}}
