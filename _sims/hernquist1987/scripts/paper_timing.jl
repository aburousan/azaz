# Cost model for the Resonance write-up.
#
# The timing in scripts/timing.jl lumps the tree build in with the walk, which
# is what you pay in practice but is useless for a cost *model*: at large theta
# the build dominates and the walk cost disappears into it. Here the two are
# timed separately, several times over, so that
#
#     cost(theta, p) = t_build + N * c_p * nterms(theta)
#
# can be fitted with c_p (seconds per accepted cell at multipole order p) coming
# out clean. Single-threaded on purpose: c_p is a per-core number.

include(joinpath(@__DIR__, "common.jl"))

const NS      = QUICK ? [4096] : [32768, 131072]
const THETAS  = QUICK ? [0.5, 1.0] : [0.2, 0.25, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.2]
const SEEDS   = QUICK ? [1987] : [1987, 42, 314]
const REPEATS = QUICK ? 1 : 5
const EPS     = 0.0

"Median of a few repeats: robust against one unlucky slice of the scheduler."
function timeit(f, repeats)
    ts = Float64[]
    f()                       # warm up / compile
    for _ in 1:repeats
        push!(ts, @elapsed f())
    end
    sort!(ts)
    ts[(length(ts) + 1) ÷ 2]
end

rows = Any[]

for N in NS, seed in SEEDS
    banner("N = $N, seed = $seed")
    pos, vel, mass = plummer_ics(N; seed = seed)
    tree = Octree(8N)
    acc  = zeros(3, N)

    for (label, quad, oct) in (("monopole", false, false),
                               ("quadrupole", true, false),
                               ("octupole", true, true))
        t_build = timeit(REPEATS) do
            build_tree!(tree, pos, mass; quadrupole = quad, octupole = oct)
        end
        build_tree!(tree, pos, mass; quadrupole = quad, octupole = oct)

        for th in THETAS
            nt = Ref(0.0)
            t_walk = timeit(REPEATS) do
                nt[] = tree_forces!(acc, tree, pos, mass, th, EPS;
                                    quadrupole = quad, octupole = oct)
            end
            push!(rows, (; N, seed, order = label, theta = th,
                         nterms = short(nt[]),
                         t_build = short(t_build), t_walk = short(t_walk),
                         t_total = short(t_build + t_walk),
                         per_cell = short(t_walk / (N * nt[]))))
            @printf("  %-11s theta=%.2f  <n>=%8.1f  build %.4f s  walk %.4f s  -> %.3e s/cell\n",
                    label, th, nt[], t_build, t_walk, t_walk / (N * nt[]))
        end
    end

    # the honest N^2 comparison, same core, same particles
    t_direct = timeit(max(REPEATS ÷ 2, 1)) do
        direct_forces!(acc, pos, mass, EPS)
    end
    push!(rows, (; N, seed, order = "direct", theta = 0.0, nterms = short(float(N - 1)),
                 t_build = 0.0, t_walk = short(t_direct), t_total = short(t_direct),
                 per_cell = short(t_direct / (N * (N - 1)))))
    @printf("  %-11s              <n>=%8d  walk %.4f s  -> %.3e s/pair\n",
            "direct", N - 1, t_direct, t_direct / (N * (N - 1)))
end

save_result("paper_timing", (; rows, threads = Threads.nthreads(), eps = EPS,
                             repeats = REPEATS))
