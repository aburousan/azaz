# The long run: a Plummer model of N = 4096 followed for 1000 leapfrog steps,
# exactly the setup of Figs. 1, 2 and 9 of the paper.
#
#   N = 4096, r0 = 0.2, R = 1, theta = 1, dt = 0.025, eps = mean separation
#
# The same run gives the snapshots (Fig. 1), the Lagrangian radii (Fig. 2), and
# the conservation diagnostics (Fig. 9). It is repeated for theta = 1, 0.5 and
# for a direct summation, so the approximation can be blamed for what it does.

include(joinpath(@__DIR__, "common.jl"))

const N       = QUICK ? 1024 : 4096
const NSTEPS  = QUICK ? 100  : 1000
const DT      = 0.025
const SNAPTIMES = [0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 25.0]

function run_case(label::String; theta::Float64, direct::Bool = false,
                  quadrupole::Bool = false)
    banner("evolution: $label")
    p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)
    eps = mean_interparticle_separation(p, N)
    pos, vel, mass = plummer_ics(N; p = p, seed = 1987)
    cfg = RunConfig(theta = theta, eps = eps, quadrupole = quadrupole,
                    direct = direct)

    times = Float64[]; lagr = Vector{Float64}[]
    Ks = Float64[]; Us = Float64[]; Es = Float64[]
    rcm = Float64[]; vcm = Float64[]; Lz = Float64[]; Lmag = Float64[]
    snaps = Dict{String,Any}()
    wanted = copy(SNAPTIMES)

    function record(step, t, pp, vv, aa)
        K = kinetic_energy(vv, mass)
        U = potential_energy(pp, mass, eps)
        c = com_position(pp, mass)
        cv = com_velocity(vv, mass)
        L = angular_momentum(pp, vv, mass)
        push!(times, t); push!(Ks, K); push!(Us, U); push!(Es, K + U)
        push!(lagr, lagrangian_radii(pp, mass, (0.1, 0.25, 0.5, 0.75, 0.9)))
        push!(rcm, sqrt(sum(abs2, c))); push!(vcm, sqrt(sum(abs2, cv)))
        push!(Lz, L[3]); push!(Lmag, sqrt(sum(abs2, L)))

        if !isempty(wanted) && t >= wanted[1] - 1e-9
            key = @sprintf("%.2f", wanted[1])
            # positions relative to the centre of mass, as the paper plots them
            n = min(size(pp, 2), 4096)
            snaps[key] = Dict(
                "x" => short(pp[1, 1:n] .- c[1], 4),
                "y" => short(pp[2, 1:n] .- c[2], 4),
                "z" => short(pp[3, 1:n] .- c[3], 4))
            popfirst!(wanted)
        end
    end

    t0 = time()
    evolve!(pos, vel, mass, cfg; dt = DT, nsteps = NSTEPS, callback = record,
            every = 5)
    wall = time() - t0
    @printf("  %s: %.1f s wall, E0 = %.6f, E1 = %.6f, dE/E = %.3f%%\n",
            label, wall, Es[1], Es[end], 100 * (Es[end] - Es[1]) / abs(Es[1]))

    return Dict(
        "label" => label, "N" => N, "theta" => theta, "direct" => direct,
        "quadrupole" => quadrupole, "eps" => eps, "dt" => DT, "nsteps" => NSTEPS,
        "wall_seconds" => short(wall),
        "time" => short(times), "K" => short(Ks), "U" => short(Us),
        "E" => short(Es), "virial" => short(-2 .* Ks ./ Us),
        "lagrangian" => [short(l) for l in lagr],
        "lagrangian_fracs" => [0.1, 0.25, 0.5, 0.75, 0.9],
        "r_cm" => short(rcm), "v_cm" => short(vcm),
        "Lz" => short(Lz), "L" => short(Lmag),
        "snapshots" => snaps)
end

results = Dict{String,Any}()
results["theta1.0"]  = run_case("theta = 1.0";  theta = 1.0)
results["theta0.5"]  = run_case("theta = 0.5";  theta = 0.5)
results["theta1.0q"] = run_case("theta = 1.0, quadrupole"; theta = 1.0,
                                quadrupole = true)
results["direct"]    = run_case("direct sum"; theta = 0.0, direct = true)

save_result("evolution", results)
