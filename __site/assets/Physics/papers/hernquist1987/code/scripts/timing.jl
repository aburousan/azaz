# Figs. 3 and 4: how the cost of one force evaluation scales with N and theta.
#
# Timing runs single-threaded on purpose. The N log N law is a statement about
# how much arithmetic the algorithm does, and spreading that arithmetic over
# cores only adds scheduling noise on top of the thing being measured.
#
# Reported quantity, as in the paper: seconds per step per particle, meaning
# (time to build the tree + walk it for every particle) / N.

include(joinpath(@__DIR__, "common.jl"))

if Threads.nthreads() > 1
    @warn "timing should be run with -t 1; got $(Threads.nthreads()) threads"
end

const NS = QUICK ? [1024, 2048] : [1024, 2048, 4096, 8192, 16384, 32768]
const THETAS = QUICK ? [0.5, 1.0] :
    [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.2, 1.5]

"Small theta means an enormous number of terms, so cap N there to stay sane."
maxN(theta) = theta == 0.0 ? 4096 :
              theta <= 0.1 ? 4096 :
              theta <= 0.2 ? 8192 :
              theta <= 0.3 ? 16384 : 32768

function time_force(N, theta, quadrupole)
    p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)
    eps = mean_interparticle_separation(p, N)
    pos, vel, mass = plummer_ics(N; p = p, seed = 1987)
    acc = zeros(3, N)
    tree = Octree(8N)
    cfg = RunConfig(theta = theta, eps = eps, quadrupole = quadrupole,
                    direct = theta == 0.0)

    compute_forces!(acc, tree, pos, mass, cfg)          # warm up / compile
    reps = N <= 4096 ? 5 : 3
    t0 = time()
    nt = 0.0
    for _ in 1:reps
        nt = compute_forces!(acc, tree, pos, mass, cfg)
    end
    elapsed = (time() - t0) / reps

    # how deep and how big the tree got, for the discussion of memory
    build_tree!(tree, pos, mass; quadrupole = quadrupole)
    return (per_particle = elapsed / N, total = elapsed, nterms = nt,
            nodes = node_count(tree), depth = tree_depth(tree))
end

rows = Any[]
for quad in (false, true), theta in THETAS, N in NS
    N > maxN(theta) && continue
    r = time_force(N, theta, quad)
    @printf("quad=%-5s theta=%.1f N=%6d  %.3e s/step/particle  <nterms>=%7.1f  nodes=%6d depth=%2d\n",
            quad, theta, N, r.per_particle, r.nterms, r.nodes, r.depth)
    push!(rows, Dict("N" => N, "theta" => theta, "quadrupole" => quad,
                     "per_particle" => short(r.per_particle),
                     "total" => short(r.total),
                     "nterms" => short(r.nterms),
                     "nodes" => r.nodes, "depth" => r.depth))
end

# The direct O(N^2) sum for the same N, so the crossover can be located.
direct_rows = Any[]
for N in NS
    p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)
    eps = mean_interparticle_separation(p, N)
    pos, vel, mass = plummer_ics(N; p = p, seed = 1987)
    acc = zeros(3, N)
    direct_forces!(acc, pos, mass, eps)
    reps = N <= 4096 ? 3 : 1
    t0 = time()
    for _ in 1:reps
        direct_forces!(acc, pos, mass, eps)
    end
    el = (time() - t0) / reps
    @printf("direct  N=%6d  %.3e s/step/particle\n", N, el / N)
    push!(direct_rows, Dict("N" => N, "per_particle" => short(el / N),
                            "total" => short(el)))
end

save_result("timing", Dict("tree" => rows, "direct" => direct_rows,
                           "threads" => Threads.nthreads()))
