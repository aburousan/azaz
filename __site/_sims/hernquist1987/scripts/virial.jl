# The starting point sir set: the virial theorem for a self-gravitating system,
#
#     2<K> + <U> = 0,     <E> = <U>/2,
#
# which follows from d^2I/dt^2 averaging to zero once the system has settled.
# Here the moment of inertia I(t) is tracked directly to show that it really
# does stop changing, and that 2K + U oscillates about zero from then on.

include(joinpath(@__DIR__, "common.jl"))

const N = QUICK ? 1024 : 4096
const NSTEPS = QUICK ? 200 : 2000
const DT = 0.025

p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)
eps = mean_interparticle_separation(p, N)

"Moment of inertia about the centre of mass, I = sum m r^2."
function moment_of_inertia(pos, mass)
    c = com_position(pos, mass)
    I = 0.0
    for i in eachindex(mass)
        I += mass[i] * ((pos[1, i] - c[1])^2 + (pos[2, i] - c[2])^2 +
                        (pos[3, i] - c[3])^2)
    end
    return I
end

function run(label; scale_to_virial::Bool)
    banner("virial: $label")
    pos, vel, mass = plummer_ics(N; p = p, seed = 1987)
    cfg = RunConfig(theta = 1.0, eps = eps)
    if scale_to_virial
        # Rescale the speeds so the model starts exactly on 2K + W = 0, which
        # removes the transient caused by the cutoff at R = 1. W rather than U,
        # because the force is softened.
        acc = zeros(3, N)
        tree = Octree(8N)
        compute_forces!(acc, tree, pos, mass, cfg)
        W = clausius_virial(pos, acc, mass)
        K = kinetic_energy(vel, mass)
        vel .*= sqrt(-W / (2K))
    end

    ts = Float64[]; Is = Float64[]; Ks = Float64[]; Us = Float64[]; Ws = Float64[]
    function record(step, t, pp, vv, aa)
        push!(ts, t)
        push!(Is, moment_of_inertia(pp, mass))
        push!(Ks, kinetic_energy(vv, mass))
        push!(Us, potential_energy(pp, mass, eps))
        push!(Ws, clausius_virial(pp, aa, mass))
    end
    evolve!(pos, vel, mass, cfg; dt = DT, nsteps = NSTEPS, callback = record,
            every = 5)

    q = -2 .* Ks ./ Us            # the textbook ratio, using U
    qW = -2 .* Ks ./ Ws           # the honest one for a softened force
    # average over the second half, once the transient has passed
    half = length(q) ÷ 2
    @printf("  -2K/U : start %.4f, late-time %.4f +/- %.4f\n",
            q[1], mean(q[half:end]), std(q[half:end]))
    @printf("  -2K/W : start %.4f, late-time %.4f +/- %.4f\n",
            qW[1], mean(qW[half:end]), std(qW[half:end]))
    @printf("  <E> = %.6f, <U>/2 = %.6f\n",
            mean(Ks[half:end] .+ Us[half:end]), mean(Us[half:end]) / 2)

    return Dict("label" => label, "time" => short(ts), "I" => short(Is),
                "K" => short(Ks), "U" => short(Us), "W" => short(Ws),
                "E" => short(Ks .+ Us), "virial" => short(q),
                "virial_W" => short(qW),
                "virial_late_mean" => short(mean(q[half:end])),
                "virial_late_std" => short(std(q[half:end])),
                "virial_W_late_mean" => short(mean(qW[half:end])),
                "virial_W_late_std" => short(std(qW[half:end])),
                "E_mean" => short(mean(Ks[half:end] .+ Us[half:end])),
                "half_U_mean" => short(mean(Us[half:end]) / 2))
end

results = Dict("as_sampled" => run("as sampled"; scale_to_virial = false),
               "rescaled" => run("rescaled to 2K+U=0"; scale_to_virial = true),
               "N" => N, "eps" => short(eps), "dt" => DT, "nsteps" => NSTEPS)

save_result("virial", results)
