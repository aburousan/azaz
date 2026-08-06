+++
title = "Tree Codes: Recreating Hernquist (1987)"
hascode = true
date = Date(2026, 8, 4)
rss = "Recreating Hernquist's 1987 paper on the performance of Barnes-Hut tree codes, from scratch in Julia: the Plummer model, the leapfrog integrator, the multipole expansion and every timing and error test in the paper."

tags = ["Julia", "physics", "papers", "N-body", "gravity", "astrophysics", "simulation"]
+++

\toc

# Performance Characteristics of Tree Codes

In our class (NISER, Astronomy & Astrophysics course) our sir asked like this. He was doing the **virial theorem** on the board, talking about when a self-gravitating configuration is stable. Take a system that is not periodic but is in equilibrium or heading towards it, i.e. an $N$-body system. Its moment of inertia stops changing, $I \to$ constant, so averaged over times much longer than the crossing time,

$$
\left\langle \frac{d^2I}{dt^2}\right\rangle = 0 \quad\Longrightarrow\quad 2\langle K\rangle + \langle U\rangle = 0 \quad\Longrightarrow\quad \langle E\rangle = \frac{1}{2}\langle U\rangle
$$

and that is the virial theorem for a self-gravitating system.

Then he drew a box on one side of the board:

> [**1987 ApJS 64, 715H**](https://ui.adsabs.harvard.edu/abs/1987ApJS...64..715H): *Performance Characteristics of Tree Codes*\\
> Poisson equation $\to \nabla^2\phi = 4\pi G\rho$\\
> Current algorithms $\to$ Mem, $\log(n)$

and on the other side wrote **Plummer Profile Problem**: you are given initial conditions $\{\vec r_i\}, \{\vec v_i\}$ and you want to evolve them under gravity only. Then he derived the integrator starting from two Taylor expansions, ending with the leapfrog scheme.

So the assignment was: do that. Take a blob of particles, give them the right positions and velocities, push them forward in time, then check that the virial theorem holds.

That is the part I started with. But once the particles were moving I could not stop, because the paper behind sir's box is really about a much better question: **how do you compute the forces at all without waiting till next year?** So I ended up recreating the whole of Hernquist's paper in **Julia**. This is what came out.

\fig{/assets/Physics/papers/hernquist1987/plummer_3d}

Each dot is one particle. Nothing is holding it together except the gravity of the other particles.

That blob is what we are going to torture. 4000 particles, held together by nothing but their own gravity. Drag it around.

## Why this is hard

Gravity is a $1/r^2$ force and it never switches off. So if I have $N$ particles, every single one of them pulls on every other one. Writing $\vec{a}_i$ for the acceleration of particle $i$,

$$
\vec{a}_i = -G\sum_{j \neq i} m_j \frac{\vec{r}_i - \vec{r}_j}{|\vec{r}_i - \vec{r}_j|^3}
$$

There are $N$ particles and each sum has $N-1$ terms, so working out all the forces once costs about $N^2$ operations. And I have to do it again at *every* time step, thousands of times over.

Some numbers. For $N = 1000$ that is a million operations per step, which sounds fine. For a million particles it is $10^{12}$ per step. A real galaxy has about $10^{11}$ stars. The $N^2$ road ends very quickly.

\note{
    This is why sir wrote **$\log(n)$** in the box next to the paper reference. The whole point of the method in that paper is to replace $N^2$ with something close to $N$.
}

## What a tree code actually is

The trick is one you already use without thinking. When you work out the pull of the Sun on the Earth, you do not add up the force from every atom in the Sun. You treat the Sun as one lump of mass sitting at one point. That is allowed because the Sun is far away compared to its own size.

A star cluster is the same, except that "far away compared to its own size" depends on who is asking. To a star out on the edge, the whole crowded core is one distant lump. To a star sitting *in* the core, its neighbours have to be counted one at a time. So you cannot decide once and for all how coarsely to group things. Every star needs to make that decision for itself, about every part of the cluster.

The way to make that cheap is to prepare, in advance, a set of lumps at every possible size. That set is the **tree**.

The whole idea fits in one picture. Draw a box around all the particles. Cut it into equal quarters (in three dimensions, into eight equal cubes). Take any piece that still has more than one particle in it and cut that up too. Keep going until every piece holds at most one particle. The pieces you get are nested inside one another, and drawing "which piece sits inside which" gives exactly the branching diagram on the right.

~~~
<div style="max-width:680px;margin:1.5rem auto">
<svg viewBox="0 0 680 340" xmlns="http://www.w3.org/2000/svg" style="width:100%;height:auto">
  <!-- ================= left: boxes in space ================= -->
  <rect x="30" y="55" width="220" height="220" fill="none" stroke="#8A8F98" stroke-width="2"/>
  <line x1="140" y1="55"  x2="140" y2="275" stroke="#8A8F98" stroke-width="1.4"/>
  <line x1="30"  y1="165" x2="250" y2="165" stroke="#8A8F98" stroke-width="1.4"/>
  <rect x="30" y="55" width="110" height="110" fill="#E5646E" fill-opacity="0.07" stroke="#E5646E" stroke-width="2"/>
  <line x1="85" y1="55"  x2="85"  y2="165" stroke="#E5646E" stroke-width="1.2"/>
  <line x1="30" y1="110" x2="140" y2="110" stroke="#E5646E" stroke-width="1.2"/>
  <circle cx="55"  cy="85"  r="3.5" fill="#4C8DF6"/>
  <circle cx="68"  cy="140" r="3.5" fill="#4C8DF6"/>
  <circle cx="112" cy="82"  r="3.5" fill="#4C8DF6"/>
  <circle cx="120" cy="145" r="3.5" fill="#4C8DF6"/>
  <circle cx="200" cy="105" r="3.5" fill="#4C8DF6"/>
  <circle cx="80"  cy="228" r="3.5" fill="#4C8DF6"/>
  <circle cx="196" cy="225" r="3.5" fill="#4C8DF6"/>
  <text x="140" y="302" fill="#8A8F98" font-size="13" text-anchor="middle">boxes drawn in space</text>
  <text x="140" y="321" fill="#8A8F98" font-size="12" text-anchor="middle">the crowded corner gets cut again</text>

  <!-- ================= right: the same thing as a tree ================= -->
  <line x1="485" y1="91" x2="365" y2="145" stroke="#8A8F98" stroke-width="1.3"/>
  <line x1="485" y1="91" x2="450" y2="145" stroke="#8A8F98" stroke-width="1.3"/>
  <line x1="485" y1="91" x2="535" y2="145" stroke="#8A8F98" stroke-width="1.3"/>
  <line x1="485" y1="91" x2="620" y2="145" stroke="#8A8F98" stroke-width="1.3"/>

  <line x1="365" y1="171" x2="320" y2="225" stroke="#E5646E" stroke-width="1.3"/>
  <line x1="365" y1="171" x2="350" y2="225" stroke="#E5646E" stroke-width="1.3"/>
  <line x1="365" y1="171" x2="380" y2="225" stroke="#E5646E" stroke-width="1.3"/>
  <line x1="365" y1="171" x2="410" y2="225" stroke="#E5646E" stroke-width="1.3"/>

  <circle cx="485" cy="78"  r="13"  fill="none" stroke="#8A8F98" stroke-width="2"/>
  <circle cx="365" cy="158" r="11"  fill="#E5646E" fill-opacity="0.14" stroke="#E5646E" stroke-width="2"/>
  <circle cx="450" cy="158" r="11"  fill="none" stroke="#8A8F98" stroke-width="2"/>
  <circle cx="535" cy="158" r="11"  fill="none" stroke="#8A8F98" stroke-width="2"/>
  <circle cx="620" cy="158" r="11"  fill="none" stroke="#8A8F98" stroke-width="2"/>
  <circle cx="320" cy="238" r="8"   fill="none" stroke="#E5646E" stroke-width="1.8"/>
  <circle cx="350" cy="238" r="8"   fill="none" stroke="#E5646E" stroke-width="1.8"/>
  <circle cx="380" cy="238" r="8"   fill="none" stroke="#E5646E" stroke-width="1.8"/>
  <circle cx="410" cy="238" r="8"   fill="none" stroke="#E5646E" stroke-width="1.8"/>

  <text x="512" y="52"  fill="#8A8F98" font-size="12">the whole box</text>
  <text x="640" y="162" fill="#8A8F98" font-size="12">its 4 pieces</text>
  <text x="365" y="270" fill="#E5646E" font-size="12" text-anchor="middle">and their pieces</text>
  <text x="485" y="302" fill="#8A8F98" font-size="13" text-anchor="middle">the same thing drawn as a tree</text>
  <text x="485" y="321" fill="#8A8F98" font-size="12" text-anchor="middle">deeper only where the particles are</text>
</svg>
</div>
~~~

Two things jump out. The tree comes out **deep where the cluster is crowded and shallow where it is empty**, all by itself: nobody had to tell it where the interesting region was. And every box, at whatever size, can be summarised once by its total mass and where that mass sits, ready for anybody who wants to use it as a lump.

That is what makes the force calculation cheap. To get the force on one star you start at the biggest box and ask a single question: *is this box far enough away, compared to how wide it is, that I can treat it as one lump?* If yes, take its summary and stop. If no, throw the box away, take the four (or in 3D, eight) smaller boxes inside it, and ask each of them the same question. Near the star you end up descending all the way down to individual particles. Far away, one giant box covers thousands of them in a single term.

\note{
    The number controlling "far enough" is one knob, written $\theta$ throughout this series. It is an **angle**: how wide a lump is allowed to look before you refuse to trust it as a lump. Small $\theta$ means fussy, accurate and slow. Large $\theta$ means squint, approximate and fast. It is the only accuracy dial the method has, and most of the paper is about what each setting costs you.
}

The counting works out very neatly. Each level of the tree contributes roughly the same fixed number of lumps, so doubling the number of particles adds one more level instead of doubling the work. That is the $N\log N$ behaviour sir's box was pointing at, and [part 3](/Pages/Physics/papers/hernquist1987/03_treecode/) does the count properly.

One refinement is left, and it is where most of the actual physics lives. Summarising a box by its total mass alone throws away its *shape*, and a box whose mass is bunched to one side does not pull quite like a point does. Putting that shape back in is the **multipole expansion**. It is the mathematical core of the paper, and part 3 derives it from scratch, term by term.

## What is in each part

1. [The problem and the model](/Pages/Physics/papers/hernquist1987/01_setup/): Poisson's equation, the Plummer sphere, where the initial positions and velocities actually come from and the virial theorem sir started from.

2. [Moving the particles](/Pages/Physics/papers/hernquist1987/02_leapfrog/): the leapfrog integrator, derived the way sir did it on the board, and why this clumsy-looking scheme beats Runge-Kutta 4 for this job.

3. [The tree and the multipole expansion](/Pages/Physics/papers/hernquist1987/03_treecode/): the long one. Building the tree, the opening angle $\theta$, and the multipole expansion worked out term by term with nothing skipped.

4. [Results](/Pages/Physics/papers/hernquist1987/04_results/): every timing curve, error curve and conservation test from the paper, recreated.

5. [The code](/Pages/Physics/papers/hernquist1987/05_code/): the full Julia source, and how to run it yourself.

6. [Doing better than 1987](/Pages/Physics/papers/hernquist1987/06_beyond/): what the paper could not afford. Higher multipoles, a fourth-order integrator, a million particles.

## Did it work?

My recreation next to the paper. These are numbers I did not tune. They came out of the code the first time it ran correctly.

Three quantities do most of the work in the table, so before the numbers: $\langle n_\text{terms}\rangle$ is **how many lumps an average particle ends up adding together**, which is the direct measure of how much work the tree saves. The *force error* is how far the tree's answer sits from the honest $N^2$ sum on the same particles. $\Delta E/E$ is how much total energy the simulation gains or loses over a run, which ideally would be zero and never is.

**Every entry is read straight out of a production run on the departmental server** ($N$ up to $32768$). My laptop was only ever used for small-$N$ checks while developing.

| Quantity | Hernquist (1987) | My Julia code |
| --- | --- | --- |
| $\langle n_\text{terms}\rangle$, Plummer, $N=32768$, $\theta=1$ | $\approx 221$ | $217.6$ |
| $\langle n_\text{terms}\rangle$, uniform sphere, same | $\approx 121$ | $122.2$ |
| $\langle n_\text{terms}\rangle$, Plummer, $N=1024$, $\theta=1$ | $\approx 130$ | $124.0$ |
| $\langle n_\text{terms}\rangle$, Plummer, $N=32768$, $\theta=0.5$ | $\approx 1060$ | $1053.2$ |
| Force error, $N=32768$, $\theta=1$ | $1.4\%$ to $1.6\%$ (Fig. 6) | $1.548 \pm 0.013\%$ |
| Force error, $N=32768$, $\theta=0.5$ | $\approx0.2\%$ (Fig. 6) | $0.182 \pm 0.003\%$ |
| Error scaling with $N$ | $\sim N^{-1/5}$ | $\sim N^{-1/5}$ |
| $N$ where tree beats direct sum, $\theta=1$ | $\approx 1700$ | $\approx 1700$ |
| Speed-up at $N=32768$, $\theta=1$ | not quoted | $23.8\times$ |
| $\Delta E/E$, 1000 steps, direct sum | $0.20\%$ | $0.22 \pm 0.10\%$ |
| $\Delta E/E$, 1000 steps, $\theta = 0.5$ | $0.32\%$ | $0.26 \pm 0.10\%$ |
| $\Delta E/E$, 1000 steps, $\theta = 1$ | $0.68\%$ | $0.96 \pm 0.14\%$ |
| Relaxation time, $\theta \lesssim 1$ | same as direct | same as direct |
| Multipole truncation error, monopole / quadrupole | $(s/d)^2$ / $(s/d)^3$ | slopes $2.00$ / $3.03$ |

Where I quote a $\pm$, it is the standard deviation over **eight independent random realisations** of the cluster, not the spread inside one run.

\note{
    **This table is deliberately matched, not optimised.** Every row runs at the paper's own settings, so the force-error rows are not "the best I can do": they are the same thing, done again. If I had tuned my code to look good, the comparison would mean nothing.
}

### Why is my force error not *smaller* than a 1987 paper's?

This bothered me for a while, so let me answer it head on.

At $\theta = 0.5$ my error is actually slightly **lower** than the paper's ($0.182\%$ against $\approx0.2\%$). At $\theta = 1$ it is slightly higher. Both differences sit inside how accurately I can read a log-scale figure from 1987, so neither means anything.

The deeper point is that **a faster computer cannot make this number smaller**. The error comes from cutting off an infinite series after a couple of terms, and that cut-off is mathematics, not hardware. Two correct codes, at the same $\theta$ and the same number of terms, on the same particles, **must** agree. Mine agrees with the paper's to about 1%, which is the strongest evidence I have that the implementation is right. If my error had come out ten times smaller, that would not have been a triumph; it would have been a bug.

So how *do* you get a better answer? Only by changing the algorithm: open more boxes (lower $\theta$), describe each box better (keep more terms), or both. Which is exactly what modern hardware buys. Not accuracy directly, but the ability to **afford settings the paper could not run in production**:

| setting | force error | vs. the paper's run | cost |
| --- | --- | --- | --- |
| monopole, $\theta=1$ *(the paper's production setting)* | $1.551\%$ | baseline | $1\times$ |
| quadrupole, $\theta=0.5$ | $0.049\%$ | $32\times$ better | $1.4\times$ |
| octupole, $\theta=0.5$ | $0.018\%$ | $84\times$ better | $1.8\times$ |
| octupole, $\theta=0.3$ | $0.0018\%$ | $871\times$ better | $3.0\times$ |
| **octupole, $\theta=0.2$** | $\mathbf{0.0003\%}$ | $\mathbf{5300\times}$ **better** | $4.9\times$ |

Those three words are just how many terms the box summary keeps: *monopole* is mass alone, *quadrupole* adds its shape, *octupole* adds one more after that. Part 3 builds all three.

And here is the part I like. One force evaluation at $N = 32768$:

| | seconds |
| --- | --- |
| Hernquist's CRAY X-MP, monopole $\theta=1$ | $23.9$ |
| my single core, monopole $\theta=1$ | $0.17$ |
| my single core, **octupole $\theta = 0.2$** | $0.84$ |

**My most accurate setting is still 29 times faster than his crudest one, while being 5300 times more accurate.** That is what forty years bought: not a better formula, but the freedom to run the formula somewhere it was never affordable before.

\note{
    There is one caveat, and [part 6](/Pages/Physics/papers/hernquist1987/06_beyond/) makes it carefully: **wanting more accuracy and needing it are different things.** Measured as accuracy per second, the quadrupole beats the octupole across the whole range anyone normally works in. Hernquist stopped at exactly the right term.
}

### How much of this is noise?

A table like that invites the question "how close is close enough?", so I measured it instead of guessing. I re-ran everything for eight random seeds, changing nothing but the luck of the draw.

| Quantity | mean over 8 seeds | scatter |
| --- | --- | --- |
| $\langle n_\text{terms}\rangle$, $\theta=1$ | $218.4$ | $0.57\%$ |
| $\langle n_\text{terms}\rangle$, $\theta=0.5$ | $1049.9$ | $0.39\%$ |
| Force error, $\theta=1$ | $1.548\%$ | $0.85\%$ |
| Force error, $\theta=0.5$ | $0.182\%$ | $1.68\%$ |
| $\Delta E/E$, direct | $0.222\%$ | $43\%$ |
| $\Delta E/E$, $\theta=1$ | $0.962\%$ | $14\%$ |

The first thing this did was correct a guess I had made. **The force quantities are far more reproducible than I expected**, under $2\%$ scatter, so the $\sim1\%$ gaps against the paper are *not* explained by the random draw. I had assumed they were, and I was wrong.

Chasing it down, the culprit turned out to be where I draw the outermost box. My tree wraps the particles in the tightest cube that contains them; nothing says it has to. Padding that cube moves every cutting plane, so it changes which boxes get accepted. Over paddings from $1.0001$ to $4$, $\langle n_\text{terms}\rangle$ swings by $\pm2.4\%$ and the paper's $221$ sits comfortably inside that range, while the **force error does not move at all**, staying between $1.550$ and $1.555\%$.

\note{
    That is a reassuring pair of facts to have separated. How *many* boxes you end up adding together is partly an accident of where you happened to draw the outer cube; how *accurate* the answer is, is not. So $\langle n_\text{terms}\rangle$ is the wrong thing to compare implementations on. The error is the right thing.
}

### So why are the numbers different at all?

The biggest reason is one the paper tells you itself, and I had walked past it. Discussing the $N=4096$ run, Hernquist writes that $\langle n_\text{terms}\rangle$ was

> approximately 170 to 175 for small $t$, but increased slowly to 195 to 200 during the first 50 time steps

**So $\langle n_\text{terms}\rangle$ is not a property of the model at all. It drifts as the cluster settles.** Every number I had been quoting was measured at the very start. Measured against time instead:

\fig{/assets/Physics/papers/hernquist1987/nterms_of_time}

Time runs along the bottom, and up the side is the average number of lumps a particle had to add together. The line starts low, climbs over the first few crossing times, then levels off. That climb is the whole point: the quantity everybody quotes as a single number is actually moving while you measure it.

| | mine | paper |
| --- | --- | --- |
| $t = 0$ | $171.5$ | $170$ to $175$ |
| after 50 steps | $188.9$ | $195$ to $200$ |
| late-time mean | $193.1$ | $195$ to $200$ |

My starting value lands **inside** the paper's stated range and the drift has the same size and shape. But look at how big that drift is: $171.5$ to $193$, a **13% rise**, ten times bigger than the $1.2\%$ gap I was trying to explain. So "why is my 218.4 not 221?" largely reduces to "at which moment did Hernquist take the snapshot?", a question the paper never answers and never needs to.

What is rising is not the cluster itself. The radii holding 10% and 90% of the mass stay flat to a percent. What changes is that the model, cut off at a finite radius, sheds a thin halo in the first crossing time and a few dozen particles wander far out.

\note{
    Escapers are expensive. A particle alone in empty space cannot be grouped with anything, so everybody else has to count it separately. Sixty-odd stragglers is what lifts $\langle n_\text{terms}\rangle$ by about twenty. The drift is not the tree misbehaving and it is not deep physics, it is the truncated starting condition relaxing.
}

I also tested the other suspect the paper flags, which is a particle being allowed to pull on itself through a box it is sitting inside. Turning that safeguard off changes nothing to four decimal places until $\theta = 1.2$, independently reproducing the paper's own conclusion that the effect "was completely negligible for $\theta \le 1.2$".

\fig{/assets/Physics/papers/hernquist1987/forced_subdivision}

$\theta$ goes right, error goes up, measured with the safeguard on and off. The curves lie on top of each other until the far right, so the effect really is negligible in the range people use.

So the differences come down to when the snapshot was taken (up to 13%), where the outer cube was drawn ($\pm2.4\%$), reading a 1987 log-scale figure by eye ($\pm20\%$), the random realisation ($0.4\%$ to $1.7\%$), and the ordinary fact that my sampler is not their sampler.

The quantities that **are** universal come from the mathematics, and those matched exactly: the tree reproducing the direct sum to $10^{-10}$ when told never to approximate, the multipole slopes $2.00$ and $3.03$ against the derived $2$ and $3$, the leapfrog order $1.98$ against $2$. Those have no free parameters and no snapshot ambiguity, and they are what establish that the code is right.

One honest loose end. $\Delta E/E$ at $\theta=1$ comes out $0.96\pm0.14\%$ against the paper's $0.68\%$, about two standard deviations high, in the same direction as my slightly larger force error there. I suspect a small difference in the opening test rather than an outright error, but I have not tracked it down, and I would rather say so than paper over it.

I also found one thing in the paper that does not survive checking: **equation (3.2)** carries an inconsistent power of $G$. It is harmless, since the whole paper works in units where $G=1$, but the printed formula does not reduce to the correct one if you restore $G$. Derivation and check are [on the setup page](/Pages/Physics/papers/hernquist1987/01_setup/#the_distribution_function).

## A note on how I did this

Everything here I wrote myself and checked in at least two ways, because a simulation that is quietly wrong looks exactly like a simulation that is right.

* The **tree walk** is checked against a brute-force $N^2$ sum. Told never to approximate, the tree is forced to give the direct answer, and it does, to $10^{-10}$.
* The **multipole algebra** was checked symbolically in Mathematica.
* The **integrator** is checked on a two-body orbit, where I know the answer exactly.
* The **initial conditions** are checked by integrating the distribution function back up to the density it came from.

The heavy runs were done on a departmental machine; the small ones ran on my laptop.

---

**Reference:** Hernquist, L. 1987, *The Astrophysical Journal Supplement Series*, **64**, 715. [ADS link](https://ui.adsabs.harvard.edu/abs/1987ApJS...64..715H)

The original algorithm is from Barnes, J. & Hut, P. 1986, *Nature*, **324**, 446.

---

Hope this helps you in some way. If you like it then share with others if possible.

If you have some queries, do let me know in the comments or contact me using the informations that are given on the page [About Me](/Pages/about_me/).

~~~
<button onclick="window.history.back()">Go Back</button>
~~~
