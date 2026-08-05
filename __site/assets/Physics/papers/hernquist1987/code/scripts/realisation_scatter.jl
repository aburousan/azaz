# How much do the headline numbers move if nothing changes but the random seed?
#
# The paper quotes single numbers from single runs. Every quantity I compare
# against is measured on one particular random realisation of a Plummer sphere,
# so before claiming agreement or disagreement with the paper I need to know
# how big the realisation-to-realisation scatter is.

include(joinpath(@__DIR__, "common.jl"))

const SEEDS = QUICK ? [1, 2] : [1987, 11, 23, 42, 101, 271, 314, 1729]
const NBIG = QUICK ? 2048 : 32768
const NEVOL = QUICK ? 1024 : 4096
const NSTEPS = QUICK ? 100 : 1000
const DT = 0.025

p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)

# ---- nterms and force error at large N, over seeds -----------------------
banner("nterms and force error, N = $NBIG, over $(length(SEEDS)) seeds")
eps_big = 0.0                       # matching the paper's error figures
rows = Any[]
for seed in SEEDS
    pos, _, mass = plummer_ics(NBIG; p = p, seed = seed)
    adir = zeros(3, NBIG)
    direct_forces!(adir, pos, mass, eps_big)
    tree = Octree(8NBIG)
    entry = Dict{String,Any}("seed" => seed)
    for th in (0.5, 1.0)
        build_tree!(tree, pos, mass; quadrupole = false)
        a = zeros(3, NBIG)
        nt = tree_forces!(a, tree, pos, mass, th, eps_big)
        er = force_error(a, adir).relative
        entry["nterms_$th"] = short(nt)
        entry["error_$th"] = short(er)
    end
    @printf("  seed %5d:  <n>(1.0) = %7.2f   err(1.0) = %.4f%%   <n>(0.5) = %8.2f   err(0.5) = %.4f%%\n",
            seed, entry["nterms_1.0"], entry["error_1.0"],
            entry["nterms_0.5"], entry["error_0.5"])
    push!(rows, entry)
end

summarise(key) = begin
    v = [Float64(r[key]) for r in rows]
    (mean = mean(v), std = std(v), rel = 100 * std(v) / mean(v),
     min = minimum(v), max = maximum(v))
end

println()
for key in ("nterms_1.0", "error_1.0", "nterms_0.5", "error_0.5")
    s = summarise(key)
    @printf("  %-12s mean %9.4f  sd %8.4f  (%.2f%%)  range [%.4f, %.4f]\n",
            key, s.mean, s.std, s.rel, s.min, s.max)
end

# ---- energy drift over a long run, over seeds ----------------------------
banner("energy drift, N = $NEVOL, $NSTEPS steps, over seeds")
eps_ev = mean_interparticle_separation(p, NEVOL)
drift = Dict("direct" => Float64[], "theta1.0" => Float64[], "theta0.5" => Float64[])
for seed in SEEDS
    for (label, cfgkw) in (("direct", (theta = 0.0, direct = true)),
                           ("theta0.5", (theta = 0.5, direct = false)),
                           ("theta1.0", (theta = 1.0, direct = false)))
        pos, vel, mass = plummer_ics(NEVOL; p = p, seed = seed)
        cfg = RunConfig(theta = cfgkw.theta, eps = eps_ev, direct = cfgkw.direct)
        E0 = kinetic_energy(vel, mass) + potential_energy(pos, mass, eps_ev)
        evolve!(pos, vel, mass, cfg; dt = DT, nsteps = NSTEPS)
        E1 = kinetic_energy(vel, mass) + potential_energy(pos, mass, eps_ev)
        push!(drift[label], 100 * (E1 - E0) / abs(E0))
    end
    @printf("  seed %5d:  direct %+.4f%%   theta=0.5 %+.4f%%   theta=1.0 %+.4f%%\n",
            seed, drift["direct"][end], drift["theta0.5"][end], drift["theta1.0"][end])
end

println()
for k in ("direct", "theta0.5", "theta1.0")
    v = drift[k]
    @printf("  %-9s mean %+.4f%%  sd %.4f%%  range [%+.4f%%, %+.4f%%]\n",
            k, mean(v), std(v), minimum(v), maximum(v))
end

save_result("realisation_scatter", Dict(
    "seeds" => SEEDS, "N_big" => NBIG, "N_evol" => NEVOL, "nsteps" => NSTEPS,
    "rows" => rows,
    "summary" => Dict(k => Dict(pairs(summarise(k))...) for k in
                      ("nterms_1.0", "error_1.0", "nterms_0.5", "error_0.5")),
    "drift" => Dict(k => short(v) for (k, v) in drift),
    "drift_summary" => Dict(k => Dict("mean" => short(mean(v)),
                                      "std" => short(std(v)),
                                      "min" => short(minimum(v)),
                                      "max" => short(maximum(v)))
                            for (k, v) in drift)))
