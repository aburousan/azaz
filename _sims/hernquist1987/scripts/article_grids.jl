# Denser grids for the article figures.
#
# The published curves were computed on coarse grids (11 values of theta, 6
# values of N), which is enough to fit a slope but reads as a set of dots when
# it is drawn. This recomputes the same quantities on finer grids, and also
# times the tree build and the tree walk separately so that a cost model can be
# fitted cleanly. Timing is single threaded; errors use all the threads.

include(joinpath(@__DIR__, "common.jl"))

const NBIG   = QUICK ? 4096 : 32768
const SEEDS  = QUICK ? [1987] : [1987, 42, 314]
const THETAS = QUICK ? [0.4, 0.8] :
    round.(10 .^ range(log10(0.15), log10(1.4), length = 25), digits = 4)
const SD     = QUICK ? [0.05, 0.2] :
    round.(10 .^ range(log10(0.02), log10(0.7), length = 25), digits = 4)
const NGRID  = QUICK ? [1024, 2048] :
    [1024, 1448, 2048, 2896, 4096, 5793, 8192, 11585, 16384, 23170, 32768,
     46341, 65536, 92682, 131072]
const NDIRECT_MAX = 46341
const EPS = 0.0

const MODES = (("monopole", false, false), ("quadrupole", true, false),
               ("octupole", true, true))

function timeit(f, repeats)
    f()
    ts = [(@elapsed f()) for _ in 1:repeats]
    sort!(ts); ts[(length(ts) + 1) ÷ 2]
end

# ============================================================ 1. one cell
# Same construction as scripts/beyond.jl, on a finer grid: a cloud of particles
# in a cube of side s, seen from distance d, averaged over many directions.
banner("truncation error of a single cell, fine grid")
using LinearAlgebra

const NCLOUD = 200
const NDIR = 600

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
        dv = x .- pts[:, i]; r = norm(dv)
        a .-= m[i] .* dv ./ r^3
    end
    a
end

cellerr = [Float64[], Float64[], Float64[]]
let rng = Random.MersenneTwister(99)
    for sd in SD
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
            na = norm(ex)
            em += norm(mo .- ex) / na; eq += norm(qu .- ex) / na
            eo += norm(oc .- ex) / na
        end
        push!(cellerr[1], em / NDIR); push!(cellerr[2], eq / NDIR)
        push!(cellerr[3], eo / NDIR)
        @printf("  s/d = %.4f   mono %.3e  quad %.3e  oct %.3e\n",
                sd, cellerr[1][end], cellerr[2][end], cellerr[3][end])
    end
end

# ============================================================ 2. error vs theta
banner("force error against theta, fine grid, N = $NBIG")
REF = Dict{Int,Any}()
for seed in SEEDS
    pos, vel, mass = plummer_ics(NBIG; seed = seed)
    adir = zeros(3, NBIG)
    direct_forces!(adir, pos, mass, EPS)
    REF[seed] = (pos, adir, mass)
end

errcurves = Dict(name => Float64[] for (name, _, _) in MODES)
ntcurve = Float64[]
for th in THETAS
    nts = Float64[]
    for (name, quad, oct) in MODES
        es = Float64[]
        for seed in SEEDS
            ps, ad, ms = REF[seed]
            tr = Octree(8NBIG)
            build_tree!(tr, ps, ms; quadrupole = quad, octupole = oct)
            a = zeros(3, NBIG)
            nt = tree_forces!(a, tr, ps, ms, th, EPS; quadrupole = quad, octupole = oct)
            push!(es, force_error(a, ad).relative)
            name == "monopole" && push!(nts, nt)
        end
        push!(errcurves[name], mean(es))
    end
    push!(ntcurve, mean(nts))
    @printf("  theta = %.4f  <n> = %8.1f   mono %.5f%%  quad %.5f%%  oct %.5f%%\n",
            th, ntcurve[end], errcurves["monopole"][end],
            errcurves["quadrupole"][end], errcurves["octupole"][end])
end

# ============================================================ 3. cost, one core
banner("cost of one force evaluation, single core, N = $NBIG")
costrows = Any[]
let
    pos, vel, mass = plummer_ics(NBIG; seed = SEEDS[1])
    tree = Octree(8NBIG); acc = zeros(3, NBIG)
    for (name, quad, oct) in MODES
        tb = timeit(3) do
            build_tree!(tree, pos, mass; quadrupole = quad, octupole = oct)
        end
        build_tree!(tree, pos, mass; quadrupole = quad, octupole = oct)
        for th in THETAS
            nt = Ref(0.0)
            tw = timeit(3) do
                nt[] = tree_forces!(acc, tree, pos, mass, th, EPS;
                                    quadrupole = quad, octupole = oct)
            end
            push!(costrows, (; order = name, theta = th, nterms = short(nt[]),
                             t_build = short(tb), t_walk = short(tw),
                             t_total = short(tb + tw)))
            @printf("  %-11s theta = %.4f  <n> = %8.1f  build %.4f s  walk %.4f s\n",
                    name, th, nt[], tb, tw)
        end
    end
    td = timeit(2) do
        direct_forces!(acc, pos, mass, EPS)
    end
    push!(costrows, (; order = "direct", theta = 0.0, nterms = short(float(NBIG - 1)),
                     t_build = 0.0, t_walk = short(td), t_total = short(td)))
    @printf("  direct sum: %.4f s\n", td)
end

# ============================================================ 4. cost vs N
banner("cost against N, single core, fine grid")
scaling = Any[]
for N in NGRID
    pos, vel, mass = plummer_ics(N; seed = SEEDS[1])
    tree = Octree(8N); acc = zeros(3, N)
    row = Dict{String,Any}("N" => N)
    for th in [0.5, 1.0]
        build_tree!(tree, pos, mass; quadrupole = false)
        nt = Ref(0.0)
        t = timeit(3) do
            build_tree!(tree, pos, mass; quadrupole = false)
            nt[] = tree_forces!(acc, tree, pos, mass, th, EPS; quadrupole = false)
        end
        row["tree_$(th)"] = short(t); row["nterms_$(th)"] = short(nt[])
    end
    if N <= NDIRECT_MAX
        row["direct"] = short(timeit(2) do
            direct_forces!(acc, pos, mass, EPS)
        end)
    end
    push!(scaling, row)
    @printf("  N = %7d  tree(1.0) %.4f s  tree(0.5) %.4f s  direct %s\n",
            N, row["tree_1.0"], row["tree_0.5"],
            haskey(row, "direct") ? @sprintf("%.4f s", row["direct"]) : "-")
end

save_result("article_grids",
            (; N = NBIG, seeds = SEEDS, eps = EPS,
             thetas = THETAS, s_over_d = SD,
             cell = (; monopole = short(cellerr[1]), quadrupole = short(cellerr[2]),
                     octupole = short(cellerr[3])),
             error_vs_theta = (; monopole = short(errcurves["monopole"]),
                               quadrupole = short(errcurves["quadrupole"]),
                               octupole = short(errcurves["octupole"]),
                               nterms = short(ntcurve)),
             cost = costrows, scaling = scaling,
             threads = Threads.nthreads()))
