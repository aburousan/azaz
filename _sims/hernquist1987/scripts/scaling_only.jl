# How the cost of one force evaluation grows with N, on one core.
# Same rule as scripts/timing_only.jl: the statistic is the minimum over
# repeats, because interference from other work can only add time.

include(joinpath(@__DIR__, "common.jl"))

const NGRID = QUICK ? [1024, 2048] :
    [1024, 1448, 2048, 2896, 4096, 5793, 8192, 11585, 16384, 23170, 32768,
     46341, 65536, 92682, 131072]
const NDIRECT_MAX = 46341
const REPEATS = QUICK ? 2 : 7
const EPS = 0.0

best(f, repeats) = (f(); minimum((@elapsed f()) for _ in 1:repeats))

rows = Any[]
banner("cost against N, one core, minimum of $REPEATS repeats")
for N in NGRID
    pos, vel, mass = plummer_ics(N; seed = 1987)
    tree = Octree(8N); acc = zeros(3, N)
    rec = Dict{String,Any}("N" => N)
    for th in [0.5, 1.0]
        nt = Ref(0.0)
        t = best(REPEATS) do
            build_tree!(tree, pos, mass; quadrupole = false)
            nt[] = tree_forces!(acc, tree, pos, mass, th, EPS; quadrupole = false)
        end
        rec["tree_$(th)"] = short(t); rec["nterms_$(th)"] = short(nt[])
    end
    if N <= NDIRECT_MAX
        rec["direct"] = short(best(max(REPEATS ÷ 3, 1)) do
            direct_forces!(acc, pos, mass, EPS)
        end)
    end
    push!(rows, rec)
    @printf("  N = %7d  tree(1.0) %.4f s  tree(0.5) %.4f s  direct %s\n",
            N, rec["tree_1.0"], rec["tree_0.5"],
            haskey(rec, "direct") ? @sprintf("%.4f s", rec["direct"]) : "-")
end

save_result("scaling_only", (; rows, repeats = REPEATS, statistic = "minimum",
                             eps = EPS, threads = Threads.nthreads()))
