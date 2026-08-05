# Two implementation choices that could explain the residual gaps against the
# paper, tested rather than argued about.
#
# 1. FORCED SUBDIVISION. I always open a cell that contains the particle
#    itself, to prevent self-attraction. The standard BH code and the standard
#    version of TREECODE do not; the paper investigates the effect separately.
#    If we differ here, we differ at theta >~ 1.
#
# 2. WHEN <n_terms> IS MEASURED. The paper notes for N = 4096, theta = 1 that
#    <n_terms> was "approximately 170-175 for small t, but increased slowly to
#    195-200 during the first 50 time steps". So the number is not a property of
#    the model alone -- it drifts as the cluster relaxes. All my quoted values
#    are measured on the initial conditions.

include(joinpath(@__DIR__, "common.jl"))

p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)

# ---------------------------------------------------- 1. forced subdivision ---
banner("forced subdivision on/off")
const NBIG = QUICK ? 4096 : 32768
const SEEDS = QUICK ? [1987] : [1987, 42, 314]

fs_rows = Any[]
for theta in (0.5, 1.0, 1.2, 1.5)
    for fs in (true, false)
        nts = Float64[]; errs = Float64[]
        for seed in SEEDS
            pos, _, mass = plummer_ics(NBIG; p = p, seed = seed)
            adir = zeros(3, NBIG)
            direct_forces!(adir, pos, mass, 0.0)
            tree = Octree(8NBIG)
            build_tree!(tree, pos, mass; quadrupole = false)
            a = zeros(3, NBIG)
            nt = tree_forces!(a, tree, pos, mass, theta, 0.0;
                              forced_subdivision = fs)
            push!(nts, nt); push!(errs, force_error(a, adir).relative)
        end
        @printf("  theta=%.1f  forced=%-5s  <n_terms> = %7.2f   error = %.4f%%\n",
                theta, fs, mean(nts), mean(errs))
        push!(fs_rows, Dict("theta" => theta, "forced" => fs,
                            "nterms" => short(mean(nts)),
                            "error" => short(mean(errs))))
    end
end

# --------------------------------------- 2. does <n_terms> drift with time? ---
banner("<n_terms> against time, N = 4096, theta = 1")
const NEV = QUICK ? 1024 : 4096
const NSTEPS = QUICK ? 100 : 1000
eps = mean_interparticle_separation(p, NEV)
pos, vel, mass = plummer_ics(NEV; p = p, seed = 1987)
cfg = RunConfig(theta = 1.0, eps = eps)

tree = Octree(8NEV)
counts = zeros(Int, NEV)
ts = Float64[]; nt_of_t = Float64[]
function record(step, t, pp, vv, aa)
    build_tree!(tree, pp, mass; quadrupole = false)
    a = zeros(3, NEV)
    nt = tree_forces!(a, tree, pp, mass, 1.0, eps; nterms = counts)
    push!(ts, t); push!(nt_of_t, nt)
end
evolve!(pos, vel, mass, cfg; dt = 0.025, nsteps = NSTEPS, callback = record,
        every = 10)

early = nt_of_t[1]
first50 = nt_of_t[findlast(<=(50 * 0.025), ts)]
late = mean(nt_of_t[(length(nt_of_t) ÷ 2):end])
@printf("  t = 0                     : <n_terms> = %.1f\n", early)
@printf("  after 50 steps (t = 1.25) : <n_terms> = %.1f\n", first50)
@printf("  late-time mean            : %.1f\n", late)
println("  paper, same setup         : 170-175 early, rising to 195-200")

save_result("why_different", Dict(
    "N_big" => NBIG, "seeds" => SEEDS, "forced_subdivision" => fs_rows,
    "N_evol" => NEV, "nsteps" => NSTEPS,
    "time" => short(ts), "nterms_of_time" => short(nt_of_t),
    "nterms_initial" => short(early), "nterms_after50" => short(first50),
    "nterms_late" => short(late)))
