+++
title = "Tree Codes 6: Doing Better Than 1987"
hascode = true
date = Date(2026, 8, 4)
rss = "Part 6 of recreating Hernquist (1987): going past the paper with octupole multipoles, a fourth-order symplectic integrator and a million particles."

tags = ["Julia", "physics", "papers", "N-body", "multipole", "octupole", "algorithms"]
+++

\toc

# 6. Doing better than 1987

Part 6 of my recreation of [Hernquist (1987)](/Pages/Physics/papers/hernquist1987/). Everything up to here was reproducing what sir's paper did. This part is about what it *could not* do.

## The gap in hardware

The paper's timings are for a **CRAY X-MP**, one of the fastest machines on Earth in 1987. Hernquist quotes a rate for his largest run of $7.3\times10^{-4}$ CPU seconds per particle per step. My code, on **one** core, single threaded, at the same $N = 32768$ and $\theta = 1$ with monopoles only, runs at about $5.5\times10^{-6}$, so

$$
\frac{7.3\times10^{-4}}{5.5\times10^{-6}} \approx 130
$$

| | Hernquist's simulation | on one of my cores |
| --- | --- | --- |
| $N = 32768$, 300 steps | **2.0 CRAY X-MP CPU hours** | **54 seconds** |

\note{
    Timings on a shared machine move around by about $20\%$ depending on what else is running, and my two independent timing sweeps put the $\theta=1$ monopole evaluation anywhere between $0.17$ and $0.22$ seconds. So read this as "**over a hundred**" rather than as $130$ on the nose. Everything downstream of it survives that uncertainty comfortably; nothing here turns on the second digit.
}

A run that consumed two hours of the world's fastest supercomputer takes under a minute on a single modern core, and I have 48 of them to hand.

It is worth being precise about what that buys and what it does not, because this is the point at which it is easiest to claim too much.

**It does not make the force error of the same approximation any smaller.** That error comes from truncating a series, which is mathematics, and mathematics did not get faster. Two implementations agreeing on the particle realisation, the tree geometry, the cell-size convention, the acceptance test and the multipole prescription should produce the same numbers up to floating point, and mine agrees with the published values to about $1\%$. Had my error come out ten times smaller at the same settings, that would have been evidence of a **bug**, not of progress.

What the hardware buys is the freedom to run settings that could not have been afforded in real work in 1987. So the interesting question is not "can I reproduce it" but **"what would I do differently, given the compute?"**

Three things: carry the multipole expansion one order further, try a better integrator and go to a million particles.

## Going one order further: the octupole

The paper stops at the quadrupole. But nothing forces that. The Legendre series [derived in part 3](/Pages/Physics/papers/hernquist1987/03_treecode/#expanding_1_vec_d_vec_s) goes on forever, and we left it at $n=2$ only because $n=3$ costs more arithmetic. Arithmetic is exactly what has got cheaper.

### The $n=3$ term

Picking up the expansion where part 3 left it, the next Legendre polynomial is

$$
P_3(x) = \frac{5x^3 - 3x}{2}
$$

so the $n=3$ contribution to the potential is

$$
\varphi_3 = -\frac{G}{d^4}\sum_\alpha m_\alpha\,s_\alpha^3\,P_3(\cos\gamma_\alpha)
= -\frac{G}{d^4}\sum_\alpha m_\alpha\,\frac{5(\hat n\cdot\vec s_\alpha)^3 - 3s_\alpha^2(\hat n\cdot\vec s_\alpha)}{2}
$$

using $s_\alpha\cos\gamma_\alpha = \hat n\cdot\vec s_\alpha$ again (and dropping the $\alpha$ on the components to keep the indices readable). Now write it in index notation. The cube gives $(\hat n\cdot\vec s)^3 = \hat n_i\hat n_j\hat n_k\,s_is_js_k$, and for the second piece we need something symmetric in $ijk$ to contract against $\hat n_i\hat n_j\hat n_k$. Using $\hat n\cdot\hat n = 1$,

$$
\hat n_i\hat n_j\hat n_k\left(s_i\delta_{jk} + s_j\delta_{ik} + s_k\delta_{ij}\right) = 3\,(\hat n\cdot\vec s)
$$

Three identical terms, which is exactly the factor of 3 we need. So the whole bracket collapses into one tensor contraction:

$$
\boxed{\;O_{ijk} = \sum_\alpha m_\alpha\left[5\,s_is_js_k - s^2\left(s_i\delta_{jk} + s_j\delta_{ik} + s_k\delta_{ij}\right)\right]\;}
$$

and

$$
\varphi_3 = -\frac{G}{2}\,\frac{O_{ijk}\,d_id_jd_k}{d^7}
$$

Like the quadrupole, this tensor is **traceless**. Contract any pair of indices:

$$
O_{ill} = \sum_\alpha m_\alpha\left[5s_i\,s^2 - s^2\big(\underbrace{3s_i}_{\delta_{ll}=3} + s_i + s_i\big)\right] = \sum_\alpha m_\alpha\left[5s^2s_i - 5s^2s_i\right] = 0
$$

A symmetric rank-3 tensor has 10 independent components; tracelessness removes 3, leaving **7 numbers per cell**.

### The force

Differentiating exactly as we did for the quadrupole, with $S_3 \equiv O_{ijk}d_id_jd_k$ and using $\partial_l S_3 = 3O_{ljk}d_jd_k$ (three equal terms, by the symmetry of $O$):

$$
\boxed{\;a_l^{(3)} = \frac{3G}{2}\,\frac{O_{ljk}d_jd_k}{d^7} \;-\; \frac{7G}{2}\,\frac{S_3\,d_l}{d^9}\;}
$$

I checked all three claims in Mathematica before writing a line of Julia: that the $P_3$ term really equals $\tfrac12\hat n_i\hat n_j\hat n_k O_{ijk}$, that $O$ is traceless and that the acceleration is $-\nabla\varphi_3$:

```mathematica
legTerm3 = s2^(3/2) LegendreP[3, (xk . nh)/Sqrt[s2]];
O3 = Table[mk (5 xk[[i]] xk[[j]] xk[[k]]
        - s2 (xk[[i]] KroneckerDelta[j, k] + xk[[j]] KroneckerDelta[i, k]
              + xk[[k]] KroneckerDelta[i, j])), {i, 3}, {j, 3}, {k, 3}];
FullSimplify[(mk legTerm3 - contract3/2) /. n3 -> Sqrt[1 - n1^2 - n2^2]]   (* 0 *)
FullSimplify[Table[Sum[O3[[i, l, l]], {l, 3}], {i, 3}]]                    (* {0,0,0} *)
FullSimplify[-Grad[phi3, {x, y, z}] - accel3]                              (* {0,0,0} *)
```

### Shifting it up the tree

Now a practical problem. It took me a while to see why it exists at all.

Every cell needs its moments measured **about its own centre of mass**, which is the whole reason the dipole vanished and the expansion is as accurate as it is. But a parent cell has a *different* centre of mass from each of its children. So the children's moments, which are correct about their own centres, are the wrong numbers for the parent. They have to be translated onto the parent's centre before they can be added up. That translation is the "axis shift".

You could of course skip it and recompute each cell's moments directly from its particles. The reason nobody does is cost: a cell holding $n$ particles costs $\mathcal{O}(n)$ to do that way, and summing over every cell at every level gives $\mathcal{O}(N\log N)$ for the moments alone, as expensive as the force calculation it was meant to accelerate. With a shifting rule, each parent is built from just its eight children in constant time, so the whole tree is filled in $\mathcal{O}(N)$.

\note{
    You already know the simplest case of this. The parallel-axis theorem for moments of inertia, $I = I_{\text{cm}} + Md^2$, is exactly the same statement one rank lower: a shape's moment about its own centre, plus a correction for that centre being displaced. Here we need the same thing for rank 2 and rank 3.
}

And that is where it gets unpleasant. The theorem for the traceless quadrupole was already fiddly; for a rank-3 traceless tensor with all those Kronecker deltas it is a genuine mess.

The fix is to stop shifting the *traceless* tensors and shift the **raw** moments instead:

$$
M^{(2)}_{ij} = \sum_\alpha m_\alpha s_is_j, \qquad M^{(3)}_{ijk} = \sum_\alpha m_\alpha s_is_js_k
$$

These have a clean binomial rule. Substituting $\vec s = \vec R_l + \vec y$ and expanding, every term linear in $\vec y$ dies by $\sum m\vec y = 0$, the same cancellation as always, leaving

$$
\begin{aligned}
M^{(2)}_{ij} &= \sum_l\left[M^{(2),l}_{ij} + m_lR_iR_j\right]\\
M^{(3)}_{ijk} &= \sum_l\left[M^{(3),l}_{ijk} + R_iM^{(2),l}_{jk} + R_jM^{(2),l}_{ik} + R_kM^{(2),l}_{ij} + m_lR_iR_jR_k\right]
\end{aligned}
$$

No deltas anywhere. Then $\mathbf{Q}$ and $\mathbf{O}$ are reconstructed from the raw moments only when a cell is actually used in a force calculation:

$$
Q_{ij} = 3M^{(2)}_{ij} - \delta_{ij}\,\mathrm{tr}\,M^{(2)}, \qquad
O_{ijk} = 5M^{(3)}_{ijk} - \left(\delta_{jk}T_i + \delta_{ik}T_j + \delta_{ij}T_k\right)
$$

with $T_i = M^{(3)}_{ill}$.

\tip{
    The general lesson for implementing multipole methods: **do the bookkeeping in the raw moments, and take traces at the last possible moment.** Raw moments shift like binomial coefficients, which is easy to get right and easy to test. Traceless tensors do not.
}

\note{
    The test that caught my sign errors: build the tree, then compare the **root** node's raw third moment against a brute-force $\sum m\,s_is_js_k$ over all $N$ particles. The root never touches a particle, since it only ever adds up its eight children, so any mistake in the recursion at any depth shows up there. It agrees to $10^{-9}$.
}

## Does it work?

First the clean test, on a single cell, exactly as [in part 3](/Pages/Physics/papers/hernquist1987/03_treecode/#how_good_is_it) but with the third curve added. The prediction is that the errors should fall as $(s/d)^2$, $(s/d)^3$ and $(s/d)^4$:

\fig{/assets/Physics/papers/hernquist1987/multipole_error_3}

Same plot as in part 3, now with a third curve. Each extra term pushes the line down and makes it steeper, and the slopes come out 2, 3 and 4 exactly as the theory says.

Fitted slopes: **1.99, 3.01, 4.00**. The theory says 2, 3, 4.

Now in the real tree, at $N = 32768$, averaged over three realisations:

\fig{/assets/Physics/papers/hernquist1987/error_vs_theta_3}

$\theta$ goes right, force error goes up, one curve per number of terms kept. All three climb steeply, because a bigger $\theta$ means trusting bigger and closer lumps. The gaps between the curves are what the extra terms buy you, and they are wide on the left and shut on the right, so past $\theta \sim 1$ keeping more terms stops helping.

| $\theta$ | monopole | quadrupole | octupole |
| --- | --- | --- | --- |
| 0.2 | $0.0159\%$ | $0.0014\%$ | $0.0003\%$ |
| 0.3 | $0.0482\%$ | $0.0068\%$ | $0.0018\%$ |
| 0.5 | $0.1847\%$ | $0.0488\%$ | $0.0184\%$ |
| 0.7 | $0.4673\%$ | $0.1960\%$ | $0.0988\%$ |
| 1.0 | $1.5507\%$ | $1.0322\%$ | $0.6778\%$ |

At $\theta = 0.5$ the octupole is **10 times more accurate than the monopole** and 2.7 times better than the quadrupole. At $\theta = 0.2$ it is **50 times** better than the monopole. The gain grows as $\theta$ shrinks, exactly as the $(s/d)^4$ law demands.

## But is it worth it?

Accuracy alone is the wrong question. The octupole costs more per cell, so the honest comparison is **error against cost**. If I can reach the same accuracy more cheaply by just lowering $\theta$ with cheaper cells, the octupole is a waste of effort.

\fig{/assets/Physics/papers/hernquist1987/pareto}

Cost goes right, error goes up, one point per setting, and you want to be at the bottom left. The useful thing here is which points nobody beats on both counts at once.

\note{
    **The costs on that figure are from a threaded run and should not be read as absolute times.** I originally quoted them as if they were, and then compared one of them against a single-CPU CRAY number, which was a straightforward mistake. The *shape* of the frontier survives, because all three orders were threaded the same way, but every number below has been redone on **one core**. If you are comparing against anything historical, that is the only currency that means anything.
}

### Doing it properly, with a cost model

Reading a frontier off a scatter of measured points is fine for a picture and hopeless for a conclusion, because the crossings land between the points I happened to run. So instead let me fit the two things that actually vary and then eliminate $\theta$ between them.

**First, the error is a power law in $\theta$**, with the exponents measured in [part 4](/Pages/Physics/papers/hernquist1987/04_results/#where_the_error_actually_comes_from):

$$
\epsilon = A_p\,\theta^{\beta_p},\qquad \beta = 2.75,\; 3.97,\; 4.68
$$

**Second, the work is a power law too**, $n = C\theta^{-\gamma}$ with $C = 229$ and $\gamma = 2.14$. That is a fit, not a theorem; the [counting model in part 3](/Pages/Physics/papers/hernquist1987/03_treecode/#a_better_count) is the physical description and this is a convenient summary of it over the useful range.

**Third, the cost of one force evaluation** is a tree build plus a walk:

$$
\text{cost}(\theta, p) = T_0 + N\,c_p\,n(\theta)
$$

with $T_0 = 0.08$ s for $N = 32768$ on one core, and $c_p$ the cost per accepted cell:

| terms kept | cost per accepted cell | spread over $\theta$ | ratio |
| --- | --- | --- | --- |
| monopole | $23.1$ ns | $18$ to $31$ ns | $1.00$ |
| quadrupole | $25.7$ ns | $20$ to $35$ ns | $1.11$ |
| octupole | $47.8$ ns | $37$ to $62$ ns | $2.07$ |

That model reproduces the measured walk times to about $18\%$, and **what is left over is not random**, which is the interesting part. Look at the spread column: the cost per accepted cell is not constant even for a fixed multipole order. For the monopole it climbs from $18$ ns at $\theta = 1.4$ to $31$ ns at $\theta = 0.15$, and the arithmetic per cell in those two cases is *identical*.

\note{
    The difference is memory, not arithmetic. At large $\theta$ the walk uses a handful of big cells near the top of the tree, which every particle reuses, so they sit permanently in cache. At small $\theta$ it reaches deep cells scattered all over memory, and every one is a cache miss. This is also why the quadrupole is only $11\%$ dearer than the monopole here where Hernquist measured $50\%$ on a CRAY: an arithmetic-bound machine charges you for arithmetic, a memory-bound one gives it away while it waits.

    Khandai and Bagla build much of their TreePM optimisation on exactly this observation, by letting a **group** of neighbouring particles share one tree walk, so each cell is fetched once instead of once per particle.
}

### Eliminating $\theta$

Now put the two power laws together. Solving $\epsilon = A_p\theta^{\beta_p}$ for $\theta$ and substituting into the cost gives the price of a target accuracy:

$$
\boxed{\;\text{cost}_p(\epsilon) = T_0 + K_p\,\epsilon^{-\gamma/\beta_p},
\qquad K_p = N c_p C A_p^{\gamma/\beta_p}\;}
$$

with exponents

| terms kept | $-\gamma/\beta_p$ |
| --- | --- |
| monopole | $-0.78$ |
| quadrupole | $-0.54$ |
| octupole | $-0.46$ |

A higher multipole order gives a **shallower** cost curve, so it must eventually win at high enough accuracy. The only question is where. Evaluating, on one core at $N = 32768$:

| target accuracy | cheapest order | its cost | monopole | quadrupole | octupole |
| --- | --- | --- | --- | --- | --- |
| $3\%$ | monopole | $0.17$ s | $0.17$ | $0.18$ | $0.24$ |
| $1\%$ | **quadrupole** | $0.26$ s | $0.29$ | $0.26$ | $0.35$ |
| $0.3\%$ | **quadrupole** | $0.41$ s | $0.62$ | $0.41$ | $0.55$ |
| $0.1\%$ | **quadrupole** | $0.68$ s | $1.36$ | $0.68$ | $0.85$ |
| $0.01\%$ | **quadrupole** | $2.16$ s | $7.7$ | $2.16$ | $2.27$ |
| $0.001\%$ | **octupole** | $6.3$ s | $45.8$ | $7.2$ | $6.3$ |
| $0.0001\%$ | **octupole** | $18.0$ s | $274$ | $24.9$ | $18.0$ |

The crossings are at

$$
\epsilon_{\text{mono}\to\text{quad}} = 2.3\%,
\qquad
\epsilon_{\text{quad}\to\text{oct}} = 5\times10^{-5} = 0.005\%
$$

\note{
    **The second crossing needs a health warning and the first does not.** The cost exponents of the quadrupole and the octupole, $-0.54$ and $-0.46$, are so close that the two curves cross at a very shallow angle. Solving $K_q\epsilon^{-0.54} = K_o\epsilon^{-0.46}$ gives $\epsilon = (K_q/K_o)^{12}$, and a **twelfth power** is not something anybody measures casually. Get the relative cost of the two wrong by $15\%$ and that crossing moves anywhere between $10^{-5}$ and $3\times10^{-4}$; by $30\%$, and it moves between $2\times10^{-6}$ and $10^{-3}$.

    The first crossing is far better behaved, because its two exponents are genuinely different. The same $15\%$ moves it only from $2.3\%$ to somewhere between $1.3\%$ and $4.2\%$.
}

### The answer, which is not the one I wanted

**The quadrupole owns the middle of the range.** For any target accuracy between about $2\%$ and $5\times10^{-5}$, which is where essentially every real astrophysical simulation lives, the cheapest route is a quadrupole tree with $\theta$ tuned to suit. The monopole wins only at the crude end. The octupole only starts paying for itself below one part in twenty thousand.

So the practical rules for this code are short:

1. Use the **quadrupole** unless an error of a few per cent is good enough.
2. Add the **octupole** only if you genuinely need better than about $10^{-4}$.
3. Within a given order, **tune $\theta$ first.** Adding a multipole order is not usually the cheapest way to reduce an error.

In other words, **Hernquist stopped at exactly the right order for the problems he was solving.** Stopping at the quadrupole was not an oversight, and it was not a limitation of 1987 hardware either. It was the correct engineering call and it remains the correct one for most work. Modern hardware does not make the octupole better; it makes the regime where the octupole is better *reachable*.

\tip{
    What is solid here is the **shape** of the frontier and the first crossing. What is not solid is the exact accuracy at which the octupole takes over, and I would not defend the second decimal place of it on a different machine, a different $N$, or a different particle distribution. Frontiers like this are worth recomputing for your own problem; that is the point of writing the model down rather than quoting a number.
}

## Can the opening test be repaired?

Two separate things so far point at the same suspect. [Part 3](/Pages/Physics/papers/hernquist1987/03_treecode/#the_test_does_not_test_what_you_think_it_tests) showed that $s/d<\theta$ does not test the quantity that decides convergence. [Part 4](/Pages/Physics/papers/hernquist1987/04_results/#what_the_average_error_is_hiding) showed that roughly half the error comes from the cells that only just passed that test, and that a comfortable mean error hides a nasty tail.

So the obvious question: **can the test be repaired without touching anything else in the code?** I tried two natural geometric repairs. Not to propose a new production algorithm, but to find out whether geometry alone is enough.

| test | rule | idea |
| --- | --- | --- |
| **Barnes-Hut** (1987) | accept if $s/d < \theta$ | the original |
| **offset aware** | accept if $d > s/\theta + \delta_c$ | push the boundary out by how lopsided the cell is |
| **safe radius** | accept if $B/d < \theta$ | test a bound on $b_{\max}$ instead of the cell width |

In the second, $\delta_c$ is the distance between the cell's centre of mass and its geometric centre. It costs one subtraction per cell and it is a cheap way of noticing that a cell's mass is not where the cell is.

In the third, $B$ is a recursively built **upper bound** on $b_{\max}$. If child $c$ has centre-of-mass displacement $\vec R_c$ from the parent and its own bound $B_c$, then

$$
B_p = \max_c\left(\left|\vec R_c\right| + B_c\right)
$$

and by the triangle inequality $B_p \ge b_{\max}^{\text{true}}$, so accepting only when $B/d<\theta<1$ **guarantees** convergence. It can of course be stricter than the exact radius would be, and in my tree it is: a well-filled cell has $B$ between $0.72s$ and $0.85s$ depending on $\theta$, which is only $4$ to $11\%$ above the exact $b_{\max}$, so the bound is tight.

### Comparing them fairly

Here is the trap, and I fell into it first time round. **The three tests are not equally strict at the same $\theta$.** Since $B$ is usually smaller than $s$, the safe-radius test *accepts more* at the same numerical $\theta$ and is therefore looser, while the offset-aware test is stricter. Comparing them at fixed $\theta$ measures nothing except how each one has been normalised.

\tip{
    The only fair comparison is **at equal cost**: interpolate every criterion onto a common mean number of accepted terms per particle, then compare the errors there. Whenever somebody shows you a new acceptance criterion that beats the old one, the first question to ask is whether the comparison was at matched $\theta$ or matched work. At matched $\theta$ you can make almost anything look good by making it slightly stricter.
}

Done that way, on the smooth Plummer cluster, **neither repair helps.** With quadrupoles, at matched cost:

| | mean error, relative to Barnes-Hut | worst particle, relative to Barnes-Hut |
| --- | --- | --- |
| offset aware | $1.00$ to $1.35$ | $0.92$ to $2.22$ |
| safe radius | $1.41$ to $2.35$ | $1.83$ to $6.99$ |

The offset-aware test is a wash: sometimes very slightly better on the worst particle, usually slightly worse on the mean, never clearly ahead. The safe-radius test, the one that carries an actual convergence *guarantee*, is **the worst of the three**. With monopoles it is worse still, up to $3.0$ times the mean error.

## Making a tree code misbehave on purpose

A smooth relaxed cluster may simply be hiding the problem, so let me build something nasty on purpose.

A heavy Plummer primary of 20000 particles, plus a **compact satellite** carrying one twentieth of the mass in 4000 particles packed into a ball of radius $0.05$. Then slide the satellite through 41 positions, so that it crosses the cell boundaries of the tree. This is the static, controlled version of something that happens by itself in any real merger simulation, and it is Salmon and Warren's *detonating galaxies* set up so I can watch it happen.

Barnes-Hut, worst error suffered by any satellite particle at any of the 41 positions:

| $\theta$ | worst satellite particle | fraction of satellite worse than $20\%$ |
| --- | --- | --- |
| $0.2$ | $0.06\%$ | none |
| $0.3$ | $0.24\%$ | none |
| $0.4$ | $0.99\%$ | none |
| $0.5$ | $2.2\%$ | none |
| $0.6$ | $3.2\%$ | none |
| $0.7$ | $8.1\%$ | none |
| $0.9$ | $\mathbf{55\%}$ | $0.03\%$ |
| $1.1$ | $\mathbf{127\%}$ | $1.9\%$ |
| $1.3$ | $\mathbf{242\%}$ | $8.3\%$ |

Read where the corner is. **Nothing at all goes wrong up to $\theta = 0.7$.** The first badly wrong particles appear near $\theta = 0.9$, which is just above the $\theta \approx 0.83$ where [part 3](/Pages/Physics/papers/hernquist1987/03_treecode/#the_test_does_not_test_what_you_think_it_tests) measured the first genuinely divergent cell, and well above the $1/\sqrt3 = 0.577$ where the formal guarantee expired.

\note{
    **Losing a guarantee is not the same as failing.** Between $0.577$ and $0.9$ the theory has stopped protecting you and nothing has gone wrong yet. That is the most dangerous region to work in, because everything looks fine right up until the geometry happens to be unlucky, and by then it is a production run.
}

### What actually went wrong

It is worth stopping at the single worst particle and asking what happened to it, because once you look, the whole thing is embarrassingly simple.

At $\theta = 1.3$, at the position of the worst spike, the responsible cell is a cube of side $0.0153$ holding **fifteen of the satellite's own particles**, sitting practically on top of the target particle. It was accepted whole, so those fifteen neighbours were replaced by a single point mass at their common centre of mass. That one substitution is wrong by $\mathbf{258\%}$ of the entire true force on that particle.

And it passed the test legitimately. At $\theta = 1.3$ a cell may be $1.3$ times as wide as it is far away. Which is another way of saying that at this setting, **a cell can be accepted while it is very nearly touching the target.** Nothing about the test noticed that the cell and the target belong to the same little clump.

For comparison, in Salmon and Warren's 20:1 merger at $\theta = 0.7$, when the smaller galaxy crosses a cell boundary, about $10\%$ of *all* bodies and nearly $70\%$ of the smaller galaxy's bodies pick up force errors above $20\%$. My configuration is milder because the satellite is smaller relative to the primary's cell structure. The mechanism is identical.

### And the repairs still do not win

If the geometric repairs were going to earn their keep anywhere, it would be here. They do not. At matched cost on this awkward configuration:

* **offset aware** is roughly level with Barnes-Hut, between $0.68$ and $1.12$ times its worst-particle error, with no consistent sign;
* **safe radius** is between $1.6$ and $5.5$ times **worse**.

### Why the guaranteed test loses

This is the part I found genuinely instructive, because it is the criterion with the theorem attached and it comes last.

**Convergence is a weak guarantee.** Take a cell with $b_{\max}/d \simeq 0.7$. The series converges, certainly. But the first term thrown away is of order $(b_{\max}/d)^3$ relative to the monopole, and at $0.7$ that is already

$$
0.7^3 = 0.34
$$

before any coefficients or geometry are counted. A convergent series stopped too early is still a bad approximation.

\note{
    **Convergence is not accuracy.** They are different questions, and the safe-radius test answers the wrong one. It tells you the series *would* eventually get there if you kept enough terms, which is no comfort at all when you are keeping two.
}

There is a second, more practical reason it loses. $b_{\max}$, and therefore the bound $B$, can be set by **one light straggler particle** out near a corner of the cell. That single particle carries almost no mass and contributes almost nothing to the field, but it inflates $B$ and forces the code to open a cell whose real force error would have been entirely negligible. So the safe-radius test spends work in the wrong places as well as failing to protect the right ones.

\tip{
    The conclusion is not that acceptance criteria cannot be improved. It is that **geometry alone is the wrong thing to test.** What controls the error is the size of the multipole moments actually being thrown away, and that depends on how the mass inside the cell is arranged, not on how far apart its extreme particles happen to be. This is exactly why Salmon and Warren, having exposed the problem, proposed error bounds built from the **moments** rather than yet another geometric distance test, and it is why modern codes use criteria of that kind.
}

\prob{
    Build one. Estimate the size of the next multipole term you are about to discard, compare it with a tolerance times the current running total of the acceleration, and accept only if it is small enough. This is one line of extra arithmetic per cell. Then test it the honest way: at matched cost, on the smooth cluster **and** on the satellite configuration, looking at the worst particle and not the mean. My prediction is that it will not beat Barnes-Hut on the mean error of a smooth cluster and will comfortably beat it on the tail, which is the thing you actually wanted.
}

## A better integrator? Not so fast

The second obvious modernisation is the integrator. Leapfrog is second order; Yoshida (1990) showed you can compose **three** leapfrog steps with weights

$$
w_1 = \frac{1}{2-2^{1/3}}, \qquad w_0 = -\frac{2^{1/3}}{2-2^{1/3}}
$$

to cancel the $\delta t^2$ term of the [shadow Hamiltonian](/Pages/Physics/papers/hernquist1987/02_leapfrog/#the_deeper_reason_a_shadow_hamiltonian), leaving a **fourth-order** scheme that is still symmetric, still time-reversible, still symplectic.

Note $w_0 < 0$: the middle sub-step runs *backwards in time*. That looks alarming but it is precisely what makes the cancellation work.

```julia
const YOSHIDA_W1 = 1 / (2 - 2^(1 / 3))
const YOSHIDA_W0 = -2^(1 / 3) / (2 - 2^(1 / 3))

function yoshida4_step!(pos, vel, acc, tree, mass, dt, cfg)
    leapfrog_step!(pos, vel, acc, tree, mass, YOSHIDA_W1 * dt, cfg)
    leapfrog_step!(pos, vel, acc, tree, mass, YOSHIDA_W0 * dt, cfg)
    leapfrog_step!(pos, vel, acc, tree, mass, YOSHIDA_W1 * dt, cfg)
end
```

On a two-body orbit it behaves exactly as advertised: halving $\delta t$ cuts the energy error by about sixteen, confirming fourth order.

But it costs **three force evaluations per step**. So the fair comparison holds the number of force evaluations fixed, letting Yoshida take steps three times longer:

\fig{/assets/Physics/papers/hernquist1987/integrator_equal_cost}

Force evaluations spent goes right, which is the real currency, and energy error goes up. Leapfrog is below Yoshida almost everywhere, so the fancier integrator is not worth it here.

$N = 4096$, $\theta = 0.5$, integrated to $t = 25$:

| force evaluations | leapfrog | Yoshida 4th order |
| --- | --- | --- |
| 500 | $4.2\times10^{-2}$ | $4.8\times10^{-1}$ |
| 1000 | $1.9\times10^{-3}$ | $2.0\times10^{-1}$ |
| 2000 | $1.8\times10^{-4}$ | $3.7\times10^{-2}$ |
| 5000 | $1.8\times10^{-4}$ | $5.3\times10^{-4}$ |
| 10000 | $3.2\times10^{-4}$ | $2.3\times10^{-4}$ |
| 20000 | $2.7\times10^{-4}$ | $2.2\times10^{-4}$ |

At every budget a working astronomer would actually use, **leapfrog wins, often by two orders of magnitude**. Yoshida only draws level once you spend ten thousand force evaluations, and by then both have stopped improving anyway.

That "stopped improving" is the interesting part.

### Why more accuracy is not always buyable

Look at the leapfrog column again. From 2000 evaluations onwards it sits at $\approx 2\times10^{-4}$ and simply **refuses to get better**. Halving the step does nothing.

That is not a bug, and it is not the integrator. It is the **tree**. The same experiment again, with the force approximation removed:

| $\delta t$ | exact forces (direct sum) | tree, $\theta = 0.5$ |
| --- | --- | --- |
| 0.0200 | $5.07\times10^{-4}$ | $4.25\times10^{-4}$ |
| 0.0100 | $8.03\times10^{-5}$ ($\div 6.3$) | $1.14\times10^{-4}$ ($\div 3.8$) |
| 0.0050 | $1.98\times10^{-5}$ ($\div 4.05$) | $1.42\times10^{-4}$ ($\times 1.25$) |
| 0.0025 | $4.94\times10^{-6}$ ($\div 4.01$) | $1.62\times10^{-4}$ ($\times 1.14$) |

With exact forces, leapfrog shows textbook $\delta t^2$ behaviour forever, dividing by four every time the step is halved, all the way down. With the tree, the error falls once and then **hits a wall and stops**. Shrinking $\delta t$ past that point makes things very slightly *worse*, because you are doing more arithmetic on forces that were already the limiting factor.

\note{
    **The error budget has a floor, set by whichever term is worst.** You are timing a race with a stopwatch good to a tenth of a second while measuring the track with a tape marked in metres. Buying a microsecond stopwatch will not improve your measurement at all, because the tape is the problem.
}

At $\theta = 0.5$ the tree *is* the tape. Its $0.18\%$ force error injects energy error at a level no time step can undo, so a fourth-order integrator is wasted effort, and so is any $\delta t < 0.0125$. The only thing that helps is a more accurate force.

This is why production $N$-body codes still use leapfrog nearly forty years on, despite fourth-order symplectic schemes being well known. It is not conservatism. The force is approximate by design, so a better integrator has nothing to bite on, and leapfrog is the cheapest scheme giving the one property you cannot do without: no secular energy drift.

\note{
    There is a sharper way to say this, which I only got straight after writing [the fine print in part 2](/Pages/Physics/papers/hernquist1987/02_leapfrog/#the_fine_print_which_matters_more_than_i_first_thought). Yoshida's construction cancels the $\delta t^2$ term of the **shadow Hamiltonian**, and a shadow Hamiltonian only exists for a system of the form $H = T(\vec p) + V(\vec q)$ with a fixed $V$. A tree force is not the gradient of any such fixed $V$: the accepted cells change as the particles move, and the interactions are not equal and opposite pair by pair. So there is no $\delta t^2$ term of the right kind for Yoshida to cancel, and the scheme is spending three force evaluations to remove an error that is not the one limiting the answer. The floor is not a time-stepping error at all, which is exactly why no time-stepping method can reach below it.
}

### Mapping the floor

So I went and measured the floor for every $\theta$. $N = 4096$, integrated to $t = 12.5$, shrinking $\delta t$ by factors of two:

\fig{/assets/Physics/papers/hernquist1987/error_budget}

Time step goes right, energy error goes up, one curve per $\theta$. Every tree curve stops improving and goes flat, so below some step size you are simply wasting time.

The dashed grey line is the direct sum. It never stops improving, falling by four every halving, all the way down to $10^{-6}$, exactly as a second-order symplectic scheme should. Every tree curve peels away from it and goes flat.

| | force error | energy floor | floor / force error |
| --- | --- | --- | --- |
| direct | $0$ | none ($10^{-6}$ and still falling) | |
| $\theta = 0.3$ | $0.048\%$ | $2.1\times10^{-5}$ | $0.04$ |
| $\theta = 0.5$ | $0.185\%$ | $1.2\times10^{-4}$ | $0.06$ |
| $\theta = 0.7$ | $0.467\%$ | $3.1\times10^{-4}$ | $0.07$ |
| $\theta = 1.0$ | $1.551\%$ | $2.7\times10^{-3}$ | $0.18$ |

The prediction was that the floor should track the force error, and it does: the last column is roughly constant. As a rule of thumb,

$$
\left|\frac{\Delta E}{E}\right|_{\text{floor}} \;\approx\; \frac{1}{10}\times\left(\text{fractional force error}\right)
$$

which is good to a factor of two across a thirty-fold range in $\theta$.

Every tree curve reaches its floor at around $\delta t \approx 0.01$, regardless of $\theta$. Three things follow:

* There is **no point** running below $\delta t \approx 0.01$ at any $\theta \gtrsim 0.3$, since you are buying nothing.
* At the paper's $\delta t = 0.025$ the integrator and the tree contribute comparably at $\theta = 0.5$, and the tree dominates at $\theta = 1$. Hernquist's step size was well chosen.
* If you want better energy conservation, **lower $\theta$ first**, then lower $\delta t$ to match.

\note{
    This is the thing I would most want to have known before starting. The three error sources are usually presented as independent dials. They are not. They have a pecking order, and the force error sits at the top of it.
}

## A million particles

The paper's largest run was $N = 32768$. Going to $2^{20} \approx 10^6$ extends the lever arm on both scaling laws by more than a decade, which is the only honest way to check that $N\log N$ is a real law and not a fit over too short a range.

\fig{/assets/Physics/papers/hernquist1987/largeN_timing}

Particles go right, time per force evaluation goes up, all the way to a million particles. The line stays straight, so the $N\log N$ promise holds well beyond what the paper could test.

The counting argument from [part 3](/Pages/Physics/papers/hernquist1987/03_treecode/#why_this_gives_n_log_n) predicted that each level of the tree contributes a constant number of terms, so $\langle n_\text{terms}\rangle$ should be **linear in $\log N$**. Over five doublings that was suggestive; over seven it is a straight line:

\fig{/assets/Physics/papers/hernquist1987/largeN_nterms}

Particles go right on a log axis, work per particle goes up. A straight line here is precisely the $\log N$ behaviour the counting argument predicted.

And it is quantitative, not just qualitative. That argument gave $28\pi/3\theta^3$ terms per level, and since one doubling of $N$ adds $1/3$ of a level in an octree, it predicts

$$
\Delta\langle n_\text{terms}\rangle = \frac{28\pi}{9\theta^3} \approx 9.8 \quad\text{per doubling of } N \text{ at } \theta = 1
$$

Measured, at $\theta = 1$:

| $N$ | $\langle n_\text{terms}\rangle$ | gain |
| --- | --- | --- |
| 32768 | 217.6 | |
| 65536 | 232.6 | $+15.1$ |
| 131072 | 243.5 | $+10.9$ |
| 262144 | 253.9 | $+10.4$ |
| 524288 | 264.4 | $+10.5$ |
| 1048576 | 274.4 | $+10.0$ |

Predicted $9.8$, measured $10.0$ to $10.9$ once the first transient has passed. I was not expecting a back-of-the-envelope volume argument to land within $5\%$.

### Where the paper's error law runs out

Now the one that genuinely revises something. The paper reports that the force error decays as $\sim N^{-1/5}$, fitted over its range of $1024 \le N \le 32768$. Over exactly that range I reproduce it: my exponent is $-0.18$, which is $-1/5$ to the accuracy anyone could ask.

But push it further:

\fig{/assets/Physics/papers/hernquist1987/largeN_error}

Particles go right, force error goes up, both on log axes. A real power law would be a straight line, and these are not straight, they bend flat towards the right. Flattening means the error is settling onto a floor instead of continuing to fall, so you cannot buy accuracy by adding particles.

| range | monopole | quadrupole | octupole |
| --- | --- | --- | --- |
| $1024 \to 32768$ (paper's range) | $-0.18$ | | |
| $32768 \to 65536$ | $-0.135$ | $-0.082$ | $-0.063$ |
| $131072 \to 262144$ | $-0.065$ | $-0.040$ | $-0.022$ |
| $262144 \to 524288$ | $-0.053$ | $-0.024$ | $-0.027$ |

The exponent is not constant. It **flattens steadily towards zero**: over $32768 \to 524288$ the effective exponent is only $-0.095$, half the quoted value and still shrinking.

This is not a contradiction of the paper. Over the range Hernquist measured, $N^{-1/5}$ is a perfectly good description and I get the same. It is a warning against **extrapolating** it, and the physics says it must fail.

Think about fixed $\theta$ as $N\to\infty$. Around any given particle the arrangement of accepted cells becomes *scale-free*: nearby small cells, distant big ones, in the same proportions however many particles there are. Each contributes a fractional error set by $(s/d)^2 \le \theta^2$, which does not care about $N$ at all.

\note{
    So the force error must approach a **constant floor set by $\theta$ alone**. It cannot decay to zero, because the truncation error of each individual cell does not decay. The apparent $N^{-1/5}$ is a finite-$N$ transient, visible only because $32768$ is not yet large enough to be asymptotic.
}

The practical statement is the one from part 4, only stronger: **you cannot fix a tree code by adding particles.** Not slowly, not at all. The only knobs that touch the force error are $\theta$ and the multipole order.

---

**Previous:** [Part 5, the code](/Pages/Physics/papers/hernquist1987/05_code/)\\
**Back to:** [the front page](/Pages/Physics/papers/hernquist1987/)

Hope this helps you in some way. If you like it then share with others if possible.

If you have some queries, do let me know in the comments or contact me using the informations that are given on the page [About Me](/Pages/about_me/).

~~~
<button onclick="window.history.back()">Go Back</button>
~~~
