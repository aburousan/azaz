+++
title = "Tree Codes 2: Moving the Particles"
hascode = true
date = Date(2026, 8, 4)
rss = "Part 2 of recreating Hernquist (1987): deriving the leapfrog integrator from Taylor expansions, and why this second-order scheme beats Runge-Kutta 4 for gravitational N-body work."

tags = ["Julia", "physics", "papers", "N-body", "numerical methods", "integrators"]
+++

\toc

# 2. Moving the particles: the leapfrog

Part 2 of my recreation of [Hernquist (1987)](/Pages/Physics/papers/hernquist1987/). In [part 1](/Pages/Physics/papers/hernquist1987/01_setup/) we built a cluster of particles with the right positions and velocities. Now we have to push them forward in time.

This is the derivation sir did on the board, so I will follow it step by step.

## Starting from Taylor

We know where every particle is and how fast it is going at time $t_0$, and from the positions we can compute every acceleration. Taylor expansion is the obvious first move:

$$
\begin{aligned}
r(t_0+\delta t) &= r(t_0) + \delta t\, v(t_0) + \frac{\delta t^2}{2}a(t_0) + \mathcal{O}(\delta t^3)\\
v(t_0+\delta t) &= v(t_0) + \delta t\, a(t_0) + \frac{\delta t^2}{2}j(t_0) + \mathcal{O}(\delta t^3)
\end{aligned}
$$

where $j = \dot a$ is the **jerk**. Let me write $r_0 = r(t_0)$, $r_1 = r(t_0+\delta t)$ and so on:

$$
r_1 = r_0 + \delta t\, v_0 + \frac{\delta t^2}{2}a_0 + \mathcal{O}(\delta t^3), \qquad
v_1 = v_0 + \delta t\, a_0 + \frac{\delta t^2}{2}j_0 + \mathcal{O}(\delta t^3)
$$

Here is the problem. The position update is fine, since I know $v_0$ and $a_0$. But the velocity update needs the **jerk** $j_0$, and computing $\dot a$ means differentiating a sum over all $N$ particles. That is extra work I would rather not do, and if I just drop the jerk term I am left with a first-order scheme, which is bad.

## Sir's trick: evaluate the velocity half a step out

Now the clever bit. Instead of asking for the velocity at $t_0 + \delta t$, ask for it at $t_0 + \delta t/2$:

$$
v_{1/2} = v_0 + \frac{\delta t}{2}a_0 + \frac{\delta t^2}{8}j_0 + \dots = v_0 + \left(\frac{\delta t}{2}\right)a_0 + \mathcal{O}(\delta t^2)
$$

Look at what that buys us. Substitute this into the position update:

$$
r_0 + \delta t\, v_{1/2} = r_0 + \delta t\left(v_0 + \frac{\delta t}{2}a_0\right) = r_0 + \delta t\, v_0 + \frac{\delta t^2}{2}a_0
$$

which is **exactly** the Taylor expansion of $r_1$ up to $\mathcal{O}(\delta t^3)$. So

$$
\boxed{\;\vec r_1 = \vec r_0 + \vec v_{1/2}\,\delta t + \mathcal{O}(\delta t^3)\;}
$$

and by the same argument, using the acceleration at the half step,

$$
\boxed{\;\vec v_1 = \vec v_0 + \vec a_{1/2}\,\delta t + \mathcal{O}(\delta t^3)\;}
$$

\note{
    This is the whole idea. By evaluating things at the **midpoint** of the interval instead of the start, we get accuracy of order $\delta t^3$ per step out of a scheme that only ever uses positions and accelerations. No jerk required. The midpoint quietly does the job the second-order term was doing.
}

Forget gravity for a moment. You are in a car that is steadily speeding up, and you want to know how far you went in the last minute.

* Use the speed at the **start**: you were slower then than on average, so you **underestimate**.
* Use the speed at the **end**: you were faster than average, so you **overestimate**.
* Use the speed at the **middle**: the amount you were too slow in the first half is exactly the amount you were too fast in the second. The errors **cancel**.

\defn{
    That cancellation is the whole trick, and it is the same reason the midpoint rule beats the endpoint rules for integrals. Leapfrog just does it twice over, position updated from the mid-step velocity and velocity from the mid-step acceleration, so each is right to one order better than you paid for.
}

## The picture: who hops over whom

The positions and velocities are now offset from each other by half a step. Sir drew this as a time line. Keep it in front of you, because the name of the method is just a description of this picture.

~~~
<div style="max-width:660px;margin:1.5rem auto">
<svg viewBox="0 0 660 300" xmlns="http://www.w3.org/2000/svg" style="width:100%;height:auto">
  <defs>
    <marker id="lfa" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto">
      <path d="M0,0 L8,4 L0,8 z" fill="#8A8F98"/>
    </marker>
  </defs>

  <text x="40" y="34" fill="#4C8DF6" font-size="13">velocities live on the half steps</text>
  <text x="40" y="292" fill="#E5646E" font-size="13">positions and accelerations live on the whole steps</text>

  <!-- time axis -->
  <line x1="45" y1="170" x2="615" y2="170" stroke="#8A8F98" stroke-width="1.6" marker-end="url(#lfa)"/>
  <text x="628" y="175" fill="#8A8F98" font-size="13" font-style="italic">t</text>

  <!-- ticks -->
  <line x1="90"  y1="163" x2="90"  y2="177" stroke="#8A8F98" stroke-width="1.4"/>
  <line x1="200" y1="163" x2="200" y2="177" stroke="#8A8F98" stroke-width="1.4"/>
  <line x1="310" y1="163" x2="310" y2="177" stroke="#8A8F98" stroke-width="1.4"/>
  <line x1="420" y1="163" x2="420" y2="177" stroke="#8A8F98" stroke-width="1.4"/>
  <line x1="530" y1="163" x2="530" y2="177" stroke="#8A8F98" stroke-width="1.4"/>

  <!-- points -->
  <circle cx="90"  cy="170" r="5" fill="#4C8DF6"/>
  <circle cx="310" cy="170" r="5" fill="#4C8DF6"/>
  <circle cx="530" cy="170" r="5" fill="#4C8DF6"/>
  <circle cx="200" cy="170" r="5" fill="#E5646E"/>
  <circle cx="420" cy="170" r="5" fill="#E5646E"/>

  <!-- velocity labels above -->
  <text x="90"  y="130" fill="#4C8DF6" font-size="15" text-anchor="middle">v<tspan font-size="11" dy="4">&#8722;1/2</tspan></text>
  <text x="310" y="130" fill="#4C8DF6" font-size="15" text-anchor="middle">v<tspan font-size="11" dy="4">1/2</tspan></text>
  <text x="530" y="130" fill="#4C8DF6" font-size="15" text-anchor="middle">v<tspan font-size="11" dy="4">3/2</tspan></text>

  <!-- position labels below -->
  <text x="200" y="196" fill="#E5646E" font-size="15" text-anchor="middle">r<tspan font-size="11" dy="4">0</tspan><tspan font-size="15" dy="-4">, a</tspan><tspan font-size="11" dy="4">0</tspan></text>
  <text x="420" y="196" fill="#E5646E" font-size="15" text-anchor="middle">r<tspan font-size="11" dy="4">1</tspan><tspan font-size="15" dy="-4">, a</tspan><tspan font-size="11" dy="4">1</tspan></text>

  <!-- velocity hops over a position point -->
  <path d="M90,138 Q200,68 310,138" fill="none" stroke="#4C8DF6" stroke-width="1.8" marker-end="url(#lfa)"/>
  <path d="M310,138 Q420,68 530,138" fill="none" stroke="#4C8DF6" stroke-width="1.8" marker-end="url(#lfa)"/>
  <text x="200" y="94" fill="#4C8DF6" font-size="13" text-anchor="middle">+ &#948;t a<tspan font-size="10" dy="3">0</tspan></text>
  <text x="420" y="94" fill="#4C8DF6" font-size="13" text-anchor="middle">+ &#948;t a<tspan font-size="10" dy="3">1</tspan></text>

  <!-- position hops over a velocity point -->
  <path d="M200,206 Q310,276 420,206" fill="none" stroke="#E5646E" stroke-width="1.8" marker-end="url(#lfa)"/>
  <text x="310" y="262" fill="#E5646E" font-size="13" text-anchor="middle">+ &#948;t v<tspan font-size="10" dy="3">1/2</tspan></text>
</svg>
</div>
~~~

Read the two arcs. To get the next velocity you jump from one blue point to the next, straight over a red one, using the acceleration at the red point you jumped over. To get the next position you jump from one red point to the next, straight over a blue one, using the velocity at the blue point you jumped over. Each one uses the other's midpoint, and neither ever lands on its own kind. That leapfrogging is where the name comes from.

Written as the recurrence that actually runs in code:

$$
v_{n+1/2} = v_{n-1/2} + \delta t\, a_n, \qquad r_{n+1} = r_n + \delta t\, v_{n+1/2}
$$

\note{
    The offset is not a bookkeeping annoyance, it is the source of the accuracy. Because every update is centred on the quantity it is stepping over, the leading error terms are the ones that cancel in the car example above. Line the two grids up and you get plain Euler, which is first order and drifts.
}

## The form I actually use: kick-drift-kick

The staggered form above is annoying in practice, because positions and velocities are never known at the same time, which matters if you want to compute the energy. The fix is to split the velocity update into two halves:

$$
\begin{aligned}
&\textbf{kick:}  &&v \leftarrow v + \tfrac{1}{2}\delta t\, a(r) \\
&\textbf{drift:} &&r \leftarrow r + \delta t\, v \\
&\textbf{kick:}  &&v \leftarrow v + \tfrac{1}{2}\delta t\, a(r_{\text{new}})
\end{aligned}
$$

Is that really the same scheme? Write out one step explicitly, from $(r_n, v_n)$:

$$
v_{n+1/2} = v_n + \tfrac{\delta t}{2}a_n, \qquad
r_{n+1} = r_n + \delta t\,v_{n+1/2}, \qquad
v_{n+1} = v_{n+1/2} + \tfrac{\delta t}{2}a_{n+1}
$$

The middle equation is exactly the staggered position update. And the last kick of step $n$ followed by the first kick of step $n+1$ gives

$$
v_{n+3/2} = \underbrace{v_{n+1/2} + \tfrac{\delta t}{2}a_{n+1}}_{\text{last kick of step }n} + \underbrace{\tfrac{\delta t}{2}a_{n+1}}_{\text{first kick of step }n+1} = v_{n+1/2} + \delta t\,a_{n+1}
$$

which is the staggered velocity update. So the two forms generate the *same sequence of positions*. Kick-drift-kick just also hands you a synchronised velocity at every whole step, for free.

And crucially it still needs **only one force evaluation per step**, because $a_{n+1}$ computed for the final kick is reused as the first kick of the next step.

The whole integrator:

```julia
function leapfrog_step!(pos, vel, acc, tree, mass, dt, cfg)
    N = length(mass)
    half = 0.5 * dt
    @inbounds for i in 1:N, k in 1:3
        vel[k, i] += half * acc[k, i]      # kick
    end
    @inbounds for i in 1:N, k in 1:3
        pos[k, i] += dt * vel[k, i]        # drift
    end
    compute_forces!(acc, tree, pos, mass, cfg)
    @inbounds for i in 1:N, k in 1:3
        vel[k, i] += half * acc[k, i]      # kick
    end
end
```

That is genuinely it. Eleven lines, one force call.

## Why not something fancier?

Here is the question that bothered me. Leapfrog is only **second order**. Runge-Kutta 4 is fourth order and everybody learns it first. Why does every serious $N$-body code use the "worse" method?

So I tested it. One particle on an eccentric Kepler orbit around a fixed mass, integrated four ways with the same step size, for 200 orbits.

\fig{/assets/Physics/papers/hernquist1987/integrator_orbits}

This is the orbit itself, seen from above, with 200 revolutions drawn on top of one another. If a method keeps the orbit correct you see one sharp ellipse. Red spreads out into a mess, so forward Euler is useless here.

All 200 orbits at once is a bit of a pile-up, so here is the same run with the orbits arriving in order. Press play and watch which curves stay put:

\fig{/assets/Physics/papers/hernquist1987/anim_integrators}

Red is forward Euler and it walks off the edge of the plot within a few orbits, never to return. Blue (leapfrog) and orange (RK4) both stay on the ellipse for all 60 orbits, and at this scale you cannot separate them. That is the honest situation: on the *orbit*, the fancy method and the cheap method look the same, and only the bad method is visibly bad.

Which is why the orbit picture is only half the story. Look at the energy, which is the thing that actually matters:

\fig{/assets/Physics/papers/hernquist1987/integrator_energy}

Orbits completed goes right, the energy error goes up. Do not look at which curve is lowest, look at the shape. Leapfrog wobbles but stays level forever. RK4 starts better but climbs steadily, and a climbing line will eventually ruin any long run.

Read that plot carefully, because the punchline is in the *shape* of the curves, not their height.

* **Forward Euler** climbs steadily. After 200 orbits it has gained more than 100% of its energy. Dead.
* **Runge-Kutta 4** has the *smallest* error early on, as advertised. But it is a straight line on this plot, so it **drifts**, steadily and forever. Over my run it went from $1.9\times10^{-5}$ at 20 orbits to $1.9\times10^{-4}$ at 200. Ten times longer, ten times worse.
* **Leapfrog** oscillates and never grows. The energy wobbles by $0.26\%$ within each orbit, which is bigger than RK4's error, but after 200 complete orbits the net drift is $8\times 10^{-9}$. It comes back.

\note{
    This is the entire argument. Leapfrog is **symplectic**: it exactly conserves a slightly wrong energy, so the true energy oscillates around the right value but never wanders off. RK4 conserves nothing, so its small errors accumulate. For a simulation run for $10^3$ steps, RK4 might win. For $10^6$ steps leapfrog wins by a mile, and $N$-body simulations are always the second kind.
}

There is a second reason, and for an $N$-body code it may be the bigger one: **cost**. RK4 needs *four* force evaluations per step. In a tree code, a force evaluation is essentially the entire cost of the simulation. So at fixed compute budget leapfrog can take four times as many steps, and its error is $\mathcal{O}(\delta t^2)$, so four times smaller steps means sixteen times better accuracy. The "worse" method wins on both counts.

To confirm the methods are behaving as advertised, here is the error against step size:

\fig{/assets/Physics/papers/hernquist1987/integrator_order}

Step size goes right, error goes up, both on log axes. On such axes the slope of a line is the order of the method, and the slopes come out 1, 2 and 4 as they should. So all three methods are behaving exactly as advertised.

The fitted slopes come out as $1.02$ for symplectic Euler, $1.98$ for leapfrog and $4.81$ for RK4: first, second and fourth order, just as they should be. So leapfrog really is "only" second order. It just does not matter.

\tip{
    Notice that **symplectic Euler** (orange) is only first-order accurate, yet its energy error is also bounded rather than drifting. The magic is not the order of the method, it is the symplectic structure. Leapfrog is essentially symplectic Euler done symmetrically, which buys the extra order.
}

## Time-reversibility, proved

The claim above, that the error stays bounded because the method is symplectic, has a cousin you can prove outright in half a page. It is the clearest way I know to *see* why leapfrog behaves.

**Claim.** Take one KDK step from $(r_0,v_0)$ to $(r_1,v_1)$. Now reverse the velocity and take another KDK step from $(r_1,-v_1)$. You land exactly on $(r_0,-v_0)$.

**Proof.** The forward step was

$$
v_{1/2} = v_0 + \tfrac{\delta t}{2}a(r_0),\qquad r_1 = r_0 + \delta t\,v_{1/2},\qquad v_1 = v_{1/2} + \tfrac{\delta t}{2}a(r_1)
$$

Now run KDK starting from $(r_1, -v_1)$, calling the new intermediates $w$:

$$
w_{1/2} = -v_1 + \tfrac{\delta t}{2}a(r_1) = -\left(v_{1/2} + \tfrac{\delta t}{2}a(r_1)\right) + \tfrac{\delta t}{2}a(r_1) = -v_{1/2}
$$

The first kick undoes the last kick of the forward step exactly, because it uses the *same* acceleration $a(r_1)$. Then the drift:

$$
r_{\text{new}} = r_1 + \delta t\,w_{1/2} = r_1 - \delta t\,v_{1/2} = r_0
$$

We are back at the starting position. And the final kick, now using $a(r_0)$:

$$
w_{\text{new}} = w_{1/2} + \tfrac{\delta t}{2}a(r_0) = -v_{1/2} + \tfrac{\delta t}{2}a(r_0) = -\left(v_{1/2} - \tfrac{\delta t}{2}a(r_0)\right) = -v_0 \qquad\blacksquare
$$

Exactly $(r_0,-v_0)$, with no error terms anywhere. The whole thing worked because the scheme is **symmetric**: it applies $a$ at the same points on the way back as on the way out.

\note{
    Now the consequence. Suppose leapfrog gained $\Delta E$ per step. Reversing the velocities does not change the kinetic energy and the reversed run uses the *same algorithm*, so it would have to gain $\Delta E$ too. But it retraces the forward path exactly, so it must *lose* what the forward run gained. The only number that is both $+\Delta E$ and $-\Delta E$ is zero. RK4 is not time-symmetric, so nothing forbids it from drifting.
}

### The deeper reason: a shadow Hamiltonian

The reversibility argument rules out secular drift but says nothing about how big the wobble is. For that I will quote the standard result without proving it.

Leapfrog can be written as a product of three exact flows: a half-step of the potential part $V$, a full step of the kinetic part $T$, another half-step of $V$. Writing these as exponentials of the corresponding operators,

$$
\text{KDK} = e^{\frac{\delta t}{2}\mathcal{L}_V}\;e^{\delta t\,\mathcal{L}_T}\;e^{\frac{\delta t}{2}\mathcal{L}_V}
$$

Each factor is the *exact* solution of a solvable problem, a pure drift or a pure kick, so each conserves phase-space volume exactly. Their product therefore does too. Combining them with the Baker-Campbell-Hausdorff formula gives a single exponential,

$$
\text{KDK} = e^{\delta t\,\mathcal{L}_{\tilde H}}, \qquad \tilde H = H + \delta t^2 H_2 + \delta t^4 H_4 + \dots
$$

The symmetric ordering kills every odd power. So leapfrog is the **exact** solution of a nearby "shadow" Hamiltonian $\tilde H$ that differs from the true $H$ at order $\delta t^2$. Since it solves that problem exactly, it conserves $\tilde H$ forever, and because $\tilde H = H + \mathcal{O}(\delta t^2)$, the true energy $H$ can never wander more than $\mathcal{O}(\delta t^2)$ away.

\tip{
    That is the whole story in one line: **leapfrog does not approximately solve your problem, it exactly solves a slightly different one.** RK4 approximately solves your problem, and there is no nearby problem it is solving exactly, so there is nothing to stop its errors accumulating. My measurements bear this out. Leapfrog's wobble is $2.6\times10^{-3}$ and stays there after 200 orbits, while RK4's drift grew by exactly a factor of ten when I ran ten times longer.
}

\defn{
    Picture a guitar string tuned very slightly flat. It is not the note you asked for, but it is a *real* note, so the string sits on it forever, humming steadily, rather than gradually going silent. Leapfrog is that string: it obeys $\tilde H$ exactly, and $\tilde H$ is only $\mathcal{O}(\delta t^2)$ out of tune with the $H$ you wanted, so your energy is pinned within that detuning forever. Runge-Kutta has no note of its own to sit on, so nothing anchors it.
}

That also tells you what to expect on a plot. Leapfrog gives a **band**: noisy, but flat and level no matter how long you run. RK4 gives a **line with a slope**. A band you can live with; a slope will eventually eat your simulation.

## Choosing the step size

The paper uses $\delta t = 0.025$ in units where $G = M = R = 1$, and says this is about $5\%$ of the core crossing time. The scale that matters is how long a typical particle takes to cross the dense middle,

$$
t_{\text{cross}} \sim \frac{r}{\sigma_0}, \qquad \sigma_0 = \sqrt{\frac{GM}{6r_0}} \approx 0.91
$$

but "the core" and "a crossing" are both loose, so it is worth pinning the number down rather than guessing at $r$. The paper does it for us elsewhere: it says 1000 steps of $0.025$ amount to "of the order of 50 core crossing times". That is $25$ time units for 50 crossings, so its crossing time is $0.5$, and $\delta t$ really is $5\%$ of it, resolving one crossing with **20 steps**.

That $0.5$ also tells you which radius the paper means. Putting the half-mass radius $r_{1/2} = 0.248$ into a there-and-back crossing gives $2r_{1/2}/\sigma_0 = 0.54$, which is the right number; using $r_0$ one way gives $0.22$, a factor of two smaller. Either convention leaves $\delta t$ comfortably small, but they differ by enough to matter if you quote steps-per-crossing, so I am using the paper's. I keep $\delta t = 0.025$ throughout so my results can be compared with the paper's directly.

\prob{
    A real production code would not use one step size for everybody. A particle in the dense core needs a much smaller $\delta t$ than one drifting in the halo. Try modifying the integrator to give each particle its own step size, chosen from something like $\delta t_i \propto \sqrt{\varepsilon / |a_i|}$, then check whether the energy conservation improves at fixed total cost. The paper mentions this idea, under "multiple time scales", as one of the obvious refinements.
}

## Where we are

We can now move particles forward in time cheaply and stably. What we still cannot do is compute $a_i$ for all $N$ particles without $O(N^2)$ work.

Which is the next part, and the real content of the paper.

---

**Previous:** [Part 1, the problem and the model](/Pages/Physics/papers/hernquist1987/01_setup/)\\
**Next:** [Part 3, the tree and the multipole expansion](/Pages/Physics/papers/hernquist1987/03_treecode/)

Hope this helps you in some way. If you like it then share with others if possible.

If you have some queries, do let me know in the comments or contact me using the informations that are given on the page [About Me](/Pages/about_me/).

~~~
<button onclick="window.history.back()">Go Back</button>
~~~
