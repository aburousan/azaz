+++
title = "Tree Codes 1: The Problem and the Model"
hascode = true
date = Date(2026, 8, 4)
rss = "Part 1 of recreating Hernquist (1987): Poisson's equation, the Plummer sphere, sampling initial conditions from a distribution function and the virial theorem."

tags = ["Julia", "physics", "papers", "N-body", "gravity", "astrophysics"]
+++

\toc

# 1. The problem, and the model we drop particles into

This is part 1 of my recreation of [Hernquist (1987)](/Pages/Physics/papers/hernquist1987/). Here I set up the physics: what equation we are solving, what object we are simulating, how to generate the starting positions and velocities and how to tell whether the thing is in equilibrium.

## Where it starts: Poisson's equation

Sir wrote this on the board first, and everything else hangs off it:

$$
\nabla^2 \phi = 4\pi G \rho
$$

That is Poisson's equation. Given a mass density $\rho(\vec{r})$ it tells you the gravitational potential $\phi(\vec{r})$, and then the acceleration of anything sitting at $\vec{r}$ is $\vec{a} = -\nabla \phi$.

We lean on this equation the whole way through, so here is where it comes from. Start with Newton's law for the field of a point mass $M$ at the origin,

$$
\vec g = -\frac{GM}{r^2}\hat r
$$

Take a sphere of radius $r$ around it and compute the flux of $\vec g$ through the surface. Because $\vec g$ is radial and has the same magnitude everywhere on the sphere,

$$
\oint \vec g\cdot d\vec S = -\frac{GM}{r^2}\times 4\pi r^2 = -4\pi GM
$$

The $r^2$ cancels, so the flux does not care how big the sphere is. That is entirely due to gravity being an inverse-*square* law, and it is the reason all of this works. Since flux is additive over sources, for any distribution enclosing total mass $M_{\text{enc}}$,

$$
\oint \vec g\cdot d\vec S = -4\pi G M_{\text{enc}} = -4\pi G\int_V \rho\, dV
$$

This is Gauss's law for gravity. Now apply the divergence theorem to the left side, $\oint\vec g\cdot d\vec S = \int_V \nabla\cdot\vec g\, dV$:

$$
\int_V \left(\nabla\cdot\vec g + 4\pi G\rho\right)dV = 0
$$

This holds for *every* volume $V$, which forces the integrand itself to vanish. So $\nabla\cdot\vec g = -4\pi G\rho$, and substituting $\vec g = -\nabla\phi$,

$$
\nabla\cdot\left(\nabla\phi\right) = \nabla^2\phi = 4\pi G\rho
$$

\note{
    Everything in this project is a consequence of that one cancellation of $r^2$. It is why the field of a spherical shell vanishes inside it, why we can replace a distant clump by a point mass and (as we will see in [part 3](/Pages/Physics/papers/hernquist1987/03_treecode/)) why the multipole expansion has the structure it does.
}

For a smooth continuous fluid you could try to solve this on a grid. But a star cluster is **not** a fluid. It is a few hundred thousand point masses, and the whole interesting physics, stars flinging each other around, the core collapsing, lives in the fact that it is made of *lumps*. So instead of solving the differential equation, we go back to its solution for point masses and add them up:

$$
\phi(\vec{r}) = -G\sum_j \frac{m_j}{|\vec{r} - \vec{r}_j|}, \qquad
\vec{a}_i = -G\sum_{j\neq i} m_j \frac{\vec{r}_i - \vec{r}_j}{|\vec{r}_i - \vec{r}_j|^3}
$$

This is the $N$-body problem, and as I said on the [front page](/Pages/Physics/papers/hernquist1987/), doing it honestly costs $O(N^2)$ per step.

### One repair we need first: softening

There is a nasty problem hiding in that formula. If two particles come very close, $|\vec r_i - \vec r_j| \to 0$ and the force goes to infinity. Numerically this is a disaster: one unlucky close pass and a particle gets launched out of the system with absurd energy.

But think about what our particles actually *represent*. In a real galaxy simulation, one "particle" stands in for millions of stars. It is a smeared-out blob, not a point. So the divergence is not even physical. The standard repair is to soften the potential, which is Hernquist's eq. (2.1):

$$
\varphi(r) = -\frac{G m_1 m_2}{\left(r^2 + \varepsilon^2\right)^{1/2}}
$$

\defn{
    **Softening length $\varepsilon$**: a small distance below which gravity is artificially weakened, so that no pair of particles can ever feel an infinite force. For $r \gg \varepsilon$ the potential is Newtonian again; for $r \to 0$ it flattens off to a finite value $-Gm_1m_2/\varepsilon$.
}

My first reaction was that this is cheating, that we broke gravity because the maths was inconvenient. It is the opposite.

A globular cluster has $\sim10^6$ stars; my simulation has 4096 particles. So one of my particles is not a star, it stands in for roughly 250 of them. And the field of 250 stars spread over some volume is smooth and finite everywhere, including in the middle. Letting my sample diverge would be claiming a sharpness the model never had.

\note{
    Softening is not a patch over a hole in Newton's law, it is an honest statement about **resolution**: below $\varepsilon$ my particles do not represent anything real, so I am not entitled to an answer there. A pixel is not a point, a grid cell is not a point and a simulation particle is not a point either.
}

How fast does it become Newtonian again? Expanding for $r \gg \varepsilon$ (I checked this in Mathematica):

$$
\frac{\varphi_{\text{soft}}}{\varphi_{\text{Kepler}}} = 1 - \frac{1}{2}\frac{\varepsilon^2}{r^2} + \frac{3}{8}\frac{\varepsilon^4}{r^4} + \dots
$$

which matches the expansion quoted in the paper. So the softening error dies off like $(\varepsilon/r)^2$, which is not very fast. This will come back to bite us later when we look at how softening interacts with the multipole expansion.

The natural size for $\varepsilon$ is the **mean interparticle separation** $\lambda$: close enough that you are not smearing out real structure, far enough that you are not resolving pairs which are not physically meaningful anyway.

## The Plummer model

Now, what do we actually simulate? Sir said "Plummer profile problem", and the paper uses it too, for a good reason. It is one of the very few self-gravitating models where *everything* can be written down in closed form: density, potential, mass profile, velocity dispersion and most importantly the distribution function.

The density is the paper's eq. (3.1):

$$
\rho(r) = \frac{3M}{4\pi}\frac{r_0^2}{\left(r^2+r_0^2\right)^{5/2}}
$$

with $M$ the total mass and $r_0$ a scale length. The paper uses $M = 1$, $r_0 = 0.2$, $G = 1$ and cuts the sphere off at radius $R = 1$. I use exactly the same.

Two limits tell you the shape at a glance:

* $r \ll r_0$: $\rho \to 3M/(4\pi r_0^3)$, a flat constant-density **core**.
* $r \gg r_0$: $\rho \to 3Mr_0^2/(4\pi r^5)$, a steeply falling **halo**.

So it is a fat core with thin wings, which is roughly what a globular cluster looks like.

The potential that goes with it is very simple:

$$
\phi(r) = -\frac{GM}{\sqrt{r^2+r_0^2}}
$$

\note{
    Look at the potential again. It is exactly the potential of a **point mass**, but with $r$ replaced by $\sqrt{r^2+r_0^2}$, the same trick as the softened potential above. A Plummer sphere *is* a softened point mass. That is not a coincidence: it is why $\varphi_{\text{soft}}$ is the standard choice, and why $\varepsilon$ is sometimes called a "Plummer softening".
}

Before using the pair I checked that it really does satisfy Poisson's equation. In spherical symmetry,

$$
\nabla^2\phi = \frac{1}{r^2}\frac{d}{dr}\left(r^2\frac{d\phi}{dr}\right)
$$

Doing this by hand is tedious, so I let Mathematica do it:

```mathematica
phiP = -G Mt/Sqrt[r^2 + r0^2];
rhoP = (3 Mt/(4 Pi)) r0^2/(r^2 + r0^2)^(5/2);
FullSimplify[(1/r^2) D[r^2 D[phiP, r], r] - 4 Pi G rhoP]
```

which returns `0`. Good, the pair is consistent.

Let me also do the enclosed mass by hand, since we need it for the sampler and the integral is a nice one:

$$
M(r) = \int_0^r 4\pi r'^2\rho(r')\,dr' = 3Mr_0^2\int_0^r\frac{r'^2\,dr'}{(r'^2+r_0^2)^{5/2}}
$$

Substitute $r' = r_0\tan\alpha$, so $dr' = r_0\sec^2\alpha\,d\alpha$ and $r'^2+r_0^2 = r_0^2\sec^2\alpha$:

$$
\int\frac{r'^2\,dr'}{(r'^2+r_0^2)^{5/2}} = \int\frac{r_0^2\tan^2\alpha\cdot r_0\sec^2\alpha\,d\alpha}{r_0^5\sec^5\alpha} = \frac{1}{r_0^2}\int\frac{\tan^2\alpha}{\sec^3\alpha}d\alpha = \frac{1}{r_0^2}\int \sin^2\alpha\cos\alpha\,d\alpha
$$

which is just $\sin^3\alpha/3$. Undoing the substitution with $\sin\alpha = r'/\sqrt{r'^2+r_0^2}$:

$$
M(r) = 3Mr_0^2\cdot\frac{1}{r_0^2}\cdot\frac{1}{3}\left[\frac{r'^3}{(r'^2+r_0^2)^{3/2}}\right]_0^r
= \boxed{\;M\,\frac{r^3}{\left(r^2+r_0^2\right)^{3/2}}\;}
$$

Two sanity checks. As $r\to\infty$ this tends to $M$, so the total mass really is $M$ and the model is not secretly infinite. As $r\to 0$ it goes as $Mr^3/r_0^3$, which is what a constant-density core must give.

The whole model in one plot. Note the log axis on $r$, and that $\rho$ has its own axis on the left while everything else shares the right one.

\fig{/assets/Physics/papers/hernquist1987/plummer_profiles}

Radius goes right, and the four curves are everything the model says about itself. Density is flat in the middle and then falls off a cliff, which is the core plus halo shape. Enclosed mass climbs and levels off at 1, so nearly all the mass sits within a couple of scale lengths. The potential is deepest at the centre. The typical speed is highest in the middle and drops outwards, which is what you expect for stars sitting deeper in the well.

## The distribution function

Now comes the part that actually matters for setting up a simulation, and it is the bit I found most interesting.

Giving the particles the right *positions* is easy: just sample from $\rho(r)$. But if I then hand them random velocities, the cluster will not be in equilibrium. It will collapse or explode and then settle into something else entirely. I need the *right* velocities too.

\defn{
    The **distribution function** $f(\vec r, \vec v)$ is the density of particles in the six-dimensional space of positions *and* velocities. The number of particles in a little box $d^3r\, d^3v$ is $f\, d^3r\, d^3v$. Getting the mass density back is just integrating over all velocities: $\rho(\vec r) = \int f\, d^3 v$.
}

For a system that is in a steady state, spherical, with no preferred direction in velocity space (an *isotropic* system), Jeans' theorem says $f$ can only depend on the energy per unit mass,

$$
E = \frac{1}{2}v^2 + \phi(r)
$$

So I need the one function $f(E)$ whose velocity integral gives back the Plummer density. Here is how you get it.

### Setting up the integral equation

Work with the **relative potential** $\Psi = -\phi$ (positive, deepest at the centre) and the **relative energy** $\mathcal{E} = -E = \Psi - \tfrac{1}{2}v^2$. A particle is bound when $\mathcal{E} > 0$.

Since $f$ is isotropic, the velocity integral only needs the magnitude of $\vec v$, so $d^3v = 4\pi v^2\,dv$:

$$
\rho(r) = \int f\,d^3v = 4\pi\int_0^{v_e}v^2 f(\mathcal{E})\,dv, \qquad v_e = \sqrt{2\Psi}
$$

Change the integration variable from $v$ to $\mathcal{E}$. From $\mathcal{E} = \Psi - v^2/2$ we get $v = \sqrt{2(\Psi-\mathcal{E})}$ and $v\,dv = -d\mathcal{E}$, so $v^2dv = v\cdot v\,dv = -\sqrt{2(\Psi-\mathcal{E})}\,d\mathcal{E}$. The limits flip ($v=0 \Rightarrow \mathcal{E}=\Psi$, and $v=v_e \Rightarrow \mathcal{E}=0$), which eats the minus sign:

$$
\rho(\Psi) = 4\pi\sqrt2\int_0^{\Psi}f(\mathcal{E})\,(\Psi-\mathcal{E})^{1/2}\;d\mathcal{E}
$$

\note{
    Notice that $\rho$ is now written as a function of $\Psi$ rather than $r$. That is legitimate whenever $\Psi(r)$ is monotonic, which it is for any sensible spherical model, so $r$ and $\Psi$ label the same points and we can move back and forth freely.
}

This is an integral equation for the unknown $f$. It has an awkward feature: the unknown sits inside an integral whose upper limit is the variable we care about. Differentiating once with respect to $\Psi$ pulls the power down by one and makes the kernel singular, which turns out to be exactly what we want. Using Leibniz's rule,

$$
\frac{d}{d\Psi}\int_0^{\Psi}f(\mathcal{E})(\Psi-\mathcal{E})^{1/2}d\mathcal{E}
= \underbrace{f(\Psi)\,(\Psi-\Psi)^{1/2}}_{=\;0}
+ \int_0^{\Psi}f(\mathcal{E})\,\frac{1}{2}(\Psi-\mathcal{E})^{-1/2}\,d\mathcal{E}
$$

The boundary term dies because the kernel itself vanishes at the upper limit. So

$$
\frac{d\rho}{d\Psi} = 4\pi\sqrt2\cdot\frac{1}{2}\int_0^{\Psi}\frac{f(\mathcal{E})}{\sqrt{\Psi-\mathcal{E}}}\,d\mathcal{E}
= 2\sqrt2\,\pi\int_0^{\Psi}\frac{f(\mathcal{E})}{\sqrt{\Psi-\mathcal{E}}}\,d\mathcal{E}
$$

### Inverting the integral equation

What we have now is **Abel's integral equation**. Strip the constants by defining

$$
g(\Psi) \;\equiv\; \frac{1}{2\sqrt2\,\pi}\frac{d\rho}{d\Psi}
\qquad\text{so that}\qquad
g(\Psi) = \int_0^{\Psi}\frac{f(\mathcal{E})}{\sqrt{\Psi-\mathcal{E}}}\,d\mathcal{E}
$$

$g$ is known, since we can differentiate $\rho(\Psi)$. $f$ is not. When I first met this I was handed the answer and told it was Abel's, which left me with no idea why an equation like this can be inverted at all. It comes out in three lines, so here they are.

**Step 1. One integral we need.** For any $a < b$,

$$
\int_a^b \frac{dx}{\sqrt{(b-x)(x-a)}} = \pi
$$

Substitute $x = a + (b-a)\sin^2\beta$. Then $dx = 2(b-a)\sin\beta\cos\beta\,d\beta$, while $x - a = (b-a)\sin^2\beta$ and $b - x = (b-a)\cos^2\beta$, so the square root is $(b-a)\sin\beta\cos\beta$ and everything cancels:

$$
\int_a^b \frac{dx}{\sqrt{(b-x)(x-a)}} = \int_0^{\pi/2}2\,d\beta = \pi
$$

Notice the answer is $\pi$ no matter what $a$ and $b$ are. That constant is the whole trick.

**Step 2. Hit the equation with the same kernel again.** Multiply both sides of Abel's equation by $(\mathcal{E}-\Psi)^{-1/2}$ and integrate $\Psi$ from $0$ to $\mathcal{E}$:

$$
\int_0^{\mathcal{E}}\frac{g(\Psi)}{\sqrt{\mathcal{E}-\Psi}}\,d\Psi
= \int_0^{\mathcal{E}}d\Psi\,\frac{1}{\sqrt{\mathcal{E}-\Psi}}\int_0^{\Psi}d\mathcal{E}'\,\frac{f(\mathcal{E}')}{\sqrt{\Psi-\mathcal{E}'}}
$$

**Step 3. Swap the order of the double integral.** The region being covered is $0 \le \mathcal{E}' \le \Psi \le \mathcal{E}$, a triangle in the $(\mathcal{E}',\Psi)$ plane. Sweeping it the other way, $\mathcal{E}'$ runs from $0$ to $\mathcal{E}$, while for each fixed $\mathcal{E}'$ the variable $\Psi$ runs from $\mathcal{E}'$ up to $\mathcal{E}$:

$$
= \int_0^{\mathcal{E}}d\mathcal{E}'\,f(\mathcal{E}')\int_{\mathcal{E}'}^{\mathcal{E}}\frac{d\Psi}{\sqrt{(\mathcal{E}-\Psi)(\Psi-\mathcal{E}')}}
$$

**Step 4. The inner integral is step 1** with $a = \mathcal{E}'$ and $b = \mathcal{E}$, so it is $\pi$ regardless of where $\mathcal{E}'$ sits:

$$
\int_0^{\mathcal{E}}\frac{g(\Psi)}{\sqrt{\mathcal{E}-\Psi}}\,d\Psi = \pi\int_0^{\mathcal{E}}f(\mathcal{E}')\,d\mathcal{E}'
$$

The unknown is now sitting under a plain integral with no kernel at all.

**Step 5. Differentiate.** By the fundamental theorem of calculus,

$$
\boxed{\;f(\mathcal{E}) = \frac{1}{\pi}\frac{d}{d\mathcal{E}}\int_0^{\mathcal{E}}\frac{g(\Psi)}{\sqrt{\mathcal{E}-\Psi}}\,d\Psi\;}
$$

and that is Abel's inversion.

\note{
    Here is the way I ended up remembering it. Integrating against $(\text{gap})^{-1/2}$ is, in a precise sense, "half an integration". Do it twice and you have done one whole integration, which a single derivative then undoes. That is why the same singular kernel shows up on the forward side and the inverse side instead of some new function: the kernel is its own partner.
}

Putting $g$ back in gives **Eddington's formula**:

$$
f(\mathcal{E}) = \frac{1}{2\sqrt2\,\pi^2}\frac{d}{d\mathcal{E}}\int_0^{\mathcal{E}}\frac{d\rho}{d\Psi}\frac{d\Psi}{\sqrt{\mathcal{E}-\Psi}}
$$

The version you usually see has the derivative moved inside, which takes one integration by parts. Take $u = d\rho/d\Psi$ and $dv = (\mathcal{E}-\Psi)^{-1/2}d\Psi$, so $v = -2(\mathcal{E}-\Psi)^{1/2}$:

$$
\int_0^{\mathcal{E}}\frac{d\rho}{d\Psi}\frac{d\Psi}{\sqrt{\mathcal{E}-\Psi}}
= \Big[-2\sqrt{\mathcal{E}-\Psi}\,\frac{d\rho}{d\Psi}\Big]_0^{\mathcal{E}}
+ 2\int_0^{\mathcal{E}}\sqrt{\mathcal{E}-\Psi}\,\frac{d^2\rho}{d\Psi^2}\,d\Psi
$$

At the upper limit the square root vanishes, so the bracket leaves only the lower limit, $+2\sqrt{\mathcal{E}}\,(d\rho/d\Psi)_{\Psi=0}$. Now differentiate with respect to $\mathcal{E}$. The first piece gives $\mathcal{E}^{-1/2}(d\rho/d\Psi)_0$, and the second gives $\int_0^{\mathcal{E}}(\mathcal{E}-\Psi)^{-1/2}(d^2\rho/d\Psi^2)d\Psi$, again with no boundary term. Collecting, and using $2\sqrt2 = \sqrt8$,

$$
f(\mathcal{E}) = \frac{1}{\sqrt{8}\,\pi^2}\left[\int_0^{\mathcal{E}}\frac{d^2\rho}{d\Psi^2}\frac{d\Psi}{\sqrt{\mathcal{E}-\Psi}} + \frac{1}{\sqrt{\mathcal{E}}}\left(\frac{d\rho}{d\Psi}\right)_{\Psi=0}\right]
$$

The two forms are the same thing. The second is convenient because for most models the boundary term vanishes, as it will here.

### Turning the handle for Plummer

Now the payoff for choosing this model. From $\Psi = GM/\sqrt{r^2+r_0^2}$ we can read off $\sqrt{r^2+r_0^2} = GM/\Psi$, so $(r^2+r_0^2)^{5/2} = (GM/\Psi)^5$, and

$$
\rho(\Psi) = \frac{3M}{4\pi}\,r_0^2\left(\frac{\Psi}{GM}\right)^5 = \underbrace{\frac{3r_0^2}{4\pi G^5M^4}}_{\;\equiv\;C}\;\Psi^5
$$

The density is a **pure power of the potential**. Which is why Plummer is the model everybody learns on. Now $d\rho/d\Psi = 5C\Psi^4$ and $d^2\rho/d\Psi^2 = 20C\Psi^3$, and the boundary term dies because $d\rho/d\Psi\propto\Psi^4\to0$ at $\Psi=0$. So

$$
f(\mathcal{E}) = \frac{1}{2\sqrt2\,\pi^2}\int_0^{\mathcal{E}}\frac{20C\,\Psi^3}{\sqrt{\mathcal{E}-\Psi}}\,d\Psi
$$

Substitute $\Psi = \mathcal{E}u$, so $d\Psi = \mathcal{E}\,du$ and $\sqrt{\mathcal{E}-\Psi} = \sqrt{\mathcal{E}}\sqrt{1-u}$:

$$
\int_0^{\mathcal{E}}\frac{\Psi^3\,d\Psi}{\sqrt{\mathcal{E}-\Psi}}
= \frac{\mathcal{E}^3\cdot\mathcal{E}}{\sqrt{\mathcal{E}}}\int_0^1 u^3(1-u)^{-1/2}du
= \mathcal{E}^{7/2}\,B\!\left(4,\tfrac12\right)
$$

where $B$ is the Beta function. Evaluating it:

$$
B\!\left(4,\tfrac12\right) = \frac{\Gamma(4)\,\Gamma(\tfrac12)}{\Gamma(\tfrac92)}
= \frac{3!\;\sqrt\pi}{\frac{7}{2}\cdot\frac{5}{2}\cdot\frac{3}{2}\cdot\frac{1}{2}\sqrt\pi}
= \frac{6}{105/16} = \frac{96}{105} = \frac{32}{35}
$$

So

$$
f(\mathcal{E}) = \frac{20C}{2\sqrt2\,\pi^2}\cdot\frac{32}{35}\,\mathcal{E}^{7/2}
= \frac{64\,C}{7\sqrt2\,\pi^2}\,\mathcal{E}^{7/2}
$$

and putting $C = 3r_0^2/(4\pi G^5M^4)$ back in, with $48/(7\sqrt2) = 24\sqrt2/7$:

$$
\boxed{\;f(\mathcal{E}) = \frac{24\sqrt{2}}{7\pi^3}\,\frac{r_0^2}{G^5M^4}\,\mathcal{E}^{7/2}\;}
$$

The Mathematica that does it, so you can check me:

```mathematica
$Assumptions = r0 > 0 && Mt > 0 && G > 0 && ee > 0 && 0 < Psi < ee;
rhoOfPsi = (3 r0^2/(4 Pi G^5 Mt^4)) Psi^5;
fE = FullSimplify[(1/(Sqrt[8] Pi^2)) (
     Integrate[D[rhoOfPsi, {Psi, 2}]/Sqrt[ee - Psi], {Psi, 0, ee}]
     + (D[rhoOfPsi, Psi] /. Psi -> 0)/Sqrt[ee])]
(* -> (24 Sqrt[2] ee^(7/2) r0^2) / (7 G^5 Mt^4 Pi^3) *)
```

\note{
    **A small discrepancy with the paper.** Hernquist's eq. (3.2) writes this as
    $$
    f(E) = \frac{\sqrt{2}}{378\pi^3G^5r_0^2\sigma_0}\left(\frac{-E}{\sigma_0^2}\right)^{7/2}, \qquad \sigma_0^2 = \frac{GM}{6r_0}
    $$
    If you substitute $\sigma_0$ and simplify, this equals my expression *except* that it carries $G^9$ where it should carry $G^5$. The ratio of the two is exactly $G^{-4}$, so in the paper's units ($G=1$) the formula is numerically correct and nothing in the paper is affected. It is just that the printed $G$-dependence does not restore properly. I only noticed because I tried to keep $G$ symbolic while checking.
}

### What the distribution function is telling us

Do not let the algebra hide the physics. $f(\mathcal{E}) \propto \mathcal{E}^{7/2}$ says: **the more tightly bound a particle is, the more of them there are.** Particles with $\mathcal{E}$ near zero are barely bound and rare; particles sitting deep in the potential well are common.

At a fixed radius $r$, the relative energy is $\mathcal{E} = \Psi(r) - \tfrac{1}{2}v^2$, so the chance of a particle there having speed $v$ goes like

$$
p(v)\,dv \;\propto\; v^2\left(\Psi - \tfrac{1}{2}v^2\right)^{7/2}dv
$$

The $v^2$ comes from the volume of the velocity-space shell. A particle cannot exceed the escape speed $v_e = \sqrt{2\Psi}$, so writing $q = v/v_e$, the whole thing collapses to a single universal shape:

$$
g(q) \propto q^2\left(1-q^2\right)^{7/2}, \qquad 0 \le q \le 1
$$

So **the shape of the speed distribution is identical at every radius**, and only the scale $v_e(r)$ changes. I like this one, and it makes the sampling easy.

### The velocity dispersion

One more thing I can get analytically, and this one gives me a second independent prediction to test the sampler against.

The **Jeans equation** for a spherical, isotropic, steady-state system is the stellar-dynamics version of hydrostatic equilibrium: the pressure gradient of the "star gas" balances gravity. With $\rho\sigma^2$ playing the role of pressure,

$$
\frac{d}{dr}\left(\rho\sigma^2\right) = -\rho\frac{d\phi}{dr}
$$

Integrate from $r$ out to infinity. Since $\rho\sigma^2\to0$ far away, the left side gives $-\rho(r)\sigma^2(r)$, so

$$
\sigma^2(r) = \frac{1}{\rho(r)}\int_r^\infty \rho(r')\frac{d\phi}{dr'}\,dr'
$$

For the Plummer model, $d\phi/dr = GMr/(r^2+r_0^2)^{3/2}$, so the integrand is

$$
\rho\frac{d\phi}{dr} = \frac{3Mr_0^2}{4\pi(r'^2+r_0^2)^{5/2}}\cdot\frac{GMr'}{(r'^2+r_0^2)^{3/2}} = \frac{3GM^2r_0^2}{4\pi}\frac{r'}{(r'^2+r_0^2)^{4}}
$$

That integral is elementary. Substitute $w = r'^2+r_0^2$, $dw = 2r'dr'$:

$$
\int_r^\infty\frac{r'\,dr'}{(r'^2+r_0^2)^4} = \frac{1}{2}\int_{r^2+r_0^2}^{\infty}\frac{dw}{w^4} = \frac{1}{6(r^2+r_0^2)^3}
$$

So

$$
\sigma^2(r) = \frac{1}{\rho(r)}\cdot\frac{3GM^2r_0^2}{4\pi}\cdot\frac{1}{6(r^2+r_0^2)^3}
= \frac{4\pi(r^2+r_0^2)^{5/2}}{3Mr_0^2}\cdot\frac{GM^2r_0^2}{8\pi(r^2+r_0^2)^3}
$$

and almost everything cancels:

$$
\boxed{\;\sigma^2(r) = \frac{GM}{6\sqrt{r^2+r_0^2}}\;}
\quad\Longrightarrow\quad
\sigma(r) = \frac{\sigma_0}{\left[1+(r/r_0)^2\right]^{1/4}}, \qquad \sigma_0^2 = \frac{GM}{6r_0}
$$

exactly as the paper quotes.

\tip{
    Compare $\sigma^2 = GM/6\sqrt{r^2+r_0^2}$ with the potential $\Psi = GM/\sqrt{r^2+r_0^2}$. They differ by a factor of exactly 6 at every radius, so $\sigma^2 = \Psi/6$ everywhere. That is a special feature of the $\rho\propto\Psi^5$ relation, and it is why the escape speed $v_e = \sqrt{2\Psi}$ is always $\sqrt{12}\,\sigma \approx 3.46\,\sigma$ in this model, the same number at the centre and in the far halo.
}

The important thing is that I never fed $\sigma(r)$ into the code. It is a *consequence* of the distribution function, so if my sampled particles reproduce it, the sampler is right.

## Generating the initial conditions

Now the practical part: turning the maths above into a list of $\{\vec r_i\}$ and $\{\vec v_i\}$.

### Positions

I want $r$ distributed so that the fraction of particles inside radius $r$ is $M(r)/M(R)$. The standard trick is **inverse transform sampling**: draw $u$ uniformly from $[0,1)$, set $M(r)/M = u \cdot M(R)/M$, then solve for $r$. With $m \equiv M(r)/M$,

$$
m = \frac{r^3}{(r^2+r_0^2)^{3/2}} \;\Longrightarrow\; m^{2/3} = \frac{r^2}{r^2+r_0^2} \;\Longrightarrow\; r = \frac{r_0\, m^{1/3}}{\sqrt{1-m^{2/3}}}
$$

Clean, closed form, no iteration. Then throw the particle in a random direction.

\tip{
    A random direction is *not* "uniform in $\theta$ and $\phi$", which piles particles up at the poles. The right way is uniform in $\cos\theta$ and uniform in $\phi$, because the solid angle element is $d\Omega = d(\cos\theta)\,d\phi$.
}

### Velocities

For speeds I need to draw $q = v/v_e$ from the universal shape $g(q) = q^2(1-q^2)^{7/2}$ derived above. The trick I used for the radius does not work here, because there is no closed-form inverse of the cumulative integral of $g$. So I use **von Neumann rejection** instead.

\defn{
    **Rejection sampling.** Draw the curve $g(q)$ on graph paper. Draw a rectangle that completely encloses it. Now throw darts uniformly at the rectangle and throw away every dart landing above the curve. The $q$-coordinates of the darts you kept are distributed exactly like $g$, because the number surviving in any thin vertical strip is proportional to the height of the curve there.
}

That rectangle is the **bounding box**, and it is doing one job: it is a shape I know how to sample from (uniform, trivial) which is guaranteed to sit entirely above the shape I do not know how to sample from. Two conditions make a box valid:

1. It must span the full range of $q$ where $g$ is non-zero. Here $g$ lives on $0 \le q \le 1$ and is zero outside, so the box runs from $0$ to $1$ horizontally. Miss part of that range and you silently never generate those speeds.
2. It must be at least as tall as the highest point of $g$. If the box is too short, the top of the curve gets clipped and those speeds come out under-represented.

Nothing forces the box to be *tight*. A taller box is still correct, only wasteful, because the fraction of darts you keep is

$$
\text{acceptance} = \frac{\text{area under } g}{\text{area of the box}}
$$

So the only thing I need is the maximum of $g$. Differentiating $g = q^2(1-q^2)^{7/2}$,

$$
g'(q) = q\left(1-q^2\right)^{5/2}\left(2 - 9q^2\right)
$$

which vanishes at $q^2 = 2/9$. Mathematica confirms the values:

$$
q_{\max} = \frac{\sqrt2}{3} \approx 0.4714, \qquad g_{\max} = \frac{686\sqrt7}{19683} \approx 0.0922
$$

So I take a box of height $0.1$, which clears the peak with a little room to spare. The area under the curve is exactly $7\pi/512 \approx 0.04295$, so the acceptance rate is $0.04295/0.1 \approx 43\%$. A little over two darts thrown per particle kept, which costs nothing.

Rather than describe it any further, here is an actual run of the sampler. Press play.

\fig{/assets/Physics/papers/hernquist1987/anim_sampler}

The dotted rectangle is the bounding box, and every dart lands somewhere inside it. Green ones fell under the curve and are kept, red ones fell above and are thrown away. The orange bars are the speeds kept so far, and they slowly grow into the blue curve. That is the whole trick: I never had to invert anything, I just threw darts and kept the lucky ones. The counter in the title settles near $43\%$, which is the number worked out above.

\note{
    The reason a slightly loose box is fine here is that $g$ is a fat, well-behaved bump. Rejection sampling only becomes painful when the target has a tall narrow spike, because then the box has to be as tall as the spike while nearly all of its area is empty, and the acceptance rate collapses.
}

The Julia:

```julia
function sample_speed_fraction(rng)
    while true
        q = rand(rng)
        y = 0.1 * rand(rng)
        if y <= q^2 * (1 - q^2)^3.5
            return q
        end
    end
end

function plummer_ics(N::Integer; p::Plummer = Plummer(), seed::Integer = 1987)
    rng = Random.MersenneTwister(seed)
    pos = zeros(3, N); vel = zeros(3, N)
    mass = fill(p.M / N, N)

    for i in 1:N
        r = sample_radius(p, rand(rng))
        nx, ny, nz = random_direction(rng)
        pos[1, i] = r * nx; pos[2, i] = r * ny; pos[3, i] = r * nz

        v = sample_speed_fraction(rng) * escape_speed(p, r)
        ux, uy, uz = random_direction(rng)
        vel[1, i] = v * ux; vel[2, i] = v * uy; vel[3, i] = v * uz
    end

    # Put the centre of mass at rest at the origin.
    for k in 1:3
        pos[k, :] .-= sum(mass .* pos[k, :]) / p.M
        vel[k, :] .-= sum(mass .* vel[k, :]) / p.M
    end
    return pos, vel, mass
end
```

The `y = 0.1 * rand(rng)` line is the vertical coordinate of the dart, and `0.1` is the height of the bounding box. The `while true` loop keeps throwing until one lands under the curve.

### Checking that it worked

Never trust a sampler. Here are 200,000 particles I generated, checked against the theory in three independent ways.

The radial distribution against $4\pi r^2\rho(r)/M(R)$:

\fig{/assets/Physics/papers/hernquist1987/plummer_sampled_radius}

Dots are my sampled particles, the curve is the theory. They sit on top of each other, so the positions are correct.

The velocity dispersion against $\sigma_0[1+(r/r_0)^2]^{-1/4}$. Remember, I never fed $\sigma(r)$ into the sampler. It fell out of the distribution function on its own:

\fig{/assets/Physics/papers/hernquist1987/plummer_sampled_sigma}

Same idea, but for speeds now. Dots are measured from the sample, the curve is the formula we derived. I never gave this formula to the sampler, so matching it means the velocities are right too.

And the universal speed shape:

\fig{/assets/Physics/papers/hernquist1987/plummer_speed_dist}

One histogram for each shell of the cluster, and they all fall on the same curve. So the speed distribution really does have the same shape everywhere, only the scale changes.

All three land on the analytic curves. I also run the check the other way in the test suite, numerically integrating $4\pi\int v^2 f(\Psi - v^2/2)\,dv$ and confirming it returns $\rho(r)$ to one part in a thousand.

## The virial theorem

This is where sir actually started, so I am going through it a step at a time.

### From the moment of inertia

Take the moment of inertia of the whole system about its centre of mass,

$$
I = \sum_i m_i r_i^2 = \sum_i m_i\,\vec r_i\cdot\vec r_i
$$

Differentiate once, using $\dot{\vec r}_i = \vec v_i$:

$$
\frac{dI}{dt} = \sum_i m_i\left(\vec v_i\cdot\vec r_i + \vec r_i\cdot\vec v_i\right) = 2\sum_i m_i\,\vec r_i\cdot\vec v_i
$$

Differentiate again, now using $\dot{\vec v}_i = \vec a_i$:

$$
\frac{d^2I}{dt^2} = 2\sum_i m_i\left(\vec v_i\cdot\vec v_i + \vec r_i\cdot\vec a_i\right)
= 2\underbrace{\sum_i m_i v_i^2}_{=\,2K} + 2\underbrace{\sum_i m_i\,\vec r_i\cdot\vec a_i}_{\;\equiv\;W}
$$

so, dividing by two,

$$
\boxed{\;\frac{1}{2}\frac{d^2I}{dt^2} = 2K + W\;}
$$

where $K$ is the total kinetic energy and $W$ is called the **Clausius virial**. Note that so far this is *exact*. No averaging, no assumptions, no equilibrium. It is just calculus applied to Newton's laws.

Now the physical step, and it is exactly the one sir wrote down. If the system is not flying apart and not collapsing, if it has settled, then $I$ fluctuates about a constant. Over a long averaging time $T$,

$$
\left\langle\frac{d^2I}{dt^2}\right\rangle = \frac{1}{T}\int_0^T\frac{d^2I}{dt^2}dt = \frac{1}{T}\left[\frac{dI}{dt}\right]_0^T \xrightarrow[\;T\to\infty\;]{} 0
$$

because $dI/dt$ stays bounded while $T$ grows. Therefore

$$
\boxed{\;2\langle K\rangle + \langle W\rangle = 0\;}
$$

### Why $W = U$ for gravity

Every treatment I have seen states that $W$ is the potential energy and moves on. Here is the show. Write $W$ in terms of forces, $m_i\vec a_i = \vec F_i$:

$$
W = \sum_i \vec r_i\cdot\vec F_i = -G\sum_i\sum_{j\neq i}m_im_j\;\frac{\vec r_i\cdot(\vec r_i-\vec r_j)}{|\vec r_i-\vec r_j|^3}
$$

The double sum runs over every *ordered* pair, so each unordered pair $\{i,j\}$ appears twice. Collect those two appearances together. Writing $\vec r_{ij} = \vec r_i - \vec r_j$, the pair contributes

$$
-Gm_im_j\;\frac{\vec r_i\cdot\vec r_{ij} + \vec r_j\cdot(-\vec r_{ij})}{r_{ij}^3}
= -Gm_im_j\;\frac{(\vec r_i-\vec r_j)\cdot\vec r_{ij}}{r_{ij}^3}
= -Gm_im_j\;\frac{r_{ij}^2}{r_{ij}^3}
$$

and that last expression is $-Gm_im_j/r_{ij}$, which is precisely the potential energy of the pair. Summing over unordered pairs,

$$
W = -G\sum_{i\lt j}\frac{m_im_j}{r_{ij}} = U
$$

\note{
    Look at what made that work. The $r_{ij}^2$ in the numerator came from $\vec r_{ij}\cdot\vec r_{ij}$, and it cancelled two of the three powers in $r_{ij}^3$, leaving exactly one, which is the potential. **That cancellation is specific to an inverse-square force.** For a force $\propto r^{-n}$ you would get $W = -(n-1)\times(\text{something})$, and the virial theorem takes a different form. Gravity being $1/r^2$ is doing the work here, just as it did in Poisson's equation.
}

So for a pure $1/r$ potential the theorem is the familiar

$$
2\langle K\rangle + \langle U\rangle = 0 \qquad\text{and}\qquad \langle E\rangle = \langle K\rangle + \langle U\rangle = \frac{1}{2}\langle U\rangle
$$

Stare at that second relation for a second. Combining $2K + U = 0$ with $E = K + U$ gives

$$
K = -E
$$

\note{
    So if the system **loses** energy, $K$ goes **up**. Take energy away from a star cluster and it gets *hotter*. This is the famous negative heat capacity of gravitating systems, and it drops straight out of the virial theorem.
}

You already know an example of this. A satellite in low orbit feels a little atmospheric drag, which removes energy. So does it slow down? No. It spirals inwards, and as it falls to a lower orbit it *speeds up*, because the potential energy it gave up was twice the kinetic energy it gained. That is $2K + U = 0$ for a one-body orbit.

A star cluster does the same thing collectively: let it lose energy, say by flinging a few stars out to infinity, and the rest contracts while the stars left behind move faster.

\defn{
    This has an alarming consequence. A hot core in contact with a cooler halo loses energy to the halo, which makes the core *hotter*, which makes it lose energy faster. Nothing stops the runaway. It is called the **gravothermal catastrophe**, and it is why real globular clusters undergo core collapse, the thing the virial theorem is quietly warning you about.
}

### The bit that caught me out

When I first measured $-2K/U$ in my simulation, I got $0.966$, not $1$. I spent a while hunting for a bug that was not there.

The reason is the **softening**, and the boxed note above already gives it away: the step $W = U$ used the inverse-square law, and a softened force is not inverse-square.

Redo the pair calculation with the softened potential $\varphi_{ij} = -Gm_im_j(r_{ij}^2+\varepsilon^2)^{-1/2}$. The force on $i$ is

$$
\vec F_{ij} = -\nabla_i\varphi_{ij} = -\frac{Gm_im_j\,\vec r_{ij}}{(r_{ij}^2+\varepsilon^2)^{3/2}}
$$

Collecting the two ordered appearances of the pair exactly as before, the numerator is still $\vec r_{ij}\cdot\vec r_{ij} = r_{ij}^2$, but now the denominator carries the $\varepsilon$:

$$
W_{ij} = -\frac{Gm_im_j\,r_{ij}^2}{(r_{ij}^2+\varepsilon^2)^{3/2}}
\qquad\text{while}\qquad
U_{ij} = -\frac{Gm_im_j}{(r_{ij}^2+\varepsilon^2)^{1/2}}
$$

Dividing, everything cancels except one clean factor:

$$
\frac{W_{ij}}{U_{ij}} = \frac{r_{ij}^2}{r_{ij}^2+\varepsilon^2} = \frac{1}{1+\varepsilon^2/r_{ij}^2} = 1 - \frac{\varepsilon^2}{r_{ij}^2} + \mathcal{O}\!\left(\frac{\varepsilon^4}{r_{ij}^4}\right)
$$

So summed over the system,

$$
\boxed{\;\frac{W}{U} \simeq 1 - \left\langle\frac{\varepsilon^2}{r^2}\right\rangle\;}
$$

with the average weighted by each pair's contribution to $U$. Two limits check out. As $\varepsilon\to0$ we get $W=U$ and the familiar theorem back. As $\varepsilon$ grows the ratio falls below 1, meaning a system genuinely in equilibrium will show $-2K/U < 1$. For my run ($\varepsilon \approx 0.031$, typical separations of order $0.2$) that predicts a few percent, which is exactly the discrepancy I was seeing.

So the honest test is $-2K/W$, not $-2K/U$. My run, measured both ways:

\fig{/assets/Physics/papers/hernquist1987/virial_as_sampled}

Time goes right, the virial ratio goes up. A value of 1 means perfect equilibrium. Orange sits on 1, blue sits a bit below, and the gap is exactly what softening predicts. So the cluster is fine, we were just measuring the wrong quantity.

I find this a nice example of how a "check that fails" can be more informative than one that passes.

### Testing it across a factor of 64 in $\varepsilon$

One run agreeing is not much of a test, so I ran the whole thing again on the server for seven softening lengths spanning $\varepsilon/\lambda$ from $1/16$ to $4$, a factor of 64. If the derivation above is right, $-2K/W$ should stay pinned at 1 the whole way while $-2K/U$ slides away from it.

\fig{/assets/Physics/papers/hernquist1987/epsilon_virial}

Softening goes right, virial ratio goes up. Orange stays flat at 1 across a factor of 64, blue slides away. This is the strongest evidence that the derivation is right.

In numbers, $-2K/W$ stays within half a percent of 1 over the whole range, while $-2K/U$ falls from $1.00$ to $0.85$. The green dashed curve is the *prediction* $1-\langle\varepsilon^2/r^2\rangle$ computed from the initial configuration. It tracks the measured offset well at small $\varepsilon$ and starts to lift away past $\varepsilon\sim\lambda$, exactly where the neglected $\mathcal{O}(\varepsilon^4/r^4)$ terms should begin to matter.

| $\varepsilon/\lambda$ | $-2K/U$ | $-2K/W$ | $W/U$ measured | $1-\langle\varepsilon^2/r^2\rangle$ |
| --- | --- | --- | --- | --- |
| 0.0625 | 1.003 | 1.003 | 0.9998 | 0.9999 |
| 0.125 | 0.997 | 0.998 | 0.9991 | 0.9997 |
| 0.25 | 0.992 | 0.995 | 0.9961 | 0.9989 |
| 0.5 | 0.981 | 0.994 | 0.9870 | 0.9954 |
| 1.0 | 0.960 | 0.995 | 0.9644 | 0.9816 |
| 2.0 | 0.917 | 0.997 | 0.9199 | 0.9266 |
| 4.0 | 0.852 | 0.9995 | 0.8525 | 0.7064 |

\note{
    So a softened $N$-body system **is** in perfect virial equilibrium. It is just that the quantity you have to measure is $W$, not $U$. If you see $-2K/U \approx 0.85$ and conclude your cluster is far from equilibrium, you will go looking for a bug that does not exist.
}

### And a warning about making $\varepsilon$ small

There is a trap here that I walked straight into. Having established that softening biases $-2K/U$, my first instinct was to shrink $\varepsilon$ until the bias went away. That is a mistake, and the same set of runs shows why:

\fig{/assets/Physics/papers/hernquist1987/epsilon_energy}

Softening length along the bottom, the energy drift over 800 steps up the side, both on log axes. At $\varepsilon = \lambda$ the drift is $0.15\%$. At $\varepsilon = \lambda/2$ it is $3.4\%$. At $\varepsilon = \lambda/16$ it is **$52\%$**, i.e. the simulation is destroyed.

The reason is that $\varepsilon$ sets the hardest interaction the simulation contains. Two particles passing at separation $\sim\varepsilon$ experience an acceleration $\sim Gm/\varepsilon^2$ over a time $\sim\varepsilon/v$, and a fixed time step $\delta t$ can only resolve that if $\delta t$ is small compared with the encounter time. Halve $\varepsilon$ and the encounters get faster and harder while $\delta t$ stays put, so the integrator starts missing them. Every missed encounter dumps spurious energy into the system.

\fig{/assets/Physics/papers/hernquist1987/epsilon_energy_history}

Time goes right, the energy error goes up, one curve per softening length. The small ones climb in visible steps, and each step is one close encounter the integrator could not handle.

\note{
    This is the real reason softening exists. The usual explanation ("it stops the force diverging") makes it sound like a cosmetic patch. It is not. Softening is what makes a **fixed time step** legitimate. It puts a floor under how violent an encounter can be, so a single $\delta t$ can resolve every interaction in the system. The choice $\varepsilon\approx\lambda$ that the paper uses is the sweet spot: small enough not to smear out real structure, large enough that the dynamics stays integrable at a sane step size.
}

\prob{
    Show that for a softened pair potential $\varphi = -Gm_1m_2(r^2+\varepsilon^2)^{-1/2}$ the quantity $\vec r\cdot\vec F$ equals $-Gm_1m_2 r^2(r^2+\varepsilon^2)^{-3/2}$, then expand $W/U$ for $\varepsilon\ll r$. Harder: work out how $\delta t$ must scale with $\varepsilon$ to keep the energy error fixed, and test it.
}

### The transient

There is a second, smaller effect. The paper says the initial models "are not precisely in equilibrium and are subject to a brief transient period before settling into a steady state", and I can see exactly why.

The model is cut off at $R=1$, which throws away the $5.7\%$ of a true Plummer sphere's mass that lives beyond that radius. But we still normalise the total mass to $1$. So the potential inside is slightly *deeper* than the one whose distribution function we sampled the velocities from. The particles start slightly too slow, so the cluster contracts a bit before settling.

I can confirm this is the whole story by removing the cutoff:

| Cutoff $R$ | $M(R)/M$ | $-2K/U$ at $t=0$ |
| --- | --- | --- |
| 1 | 0.943 | 0.958 |
| 2 | 0.985 | 0.990 |
| 5 | 0.998 | 1.001 |
| 20 | 1.000 | 1.003 |

As the cutoff goes away, the model lands exactly on the virial theorem. If I rescale the velocities at the start to sit exactly on $2K + W = 0$, the transient disappears:

\fig{/assets/Physics/papers/hernquist1987/virial_rescaled}

Same plot as before, but the starting velocities were rescaled to sit exactly on the theorem. The early wobble is gone, which confirms the wobble was coming from the cutoff and nothing else.

And here is $I(t)$ itself, doing what sir said it would: moving at first, then settling down and staying put.

\fig{/assets/Physics/papers/hernquist1987/virial_inertia}

Time goes right, and up is a single number saying how spread out the cluster is. It twitches for one crossing time and then goes flat and stays flat. Flat is the whole assumption the virial theorem rests on, so seeing it directly is a better check than any ratio.

## Where we are

We now have a physically sensible blob of particles with the right positions and the right velocities, plus a way of telling whether it is in equilibrium. What is missing is (a) a way to push the particles forward in time and (b) a way to compute the forces without dying of old age.

Those are the next two parts.

---

**Next:** [Part 2, moving the particles: the leapfrog](/Pages/Physics/papers/hernquist1987/02_leapfrog/)

Hope this helps you in some way. If you like it then share with others if possible.

If you have some queries, do let me know in the comments or contact me using the informations that are given on the page [About Me](/Pages/about_me/).

~~~
<button onclick="window.history.back()">Go Back</button>
~~~
