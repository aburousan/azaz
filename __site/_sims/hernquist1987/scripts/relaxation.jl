# Fig. 10: is a tree code more collisional than a direct sum?
#
# Grouping particles into cells replaces many small bodies by one big
# pseudo-particle, and a lumpier force field would relax the system faster.
# The test of section IV: fire massless test particles through the system and
# measure how much they get deflected, t_r = <dt> / <sin^2 Phi>. Everything is
# quoted relative to the direct calculation, t_r(theta) / t_r(0).

include(joinpath(@__DIR__, "common.jl"))

const N = QUICK ? 1024 : 4096
const THETAS = QUICK ? [0.0, 1.0] :
    [0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.1, 1.2, 1.3, 1.4]
const NSAMPLES = QUICK ? 2 : 5
const NORBITS = QUICK ? 20 : 200

# The paper works with a uniform sphere here (Standish & Aksnes' setup): unit
# radius, unit mass, test particle launched inward at half the escape speed.
const V0 = sqrt(2) / 2

function relaxation_curve(; eps_mode::Symbol, quadrupole::Bool)
    lam = uniform_lambda(N)
    eps = eps_mode === :lambda ? lam : 0.0
    out = Float64[]; sd = Float64[]
    for th in THETAS
        samples = Float64[]
        for s in 1:NSAMPLES
            # A fresh field for every sample, so the test orbits are not all
            # feeling the same set of lumps.
            pos, _, mass = uniform_sphere_ics(N; seed = 1000 + 97 * s)
            cfg = RunConfig(theta = th, eps = eps, quadrupole = quadrupole,
                            direct = th == 0.0)
            tr = relaxation_time(pos, mass, cfg; v0 = V0, ntest = NORBITS,
                                 dt = 0.002,
                                 rng = Random.MersenneTwister(5000 + s))
            push!(samples, tr)
        end
        push!(out, mean(samples))
        push!(sd, std(samples) / sqrt(NSAMPLES))
        @printf("  eps=%-7s quad=%-5s theta=%.1f  t_r = %.3f +/- %.3f\n",
                eps_mode, quadrupole, th, out[end], sd[end])
    end
    return out, sd
end

curves = Any[]
for eps_mode in (:zero, :lambda), quad in (false, true)
    banner("relaxation: eps = $eps_mode, quadrupole = $quad")
    tr, err = relaxation_curve(eps_mode = eps_mode, quadrupole = quad)
    ref = tr[1]                       # theta = 0, the direct calculation
    push!(curves, Dict("eps_mode" => String(eps_mode), "quadrupole" => quad,
                       "theta" => THETAS,
                       "t_r" => short(tr), "t_r_err" => short(err),
                       "ratio" => short(tr ./ ref),
                       "ratio_err" => short(err ./ ref)))
end

save_result("relaxation", Dict("N" => N, "nsamples" => NSAMPLES,
                               "norbits" => NORBITS, "v0" => short(V0),
                               "curves" => curves))
