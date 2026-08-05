# Improvements the 1987 paper could not afford, measured.
#
#   1. octupole (n=3) multipoles -- error O((s/d)^4) instead of O((s/d)^3)
#   2. accuracy per unit cost, which is the comparison that actually matters
#   3. a fourth-order symplectic integrator at equal force-evaluation cost

include(joinpath(@__DIR__, "common.jl"))
using LinearAlgebra

p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)

# ============================================ 1. one cell, three expansions ===
banner("truncation error of a single cell: monopole, quadrupole, octupole")

const NCLOUD = 200
const NDIR = 600
const RATIOS = [0.02, 0.03, 0.05, 0.08, 0.12, 0.18, 0.25, 0.35, 0.5, 0.7, 1.0]

function cloud(s, seed)
    rng = Random.MersenneTwister(seed)
    pts = s .* (rand(rng, 3, NCLOUD) .- 0.5)
    m = fill(1.0 / NCLOUD, NCLOUD)
    c = [sum(m .* pts[k, :]) for k in 1:3]
    pts .-= c
    return pts, m
end

exact_accel(pts, m, x) = begin
    a = zeros(3)
    for i in eachindex(m)
        d = x .- pts[:, i]; r = norm(d)
        a .-= m[i] .* d ./ r^3
    end
    a
end

emono = Float64[]; equad = Float64[]; eoct = Float64[]
rng = Random.MersenneTwister(99)
for sd in RATIOS
    s = 1.0; d = s / sd
    pts, m = cloud(s, 12345)
    M = sum(m)
    Q = zeros(3, 3); M3 = zeros(3, 3, 3)
    for n in eachindex(m)
        v = pts[:, n]; r2 = dot(v, v)
        for a in 1:3, b in 1:3
            Q[a, b] += m[n] * (3v[a]*v[b] - (a == b ? r2 : 0.0))
            for c in 1:3
                M3[a, b, c] += m[n] * v[a]*v[b]*v[c]
            end
        end
    end
    # traceless octupole from the raw third moment
    T = [sum(M3[i, l, l] for l in 1:3) for i in 1:3]
    O = zeros(3, 3, 3)
    for i in 1:3, j in 1:3, k in 1:3
        O[i,j,k] = 5M3[i,j,k] - (T[i]*(j==k) + T[j]*(i==k) + T[k]*(i==j))
    end

    em = eq = eo = 0.0
    for _ in 1:NDIR
        nx, ny, nz = random_direction(rng)
        x = d .* [nx, ny, nz]
        ex = exact_accel(pts, m, x)
        r = norm(x)
        mo = -M .* x ./ r^3
        qu = mo .+ (Q * x) ./ r^5 .- 2.5 * (x' * Q * x) .* x ./ r^7
        V = [sum(O[l,j,k]*x[j]*x[k] for j in 1:3, k in 1:3) for l in 1:3]
        S3 = sum(V[l]*x[l] for l in 1:3)
        oc = qu .+ 1.5 .* V ./ r^7 .- 3.5 * S3 .* x ./ r^9
        em += norm(mo .- ex)/norm(ex)
        eq += norm(qu .- ex)/norm(ex)
        eo += norm(oc .- ex)/norm(ex)
    end
    push!(emono, em/NDIR); push!(equad, eq/NDIR); push!(eoct, eo/NDIR)
    @printf("  s/d = %.3f  mono %.3e  quad %.3e  oct %.3e\n",
            sd, emono[end], equad[end], eoct[end])
end

fitslope(x, y) = begin
    lx = log.(x); ly = log.(y); n = length(x)
    (n*sum(lx.*ly) - sum(lx)*sum(ly)) / (n*sum(lx.^2) - sum(lx)^2)
end
k = 6
sm = fitslope(RATIOS[1:k], emono[1:k])
sq = fitslope(RATIOS[1:k], equad[1:k])
so = fitslope(RATIOS[1:k], eoct[1:k])
@printf("\n  fitted slopes: monopole %.2f, quadrupole %.2f, octupole %.2f\n", sm, sq, so)

# ==================================== 2. error and cost in the real tree ======
banner("error and cost against theta, N = $(QUICK ? 4096 : 32768)")
const NBIG = QUICK ? 4096 : 32768
const THETAS = QUICK ? [0.5, 1.0] :
    [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.2, 1.4]
const SEEDS = QUICK ? [1987] : [1987, 42, 314]

pos, _, mass = plummer_ics(NBIG; p = p, seed = 1987)
adir = zeros(3, NBIG)
direct_forces!(adir, pos, mass, 0.0)

# Cache one direct-sum reference per seed instead of recomputing it inside
# every (mode, theta) loop -- at N = 32768 that is the dominant cost.
const REF = Dict{Int,Tuple{Matrix{Float64},Matrix{Float64},Vector{Float64}}}()
for seed in SEEDS
    ps, _, ms = plummer_ics(NBIG; p = p, seed = seed)
    ad = zeros(3, NBIG); direct_forces!(ad, ps, ms, 0.0)
    REF[seed] = (ps, ad, ms)
end

modes = [("monopole", false, false), ("quadrupole", true, false),
         ("octupole", true, true)]
curves = Any[]
for (name, quad, oct) in modes
    errs = Float64[]; costs = Float64[]; nts = Float64[]
    for th in THETAS
        es = Float64[]
        for seed in SEEDS
            ps, ad, ms = REF[seed]
            tr = Octree(8NBIG)
            build_tree!(tr, ps, ms; quadrupole = quad, octupole = oct)
            a = zeros(3, NBIG)
            tree_forces!(a, tr, ps, ms, th, 0.0; quadrupole = quad, octupole = oct)
            push!(es, force_error(a, ad).relative)
        end
        # cost measured on one realisation, single evaluation
        tr = Octree(8NBIG)
        a = zeros(3, NBIG)
        build_tree!(tr, pos, mass; quadrupole = quad, octupole = oct)
        nt = tree_forces!(a, tr, pos, mass, th, 0.0; quadrupole = quad, octupole = oct)
        t0 = time()
        for _ in 1:3
            build_tree!(tr, pos, mass; quadrupole = quad, octupole = oct)
            tree_forces!(a, tr, pos, mass, th, 0.0; quadrupole = quad, octupole = oct)
        end
        el = (time() - t0) / 3
        push!(errs, mean(es)); push!(costs, el); push!(nts, nt)
        @printf("  %-11s theta=%.1f  error %.5f%%  cost %.4f s  <n>=%.0f\n",
                name, th, errs[end], el, nt)
    end
    push!(curves, Dict("name" => name, "theta" => THETAS,
                       "error" => short(errs), "cost" => short(costs),
                       "nterms" => short(nts)))
end

# ============================== 3. fourth-order integrator at equal cost ======
banner("leapfrog vs fourth-order symplectic, at equal force-evaluation cost")
const NEV = QUICK ? 1024 : 4096
const TEND = QUICK ? 5.0 : 25.0
eps = mean_interparticle_separation(p, NEV)
cfg = RunConfig(theta = 0.5, eps = eps)

int_rows = Any[]
for dt2 in (0.00125, 0.0025, 0.005, 0.0125, 0.025, 0.05)
    # leapfrog: 1 force eval per step. yoshida: 3 per step, so it takes
    # steps of 3*dt2 to use the same number of evaluations.
    for (name, dt, nev_per_step) in (("leapfrog", dt2, 1),
                                     ("yoshida4", 3 * dt2, 3))
        ipos, ivel, imass = plummer_ics(NEV; p = p, seed = 1987)
        E0 = kinetic_energy(ivel, imass) + potential_energy(ipos, imass, eps)
        nsteps = round(Int, TEND / dt)
        worst = 0.0
        watch = (s, t, pp, vv, aa) -> begin
            E = kinetic_energy(vv, imass) + potential_energy(pp, imass, eps)
            worst = max(worst, abs((E - E0) / E0))
        end
        t0 = time()
        if name == "leapfrog"
            evolve!(ipos, ivel, imass, cfg; dt = dt, nsteps = nsteps,
                    callback = watch, every = 10)
        else
            evolve4!(ipos, ivel, imass, cfg; dt = dt, nsteps = nsteps,
                     callback = watch, every = 10)
        end
        wall = time() - t0
        E1 = kinetic_energy(ivel, imass) + potential_energy(ipos, imass, eps)
        nev = nsteps * nev_per_step
        @printf("  %-9s dt=%.4f  %6d steps (%6d force evals)  |dE/E|max = %.3e  final %.3e  %.1fs\n",
                name, dt, nsteps, nev, worst, abs((E1-E0)/E0), wall)
        push!(int_rows, Dict("method" => name, "dt" => dt, "nsteps" => nsteps,
                             "force_evals" => nev, "max_dE" => short(worst),
                             "final_dE" => short(abs((E1-E0)/E0)),
                             "wall" => short(wall)))
    end
end

save_result("beyond", Dict(
    "cell" => Dict("s_over_d" => RATIOS, "monopole" => short(emono),
                   "quadrupole" => short(equad), "octupole" => short(eoct),
                   "slope_monopole" => short(sm, 4),
                   "slope_quadrupole" => short(sq, 4),
                   "slope_octupole" => short(so, 4)),
    "N" => NBIG, "seeds" => SEEDS, "curves" => curves,
    "integrators" => int_rows, "N_evol" => NEV))
