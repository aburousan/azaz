# Timing of one force evaluation on one core, with enough repeats that the
# result is not spoiled by whatever else the machine is doing.
#
# The statistic is the MINIMUM over repeats, not the mean or the median. On a
# shared machine every disturbance can only make a measurement slower, so the
# fastest of many runs is the closest estimate of the true cost.

include(joinpath(@__DIR__, "common.jl"))

const NBIG    = QUICK ? 4096 : 32768
const THETAS  = QUICK ? [0.4, 0.8] :
    round.(10 .^ range(log10(0.15), log10(1.4), length = 13), digits = 4)
const REPEATS = QUICK ? 2 : 9
const EPS     = 0.0
const MODES   = (("monopole", false, false), ("quadrupole", true, false),
                 ("octupole", true, true))

best(f, repeats) = (f(); minimum((@elapsed f()) for _ in 1:repeats))

pos, vel, mass = plummer_ics(NBIG; seed = 1987)
tree = Octree(8NBIG); acc = zeros(3, NBIG)
rows = Any[]

banner("one core, N = $NBIG, minimum of $REPEATS repeats")
for (name, quad, oct) in MODES
    tb = best(REPEATS) do
        build_tree!(tree, pos, mass; quadrupole = quad, octupole = oct)
    end
    build_tree!(tree, pos, mass; quadrupole = quad, octupole = oct)
    for th in THETAS
        nt = Ref(0.0)
        tw = best(REPEATS) do
            nt[] = tree_forces!(acc, tree, pos, mass, th, EPS;
                                quadrupole = quad, octupole = oct)
        end
        push!(rows, (; order = name, theta = th, nterms = short(nt[]),
                     t_build = short(tb), t_walk = short(tw),
                     t_total = short(tb + tw),
                     ns_per_term = short(1e9 * tw / (NBIG * nt[]))))
        @printf("  %-11s theta = %.4f  <n> = %8.1f  build %.4f s  walk %8.4f s  %6.1f ns/term\n",
                name, th, nt[], tb, tw, 1e9 * tw / (NBIG * nt[]))
    end
end

td = best(max(REPEATS ÷ 3, 1)) do
    direct_forces!(acc, pos, mass, EPS)
end
push!(rows, (; order = "direct", theta = 0.0, nterms = short(float(NBIG - 1)),
             t_build = 0.0, t_walk = short(td), t_total = short(td),
             ns_per_term = short(1e9 * td / (NBIG * (NBIG - 1)))))
@printf("  direct sum: %.4f s  (%.2f ns per pair)\n", td, 1e9 * td / (NBIG * (NBIG - 1)))

save_result("timing_only", (; N = NBIG, thetas = THETAS, repeats = REPEATS,
                            statistic = "minimum", eps = EPS, rows,
                            threads = Threads.nthreads()))
