# Pushing N well past what a CRAY X-MP could hold.
#
# The paper stops at N = 32768. Going to a million particles extends the lever
# arm on both scaling laws by another 1.5 decades, which is the cleanest way to
# check that N log N and the N^(-1/5) error decay are real and not local fits.
#
# Timing is single-threaded on purpose (the scaling law is about arithmetic, not
# cores); the direct-sum references are threaded, because otherwise the N = 10^6
# reference alone would take an hour.

include(joinpath(@__DIR__, "common.jl"))

const NS = QUICK ? [4096, 8192] :
    [32768, 65536, 131072, 262144, 524288, 1048576]
const NS_ERR = QUICK ? [4096] :
    [32768, 65536, 131072, 262144, 524288]      # direct reference needed
const THETAS = [0.5, 0.7, 1.0]

p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)

# ------------------------------------------------------------- timing --------
banner("cost per particle against N, single-threaded tree walk")
timing = Any[]
for N in NS
    pos, _, mass = plummer_ics(N; p = p, seed = 1987)
    eps = mean_interparticle_separation(p, N)
    tree = Octree(4N)
    acc = zeros(3, N)
    for th in THETAS
        build_tree!(tree, pos, mass; quadrupole = false)
        tree_forces!(acc, tree, pos, mass, th, eps)      # warm up
        reps = N <= 131072 ? 3 : 1
        t0 = time()
        nt = 0.0
        for _ in 1:reps
            build_tree!(tree, pos, mass; quadrupole = false)
            nt = tree_forces!(acc, tree, pos, mass, th, eps)
        end
        el = (time() - t0) / reps
        @printf("  N = %8d  theta = %.1f   %.4e s/particle   <n> = %8.1f   nodes = %9d  depth = %2d\n",
                N, th, el / N, nt, node_count(tree), tree_depth(tree))
        push!(timing, Dict("N" => N, "theta" => th,
                           "per_particle" => short(el / N), "total" => short(el),
                           "nterms" => short(nt), "nodes" => node_count(tree),
                           "depth" => tree_depth(tree)))
    end
end

# -------------------------------------------------------------- errors -------
banner("force error against N, against an exact direct sum")
errors = Any[]
for N in NS_ERR
    pos, _, mass = plummer_ics(N; p = p, seed = 1987)
    adir = zeros(3, N)
    t0 = time()
    direct_forces!(adir, pos, mass, 0.0)
    @printf("  N = %8d  direct reference took %.1f s\n", N, time() - t0)
    tree = Octree(4N)
    for th in THETAS
        for (name, quad, oct) in (("monopole", false, false),
                                  ("quadrupole", true, false),
                                  ("octupole", true, true))
            build_tree!(tree, pos, mass; quadrupole = quad, octupole = oct)
            a = zeros(3, N)
            tree_forces!(a, tree, pos, mass, th, 0.0;
                         quadrupole = quad, octupole = oct)
            er = force_error(a, adir).relative
            @printf("      theta=%.1f %-11s  %.5f%%\n", th, name, er)
            push!(errors, Dict("N" => N, "theta" => th, "mode" => name,
                               "error" => short(er)))
        end
    end
end

save_result("largeN", Dict("timing" => timing, "errors" => errors,
                           "thetas" => THETAS))
