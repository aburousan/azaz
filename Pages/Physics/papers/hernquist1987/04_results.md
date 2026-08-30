+++
title = "Tree Codes 4: Results"
hascode = true
date = Date(2026, 8, 4)
rss = "Part 4 of recreating Hernquist (1987): the evolving cluster, timing against N and theta, force errors, softening, conservation laws and relaxation, all measured with my own Julia code."

tags = ["Julia", "physics", "papers", "N-body", "Barnes-Hut", "simulation"]
+++

\toc

# 4. Results

Part 4 of my recreation of [Hernquist (1987)](/Pages/Physics/papers/hernquist1987/). The code is built and checked; now let me measure it and see whether the paper's conclusions hold up.

Everything below uses the paper's own parameters: a Plummer model with $M=1$, $r_0=0.2$, cutoff $R=1$, $G=1$, softening equal to the mean interparticle separation at the half-mass radius and $\delta t = 0.025$.

## Does it stay put?

The first and most basic test. The model was constructed to be in equilibrium, so if the code is right, the cluster should sit there and do essentially nothing for a long time.

$N = 4096$, $\theta = 1$, 1000 leapfrog steps. **Press play**:

\fig{/assets/Physics/papers/hernquist1987/evolution_anim}

Press play and watch whether the blob stays the same size. It does, so the cluster is in equilibrium and the code is not quietly blowing it up.

It breathes a little and jiggles, but it does not collapse and it does not evaporate. That is the paper's Fig. 1, and a harder test than it looks. A bug in the force calculation, the tree or the sampling would show up here immediately as a cluster that explodes or implodes within a few crossing times.

A sharper version of the same test is to track the radii containing fixed fractions of the mass. If the model really is stationary, these should be flat lines:

\fig{/assets/Physics/papers/hernquist1987/lagrangian_radii}

Time goes right, radius goes up. Each curve is the radius holding a fixed share of the mass, so flat lines mean the cluster is not expanding or collapsing. They are flat.

The small wobble at early times is the one we [predicted in part 1](/Pages/Physics/papers/hernquist1987/01_setup/#the_transient) from the cutoff at $R=1$. The 90% radius is the noisiest, which makes sense: it is set by a handful of particles way out in the sparse halo, so it is the most affected by small-number statistics.

## How fast is it?

Now the question the paper is named after.

### Cost against $N$

Time for one force evaluation, per particle, against $\log_{10}N$, for a range of $\theta$. Straight lines on these axes mean $\text{cost} \propto N\log N$:

\fig{/assets/Physics/papers/hernquist1987/timing_vs_N}

For $\theta \gtrsim 0.4$ the curves are straight, so the $N\log N$ scaling is real. For $\theta \lesssim 0.3$ (dashed) they bend upwards, because so few cells are being accepted that the method is drifting back towards $O(N^2)$. In the limit $\theta \to 0$ it *is* a direct sum, by construction.

This reproduces the paper's Fig. 3, including where the behaviour changes. Hernquist concludes that $\theta \gtrsim 0.4$ is needed to stay in the $N\log N$ regime, and I find the same.

### Cost against $\theta$

The same data sliced the other way, which is the paper's Fig. 4:

\fig{/assets/Physics/papers/hernquist1987/timing_vs_theta}

$\theta$ goes right, time per force evaluation goes up. The cost drops very fast up to about $\theta = 1$ and then flattens, so there is no point pushing $\theta$ higher: you pay in error and get almost no speed.

That flattening is the practical reason $\theta \sim 0.5$ to $1$ is the range everybody actually uses.

The direct cause is visible if you plot the number of terms instead of the time:

\fig{/assets/Physics/papers/hernquist1987/nterms_vs_theta}

Same story with the machine taken out of it. $\theta$ goes right, terms per particle goes up. Thousands of terms at small $\theta$, about a hundred at large $\theta$.

Past $\theta \approx 1$ almost everything is already clumped, so relaxing further just regroups cells that were being accepted anyway.

### When is it actually worth it?

A tree code is not free. It has to build a tree, chase pointers and do a comparison at every node, while a direct sum is a tight, perfectly predictable inner loop that a compiler can vectorise beautifully. For small $N$, the simple method wins.

\fig{/assets/Physics/papers/hernquist1987/tree_vs_direct}

Number of particles goes right, time goes up. Below the crossing point the simple $N^2$ sum is actually faster, so a tree is only worth building once you have a few thousand particles.

At $N = 32768$ my tree is $24\times$ faster than the direct sum, and the gap keeps widening.

Where exactly the crossover falls is the interesting part, and I got this badly wrong the first time I wrote it up, so let me do it carefully.

| | Hernquist (1987) | this work |
| --- | --- | --- |
| crossover $N$, $\theta = 1$ | $\approx 1700$ | already below $1024$ |
| crossover $N$, $\theta = 0.5$ | $\approx 7000$ | $\approx 2300$ |

At $\theta = 1$ my tree is **already faster at the smallest $N$ I measured**: at $N = 1024$ the direct sum takes $3.96$ ms and the tree $2.88$ ms, so the crossing has happened before the plot starts.

\note{
    **An earlier version of this page claimed the crossover landed at $N\approx1700$, "exactly what the paper estimates", and then argued that the ratio must be a property of the algorithm rather than the computer.** Both halves were wrong, and the second one was wrong in an instructive way, so I am leaving the wreckage visible instead of quietly deleting it.

    The crossover is the point where **two inner loops break even**, and how fast each of those loops runs is a fact about the machine, not about the mathematics. A direct sum is a tight, perfectly predictable, branch-free loop, which is exactly the shape of code a CRAY X-MP's vector units were built to devour. A tree walk is a pointer chase through a stack with an unpredictable branch at every node, which is the shape of code that machine was worst at. So on a CRAY the tree started a long way behind and only caught up near $N\approx1700$. On a modern out-of-order core the two loops are much closer in speed, so my tree catches up far sooner.

    **The crossover has to be measured again on every architecture.** It is the one number in this entire project that I should have expected *not* to reproduce, and I talked myself into being pleased when it seemed to.
}

\tip{
    A useful way to tell the two kinds of number apart, which I wish I had had at the start. Ask whether the quantity would change if you reran the identical code on a different machine. The force error would not: it comes from truncating a series, and it is mathematics. The crossover would: it is a ratio of two wall-clock times. Anything in the second category is a benchmark, not a result, and agreement with 1987 is a coincidence rather than a confirmation.
}

### What does the quadrupole cost?

\fig{/assets/Physics/papers/hernquist1987/quadrupole_cost}

How much extra time the shape term costs, as a ratio. It does not grow with $N$, so whatever it costs, it costs that once and for all.

Measured as whole force evaluations at matched $\theta$, the ratio comes out around $1.3$ to $1.5$, which looks like a clean confirmation of the paper's "a factor $\sim 1.5$". It is not, and it took me a while to see why. That ratio is contaminated by the tree build, by how many cells happened to be accepted, and by memory behaviour that has nothing to do with the quadrupole. **The honest quantity is the cost per accepted cell**, which strips all of that out:

| terms kept | cost per accepted cell | ratio |
| --- | --- | --- |
| monopole | $23$ ns | $1$ |
| quadrupole | $26$ ns | $1.11$ |
| octupole | $48$ ns | $2.07$ |

So on this machine **the quadrupole is $11\%$ dearer than the monopole, not $50\%$.** That is a real disagreement with 1987, and it is not a disagreement about the algorithm, which has not changed. It is architectural.

\note{
    A CRAY X-MP was limited by **arithmetic**: if you asked it to do more floating-point operations per cell, you waited longer, more or less in proportion. A present-day core is usually limited by **memory**: most of the time it is sitting idle waiting for a cache line to arrive. The extra quadrupole arithmetic hides inside that wait and is very nearly free.

    You can watch this happening in the same data. The cost per accepted cell is not even constant for a *fixed* multipole order: for the monopole it climbs from $18$ ns at $\theta = 1.4$ to $31$ ns at $\theta = 0.15$. The arithmetic per cell is literally identical in the two cases. What changes is that at large $\theta$ the walk uses a few big cells near the top of the tree, which every particle reuses and which therefore live permanently in cache, while at small $\theta$ it reaches deep cells scattered all over memory. Khandai and Bagla build much of their TreePM optimisation on exactly this, by letting a *group* of neighbouring particles share one tree walk so each cell is fetched once instead of once per particle.
}

Whether the extra term is worth paying for is a different question from what it costs, and [part 6](/Pages/Physics/papers/hernquist1987/06_beyond/#but_is_it_worth_it) answers it properly, at matched accuracy rather than matched $\theta$.

## How wrong are the forces?

This is the part I care about most. Speed is worthless if the answer is rubbish.

The measure is the paper's, from eqs. (3.4) and (3.5). For each Cartesian component, compare the tree acceleration against a direct sum on the same particles, take the mean offset, then take the mean absolute deviation about it:

$$
\overline{\delta a_i} = \frac{1}{N}\sum_j\left(a^{\text{tree}}_{i,j}-a^{\text{direct}}_{i,j}\right), \qquad
A(\delta a_i) = \frac{1}{N}\sum_j\left|a^{\text{tree}}_{i,j}-a^{\text{direct}}_{i,j}-\overline{\delta a_i}\right|
$$

and quote $A(\delta a_i)/\bar a_i$ as a percentage.

\note{
    Why the mean absolute deviation rather than a plain average error? Because the errors have essentially **random sign**: a cell approximated badly might pull a particle slightly left, the next one slightly right. The mean $\overline{\delta a_i}$ is typically a hundred times smaller than the spread, so it would badly understate how wrong an individual force is. The scatter is what matters.
}

\fig{/assets/Physics/papers/hernquist1987/error_vs_theta}

$\theta$ goes right, force error goes up. This is the plot that decides everything: about $0.2\%$ at $\theta = 0.5$, $1.5\%$ at $\theta = 1$, and useless beyond $\theta = 2$. The usable range is narrow.

This is the paper's Fig. 6, and if you remember one plot from the series, make it this one.

My numbers next to the paper's:

| $N$ | $\theta = 0.5$ | $\theta = 1.0$ |
| --- | --- | --- |
| 1024 | 0.43% | 2.91% |
| 4096 | 0.31% | 2.32% |
| 16384 | 0.22% | 1.71% |
| 32768 | 0.18% | 1.55% |
| *paper, $N=32768$* | *$\approx 0.2\%$* | *$\approx 1.4\%$* |

### The error gets *better* with more particles

Look at the columns above again. The error goes **down** as $N$ goes up. That surprised me at first. More particles means a deeper tree and more approximations, so surely more error?

\fig{/assets/Physics/papers/hernquist1987/error_vs_N}

Particles go right, error goes up, both log. The line slopes gently downwards, so adding particles does reduce the error, but so slowly that it is not a practical way to get accuracy.

Over this range the fitted behaviour is $\sim N^{-1/5}$, exactly the scaling the paper reports (my exponent is $-0.18$).

The reasoning I eventually settled on goes like this. Each accepted cell contributes a small error of random sign, so the total error on a particle is a **random walk** over the $n_\text{terms}$ cells it used. A random walk of $n$ steps of size $\epsilon$ accumulates $\sqrt{n}\,\epsilon$, not $n\epsilon$. Meanwhile the true acceleration itself grows as more mass is resolved. The competition between those two gives a slow decline, and it is genuinely slow: to halve the error you would need to increase $N$ by a factor of 32.

\note{
    **A caveat I only found later.** Taken out to $N = 524288$ in part 6, the $N^{-1/5}$ law turns out **not to continue**. The exponent flattens to $-0.095$ and keeps shrinking, because at fixed $\theta$ the error approaches a constant floor rather than decaying to zero. So it is a good description over the range the paper measured, and a bad thing to extrapolate.
}

The practical conclusion is unchanged, only sharpened: **you cannot fix a tree code by throwing particles at it.** You fix it with $\theta$.

### Does the quadrupole help?

\fig{/assets/Physics/papers/hernquist1987/error_mono_vs_quad}

Two curves, with and without the shape term. The gap between them is what the shape term buys, and it is large on the left and small on the right. So the shape term is worth most when you are already being careful.

At small $\theta$, enormously. At $\theta = 0.5$ the quadrupole version has error $0.05\%$ against the monopole's $0.18\%$, nearly four times better. At $\theta = 1$, $1.04\%$ against $1.55\%$, only about a third better.

The trend is clearer as a ratio, which is the paper's Fig. 7:

\fig{/assets/Physics/papers/hernquist1987/error_ratio}

The same gap drawn as a ratio. It shrinks towards zero as $\theta$ grows, meaning at large $\theta$ the extra term stops helping. That is the series failing to converge, exactly as part 3 warned.

This is exactly the convergence issue from [part 3](/Pages/Physics/papers/hernquist1987/03_treecode/#how_good_is_it). The expansion is a power series in $s/d$; once $\theta \gtrsim 1$ we are evaluating it at $s/d \gtrsim 1$, where it is not guaranteed to converge, so adding the next term is not guaranteed to help.

\tip{
    The practical way to read this: the quadrupole is not "more accuracy for 1.5× the cost". It is a way of **buying a larger $\theta$ at the same accuracy**. My quadrupole run at $\theta = 1$ is about as accurate as my monopole run at $\theta = 0.7$, and it is faster than that, so it wins. At small $\theta$ the accuracy gain is enormous but you were already accurate, so it may be wasted money. Which is better genuinely depends on what accuracy you need.
}

### Softening fights the expansion

The last error test, and the one with the nicest physics in it. What happens when the softening length $\varepsilon$ becomes comparable to the interparticle separation $\lambda$?

\fig{/assets/Physics/papers/hernquist1987/error_vs_softening}

Softening goes right, error goes up. A little softening helps, too much hurts, and past $\varepsilon \approx \lambda$ the shape term actually makes things worse than not using it at all.

For small $\varepsilon$ the error *drops*, because softening smooths out the very close pairs whose forces are hardest to approximate. But past $\varepsilon/\lambda \approx 1$ it climbs again, and strikingly **the quadrupole version becomes worse than the monopole one**.

This is not a numerical accident. The multipole expansion I derived in part 3 is an expansion for **point masses**: it assumes each particle in the cell is a point at $\vec s_k$. Softening replaces every particle by a smeared blob of size $\varepsilon$. Once $\varepsilon$ is comparable to the cell size, the "shape" that $\mathbf{Q}$ is carefully describing is no longer the shape of the actual mass distribution, so the quadrupole is correcting for a geometry that the force law does not have. So the correction stops being a correction.

This is the paper's Fig. 8, and its conclusion that the useful range is $\varepsilon/\lambda \approx 1$ to $2$ is what I find too.

## Where the error actually comes from

Now a measurement that was simply not practical on 1987 hardware, and which answers a question the plots above raise without settling.

Compare the two slopes. A single isolated cell, truncated after the term $n = k-1$, has a relative error of order $(s/d)^k$, and I measured exactly that: fitted slopes of $1.99$, $3.01$ and $4.00$ against the predicted $2$, $3$ and $4$. But the **full tree walk** does better than that. Fitting the force error over $0.15\le\theta\le1$ gives

$$
\text{error} \;\propto\; \theta^{2.75},\qquad \theta^{3.97},\qquad \theta^{4.68}
$$

Every one of those is about **one full power of $\theta$ steeper** than the single-cell rule. At $\theta = 0.3$ that is already close to a factor of three in accuracy, which is enough to change what a real calculation costs. Where does the extra power come from?

### Instrumenting the walk

To find out I put instruments inside the tree walk. For one target particle, every accepted cell now records two accelerations: the multipole approximation it contributed, and the **exact** contribution obtained by summing the particles inside that cell one at a time. The difference is that cell's exact error vector.

\note{
    This is not an estimate or a model, and the reason is worth stating. The accepted cells **partition** the source particles: every other particle in the system is inside exactly one accepted cell, or is itself an accepted leaf. So adding up all the exact contributions gives back the direct sum, identically. The error vectors therefore add up to the total force error, exactly, with nothing left over.
}

And the picture that comes out is simple. Every accepted cell leaves behind a small error **arrow**. If all those arrows point roughly the same way, they add up and the total error is large. If they point in many different directions, most of the error cancels, the way the net displacement of a random walk is much smaller than the distance walked.

\defn{
    Ten errors of length one add to length ten if they are aligned. If their directions are unrelated, the typical resultant is about $\sqrt{10}$. A tree force is a **vector** sum, so this cancellation matters just as much as how wrong any single cell is.
}

To measure the alignment, define

$$
\kappa \;=\; \frac{\left|\sum_c \delta\vec a_c\right|}{\sqrt{\sum_c\left|\delta\vec a_c\right|^2}}
$$

If every cell error pointed the same way, the numerator would be the sum of their lengths and $\kappa$ would be $\sqrt{n}$ for $n$ cells. If they point in unrelated directions they add in quadrature and $\kappa$ stays of order one.

The answer is unambiguous. Across three multipole orders, eight values of $\theta$ and 256 target particles, $\kappa$ sits between $0.81$ and $1.13$ in twenty-three of the twenty-four combinations, while $\sqrt{n}$ over the same runs ranges from $14$ to $64$.

\note{
    The twenty-fourth is the octupole at $\theta=0.2$, where $\kappa = 1.58$. I do not think that one means anything: at that setting the total octupole error is about $4\times10^{-6}$ of the force, and the reference direct sum I am differencing against is itself only good to roughly that level, so what I am measuring there is mostly floating-point round-off. I mention it because "$\kappa$ stays between $0.81$ and $1.13$" is a cleaner sentence than the truth, and the cleaner sentence has one counterexample in it.
}

So the cell errors point in almost unrelated directions, and the cancellation is large:

| | monopole | quadrupole | octupole |
| --- | --- | --- | --- |
| cancellation factor at $\theta = 0.2$ | $33$ | $23$ | $13$ |
| cancellation factor at $\theta = 1.0$ | $5.2$ | $4.4$ | $3.9$ |

where the cancellation factor is the sum of the error **lengths** divided by the length of their **sum**. At $\theta=0.2$ with quadrupoles, about $96\%$ of the error made by individual cells cancels against other cells before it ever reaches the answer. Notice the factor shrinks as $\theta$ grows, for the plain reason that there are fewer cells left to cancel against.

### The law that comes out of it

Now the argument writes itself. Suppose accepted cell $c$ contributes a force of size $a_c$ with a truncation error of about $C_k\theta^k a_c$. If the directions are only weakly aligned, the total goes like the quadrature sum,

$$
\left|\delta\vec a\right| \sim C_k\theta^k\sqrt{\sum_c a_c^2}
$$

and dividing by the true force,

$$
\frac{\left|\delta\vec a\right|}{\left|\vec a\right|} \sim C_k\theta^k\frac{\sqrt{\sum_c a_c^2}}{\left|\vec a\right|}
$$

If the $n$ accepted cells contribute comparably, so that $a_c\sim|\vec a|/n$, this collapses to

$$
\boxed{\;\frac{\left|\delta\vec a\right|}{\left|\vec a\right|} \;\approx\; c_k\,\frac{\theta^k}{\sqrt n}\;}
$$

with $n$ the number of terms the walk actually used. **That $1/\sqrt n$ is the missing power of $\theta$.** Since $n\propto\theta^{-2.14}$ from the counting model in [part 3](/Pages/Physics/papers/hernquist1987/03_treecode/#a_better_count), the extra factor contributes about $\theta^{1.07}$:

| terms kept | naive $k$ | $k + 1.07$ | measured exponent |
| --- | --- | --- | --- |
| monopole | $2$ | $3.07$ | $2.75$ |
| quadrupole | $3$ | $4.07$ | $3.97$ |
| octupole | $4$ | $5.07$ | $4.68$ |

The quadrupole row is nearly exact, the other two are out by ten to eight per cent in the exponent. So this is clearly the right mechanism and not the whole story, which is what you would expect from an argument that assumed every accepted cell carries the same weight.

Dividing the measured force error by $\theta^k/\sqrt n$ should then give a constant, and it nearly does:

| terms kept | $c_k$ |
| --- | --- |
| monopole | $0.20 \pm 0.02$ |
| quadrupole | $0.117 \pm 0.005$ |
| octupole | $0.09 \pm 0.03$ |

\tip{
    The practical reading: **opening more cells helps you twice over.** Each cell you open is replaced by better-resolved children, which is the obvious gain, and the extra terms give the small errors that remain more chance to cancel against each other, which is the one nobody mentions. That second effect is worth roughly a full power of $\theta$, and it is the reason a tree code is more accurate than a back-of-envelope truncation estimate says it should be.
}

### Three warnings about that law

It is a working rule and not a theorem, and each of the assumptions it makes fails somewhere.

**It assumed equal weights.** The step from the quadrature sum to $c_k\theta^k/\sqrt n$ needed every accepted cell to contribute comparably, and real cells do not. The rare badly-wrong particles in the next section arise from exactly this: unusual weights and unusual geometry.

**It is an average, not a bound.** It describes what happens to a typical particle in an ordinary cluster-like arrangement of matter. Salmon and Warren proved that the test $s/d<\theta$ carries no guarantee at all once $\theta > 1/\sqrt3 \approx 0.577$, which covers most practical choices including the $\theta=1$ of the 1987 paper. Nothing in this law protects you from that, and [part 6](/Pages/Physics/papers/hernquist1987/06_beyond/#making_a_tree_code_misbehave_on_purpose) builds a configuration where it does not.

**It describes changing $\theta$, not changing $N$.** Going from $N = 3\times10^4$ to $5\times10^5$ at $\theta = 0.5$, the measured error falls by a factor $0.46$, while the $1/\sqrt n$ factor alone predicts only $0.86$. Something else changes with resolution, most likely how the total force is shared among the accepted cells, and I have not isolated it.

### Which cells are doing the damage

The same instrumentation answers a question I had not thought to ask: is the error spread evenly over the accepted cells, or concentrated? Concentrated, and increasingly so:

| terms kept | share of the total squared error from cells with $s/d > 0.8\theta$ |
| --- | --- |
| monopole | $47\%$ |
| quadrupole | $56\%$ |
| octupole | $61\%$ |

Those are the **marginal** cells, the ones that only just squeaked past the opening test. Roughly half the error comes from the cells that were nearly opened, and the fraction rises as you add multipole terms.

\note{
    That trend is not a coincidence and it says something useful. A higher multipole order improves the *comfortable* far-away cells much faster than it improves the marginal ones, because the improvement goes like an extra power of $s/d$ and $s/d$ is small out there and close to $\theta$ here. So each term you add makes the answer better **and** makes the remaining error more concentrated in the few cells that were borderline. That is a direct argument for spending effort on a smarter acceptance test rather than on yet another multipole order, which is exactly where [part 6](/Pages/Physics/papers/hernquist1987/06_beyond/#can_the_opening_test_be_repaired) goes.
}

## What the average error is hiding

Every force error quoted so far, mine and the paper's, is an **average over all the particles**. That is the natural thing to report, and it is what makes the law above possible. But an average can hide precisely the particles that matter most for the dynamics, so let me look at the error one particle at a time:

$$
\epsilon_j = \frac{\left|\vec a^{\,\text{tree}}_j - \vec a^{\,\text{dir}}_j\right|}{\left|\vec a^{\,\text{dir}}_j\right|}
$$

and keep the whole distribution instead of collapsing it to one number. $N = 32768$, quadrupoles, Barnes-Hut test. The 99th percentile means $99\%$ of particles are better than that and $1\%$ are worse:

| $\theta$ | mean | 99th pct | 99.9th pct | worst particle | worst / mean |
| --- | --- | --- | --- | --- | --- |
| $0.15$ | $0.00048\%$ | $0.0013\%$ | $0.0029\%$ | $0.0075\%$ | $15$ |
| $0.2$ | $0.0015\%$ | $0.0048\%$ | $0.012\%$ | $0.033\%$ | $22$ |
| $0.3$ | $0.0069\%$ | $0.029\%$ | $0.058\%$ | $0.13\%$ | $19$ |
| $0.5$ | $0.049\%$ | $0.22\%$ | $0.53\%$ | $1.19\%$ | $24$ |
| $0.7$ | $0.19\%$ | $0.81\%$ | $1.86\%$ | $7.0\%$ | $36$ |
| $1.0$ | $0.96\%$ | $4.50\%$ | $10.6\%$ | $37.6\%$ | $39$ |
| $1.2$ | $2.40\%$ | $12.9\%$ | $43.1\%$ | $124\%$ | $52$ |

Read the $\theta = 1$ row, which is the paper's own opening angle. The mean error is under one per cent, which sounds thoroughly comfortable. But **one particle in a hundred is wrong by more than $4.5\%$, one in a thousand by more than $11\%$, and the worst particle in the cluster is wrong by $38\%$.**

\note{
    **A tree code is not uniformly a little bit wrong.** It is very accurate for almost every particle and occasionally very wrong for a few, and an average cannot tell you which situation you are in. Notice too that the columns are not parallel: as $\theta$ grows the tail pulls away from the mean, from a worst-to-mean ratio of about $15$ at $\theta=0.15$ to about $52$ at $\theta = 1.2$. Pushing $\theta$ up does not just make everything slightly worse; it makes the *distribution* worse-shaped.
}

\tip{
    Whether this matters depends entirely on what you are computing. For a bulk quantity averaged over the whole cluster, a $1\%$ mean error with a fat tail is fine, because the tail is $1\%$ of the particles and they are averaged away. For anything where a few individual orbits matter, a binary hardening, a particle on a nearly radial orbit through the centre, a satellite being disrupted, the tail is exactly the population you care about. **Quote the tail as well as the mean, or you have not reported your error.**
}

\prob{
    Reproduce that table for your own code at one value of $\theta$, then go and find the worst particle and ask *why* it is worst. Where is it in the cluster? How many terms did its walk use, compared with the average? Which single accepted cell contributed most of its error, and what does that cell look like? I found this more instructive than any amount of staring at mean errors.
}

## The conservation laws

Approximating forces has consequences beyond a number being slightly wrong, and this is the part of the paper I find most instructive.

### Energy

\fig{/assets/Physics/papers/hernquist1987/energy_conservation}

Time goes right, energy error goes up. The important thing is that even the exact $N^2$ sum does not sit at zero, so some of the error was never the tree's fault.

Energy drift turns out to be a genuinely noisy quantity, since the same run with a different random seed can differ by a factor of three, so single numbers are not worth much here. Averaging over eight independent realisations:

| | direct sum | $\theta = 0.5$ | $\theta = 1$ |
| --- | --- | --- | --- |
| mine, 8 seeds | $0.22 \pm 0.10\%$ | $0.26 \pm 0.10\%$ | $0.96 \pm 0.14\%$ |
| Hernquist (1987) | $0.20\%$ | $0.32\%$ | $0.68\%$ |

The first two land on the paper's values. The $\theta=1$ column is about two standard deviations high, in the same direction as my slightly larger force error at that $\theta$. See [the discussion on the front page](/Pages/Physics/papers/hernquist1987/#how_much_of_this_is_noise).

The instructive part is that **the direct sum does not conserve energy either**. Its $0.12\%$ comes entirely from the leapfrog's finite step size, and it is the floor that no force approximation can go below. At $\theta = 0.5$ the tree's contribution is comparable to the integrator's; at $\theta = 1$ the tree dominates. That tells you how to spend effort: there is no point using a fancier integrator at $\theta=1$.

But that floor is not fixed. It depends on the softening, and much more violently than I expected. The same 800-step run, repeated across a factor of 64 in $\varepsilon$:

\fig{/assets/Physics/papers/hernquist1987/epsilon_energy}

Softening goes right, energy error goes up, both on log axes. Read it right to left: as the softening shrinks the error climbs by a factor of a thousand. So the left end of this plot is not more accurate physics, it is a broken simulation.

| $\varepsilon/\lambda$ | 0.0625 | 0.125 | 0.25 | 0.5 | 1.0 | 2.0 | 4.0 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| $\Delta E/E$ | $+51.6\%$ | $+34.0\%$ | $+15.9\%$ | $+3.35\%$ | $+0.15\%$ | $+0.005\%$ | $-0.29\%$ |

At $\varepsilon = \lambda/16$ the simulation gains half its own energy. The mechanism is [explained in part 1](/Pages/Physics/papers/hernquist1987/01_setup/#and_a_warning_about_making_varepsilon_small): $\varepsilon$ sets the hardest encounter in the system, so a fixed $\delta t$ can only resolve encounters that are not too hard.

\note{
    This reframes the whole error budget. It is tempting to think of the three error sources (time step, force approximation, softening) as independent knobs. They are not. **Softening and time step are coupled**, and at $\varepsilon\ll\lambda$ the integrator error swamps everything the tree could possibly do wrong. Chasing $\theta$ down to $0.3$ while running at $\varepsilon = \lambda/8$ would be spending effort in exactly the wrong place.
}

### Momentum, the one that really breaks

Now the subtle failure, and the paper's sharpest observation.

Think about what happens when a particle interacts with a distant cell. The particle feels the pull of the whole cell. But the cell does **not** feel the pull of the particle. Instead, each particle inside that cell separately does its own tree walk, and *its* view of our particle may be as part of a different cell entirely.

So the force of $A$ on $B$ is not equal and opposite to the force of $B$ on $A$. **Newton's third law is broken by construction.** And momentum conservation is a direct consequence of the third law, so momentum is not conserved:

\fig{/assets/Physics/papers/hernquist1987/com_drift}

Time goes right, distance wandered goes up. The centre of mass should never move at all, and it does. Lowering $\theta$ is the only thing that helps.

It is a random walk, and the size of it depends only on $\theta$. At $\theta = 1$ the centre wanders about $1\%$ of the system radius over 1000 steps; at $\theta = 0.5$ it is roughly ten times smaller.

That drift is a *consequence*, measured after a thousand steps. It is more useful to measure the cause directly, in a single force evaluation, so I also track the spurious force on the centre of mass against the total force scale:

$$
\eta_P = \frac{\left|\sum_i m_i\vec a_i\right|}{\sum_i m_i\left|\vec a_i\right|}
$$

A direct pair sum must give zero here, up to round-off, because every interaction is added twice with opposite signs. A one-sided particle-to-cell walk has no such symmetry, so this number must be small and must **not** be zero. If it ever came out at round-off for a tree walk, I would go looking for a bug in my diagnostic. At $N = 8192$ with quadrupoles and $\varepsilon = 0$, averaged over three realisations:

| | $\eta_P$ |
| --- | --- |
| direct sum | $4.0\times10^{-17}$ |
| tree, $\theta = 0.5$ | $1.3\times10^{-5}$ |
| tree, $\theta = 1.0$ | $1.6\times10^{-4}$ |

So at $\theta = 1$ the tree invents a net force on the whole cluster equal to about two parts in ten thousand of the total force scale, out of nothing, every single step. Lowering $\theta$ to $0.5$ cuts it by twelve.

\tip{
    While I had that diagnostic running I used it for a second check that has nothing to do with momentum. **Translation covariance**: shift every particle by the same fixed vector, rebuild the tree from scratch, recompute. The exact force cannot have changed, so the tree's answer must not change either, even though the outer cube and every dividing plane inside it have moved. Both methods agree to about $10^{-15}$, which says the tree is not accidentally depending on where I happened to draw the box. The number of *terms* is allowed to change, and does, for exactly that reason.
}

\note{
    A direct sum conserves momentum **exactly**, to round-off, because it adds $+\vec f$ to one particle and $-\vec f$ to the other in the same operation. No amount of time-step refinement fixes the tree's drift, because it is not a time-stepping error at all. It is baked into the force calculation, and the only control you have is $\theta$.
}

This is the sort of thing that makes me like this paper. It is not just "here is a fast algorithm", it is "here is precisely which piece of physics I traded away and here is how much".

## Is the tree code more collisional?

The last question, and it is a genuinely worrying one.

A star cluster relaxes because individual stars deflect each other. The granularity of the mass distribution slowly randomises orbits, on the **relaxation time** $t_r$. A tree code replaces groups of stars with single massive pseudo-particles. Bigger lumps mean bigger deflections. So does the tree make the simulation artificially more collisional than it should be, silently corrupting the physics?

The paper tests this with the Standish & Aksnes method, and so did I: fire massless test particles through the system, measure how much they are deflected in one crossing, then form

$$
t_r = \frac{\langle \Delta t\rangle}{\langle\sin^2\Phi\rangle}
$$

Then quote everything relative to a direct calculation, $t_r(\theta)/t_r(0)$:

\fig{/assets/Physics/papers/hernquist1987/relaxation}

$\theta$ goes right, and up is the relaxation time compared with the exact calculation. A value of 1 means the tree changed nothing. It stays at 1 up to about $\theta = 1.1$, so grouping particles does not secretly make the physics grainier.

The answer is **no**, at least in the range anyone uses. Only beyond $\theta \approx 1.2$ does the ratio start to fall, reaching about $0.8$ at $\theta = 1.4$ with softening.

This matches the paper's Fig. 10, including the detail that the $\varepsilon = 0$ curves are much noisier. Without softening, the occasional very close encounter dominates the deflection statistics and the variance goes through the roof.

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

Which lands on $\theta \approx 0.5$ to $1.0$ as the sensible operating range, exactly where the paper's abstract puts it.

Some things I did not do, if you want to take this further:

1. **Individual time steps.** Every particle currently takes the same $\delta t$, set by the fastest one. Giving core particles smaller steps than halo particles should be a large win.
2. **Octupole terms.** The $n=3$ term gives $\mathcal{O}((s/d)^4)$. Worth it, or is the extra bookkeeping self-defeating? I went and did this one; see [part 6](/Pages/Physics/papers/hernquist1987/06_beyond/).
3. **A better opening criterion.** $s/d<\theta$ is crude, since it ignores where the mass inside a cell actually sits. I have since tried two geometric repairs and neither of them beats it at equal cost; [part 6 has the comparison](/Pages/Physics/papers/hernquist1987/06_beyond/#can_the_opening_test_be_repaired) and the argument for why the fix has to come from the multipole moments rather than from geometry.
4. **Reversing the drift.** Since momentum is not conserved, why not re-centre the system every step? The paper suggests it; does it introduce artefacts of its own?

---

**Previous:** [Part 3, the tree and the multipole expansion](/Pages/Physics/papers/hernquist1987/03_treecode/)\\
**Next:** [Part 5, the code](/Pages/Physics/papers/hernquist1987/05_code/), then [Part 6, doing better than 1987](/Pages/Physics/papers/hernquist1987/06_beyond/)

Hope this helps you in some way. If you like it then share with others if possible.

If you have some queries, do let me know in the comments or contact me using the informations that are given on the page [About Me](/Pages/about_me/).

~~~
<button onclick="window.history.back()">Go Back</button>
~~~
