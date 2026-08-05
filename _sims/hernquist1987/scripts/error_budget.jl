# Where does the energy error actually come from?
#
# Three knobs control the accuracy of an N-body run: the time step, the opening
# angle, and the softening. They are usually discussed separately, but they are
# not independent -- and if one of them dominates, tightening the others is
# wasted effort.
#
# The experiment: shrink dt at fixed theta and watch what happens. With exact
# forces the energy error must keep falling as dt^2 forever. With a tree it can
# only fall until it hits the floor set by the force approximation, and then it
# stops. Locating that floor for each theta tells you exactly how much time
# resolution your force accuracy is worth.

include(joinpath(@__DIR__, "common.jl"))

const N = QUICK ? 1024 : 4096
const TEND = QUICK ? 5.0 : 12.5
const DTS = QUICK ? [0.02, 0.01] :
    [0.04, 0.02, 0.01, 0.005, 0.0025, 0.00125]

p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)
eps = mean_interparticle_separation(p, N)
@printf("N = %d, eps = %.5f, integrating to t = %.1f\n\n", N, eps, TEND)

cases = [("direct", RunConfig(theta = 0.0, eps = eps, direct = true)),
         ("theta=0.3", RunConfig(theta = 0.3, eps = eps)),
         ("theta=0.5", RunConfig(theta = 0.5, eps = eps)),
         ("theta=0.7", RunConfig(theta = 0.7, eps = eps)),
         ("theta=1.0", RunConfig(theta = 1.0, eps = eps))]

rows = Any[]
for (label, cfg) in cases
    errs = Float64[]
    println(label)
    for dt in DTS
        pos, vel, mass = plummer_ics(N; p = p, seed = 1987)
        E0 = kinetic_energy(vel, mass) + potential_energy(pos, mass, eps)
        worst = 0.0
        watch = (s, t, pp, vv, aa) -> begin
            E = kinetic_energy(vv, mass) + potential_energy(pp, mass, eps)
            worst = max(worst, abs((E - E0) / E0))
        end
        evolve!(pos, vel, mass, cfg; dt = dt, nsteps = round(Int, TEND / dt),
                callback = watch, every = 5)
        push!(errs, worst)
        ratio = length(errs) < 2 ? NaN : errs[end-1] / errs[end]
        @printf("   dt = %.5f   max|dE/E| = %.4e   gain on halving dt = %.2f\n",
                dt, worst, ratio)
    end
    push!(rows, Dict("label" => label, "dt" => DTS, "error" => short(errs)))
    println()
end

save_result("error_budget", Dict("N" => N, "eps" => short(eps), "tend" => TEND,
                                 "curves" => rows))
