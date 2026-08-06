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

The paper's timings are for a **CRAY X-MP**, one of the fastest machines on Earth in 1987. Hernquist quotes a rate for his largest run of $7.3\times10^{-4}$ CPU seconds per particle per step. My code, on **one** core, single-threaded, at the same $N = 32768$ and $\theta = 1$ with monopoles only, runs at $5.2\times10^{-6}$.

$$
\frac{7.3\times10^{-4}}{5.2\times10^{-6}} \approx 140
$$

| | Hernquist's simulation | on one of my cores |
| --- | --- | --- |
| $N = 32768$, 300 steps | **2.0 CRAY X-MP CPU hours** | **51 seconds** |

A run that consumed two hours of the world's fastest supercomputer takes under a minute on a single modern core, and I have 48 of them to hand. So the interesting question is not "can I reproduce it" but **"what would I do differently, given the compute?"**

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

Down and to the left is better. Reading off the frontier, i.e. the set of settings that are not beaten on both counts at once:

| cost (s) | best choice | error |
| --- | --- | --- |
| $0.064$ | monopole, $\theta=1.0$ | $1.55\%$ |
| $0.068$ | **quadrupole**, $\theta=0.9$ | $0.61\%$ |
| $0.073$ | **quadrupole**, $\theta=0.7$ | $0.196\%$ |
| $0.090$ | **quadrupole**, $\theta=0.5$ | $0.049\%$ |
| $0.117$ | **octupole**, $\theta=0.5$ | $0.018\%$ |
| $0.191$ | **octupole**, $\theta=0.3$ | $0.0018\%$ |
| $0.313$ | **octupole**, $\theta=0.2$ | $0.0003\%$ |

And here is the answer, which is not the one I was hoping for when I started writing the octupole code:

\note{
    **The quadrupole owns the middle of the range.** For any accuracy between about $1\%$ and $0.02\%$, where essentially every astrophysical simulation actually lives, the cheapest route is a quadrupole tree with $\theta$ tuned to suit. The monopole only wins at the crude end, and the octupole only starts paying for itself below $0.02\%$.
}

In other words, **Hernquist stopped at exactly the right order for the problems he was solving.** Adding the next term was not an oversight and not a limitation of 1987 hardware; it was the correct engineering call and it still is for most work. Modern hardware does not make the octupole better. It makes the regime where the octupole is better *reachable*.

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
