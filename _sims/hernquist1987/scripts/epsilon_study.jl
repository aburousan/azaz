# What does the softening length actually do to the physics?
#
# Three separate things get measured as a function of eps/lambda:
#
#   1. W/U, the ratio of the Clausius virial to the potential energy. The
#      claim derived on the setup page is W/U ~ 1 - <eps^2/r^2>, so this is a
#      direct test of it.
#   2. the equilibrium the model settles into, through -2K/U and -2K/W
#   3. how well energy is conserved over a long run
#
# This is the run that justifies the statement that -2K/U sitting below 1 is
# softening and not a bug.

include(joinpath(@__DIR__, "common.jl"))

const N = QUICK ? 1024 : 4096
const NSTEPS = QUICK ? 200 : 800
const DT = 0.025
const THETA = 0.5          # accurate enough that the tree is not the story
const RATIOS = QUICK ? [0.5, 1.0] :
    [0.0625, 0.125, 0.25, 0.5, 1.0, 2.0, 4.0]

p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)
lambda = mean_interparticle_separation(p, N)
@printf("N = %d, lambda = %.5f\n", N, lambda)

"Mean of eps^2/r^2 over all pairs -- the leading correction predicted for W/U."
function mean_eps2_over_r2(pos, mass, eps)
    N = length(mass)
    s = 0.0; n = 0
    for i in 1:N, j in (i+1):N
        r2 = (pos[1,i]-pos[1,j])^2 + (pos[2,i]-pos[2,j])^2 + (pos[3,i]-pos[3,j])^2
        s += eps^2 / r2
        n += 1
    end
    return s / n
end

rows = Any[]
for ratio in RATIOS
    eps = ratio * lambda
    banner(@sprintf("eps/lambda = %.4f  (eps = %.5f)", ratio, eps))
    pos, vel, mass = plummer_ics(N; p = p, seed = 1987)
    cfg = RunConfig(theta = THETA, eps = eps)

    ts = Float64[]; Ks = Float64[]; Us = Float64[]; Ws = Float64[]; Es = Float64[]
    lagr = Vector{Float64}[]
    function record(step, t, pp, vv, aa)
        K = kinetic_energy(vv, mass)
        U = potential_energy(pp, mass, eps)
        W = clausius_virial(pp, aa, mass)
        push!(ts, t); push!(Ks, K); push!(Us, U); push!(Ws, W); push!(Es, K + U)
        push!(lagr, lagrangian_radii(pp, mass, (0.1, 0.5, 0.9)))
    end
    evolve!(pos, vel, mass, cfg; dt = DT, nsteps = NSTEPS, callback = record,
            every = 5)

    half = length(ts) ÷ 2
    qU = -2 .* Ks ./ Us
    qW = -2 .* Ks ./ Ws
    WU = Ws ./ Us
    drift = 100 * (Es[end] - Es[1]) / abs(Es[1])

    @printf("  W/U        = %.4f (late-time mean)\n", mean(WU[half:end]))
    @printf("  -2K/U      = %.4f +/- %.4f\n", mean(qU[half:end]), std(qU[half:end]))
    @printf("  -2K/W      = %.4f +/- %.4f\n", mean(qW[half:end]), std(qW[half:end]))
    @printf("  dE/E       = %+.4f %%\n", drift)

    push!(rows, Dict(
        "eps_over_lambda" => ratio, "eps" => short(eps),
        "time" => short(ts),
        "virial_U" => short(qU), "virial_W" => short(qW), "W_over_U" => short(WU),
        "E" => short(Es),
        "energy_drift_percent" => short(drift),
        "W_over_U_late" => short(mean(WU[half:end])),
        "virial_U_late" => short(mean(qU[half:end])),
        "virial_U_std" => short(std(qU[half:end])),
        "virial_W_late" => short(mean(qW[half:end])),
        "virial_W_std" => short(std(qW[half:end])),
        "lagrangian" => [short(l) for l in lagr]))
end

# The predicted correction, evaluated on the initial conditions.
pos0, _, mass0 = plummer_ics(N; p = p, seed = 1987)
pred = [Dict("eps_over_lambda" => r,
             "one_minus_mean" => short(1 - mean_eps2_over_r2(pos0, mass0, r * lambda)))
        for r in RATIOS]
println("\npredicted 1 - <eps^2/r^2>:")
for q in pred
    @printf("  eps/lambda = %.4f  ->  %.4f\n", q["eps_over_lambda"], q["one_minus_mean"])
end

save_result("epsilon_study", Dict("N" => N, "lambda" => short(lambda),
                                  "theta" => THETA, "nsteps" => NSTEPS,
                                  "runs" => rows, "prediction" => pred))
