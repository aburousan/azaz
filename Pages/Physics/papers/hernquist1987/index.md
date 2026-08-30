+++
title = "Tree Codes: Recreating Hernquist (1987)"
hascode = true
date = Date(2026, 8, 4)
rss = "Recreating Hernquist's 1987 paper on the performance of Barnes-Hut tree codes, from scratch in Julia: the Plummer model, the leapfrog integrator, the multipole expansion and every timing and error test in the paper."
card = true
card_category = "Series"

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

1. [The problem and the model](/Pages/Physics/papers/hernquist1987/01_setup/): Poisson's equation, the Plummer sphere, where the initial positions and velocities actually come from, and the virial theorem sir started from. Also why a softened system sits at $-2K/U = 0.966$ and is nonetheless in perfect equilibrium.

2. [Moving the particles](/Pages/Physics/papers/hernquist1987/02_leapfrog/): the leapfrog integrator, derived the way sir did it on the board, why this clumsy-looking scheme beats Runge-Kutta 4 for this job, and the fine print about what "symplectic" does and does not promise once the forces come from a tree.

3. [The tree and the multipole expansion](/Pages/Physics/papers/hernquist1987/03_treecode/): the long one. Building the tree, the opening angle $\theta$, and the multipole expansion worked out term by term with nothing skipped. Then the two things I originally got wrong: what the opening test really tests (not what I thought), and a proper count of the work with no free parameters in it.

4. [Results](/Pages/Physics/papers/hernquist1987/04_results/): every timing curve, error curve and conservation test from the paper, recreated. Plus where the error actually comes from, cell by cell, and what the average error is hiding.

5. [The code](/Pages/Physics/papers/hernquist1987/05_code/): the full Julia source, the 44 tests, and how to run it yourself.

6. [Doing better than 1987](/Pages/Physics/papers/hernquist1987/06_beyond/): what the paper could not afford. Higher multipoles and where they actually pay, a fourth-order integrator that loses, two attempts at repairing the opening test that also lose, and a million particles.

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
| Error scaling with $N$, over the paper's range | $\sim N^{-1/5}$ | $N^{-0.18}$ |
| $N$ where tree beats direct sum, $\theta=1$ | $\approx 1700$ | below $1024$ (machine dependent) |
| $N$ where tree beats direct sum, $\theta=0.5$ | $\approx 7000$ | $\approx 2300$ (machine dependent) |
| Speed-up at $N=32768$, $\theta=1$ | not quoted | $24\times$ |
| $\Delta E/E$, 1000 steps, direct sum | $0.20\%$ | $0.22 \pm 0.10\%$ |
| $\Delta E/E$, 1000 steps, $\theta = 0.5$ | $0.32\%$ | $0.26 \pm 0.10\%$ |
| $\Delta E/E$, 1000 steps, $\theta = 1$ | $0.68\%$ | $0.96 \pm 0.14\%$ |
| Relaxation time, $\theta \lesssim 1$ | same as direct | same as direct |
| Multipole truncation error, monopole / quadrupole | $(s/d)^2$ / $(s/d)^3$ | slopes $2.00$ / $3.03$ |
| Net (spurious) force on the centre of mass, $\theta=1$ | not measured | $1.6\times10^{-4}$, against $4\times10^{-17}$ direct |

Where I quote a $\pm$, it is the standard deviation over **eight independent random realisations** of the cluster, not the spread inside one run.

Two rows in that table are *supposed* to disagree, and I had them wrong for a long time. The $N$ at which the tree overtakes the direct sum is **not a property of the algorithm**. It is the point where two inner loops break even, and how fast each of those loops runs is a fact about the machine. On a CRAY X-MP the direct sum vectorised beautifully while a branch-heavy tree walk did not, so the tree had a lot of ground to make up and only caught up near $N\approx1700$. On a modern core the two loops are far closer in speed, so my tree wins much sooner: already below $N=1024$ at $\theta=1$, and near $N\approx2300$ at $\theta=0.5$ against his $\approx7000$. [Part 4](/Pages/Physics/papers/hernquist1987/04_results/#when_is_it_actually_worth_it) has the measurement. This number has to be measured again on every architecture, and an earlier version of these pages made a virtue of an agreement that was not really there.

\note{
    **This table is deliberately matched, not optimised.** Every row runs at the paper's own settings, so the force-error rows are not "the best I can do": they are the same thing, done again. If I had tuned my code to look good, the comparison would mean nothing.
}

### Why is my force error not *smaller* than a 1987 paper's?

This bothered me for a while, so let me answer it head on.

At $\theta = 0.5$ my error is actually slightly **lower** than the paper's ($0.182\%$ against $\approx0.2\%$). At $\theta = 1$ it is slightly higher. Both differences sit inside how accurately I can read a log-scale figure from 1987, so neither means anything.

The deeper point is that **a faster computer cannot make this number smaller**. The error comes from cutting off an infinite series after a couple of terms, and that cut-off is mathematics, not hardware. Two correct codes, at the same $\theta$ and the same number of terms, on the same particles, **must** agree. Mine agrees with the paper's to about 1%, which is the strongest evidence I have that the implementation is right. If my error had come out ten times smaller, that would not have been a triumph; it would have been a bug.

So how *do* you get a better answer? Only by changing the algorithm: open more boxes (lower $\theta$), describe each box better (keep more terms), or both. Which is exactly what modern hardware buys. Not accuracy directly, but the ability to **afford settings the paper could not run in production**.

Here is one force evaluation on the whole $N = 32768$ cluster. Every row is **one core, single threaded**, so it is the same currency Hernquist was paying in:

| one force evaluation, $N=32768$, one core | seconds | force error |
| --- | --- | --- |
| CRAY X-MP, monopole, $\theta = 1$ (1987) | $23.9$ | $1.55\%$ |
| this work, monopole, $\theta = 1$ | $0.18$ | $1.55\%$ |
| this work, quadrupole, $\theta = 0.55$ | $0.70$ | $0.071\%$ |
| this work, octupole, $\theta = 0.22$ | $12.1$ | $0.00043\%$ |
| this work, direct sum (no approximation) | $4.12$ | $0$ |

*Monopole*, *quadrupole* and *octupole* are just how many terms the box summary keeps: mass alone, then its shape, then one more after that. Part 3 builds all three.

Read that table slowly, because it is easy to claim too much from it. **The most accurate setting I ran takes about half the time the CRAY needed for its crudest one, and gives a force error 3600 times smaller.** That is the headline, and it is a real one. But it is not free. Inside one machine, that same octupole setting still costs **67 times more** than the crude setting costs today. Accuracy still has a price; only the scale has changed.

The last row is the one that puts it in perspective. At this $N$ the *exact* answer, with no approximation anywhere, now costs $4.12$ seconds, which is a sixth of what the *approximate* answer cost in 1987. Four decades did not supply a better formula. They supplied enough fast arithmetic to run the same formula in a regime that was not practical before.

\note{
    **An earlier version of this page got that comparison badly wrong**, and I would rather fix it in public than quietly. I had claimed the octupole setting was "29 times faster than his crudest one". That number came from a **multi-threaded** run of my code being compared against a **single-CPU** CRAY figure, which is not a comparison at all. On one core the honest answer is a factor of about two, not twenty-nine. The accuracy gain also came down, from $5300\times$ to $3600\times$, once I quoted both errors at the same $\theta$ grid points. The physics did not change; my bookkeeping did.
}

Since there is no page limit here, the full single-core sweep, so you can pick your own point on it. Timings on a shared machine are good to about $20\%$, so read the seconds as indicative and the errors as solid:

| $\theta$ | terms per particle | monopole | quadrupole | octupole |
| --- | --- | --- | --- | --- |
| $0.15$ | $11160$ | $11.6$ s, $0.0069\%$ | $12.8$ s, $0.00046\%$ | $22.9$ s, $0.000080\%$ |
| $0.18$ | $8434$ | $8.31$ s, $0.0118\%$ | $8.70$ s, $0.00097\%$ | $16.1$ s, $0.00018\%$ |
| $0.22$ | $6153$ | $4.77$ s, $0.0203\%$ | $6.76$ s, $0.0020\%$ | $12.1$ s, $0.00043\%$ |
| $0.26$ | $4325$ | $3.40$ s, $0.0338\%$ | $4.13$ s, $0.0040\%$ | $6.65$ s, $0.00097\%$ |
| $0.32$ | $2906$ | $2.05$ s, $0.0553\%$ | $2.52$ s, $0.0083\%$ | $4.94$ s, $0.0023\%$ |
| $0.38$ | $1915$ | $1.89$ s, $0.0906\%$ | $1.66$ s, $0.0169\%$ | $2.85$ s, $0.0053\%$ |
| $0.46$ | $1269$ | $0.86$ s, $0.147\%$ | $1.04$ s, $0.0349\%$ | $1.81$ s, $0.0126\%$ |
| $0.55$ | $841$ | $0.57$ s, $0.240\%$ | $0.70$ s, $0.0710\%$ | $1.18$ s, $0.0289\%$ |
| $0.66$ | $539$ | $0.39$ s, $0.404\%$ | $0.66$ s, $0.161\%$ | $1.15$ s, $0.0808\%$ |
| $0.80$ | $342$ | $0.33$ s, $0.695\%$ | $0.33$ s, $0.338\%$ | $0.77$ s, $0.187\%$ |
| $0.96$ | $233$ | $0.25$ s, $1.35\%$ | $0.25$ s, $0.865\%$ | $0.38$ s, $0.552\%$ |
| $1.16$ | $170$ | $0.19$ s, $2.89\%$ | $0.20$ s, $2.22\%$ | $0.30$ s, $1.60\%$ |
| $1.40$ | $130$ | $0.16$ s, $5.98\%$ | $0.17$ s, $4.96\%$ | $0.26$ s, $3.67\%$ |

Two things fall out of that table which took me a while to see. Along any row the extra terms are almost free at large $\theta$ and expensive at small $\theta$, which is a **memory** effect, not an arithmetic one, and [part 6](/Pages/Physics/papers/hernquist1987/06_beyond/) works out why. And the octupole column only pulls decisively ahead once you are already chasing errors below about one part in $10^4$, which is why the quadrupole owns the middle of the range.

\note{
    There is one caveat, and [part 6](/Pages/Physics/papers/hernquist1987/06_beyond/) makes it carefully: **wanting more accuracy and needing it are different things.** Measured as accuracy per second, the quadrupole is the cheapest route to any error between about $2\%$ and $5\times10^{-5}$, which is where essentially every real simulation lives. The octupole only starts paying for itself below that. Hernquist stopped at the right term, and he stopped there for a reason that is still true.
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

I also tested the other suspect the paper flags, which is a particle being allowed to pull on itself through a box it is sitting inside. Turning that safeguard off changes the force error by this much:

| $\theta$ | safeguard on | safeguard off |
| --- | --- | --- |
| $0.5$ | $0.18474\%$ | $0.18474\%$ |
| $1.0$ | $1.55068\%$ | $1.55079\%$ |
| $1.2$ | $3.3020\%$ | $3.3184\%$ |
| $1.5$ | $7.445\%$ | $8.073\%$ |

At $\theta = 0.5$ it is identical to every digit I print, because no particle is ever inside a cell that passes the test. At $\theta = 1$ it moves the fourth decimal place. By $\theta = 1.5$ it is worth $8\%$ of the error. That independently reproduces the paper's own conclusion that the effect "was completely negligible for $\theta \le 1.2$", and shows where it stops being negligible.

\fig{/assets/Physics/papers/hernquist1987/forced_subdivision}

$\theta$ goes right, error goes up, measured with the safeguard on and off. The curves lie on top of each other until the far right, so the effect really is negligible in the range people use.

So the differences come down to when the snapshot was taken (up to 13%), where the outer cube was drawn ($\pm2.4\%$), reading a 1987 log-scale figure by eye ($\pm20\%$), the random realisation ($0.4\%$ to $1.7\%$), and the ordinary fact that my sampler is not their sampler.

The quantities that **are** universal come from the mathematics, and those matched exactly: the tree reproducing the direct sum to $10^{-10}$ when told never to approximate, the multipole slopes $2.00$ and $3.03$ against the derived $2$ and $3$, the leapfrog order $1.98$ against $2$. Those have no free parameters and no snapshot ambiguity, and they are what establish that the code is right.

One honest loose end. $\Delta E/E$ at $\theta=1$ comes out $0.96\pm0.14\%$ against the paper's $0.68\%$, about two standard deviations high, in the same direction as my slightly larger force error there. I suspect a small difference in the opening test rather than an outright error, but I have not tracked it down, and I would rather say so than paper over it.

\note{
    **A retraction.** An earlier version of this page claimed I had found an error in the paper: that **equation (3.2)** carries an inconsistent power of $G$. That claim was wrong, and the mistake was mine, in copying the formula out. Written with a single $G$ in the prefactor, which is what the paper actually prints, equation (3.2) reduces **exactly** to the Eddington result I derive on the [setup page](/Pages/Physics/papers/hernquist1987/01_setup/#the_distribution_function), powers of $G$ and all. I had written $G^5$ where the paper has $G$, and then dutifully discovered the $G^{-4}$ I had put there myself. The check is redone, symbolically and numerically, on that page.

    The lesson I take from it is not a comfortable one. It is very easy to find an "error" in somebody else's paper when the error is in your own transcription, and the check that would have caught it, going back to the printed page instead of to my notes, is the one I skipped.
}

## A note on how I did this

Everything here I wrote myself and checked in at least two ways, because a simulation that is quietly wrong looks exactly like a simulation that is right.

* The **tree walk** is checked against a brute-force $N^2$ sum. Told never to approximate, the tree is forced to give the direct answer, and it does, to $10^{-10}$.
* The **multipole algebra** was checked symbolically in Mathematica: the Legendre expansion order by order, the collapse of each Legendre term into its tensor, tracelessness, and that every acceleration really is minus the gradient of its own potential.
* The **moment recursion** is checked at the root of the tree, which never touches a particle directly, against a brute-force sum over all $N$. Quadrupole and raw third moment both agree to about one part in $10^9$.
* The **integrator** is checked on a two-body orbit, where I know the answer exactly, and its order comes out $1.98$ against the promised $2$.
* The **initial conditions** are checked by integrating the distribution function back up to the density it came from, and separately against the Jeans velocity dispersion, which was never fed to the sampler.
* The **one-sided force** is checked with a net-force diagnostic, which must be small but is not allowed to be zero, and with translation covariance: move every particle by the same vector and the accelerations must not change.

The heavy runs were done on a departmental machine; the small ones ran on my laptop.

## What changed after I wrote this up properly

These pages went up first as a set of notes. Turning them into a two-part article for *Resonance* meant defending every number in front of an editor, and that process turned up several things I had got wrong. I have fixed them above rather than leaving the old text standing, but it seems dishonest to fix them silently, so here is the list:

1. **The headline speed comparison.** I compared a threaded run of my code against a single-CPU CRAY number and got "29 times faster". On one core it is about two times faster. Corrected above.
2. **Hernquist's equation (3.2).** I claimed it carries a wrong power of $G$. It does not. I had mis-transcribed it. Retracted above and on [part 1](/Pages/Physics/papers/hernquist1987/01_setup/#the_distribution_function).
3. **The tree-versus-direct crossover.** I reported $N\approx1700$ "exactly matching the paper" and drew a conclusion about the ratio being machine-independent. Both were wrong: my crossover is well below $1024$, and the crossover is exactly the sort of number that *is* machine dependent. Corrected on [part 4](/Pages/Physics/papers/hernquist1987/04_results/#when_is_it_actually_worth_it).
4. **What the quadrupole costs.** I quoted "1.3 to 1.5 times", agreeing with the paper. Per accepted cell it is $11\%$ on this machine, and the discrepancy with 1987 is architectural, not algorithmic. Corrected on [part 4](/Pages/Physics/papers/hernquist1987/04_results/#what_does_the_quadrupole_cost).
5. **How to soften a multipole.** I claimed my softening prescription was exactly the gradient of a consistently softened quadrupole potential. It is not, and the missing piece is interesting rather than embarrassing: the softened kernel is not harmonic, so the trace no longer drops out. Now derived properly on [part 3](/Pages/Physics/papers/hernquist1987/03_treecode/#what_softening_does_to_the_expansion).
6. **Where the series actually converges.** I said "keep $\theta$ below about 1 because the series needs $s/d<1$". The acceptance test does not test that quantity at all, and the real threshold is $\theta \le 1/\sqrt3 \approx 0.577$. This one is worth a whole section, and it now has one on [part 3](/Pages/Physics/papers/hernquist1987/03_treecode/#the_test_does_not_test_what_you_think_it_tests).
7. **Why $\theta^{-3}$ does not hold.** I noted the discrepancy and shrugged at it. There is a proper counting model with no free parameters that explains it, now on [part 3](/Pages/Physics/papers/hernquist1987/03_treecode/#a_better_count).

And several sections are new rather than corrected: where the tree error actually comes from and why it cancels, what the average error hides, and whether the opening test can be repaired.

---

**Reference:** Hernquist, L. 1987, *The Astrophysical Journal Supplement Series*, **64**, 715. [ADS link](https://ui.adsabs.harvard.edu/abs/1987ApJS...64..715H)

The original algorithm is from Barnes, J. & Hut, P. 1986, *Nature*, **324**, 446.

---

Hope this helps you in some way. If you like it then share with others if possible.

If you have some queries, do let me know in the comments or contact me using the informations that are given on the page [About Me](/Pages/about_me/).

~~~
<button onclick="window.history.back()">Go Back</button>
~~~
