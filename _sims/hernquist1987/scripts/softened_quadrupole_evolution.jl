# Time-evolution comparison of Hernquist's historical softened quadrupole patch
# against the exact Taylor expansion of the Plummer-softened kernel.

include(joinpath(@__DIR__, "common.jl"))

const N = QUICK ? 1024 : 4096
const NSTEPS = QUICK ? 100 : 1000
const DT = 0.025
const THETA = 1.0
const EVERY = QUICK ? 5 : 5
const RUN_DIRECT = QUICK || "--direct" in ARGS

function run_case(label; direct = false, exact_softened_quadrupole = false,
                  eps_override = nothing)
    p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)
    eps = eps_override === nothing ? mean_interparticle_separation(p, N) :
        Float64(eps_override)
    pos, vel, mass = plummer_ics(N; p = p, seed = 1987)
    cfg = RunConfig(theta = THETA, eps = eps, quadrupole = !direct,
                    exact_softened_quadrupole = exact_softened_quadrupole,
                    direct = direct)

    times = Float64[]
    energies = Float64[]
    virials = Float64[]
    clausius = Float64[]
    etaP = Float64[]
    rcm = Float64[]
    Lmag = Float64[]
    nterms = Float64[]

    function record(step, t, pp, vv, aa)
        K = kinetic_energy(vv, mass)
        U = potential_energy(pp, mass, eps)
        W = clausius_virial(pp, aa, mass)
        c = com_position(pp, mass)
        L = angular_momentum(pp, vv, mass)
        push!(times, t)
        push!(energies, K + U)
        push!(virials, -2K / U)
        push!(clausius, -2K / W)
        push!(etaP, net_force_fraction(aa, mass))
        push!(rcm, sqrt(sum(abs2, c)))
        push!(Lmag, sqrt(sum(abs2, L)))
        push!(nterms, step == 0 || direct ? float(N - 1) : NaN)
    end

    t0 = time()
    evolve!(pos, vel, mass, cfg; dt = DT, nsteps = NSTEPS, callback = record,
            every = EVERY)
    wall = time() - t0

    dE = 100 * (energies[end] - energies[1]) / abs(energies[1])
    dL = abs(Lmag[end] - Lmag[1]) / max(Lmag[1], Base.eps(Float64))
    @printf("%-30s  wall %.1fs  dE/E %+.4f%%  etaP final %.3e  dL/L %.3e\n",
            label, wall, dE, etaP[end], dL)

    return Dict(
        "label" => label,
        "N" => N,
        "theta" => THETA,
        "eps" => eps,
        "dt" => DT,
        "nsteps" => NSTEPS,
        "direct" => direct,
        "quadrupole" => !direct,
        "exact_softened_quadrupole" => exact_softened_quadrupole,
        "wall_seconds" => short(wall),
        "time" => short(times),
        "E" => short(energies),
        "virial" => short(virials),
        "clausius_virial" => short(clausius),
        "eta_P" => short(etaP, 8),
        "r_cm" => short(rcm, 8),
        "L" => short(Lmag, 8),
        "summary" => Dict(
            "energy_error_percent" => short(dE, 8),
            "abs_energy_error_percent" => short(abs(dE), 8),
            "final_eta_P" => short(etaP[end], 8),
            "max_eta_P" => short(maximum(etaP), 8),
            "final_r_cm" => short(rcm[end], 8),
            "max_r_cm" => short(maximum(rcm), 8),
            "angular_momentum_fractional_change" => short(dL, 8),
            "final_virial" => short(virials[end], 8),
            "final_clausius_virial" => short(clausius[end], 8),
        ),
    )
end

results = Dict{String,Any}()
results["historical_patch"] =
    run_case("tree quadrupole, historical patch")
results["exact_softened_quadrupole"] =
    run_case("tree quadrupole, exact softened"; exact_softened_quadrupole = true)
results["newtonian_quadrupole"] =
    run_case("tree quadrupole, Newtonian"; eps_override = 0.0)
if RUN_DIRECT
    results["direct"] = run_case("direct softened sum"; direct = true)
else
    results["direct"] = Dict(
        "skipped" => true,
        "note" => "Run with --direct to recompute the O(N^2) softened baseline; the existing article baseline is in data/evolution.json.",
    )
end

results["paper_reference"] = Dict(
    "source" => "Hernquist 1987 comparison quoted in article.tex",
    "theta" => 1.0,
    "energy_error_percent" => 0.68,
    "note" => "Paper reference is for the original tree-code run, not for the new exact-softened-quadrupole variant.",
)

save_result("softened_quadrupole_evolution", results)
