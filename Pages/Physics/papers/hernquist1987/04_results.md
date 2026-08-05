+++
title = "Tree Codes 4: Results"
hascode = true
date = Date(2026, 8, 4)
rss = "Part 4 of recreating Hernquist (1987): the evolving cluster, timing against N and theta, force errors, softening, conservation laws and relaxation, all measured with my own Julia code."

tags = ["Julia", "physics", "papers", "N-body", "Barnes-Hut", "simulation"]
+++

\toc

# 4. Results

Part 4 of my recreation of [Hernquist (1987)](/Pages/Physics/papers/hernquist1987/). The code is built and checked; now let me measure it, and see whether the paper's conclusions hold up.

Everything below uses the paper's own parameters: a Plummer model with $M=1$, $r_0=0.2$, cutoff $R=1$, $G=1$, softening equal to the mean interparticle separation at the half-mass radius, and $\delta t = 0.025$.

## Does it stay put?

The first and most basic test. The model was constructed to be in equilibrium, so if the code is right, the cluster should sit there and do essentially nothing for a long time.

$N = 4096$, $\theta = 1$, 1000 leapfrog steps. **Press play**:

\fig{/assets/Physics/papers/hernquist1987/evolution_anim}

It breathes a little and jiggles, but it does not collapse and it does not evaporate. That is the paper's Fig. 1, and it is more of a test than it looks — a bug in the force calculation, the tree, or the sampling would show up here immediately as a cluster that explodes or implodes within a few crossing times.

A sharper version of the same test is to track the radii containing fixed fractions of the mass. If the model really is stationary, these should be flat lines:

\fig{/assets/Physics/papers/hernquist1987/lagrangian_radii}

They are flat, with the small wobble at early times that we [predicted in part 1](/Pages/Physics/papers/hernquist1987/01_setup/#the_transient) from the cutoff at $R=1$. The 90% radius is the noisiest, which makes sense — it is set by a handful of particles way out in the sparse halo, so it is the most affected by small-number statistics.

## How fast is it?

Now the question the paper is named after.

### Cost against $N$

Time for one force evaluation, per particle, against $\log_{10}N$, for a range of $\theta$. Straight lines on these axes mean $\text{cost} \propto N\log N$:

\fig{/assets/Physics/papers/hernquist1987/timing_vs_N}

For $\theta \gtrsim 0.4$ the curves are straight — the $N\log N$ scaling is real. For $\theta \lesssim 0.3$ (dashed) they bend upwards, because so few cells are being accepted that the method is drifting back towards $O(N^2)$. In the limit $\theta \to 0$ it *is* a direct sum, by construction.

This reproduces the paper's Fig. 3, including where the behaviour changes. Hernquist concludes that $\theta \gtrsim 0.4$ is needed to stay in the $N\log N$ regime, and I find the same.

### Cost against $\theta$

The same data sliced the other way, which is the paper's Fig. 4:

\fig{/assets/Physics/papers/hernquist1987/timing_vs_theta}

The cost falls off a cliff between $\theta = 0$ and $\theta \approx 1$, then flattens out. Beyond $\theta \approx 1$ you are paying a rapidly growing error for almost no further speed-up — which is the practical reason $\theta \sim 0.5$–$1$ is the range everybody actually uses.

The direct cause is visible if you plot the number of terms instead of the time:

\fig{/assets/Physics/papers/hernquist1987/nterms_vs_theta}

At $\theta = 0.05$ a particle is summing over thousands of terms; at $\theta = 1.5$ it is around a hundred. Past $\theta \approx 1$ almost everything is already clumped, so relaxing further just regroups cells that were being accepted anyway.

### When is it actually worth it?

A tree code is not free. It has to build a tree, chase pointers, and do a comparison at every node — while a direct sum is a tight, perfectly predictable inner loop that a compiler can vectorise beautifully. For small $N$, the simple method wins.

\fig{/assets/Physics/papers/hernquist1987/tree_vs_direct}

The crossover at $\theta = 1$ lands at $N \approx 1700$, which is exactly what the paper estimates ("the two are comparable for $N \approx 1700$"). At $N = 32768$ my tree is $24\times$ faster than the direct sum, and the gap keeps widening.

\note{
    I did not expect the crossover to agree so precisely, because it depends on implementation details, language and hardware — none of which are shared with a 1987 FORTRAN code on a CRAY. I think the reason it works is that both sides of the comparison scale the same way with machine speed, so the *ratio* is a property of the algorithm rather than the computer.
}

### What does the quadrupole cost?

\fig{/assets/Physics/papers/hernquist1987/quadrupole_cost}

Keeping the quadrupole moments makes the force evaluation roughly 1.3–1.5 times more expensive, agreeing with the paper's "a factor $\sim 1.5$". Whether that is worth paying is the next question.

## How wrong are the forces?

This is the part I care about most, because speed is worthless if the answer is rubbish.

The measure is the paper's, from eqs. (3.4) and (3.5). For each Cartesian component, compare the tree acceleration against a direct sum on the same particles, take the mean offset, and then the mean absolute deviation about it:

$$
\overline{\delta a_i} = \frac{1}{N}\sum_j\left(a^{\text{tree}}_{i,j}-a^{\text{direct}}_{i,j}\right), \qquad
A(\delta a_i) = \frac{1}{N}\sum_j\left|a^{\text{tree}}_{i,j}-a^{\text{direct}}_{i,j}-\overline{\delta a_i}\right|
$$

and quote $A(\delta a_i)/\bar a_i$ as a percentage.

\note{
    Why the mean absolute deviation rather than a plain average error? Because the errors have essentially **random sign** — a cell approximated badly might pull a particle slightly left, the next one slightly right. The mean $\overline{\delta a_i}$ is typically a hundred times smaller than the spread, so it would badly understate how wrong an individual force is. The scatter is what matters.
}

\fig{/assets/Physics/papers/hernquist1987/error_vs_theta}

This is the paper's Fig. 6 and it is the plot to remember. At $\theta = 0.5$ the error is about $0.2\%$; at $\theta = 1$ it is $1.5\%$; at $\theta = 2$ it is over $10\%$ and the method is useless. The rise is steep and the useful range is narrow.

My numbers next to the paper's:

| $N$ | $\theta = 0.5$ | $\theta = 1.0$ |
| --- | --- | --- |
| 1024 | 0.43% | 2.91% |
| 4096 | 0.31% | 2.32% |
| 16384 | 0.22% | 1.71% |
| 32768 | 0.18% | 1.55% |
| *paper, $N=32768$* | *$\approx 0.2\%$* | *$\approx 1.4\%$* |

### The error gets *better* with more particles

Look at the columns above again — the error goes **down** as $N$ goes up. That surprised me at first. More particles means a deeper tree and more approximations, so surely more error?

\fig{/assets/Physics/papers/hernquist1987/error_vs_N}

Over this range the fitted behaviour is $\sim N^{-1/5}$, exactly the scaling the paper reports (my exponent is $-0.18$).

Here is the reasoning I eventually settled on. Each accepted cell contributes a small error of random sign, so the total error on a particle is a **random walk** over the $n_\text{terms}$ cells it used. A random walk of $n$ steps of size $\epsilon$ accumulates $\sqrt{n}\,\epsilon$, not $n\epsilon$. Meanwhile the true acceleration itself grows as more mass is resolved. The competition between those two gives a slow decline — and it is *slow*: to halve the error you would need to increase $N$ by a factor of 32.

\note{
    **A caveat I only found later.** Taken out to $N = 524288$ in part 6, the $N^{-1/5}$ law turns out **not to continue** — the exponent flattens to $-0.095$ and keeps shrinking, because at fixed $\theta$ the error approaches a constant floor rather than decaying to zero. So it is a good description over the range the paper measured, and a bad thing to extrapolate.
}

The practical conclusion is unchanged, only sharpened: **you cannot fix a tree code by throwing particles at it.** You fix it with $\theta$.

### Does the quadrupole help?

\fig{/assets/Physics/papers/hernquist1987/error_mono_vs_quad}

At small $\theta$, enormously. At $\theta = 0.5$ the quadrupole version has error $0.05\%$ against the monopole's $0.18\%$ — nearly four times better. At $\theta = 1$, $1.04\%$ against $1.55\%$, only about a third better.

The trend is clearer as a ratio, which is the paper's Fig. 7:

\fig{/assets/Physics/papers/hernquist1987/error_ratio}

The curve rises towards zero (no gain) as $\theta$ grows, and this is exactly the convergence issue from [part 3](/Pages/Physics/papers/hernquist1987/03_treecode/#how_good_is_it). The expansion is a power series in $s/d$; once $\theta \gtrsim 1$ we are evaluating it at $s/d \gtrsim 1$, where it is not guaranteed to converge, so adding the next term is not guaranteed to help.

\tip{
    The practical way to read this: the quadrupole is not "more accuracy for 1.5× the cost". It is a way of **buying a larger $\theta$ at the same accuracy**. My quadrupole run at $\theta = 1$ is about as accurate as my monopole run at $\theta = 0.7$, and it is faster than that, so it wins. At small $\theta$ the accuracy gain is enormous but you were already accurate, so it may be wasted money. Which is better genuinely depends on what accuracy you need.
}

### Softening fights the expansion

The last error test, and the one with the nicest physics in it. What happens when the softening length $\varepsilon$ becomes comparable to the interparticle separation $\lambda$?

\fig{/assets/Physics/papers/hernquist1987/error_vs_softening}

For small $\varepsilon$ the error *drops* — softening smooths out the very close pairs whose forces are hardest to approximate. But past $\varepsilon/\lambda \approx 1$ it climbs again, and, strikingly, **the quadrupole version becomes worse than the monopole one**.

The reason is worth spelling out, because it is not a numerical accident. The multipole expansion I derived in part 3 is an expansion for **point masses**: it assumes each particle in the cell is a point at $\vec s_k$. Softening replaces every particle by a smeared blob of size $\varepsilon$. Once $\varepsilon$ is comparable to the cell size, the "shape" that $\mathbf{Q}$ is carefully describing is no longer the shape of the actual mass distribution — the quadrupole is now correcting for a geometry that the force law does not have. So the correction stops being a correction.

This is the paper's Fig. 8, and its conclusion — that the useful range is $\varepsilon/\lambda \approx 1$–$2$ — is what I find too.

## The conservation laws

Approximating forces has consequences beyond a number being slightly wrong, and this is the part of the paper I find most instructive.

### Energy

\fig{/assets/Physics/papers/hernquist1987/energy_conservation}

Energy drift turns out to be a genuinely noisy quantity — the same run with a different random seed can differ by a factor of three — so single numbers are not worth much here. Averaging over eight independent realisations:

| | direct sum | $\theta = 0.5$ | $\theta = 1$ |
| --- | --- | --- | --- |
| mine, 8 seeds | $0.22 \pm 0.10\%$ | $0.26 \pm 0.10\%$ | $0.96 \pm 0.14\%$ |
| Hernquist (1987) | $0.20\%$ | $0.32\%$ | $0.68\%$ |

The first two land on the paper's values. The $\theta=1$ column is about two standard deviations high, in the same direction as my slightly larger force error at that $\theta$ — see [the discussion on the front page](/Pages/Physics/papers/hernquist1987/#how_much_of_this_is_noise).

The instructive part is that **the direct sum does not conserve energy either**. Its $0.12\%$ comes entirely from the leapfrog's finite step size, and it is the floor that no force approximation can go below. At $\theta = 0.5$ the tree's contribution is comparable to the integrator's; at $\theta = 1$ the tree dominates. That tells you how to spend effort: there is no point using a fancier integrator at $\theta=1$.

But that floor is not fixed — it depends on the softening, and much more violently than I expected. Here is the same 800-step run repeated across a factor of 64 in $\varepsilon$:

\fig{/assets/Physics/papers/hernquist1987/epsilon_energy}

| $\varepsilon/\lambda$ | 0.0625 | 0.125 | 0.25 | 0.5 | 1.0 | 2.0 | 4.0 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| $\Delta E/E$ | $+51.6\%$ | $+34.0\%$ | $+15.9\%$ | $+3.35\%$ | $+0.15\%$ | $+0.005\%$ | $-0.29\%$ |

At $\varepsilon = \lambda/16$ the simulation gains half its own energy. The mechanism is [explained in part 1](/Pages/Physics/papers/hernquist1987/01_setup/#and_a_warning_about_making_varepsilon_small): $\varepsilon$ sets the hardest encounter in the system, and a fixed $\delta t$ can only resolve encounters that are not too hard.

\note{
    This reframes the whole error budget. It is tempting to think of the three error sources — time step, force approximation, softening — as independent knobs. They are not. **Softening and time step are coupled**, and at $\varepsilon\ll\lambda$ the integrator error swamps everything the tree could possibly do wrong. Chasing $\theta$ down to $0.3$ while running at $\varepsilon = \lambda/8$ would be spending effort in exactly the wrong place.
}

### Momentum — the one that really breaks

Here is the subtle failure, and it is the paper's sharpest observation.

Think about what happens when a particle interacts with a distant cell. The particle feels the pull of the whole cell. But the cell does **not** feel the pull of the particle — instead, each particle inside that cell separately does its own tree walk, and *its* view of our particle may be as part of a different cell entirely.

So the force of $A$ on $B$ is not equal and opposite to the force of $B$ on $A$. **Newton's third law is broken by construction.** And momentum conservation is a direct consequence of the third law, so momentum is not conserved:

\fig{/assets/Physics/papers/hernquist1987/com_drift}

The centre of mass, which should sit still forever, executes a random walk. At $\theta = 1$ it wanders about $1\%$ of the system radius over 1000 steps; at $\theta = 0.5$ it is roughly ten times smaller.

\note{
    A direct sum conserves momentum **exactly**, to round-off, because it adds $+\vec f$ to one particle and $-\vec f$ to the other in the same operation. No amount of time-step refinement fixes the tree's drift, because it is not a time-stepping error at all — it is baked into the force calculation, and the only control you have is $\theta$.
}

This is the sort of thing that makes me like this paper. It is not just "here is a fast algorithm", it is "here is precisely which piece of physics I traded away, and here is how much".

## Is the tree code more collisional?

The last question, and it is a genuinely worrying one.

A star cluster relaxes because individual stars deflect each other — the granularity of the mass distribution slowly randomises orbits, on the **relaxation time** $t_r$. A tree code replaces groups of stars with single massive pseudo-particles. Bigger lumps mean bigger deflections. So does the tree make the simulation artificially more collisional than it should be, silently corrupting the physics?

The paper tests this with the Standish & Aksnes method, and so did I: fire massless test particles through the system, measure how much they are deflected in one crossing, and form

$$
t_r = \frac{\langle \Delta t\rangle}{\langle\sin^2\Phi\rangle}
$$

Then quote everything relative to a direct calculation, $t_r(\theta)/t_r(0)$:

\fig{/assets/Physics/papers/hernquist1987/relaxation}

The answer is **no**, at least in the range anyone uses. For $\theta \lesssim 1.1$ the ratio sits on 1 within the error bars — the tree code is no more collisional than a direct sum. Only beyond $\theta \approx 1.2$ does it start to fall, reaching about $0.8$ at $\theta = 1.4$ with softening.

This matches the paper's Fig. 10, including the detail that the $\varepsilon = 0$ curves are much noisier — without softening, the occasional very close encounter dominates the deflection statistics and the variance goes through the roof.

\note{
    This is the result that makes tree codes respectable rather than merely fast. It says that grouping particles for the purpose of computing forces does **not** import a spurious graininess into the dynamics. Without it you could not trust a tree code for anything where relaxation matters.
}

## What I take away from it

Pulling the threads together, the picture that emerges is clean:

* The $N\log N$ scaling is **real** for $\theta \gtrsim 0.4$, and the tree beats a direct sum from about $N \sim 1700$ upwards.
* The force error is controllable and predictable, about $1\%$ at $\theta=1$ and $0.2\%$ at $\theta=0.5$, improving only glacially with $N$.
* The quadrupole is best understood as a way of affording a larger $\theta$, not as free accuracy.
* Energy conservation is comparable to a direct calculation. **Momentum conservation is not**, and cannot be fixed except by lowering $\theta$.
* Collisionality is unaffected for $\theta \lesssim 1.1$.

Which lands on $\theta \approx 0.5$–$1.0$ as the sensible operating range, exactly where the paper's abstract puts it.

Some things I did not do, if you want to take this further:

1. **Individual time steps.** Every particle currently takes the same $\delta t$, set by the fastest one. Giving core particles smaller steps than halo particles should be a large win.
2. **Octupole terms.** The $n=3$ term gives $\mathcal{O}((s/d)^4)$ — worth it, or is the extra bookkeeping self-defeating? I went and did this one; see [part 6](/Pages/Physics/papers/hernquist1987/06_beyond/).
3. **A better opening criterion.** $s/d<\theta$ is crude, since it ignores where the mass inside a cell actually sits. Modern codes use criteria based on the multipole moments themselves.
4. **Reversing the drift.** Since momentum is not conserved, why not re-centre the system every step? The paper suggests it; does it introduce artefacts of its own?

---

**Previous:** [Part 3 — The tree and the multipole expansion](/Pages/Physics/papers/hernquist1987/03_treecode/)\\
**Next:** [Part 5 — The code](/Pages/Physics/papers/hernquist1987/05_code/), then [Part 6 — Doing better than 1987](/Pages/Physics/papers/hernquist1987/06_beyond/)

Hope this helps you in some way. If you like it then share with others if possible.

If you have some queries, do let me know in the comments or contact me using the informations that are given on the page [About Me](/Pages/about_me/).

~~~
<button onclick="window.history.back()">Go Back</button>
~~~
