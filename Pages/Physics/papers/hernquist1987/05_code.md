+++
title = "Tree Codes 5: The Code"
hascode = true
date = Date(2026, 8, 4)
rss = "Part 5 of recreating Hernquist (1987): the complete Julia source for the Barnes-Hut tree code, the test suite, and how to run everything yourself."

tags = ["Julia", "physics", "papers", "N-body", "code"]
+++

\toc

# 5. The code

Part 5 of my recreation of [Hernquist (1987)](/Pages/Physics/papers/hernquist1987/). Everything I used is here. It is plain Julia with no dependencies beyond the standard library and `JSON3` for writing out results, so it should run anywhere Julia does.

**[Download the whole thing (33 kB tarball)](/assets/Physics/papers/hernquist1987/TreeCodeH87.tar.gz)**

## Layout

```
TreeCodeH87/
├── Project.toml
├── src/
│   ├── TreeCodeH87.jl     module, exports
│   ├── plummer.jl         the model and the initial conditions
│   ├── tree.jl            octree, multipole moments, the walk
│   ├── octupole.jl        the n=3 term, and raw-moment shifting
│   ├── direct.jl          the honest O(N^2) sum, used as the yardstick
│   ├── integrate.jl       leapfrog
│   └── diagnostics.jl     energies, virial, Lagrangian radii, errors
├── test/runtests.jl       44 tests, all of the checks described in these pages
├── scripts/               one script per figure in the paper
└── figures/               turns the results into the plots on these pages
```

## Running it

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'

# the checks first, always
julia --project=. -t 4 test/runtests.jl

# then any of the measurements
julia --project=. -t 8 scripts/evolution.jl     # Figs. 1, 2, 9
julia --project=. -t 1 scripts/timing.jl        # Figs. 3, 4  (one thread!)
julia --project=. -t 8 scripts/errors.jl        # Figs. 6, 7
julia --project=. -t 8 scripts/relaxation.jl    # Fig. 10
```

Every script takes a `--quick` flag that cuts $N$ and the number of steps down, so you can check the whole pipeline in a couple of minutes before committing to the real thing.

\tip{
    Run `timing.jl` with **one** thread. The $N\log N$ law is a statement about how much arithmetic the algorithm does; spreading that arithmetic across cores only layers scheduling noise on top of the thing you are trying to measure. Everything else is happy multithreaded.
}

The full production run is a shell script:

```bash
THREADS=48 ./run_all.sh
```

On a 256-core machine the whole set finishes in a few minutes, except the single-threaded timing sweep which takes longer. My laptop can do everything except the $N = 32768$ points.

## The pieces

The tree walk and the multipole recursion are listed and explained [in part 3](/Pages/Physics/papers/hernquist1987/03_treecode/), and the integrator [in part 2](/Pages/Physics/papers/hernquist1987/02_leapfrog/), so I will not repeat them. Here are the parts that have not appeared yet.

### The octree, as flat arrays

Rather than a linked structure of objects, the whole tree is a handful of contiguous vectors indexed by node number. This keeps everything cache-friendly and makes the walk a simple loop over integers.

```julia
mutable struct Octree
    child::Matrix{Int32}      # 8 x nmax, 0 means "no child"
    leafpart::Vector{Int32}   # particle index for leaves, 0 otherwise
    mass::Vector{Float64}
    com::Matrix{Float64}      # 3 x nmax, centre of mass of the node
    quad::Matrix{Float64}     # 6 x nmax, quadrupole about the node's own COM
    center::Matrix{Float64}   # 3 x nmax, geometric centre of the cell
    size::Vector{Float64}     # full width of the cell
    nnodes::Int
end
```

The quadrupole is symmetric and traceless, so six numbers per node is all it needs — I store `(xx, xy, xz, yy, yz, zz)` and reconstruct the rest by symmetry.

A node is exactly one of three things: **empty** (`mass == 0`), a **leaf** holding one particle (`leafpart > 0`), or **internal** with up to eight children. Empty cells are never created, which is why the node count stays proportional to $N$ and not to the volume.

### The Plummer model and the sampler

```julia
Base.@kwdef struct Plummer
    M::Float64 = 1.0
    r0::Float64 = 0.2
    R::Float64 = 1.0
end

density(p::Plummer, r) = 3p.M / (4pi) * p.r0^2 / (r^2 + p.r0^2)^2.5
enclosed_mass(p::Plummer, r) = p.M * r^3 / (r^2 + p.r0^2)^1.5
potential(p::Plummer, r) = -p.M / sqrt(r^2 + p.r0^2)
relative_potential(p::Plummer, r) = p.M / sqrt(r^2 + p.r0^2)
escape_speed(p::Plummer, r) = sqrt(2 * relative_potential(p, r))

# Invert the cumulative mass profile, truncated at R:
#   m = r^3/(r^2+r0^2)^(3/2)  =>  r = r0 m^(1/3) / sqrt(1 - m^(2/3))
function sample_radius(p::Plummer, u::Float64)
    mmax = enclosed_mass(p, p.R) / p.M
    m = u * mmax
    return p.r0 * cbrt(m) / sqrt(1 - cbrt(m)^2)
end

# f(E) ~ (-E)^(7/2) collapses to one universal speed shape at every radius:
#   g(q) ~ q^2 (1-q^2)^(7/2),  q = v / v_escape,  max 0.0922 at q = sqrt(2)/3
function sample_speed_fraction(rng)
    while true
        q = rand(rng)
        y = 0.1 * rand(rng)
        y <= q^2 * (1 - q^2)^3.5 && return q
    end
end
```

### The softening scale

Getting this right took me a while, because "mean interparticle separation" can mean several things and they differ by factors that matter. The definition that reproduces the paper's numbers is $\lambda = n^{-1/3}$ with $n$ the **mean number density inside the half-mass radius**:

```julia
function mean_interparticle_separation(p::Plummer, N::Integer)
    rh = half_mass_radius(p)
    n = (N / 2) / (4pi / 3 * rh^3)
    return n^(-1 / 3)
end
```

For the truncated model this gives $r_{1/2} = 1.24\,r_0$ and $\lambda = 2.5\,r_0N^{-1/3}$, so $\varepsilon = 0.031$ at $N = 4096$ — matching the paper's quoted $0.032$. Using the *local* density at $r_{1/2}$ instead would have given $3.5\,r_0N^{-1/3}$, which is wrong by 40%.

### The Clausius virial

The diagnostic that [caught me out in part 1](/Pages/Physics/papers/hernquist1987/01_setup/#the_bit_that_caught_me_out). For a softened force, the virial theorem is $2K + W = 0$ with $W = \sum_i m_i\vec r_i\cdot\vec a_i$, and $W \neq U$:

```julia
function clausius_virial(pos, acc, mass)
    W = 0.0
    @inbounds for i in eachindex(mass)
        W += mass[i] * (pos[1,i]*acc[1,i] + pos[2,i]*acc[2,i] + pos[3,i]*acc[3,i])
    end
    return W
end
```

Note that it uses the accelerations the code **actually applied**, tree approximation and all. So it tests the real dynamics rather than an idealised version of it.

## The tests

I want to be explicit about this, because a wrong simulation looks exactly like a right one. There are 44 tests and they all pass. The important ones:

**The tree must reproduce the direct sum.** At $\theta = 0$ nothing can be accepted, so the walk has to descend to individual particles:

```julia
build_tree!(t, pos, mass; quadrupole = false)
tree_forces!(a0, t, pos, mass, 0.0, eps)
@test maximum(abs.(a0 .- adir)) < 1e-10 * maximum(abs.(adir))
```

If this passes, the tree structure and the walk are both right, and only the multipole terms are left to check.

**The quadrupole recursion must be right.** Build the tree, then compare the **root** node's $\mathbf{Q}$ against a brute-force sum over all $N$ particles. The root never touches a particle directly — it only adds up its eight children — so an error anywhere in the recursion shows up here:

```julia
@test maximum(abs.(Q .- Qt)) < 1e-10 * maximum(abs.(Q))
@test abs(tr(Qt)) < 1e-10 * maximum(abs.(Q))   # traceless by construction
```

**The acceleration must be minus the gradient of the potential.** Numerically differentiate the multipole potential and compare with eq. (2.4):

```julia
for k in 1:3
    xp = copy(x0); xp[k] += h
    xm = copy(x0); xm[k] -= h
    num[k] = -(phi(xp) - phi(xm)) / (2h)
end
@test isapprox(num, accel(x0); rtol = 1e-6)
```

**The distribution function must give back the density.** Integrate $4\pi\int_0^{v_e} v^2 f(\Psi - v^2/2)\,dv$ and check it returns $\rho(r)$:

```julia
@test isapprox(s, density(p, r); rtol = 1e-3)
```

**The integrator must close a circular orbit and be second order.** A two-body circular orbit has to come back to where it started after one period, and the energy wobble on an eccentric orbit must fall by four when the step is halved:

```julia
@test isapprox(pos[1, 1], r; atol = 1e-4)
@test 3.0 < errs[1] / errs[2] < 5.0
```

**Poisson's equation.** The density–potential pair, checked numerically as well as symbolically:

```julia
lap = (f(r + h) - f(r - h)) / (2h) / r^2
@test isapprox(lap, 4pi * density(p, r); rtol = 1e-4)
```

Two of these tests failed the first time, and both failures were **real physics** rather than bugs. The virial ratio came out at 0.94 instead of 1 — that was the softening, now explained in part 1 rather than papered over. And a truncated Plummer sphere is not exactly virialised, which I confirmed by removing the cutoff and watching the ratio walk back to 1.

\note{
    In both cases the useful move was to keep the test and make it assert the *right* thing, instead of loosening the tolerance until it went green.
}

## The symbolic checks

The algebra in [part 3](/Pages/Physics/papers/hernquist1987/03_treecode/) was verified in Mathematica rather than by squinting at it. All of it is reproduced on those pages, but the list is:

| What | Result |
| --- | --- |
| Legendre expansion of the inverse distance, orders 0–4 | exact |
| $n=2$ Legendre term $= \tfrac12\hat n\cdot\mathbf{Q}\cdot\hat n$ | exact |
| eq. (2.4) $= -\nabla$ eq. (2.2) | exact |
| Poisson for the Plummer pair | residual 0 |
| Eddington inversion for $f(E)$ | $\frac{24\sqrt2}{7\pi^3}\frac{r_0^2}{G^5M^4}\mathcal{E}^{7/2}$ |
| paper's eq. (3.2) vs. the above | differs by $G^{-4}$ |
| Jeans equation for $\sigma(r)$ | $\sigma_0(1+(r/r_0)^2)^{-1/4}$ |
| softened potential expansion | $1-\tfrac12\varepsilon^2/r^2+\tfrac38\varepsilon^4/r^4$ |
| maximum of $g(q)=q^2(1-q^2)^{7/2}$ | $q=\sqrt2/3$, $g=686\sqrt7/19683$ |

## Individual files

| File | What is in it |
| --- | --- |
| [`TreeCodeH87.jl`](/assets/Physics/papers/hernquist1987/code/src/TreeCodeH87.jl) | module and exports |
| [`plummer.jl`](/assets/Physics/papers/hernquist1987/code/src/plummer.jl) | Plummer model, distribution function, samplers |
| [`tree.jl`](/assets/Physics/papers/hernquist1987/code/src/tree.jl) | octree, multipole moments, the walk |
| [`octupole.jl`](/assets/Physics/papers/hernquist1987/code/src/octupole.jl) | the n = 3 term and the raw-moment recursion |
| [`direct.jl`](/assets/Physics/papers/hernquist1987/code/src/direct.jl) | $O(N^2)$ reference sum |
| [`integrate.jl`](/assets/Physics/papers/hernquist1987/code/src/integrate.jl) | leapfrog |
| [`diagnostics.jl`](/assets/Physics/papers/hernquist1987/code/src/diagnostics.jl) | energies, virial, radii, force errors, relaxation |
| [`runtests.jl`](/assets/Physics/papers/hernquist1987/code/test/runtests.jl) | the 44 checks above |
| [`evolution.jl`](/assets/Physics/papers/hernquist1987/code/scripts/evolution.jl) | Figs. 1, 2, 9 |
| [`timing.jl`](/assets/Physics/papers/hernquist1987/code/scripts/timing.jl) | Figs. 3, 4 |
| [`nterms.jl`](/assets/Physics/papers/hernquist1987/code/scripts/nterms.jl) | Fig. 5 |
| [`errors.jl`](/assets/Physics/papers/hernquist1987/code/scripts/errors.jl) | Figs. 6, 7 |
| [`softening.jl`](/assets/Physics/papers/hernquist1987/code/scripts/softening.jl) | Fig. 8 |
| [`relaxation.jl`](/assets/Physics/papers/hernquist1987/code/scripts/relaxation.jl) | Fig. 10 |
| [`virial.jl`](/assets/Physics/papers/hernquist1987/code/scripts/virial.jl) | the virial theorem run |
| [`integrators.jl`](/assets/Physics/papers/hernquist1987/code/scripts/integrators.jl) | leapfrog against Euler and RK4 |
| [`treeviz.jl`](/assets/Physics/papers/hernquist1987/code/scripts/treeviz.jl) | the quadtree pictures |
| [`multipole_error.jl`](/assets/Physics/papers/hernquist1987/code/scripts/multipole_error.jl) | the $(s/d)^2$ and $(s/d)^3$ test |

## If you want to build on it

The obvious next steps, roughly in order of how much they would buy you:

1. **Individual time steps** — the single biggest win available, since core particles currently drag the whole simulation down to their step size.
2. **A better opening criterion** — $s/d<\theta$ ignores where the mass inside a cell actually sits. Criteria based on the multipole moments themselves do much better at the same cost.
3. **A tree that is not rebuilt from scratch every step** — most of the structure does not change between steps.

Octupole terms used to be on this list; they are now implemented, and [part 6](/Pages/Physics/papers/hernquist1987/06_beyond/) measures what they buy.

\prob{
    A good first exercise: take the code and make it two-dimensional. Everything carries over — the Legendre expansion, the quadrupole, the opening criterion — but a quadtree is a quarter of the bookkeeping and everything can be drawn. Then check whether the error still scales as $(s/d)^2$ and $(s/d)^3$, or whether the dimension changes it.
}

---

**Previous:** [Part 4 — Results](/Pages/Physics/papers/hernquist1987/04_results/)\\
**Next:** [Part 6 — Doing better than 1987](/Pages/Physics/papers/hernquist1987/06_beyond/)

Hope this helps you in some way. If you like it then share with others if possible.

If you have some queries, do let me know in the comments or contact me using the informations that are given on the page [About Me](/Pages/about_me/).

~~~
<button onclick="window.history.back()">Go Back</button>
~~~
