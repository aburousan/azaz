+++
title = "Tree Codes: Recreating Hernquist (1987)"
hascode = true
date = Date(2026, 8, 4)
rss = "Recreating Hernquist's 1987 paper on the performance of Barnes-Hut tree codes, from scratch in Julia: the Plummer model, the leapfrog integrator, the multipole expansion, and every timing and error test in the paper."

tags = ["Julia", "physics", "papers", "N-body", "gravity", "astrophysics", "simulation"]
+++

\toc

# Performance Characteristics of Tree Codes

In our class(NISER, Astronomy & Astrophysics course) our sir asked was doing the **virial theorem** on the board and discussing about the stablility of self gravitating configurations. Take a system that is not periodic but is in equilibrium or approaching it i.e., an $N$-body system. Then the moment of inertia stops changing, $I \to$ constant, so averaged over times much longer than the crossing time,

$$
\left\langle \frac{d^2I}{dt^2}\right\rangle = 0 \quad\Longrightarrow\quad 2\langle K\rangle + \langle U\rangle = 0 \quad\Longrightarrow\quad \langle E\rangle = \frac{1}{2}\langle U\rangle
$$

and that is the virial theorem for a self-gravitating system.

Then he drew a box on one side of the board:

> **1987 ApJS 64, 715H** — *Performance Characteristics of Tree Codes*\\
> Poisson equation $\to \nabla^2\phi = 4\pi G\rho$\\
> Current algorithms $\to$ Mem, $\log(n)$

and on the other side wrote **Plummer Profile Problem**: you are given initial conditions $\{\vec r_i\}, \{\vec v_i\}$ and you want to evolve them under gravity only. Then he derived the integrator starting from two Taylor expansions and ending with the leapfrog scheme.

So the assignment was: do that. Take a blob of particles set up as a Plummer sphere, give them the right positions and velocities, push them forward with leapfrog, and check the virial theorem holds.

That is the part I started with. But once the particles were moving I could not stop, because the paper behind sir's box is really about a much better question: **how do you compute the forces at all without waiting till next year?** So I ended up recreating the whole of Hernquist's paper in **Julia** and this is what came out.

\fig{/assets/Physics/papers/hernquist1987/plummer_3d}

That is the object we are going to torture. 4000 particles, held together by nothing but their own gravity. Drag it around.

## The problem, honestly stated

Gravity is a $1/r^2$ force and it never switches off. So if I have $N$ particles, every single one of them pulls on every other one. Writing $\vec{a}_i$ for the acceleration of particle $i$,

$$
\vec{a}_i = -G\sum_{j \neq i} m_j \frac{\vec{r}_i - \vec{r}_j}{|\vec{r}_i - \vec{r}_j|^3}
$$

There are $N$ particles and each sum has $N-1$ terms, so one force evaluation costs $\sim N^2$ operations. And I need to do this *every single time step*, thousands of times.

Let's put numbers on that. For $N = 1000$ it is a million operations per step (looks fine ?). For $N = 10^6$ it is $10^{12}$ per step and a galaxy has $N \sim 10^{11}$ stars. The $O(N^2)$ road ends very quickly.

\note{
    This is why sir wrote **$\log(n)$** in a box on the board next to the paper reference. The whole point of a tree code is to replace that $N^2$ with $N\log N$.
}

The idea behind the fix is one you already use without thinking. **When you compute the pull of the Sun on the Earth, you do not add up the force from every atom in the Sun**. You treat the Sun as a single point of mass $M_\odot$ sitting at its centre. That is legal because the Sun is *far away compared to its own size*.

A tree code does exactly this, but it decides for itself, particle by particle, which clumps are far enough away to be squashed into a single point — and when a point is not good enough, it adds a correction term for the *shape* of the clump. That correction is the **multipole expansion**, and it is the mathematical heart of the whole method.

## What is in each part

1. **[The problem and the model](/Pages/Physics/papers/hernquist1987/01_setup/)** — Poisson's equation, the Plummer sphere, where the initial positions and velocities actually come from, and the virial theorem that sir started from.

2. **[Moving the particles](/Pages/Physics/papers/hernquist1987/02_leapfrog/)** — the leapfrog integrator, derived the way sir did it on the board, and why this clumsy-looking scheme beats Runge-Kutta 4 for this job.

3. **[The tree and the multipole expansion](/Pages/Physics/papers/hernquist1987/03_treecode/)** — the long one. Building an octree, the opening criterion $s/d < \theta$, and the multipole expansion worked out term by term with nothing skipped.

4. **[Results](/Pages/Physics/papers/hernquist1987/04_results/)** — every timing curve, error curve and conservation test from the paper, recreated.

5. **[The code](/Pages/Physics/papers/hernquist1987/05_code/)** — the full Julia source, and how to run it yourself.

6. **[Doing better than 1987](/Pages/Physics/papers/hernquist1987/06_beyond/)** — what the paper could not afford. Octupole multipoles, a fourth-order symplectic integrator, and a million particles.

## Did it work?

Before anything else, here is my recreation next to the paper. These are numbers I did not tune. They came out of the code the first time it ran correctly.

**Every entry in this table is read straight out of a production run on the departmental server** ($N$ up to $32768$). My laptop was only ever used for small-$N$ checks while developing. Nothing in this table comes from it.

| Quantity | Hernquist (1987) | My Julia code |
| --- | --- | --- |
| $\langle n_\text{terms}\rangle$, Plummer, $N=32768$, $\theta=1$ | $\approx 221$ | $217.6$ |
| $\langle n_\text{terms}\rangle$, uniform sphere, same | $\approx 121$ | $122.2$ |
| $\langle n_\text{terms}\rangle$, Plummer, $N=1024$, $\theta=1$ | $\approx 130$ | $124.0$ |
| $\langle n_\text{terms}\rangle$, Plummer, $N=32768$, $\theta=0.5$ | $\approx 1060$ | $1053.2$ |
| Force error, $N=32768$, $\theta=1$ | $\approx1.4$–$1.6\%$ (Fig. 6) | $1.548 \pm 0.013\%$ |
| Force error, $N=32768$, $\theta=0.5$ | $\approx0.2\%$ (Fig. 6) | $0.182 \pm 0.003\%$ |
| Error scaling with $N$ | $\sim N^{-1/5}$ | $\sim N^{-1/5}$ |
| $N$ where tree beats direct sum, $\theta=1$ | $\approx 1700$ | $\approx 1700$ |
| Speed-up at $N=32768$, $\theta=1$ | — | $23.8\times$ |
| $\Delta E/E$, 1000 steps, direct sum | $0.20\%$ | $0.22 \pm 0.10\%$ |
| $\Delta E/E$, 1000 steps, $\theta = 0.5$ | $0.32\%$ | $0.26 \pm 0.10\%$ |
| $\Delta E/E$, 1000 steps, $\theta = 1$ | $0.68\%$ | $0.96 \pm 0.14\%$ |
| Relaxation time, $\theta \lesssim 1$ | same as direct | same as direct |
| Multipole truncation error, monopole / quadrupole | $(s/d)^2$ / $(s/d)^3$ | slopes $2.00$ / $3.03$ |
| $-2K/W$ across $\varepsilon/\lambda = 1/16 \to 4$ | — | $1.000 \pm 0.003$ |

Where I quote a $\pm$, it is the standard deviation over **eight independent random realisations** of the Plummer sphere & not a single run.

\note{
    **This table is deliberately matched, not optimised.** Every row runs at the paper's own settings, so the force-error rows are not "the best I can do" — they are the same thing, done again. If I had tuned my code to look good, the comparison would mean nothing.
}

[Part 6](/Pages/Physics/papers/hernquist1987/06_beyond/) is where I stop matching and start improving.

### Why is my force error not *smaller* than a 1987 paper's?

This was the first thing that bothered me about the table above, so it is worth answering directly.

At $\theta = 0.5$ my error is actually slightly **lower** than the paper's ($0.182\%$ against $\approx0.2\%$). At $\theta = 1$ it is slightly higher. Both differences are within how accurately I can read a log-scale figure from 1987, and neither means anything.

But the deeper point is that **a faster computer cannot make this number smaller**, and expecting it to is a misunderstanding of where the error comes from:

$$
\text{force error at fixed }\theta \;=\; \text{a property of the algorithm, not of the machine}
$$

The error is the multipole series truncated at $(s/d)^2$. That truncation is mathematics. Two correct Barnes-Hut codes, at the same $\theta$, same multipole order, on the same particle distribution, **must** agree to within realisation noise — and mine agrees with the paper's to about 1%, which is the strongest evidence I have that the implementation is right. If my error had come out ten times smaller, that would not have been a triumph; it would have been a bug.

So how *do* you get a better answer? Only by changing the algorithm, and there are exactly three knobs:

1. **Lower $\theta$** — open more cells
2. **Higher multipole order** — describe each cell better
3. **Both**

Which is precisely what modern hardware buys. Not accuracy directly, but the ability to **afford settings the paper could not run in production**:

| setting | force error | vs. the paper's run | cost |
| --- | --- | --- | --- |
| monopole, $\theta=1$ *(the paper's production setting)* | $1.551\%$ | — | $1\times$ |
| quadrupole, $\theta=0.5$ | $0.049\%$ | $32\times$ better | $1.4\times$ |
| octupole, $\theta=0.5$ | $0.018\%$ | $84\times$ better | $1.8\times$ |
| octupole, $\theta=0.3$ | $0.0018\%$ | $871\times$ better | $3.0\times$ |
| **octupole, $\theta=0.2$** | $\mathbf{0.0003\%}$ | $\mathbf{5300\times}$ **better** | $4.9\times$ |

And here is the part I like. One force evaluation at $N = 32768$:

| | seconds |
| --- | --- |
| Hernquist's CRAY X-MP, monopole $\theta=1$ | $23.9$ |
| my single core, monopole $\theta=1$ | $0.17$ |
| my single core, **octupole $\theta = 0.2$** | $0.84$ |

**My most accurate setting is still 29 times faster than his crudest one, while being 5300 times more accurate.** That is what forty years bought — not a better formula, but the freedom to run the formula somewhere it was never affordable before.

\note{
    There is one caveat, and [part 6](/Pages/Physics/papers/hernquist1987/06_beyond/) makes it carefully: **wanting more accuracy and needing it are different things.** On an accuracy-per-cost basis the quadrupole beats the octupole across the whole range anyone normally works in. The octupole earns its keep only below about $0.02\%$ error — a regime that exists now, but that almost no astrophysical problem actually requires.
}

\note{
    A paper from 1987 written for a **CRAY X-MP**, recreated on a laptop and a departmental server, agreeing to a few percent on quantities nobody was aiming at. I find that genuinely satisfying. The numbers that describe the *algorithm* — how many terms, how big the error — do not care what machine you are on, and they came out right.
}

### How much of this is noise?

A table like that invites the question "how close is close enough?", so I measured it instead of guessing. I re-ran everything for eight different random seeds, changing nothing but the realisation of the sphere.

| Quantity | mean over 8 seeds | scatter |
| --- | --- | --- |
| $\langle n_\text{terms}\rangle$, $\theta=1$ | $218.4$ | $0.57\%$ |
| $\langle n_\text{terms}\rangle$, $\theta=0.5$ | $1049.9$ | $0.39\%$ |
| Force error, $\theta=1$ | $1.548\%$ | $0.85\%$ |
| Force error, $\theta=0.5$ | $0.182\%$ | $1.68\%$ |
| $\Delta E/E$, direct | $0.222\%$ | $43\%$ |
| $\Delta E/E$, $\theta=1$ | $0.962\%$ | $14\%$ |

Two things fall out of this, and the first one corrected a guess I had made.

**The force quantities are far more reproducible than I expected** — under $2\%$ scatter. So the $\sim1\%$ gaps against the paper in $\langle n_\text{terms}\rangle$ are *not* explained by the luck of the draw. I had assumed they were, and I was wrong.

Chasing that down, the culprit turned out to be the **root cell**. My tree wraps the particles in their tight bounding cube; nothing says it has to. Padding that cube changes where every subdivision plane falls, and therefore which cells get accepted:

| root cell padding | $\langle n_\text{terms}\rangle$ | force error |
| --- | --- | --- |
| $1.0001$ (tight) | $218.5$ | $1.551\%$ |
| $1.25$ | $228.9$ | $1.555\%$ |
| $1.5$ | $225.2$ | $1.555\%$ |
| $2.0$ | $219.8$ | $1.550\%$ |
| $4.0$ | $219.8$ | $1.550\%$ |

$\langle n_\text{terms}\rangle$ swings over a $\pm2.4\%$ range purely from that arbitrary choice, and the paper's $221$ sits comfortably inside it. Meanwhile the **force error does not move at all** — $1.550$ to $1.555\%$ across the whole range.

\note{
    That is a reassuring pair of facts to have separated. How *many* cells you end up summing is partly an accident of where you happened to draw the box; how *accurate* the answer is, is not. So $\langle n_\text{terms}\rangle$ is the wrong thing to compare implementations on, and the error is the right thing.
}

### So why are the numbers different at all?

Once I had that, the honest question became: if the code passes every mathematical check exactly, why does it not land exactly on the paper?

The biggest reason is one the paper tells you itself, and I had walked past it. Discussing the $N=4096$, $\theta=1$ run, Hernquist writes that $\langle n_\text{terms}\rangle$ was

> approximately 170–175 for small $t$, but increased slowly to 195–200 during the first 50 time steps

**$\langle n_\text{terms}\rangle$ is not a property of the model at all — it drifts as the cluster relaxes.** Every number I had been quoting was measured on the initial conditions. So I measured it as a function of time for exactly that setup:

\fig{/assets/Physics/papers/hernquist1987/nterms_of_time}

| | mine | paper |
| --- | --- | --- |
| $t = 0$ | $171.5$ | $170$–$175$ |
| after 50 steps | $188.9$ | $195$–$200$ |
| late-time mean | $193.1$ | $195$–$200$ |

My initial value lands **inside** the paper's stated range, and the drift has the same size and shape. But look at the magnitude of that drift: $171.5 \to 193$, a **13% rise**. That is an order of magnitude larger than the $1.2\%$ gap I was trying to explain. So "why is my 218.4 not 221?" partly reduces to "at which moment did Hernquist take that snapshot?" — a question the paper does not answer, and does not need to.

So what is actually rising? From the same run:

| $t$ | 10% radius | 90% radius | max $\lvert r\rvert$ | particles beyond $r=1$ | $\langle n_\text{terms}\rangle$ |
| --- | --- | --- | --- | --- | --- |
| 0 | 0.103 | 0.586 | 1.00 | 2 | 171.5 |
| 2 | 0.106 | 0.614 | 1.93 | 85 | 191.5 |
| 10 | 0.104 | 0.602 | 5.30 | 61 | 194.4 |
| 25 | 0.108 | 0.610 | 5.50 | 73 | 199.0 |

The cluster itself does not move. The radii holding 10% and 90% of the mass stay flat to a percent — that is the equilibrium checked in part 1. What changes is that the model, cut off at $R=1$, sheds a thin halo in the first crossing time and a few dozen particles wander out to $r\sim5$.

\note{
    Escapers are expensive. A particle alone in empty space cannot be lumped in with anything, so every other particle has to count it as a separate term. Sixty-odd stragglers is what lifts $\langle n_\text{terms}\rangle$ by about twenty — the drift is not the tree misbehaving and not deep physics, it is the truncated initial condition relaxing.
}

I also tested the other suspect, since the paper flags it as a possible trap. My walk always opens a cell containing the particle itself, to stop a particle attracting itself; the standard Barnes-Hut code does not:

\fig{/assets/Physics/papers/hernquist1987/forced_subdivision}

| $\theta$ | error, forced on | forced off |
| --- | --- | --- |
| 0.5 | $0.1847\%$ | $0.1847\%$ |
| 1.0 | $1.5507\%$ | $1.5508\%$ |
| 1.2 | $3.302\%$ | $3.318\%$ |
| 1.5 | $7.445\%$ | $8.073\%$ |

Identical to four decimal places until $\theta = 1.2$, then it starts to bite. So this is *not* the explanation either — but it does independently reproduce the paper's own conclusion that the effect "was completely negligible for $\theta \le 1.2$", which is a pleasing thing to be able to confirm from the outside.

So the differences come down to:

1. **When the snapshot is taken** — worth up to 13% on $\langle n_\text{terms}\rangle$, and by far the largest effect.
2. **Root cell geometry** — an arbitrary choice worth $\pm2.4\%$.
3. **Reading a log-scale figure** — the force-error comparison cannot be done better than $\pm20\%$ by eye.
4. **The random realisation** — worth $0.4$–$1.7\%$.
5. **Everything else about an independent reimplementation** — my sampler is not their sampler, my $\varepsilon = 0.0314$ is not their $0.032$.

\note{
    So $\langle n_\text{terms}\rangle$ and $\Delta E/E$ are not physical constants. They belong to one realisation, meshed one way, measured at one instant, and two correct codes will not agree on them better than a few percent.
}

The quantities that **are** universal come from the mathematics, and those matched exactly: the tree reproducing the direct sum to $10^{-10}$ at $\theta=0$, the multipole slopes $2.00$ and $3.03$ against the derived $2$ and $3$, the leapfrog order $1.98$ against $2$. Those have no free parameters and no snapshot ambiguity, and they are what establish that the code is right.

**Energy drift is the opposite case** — genuinely noisy, $43\%$ scatter for the direct sum. My original table quoted a single run that happened to give $0.12\%$, which turned out to be the *lowest* of the eight. The honest number is $0.22\pm0.10\%$, which sits right on the paper's $0.20\%$. Quoting one run there was misleading and I have replaced it with the mean.

The one row that does not fully reconcile is $\Delta E/E$ at $\theta=1$: I get $0.96\pm0.14\%$ against the paper's $0.68\%$, about two standard deviations low. It is consistent in sign with my force error at $\theta=1$ being a touch higher than theirs, so I suspect a small difference in the opening test rather than an error — but I have not tracked it down, and I would rather say so than paper over it.

I also found one thing in the paper that does not survive checking: **equation (3.2)**, the distribution function of the Plummer model, has an inconsistent power of $G$. It is harmless, because the whole paper works in units where $G=1$, but the printed formula does not reduce to the correct one if you restore $G$. I show the derivation and the check [on the setup page](/Pages/Physics/papers/hernquist1987/01_setup/#the_distribution_function).

## A note on how I did this

Everything here I wrote myself and checked in at least two ways, because a simulation that is quietly wrong looks exactly like a simulation that is right.

* The **tree walk** is checked against a brute-force $O(N^2)$ sum. At $\theta = 0$ every cell must be opened, so the tree is forced to give the direct answer — and it does, to $10^{-10}$.
* The **multipole algebra** was checked symbolically in Mathematica: the Legendre expansion, the claim that the quoted acceleration really is $-\nabla\varphi$ of the quoted potential, and the parallel-axis recursion.
* The **integrator** is checked on a two-body orbit, where I know the answer exactly.
* The **initial conditions** are checked by integrating the distribution function back up to the density it came from.

The heavy runs ($N$ up to $32768$, the timing sweeps, the relaxation measurements) were done on a departmental machine; the small ones ran on my laptop.

---

**Reference:** Hernquist, L. 1987, *The Astrophysical Journal Supplement Series*, **64**, 715. [ADS link](https://ui.adsabs.harvard.edu/abs/1987ApJS...64..715H)

The original algorithm is from Barnes, J. & Hut, P. 1986, *Nature*, **324**, 446.

---

Hope this helps you in some way. If you like it then share with others if possible.

If you have some queries, do let me know in the comments or contact me using the informations that are given on the page [About Me](/Pages/about_me/).

~~~
<button onclick="window.history.back()">Go Back</button>
~~~
