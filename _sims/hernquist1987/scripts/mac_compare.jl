# Worst-case force errors, and what a safer opening criterion buys.
#
# The Barnes-Hut criterion compares the WIDTH of a cell with the distance to its
# centre of mass. The quantity that actually controls the Legendre expansion is
# the distance of the furthest PARTICLE of the cell from that same centre of
# mass. The two are not the same, and Salmon and Warren (1994) showed that the
# gap between them lets the worst-case error go unbounded once theta > 1/sqrt(3).
#
# Three acceptance tests are compared here, all with the same tree:
#
#   BH        s/d < theta                     (the 1987 criterion)
#   OFFSET    d > s/theta + |com - centre|    (allow for the shifted centre)
#   BMAX      bmax/d < theta                  (bmax = distance from the centre of
#                                              mass to the furthest particle)
#
# For each one we record the whole distribution of the per-particle relative
# error, not only its mean, because the mean is exactly what hides this problem.

include(joinpath(@__DIR__, "common.jl"))
using LinearAlgebra

const N      = QUICK ? 4096 : 32768
# a wide grid, because the three criteria are not equally strict at the same
# theta: they must be compared at matched cost, not at matched theta
const THETAS = QUICK ? [0.5, 1.0] :
    [0.1, 0.125, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.2]
const SEED   = 1987
const EPS    = 0.0
const T      = TreeCodeH87

include(joinpath(@__DIR__, "mac_lib.jl"))

pos, vel, mass = plummer_ics(N; seed = SEED)
adir = zeros(3, N)
direct_forces!(adir, pos, mass, EPS)
amag = [sqrt(adir[1,j]^2 + adir[2,j]^2 + adir[3,j]^2) for j in 1:N]

pct(v, q) = sort(v)[clamp(ceil(Int, q * length(v)), 1, length(v))]

# the relative test's parameter is a tolerance, not an angle, so it needs its
# own range of values
grid(mac) = mac === :relative ?
    (QUICK ? [1e-3, 1e-2] : [3e-6, 1e-5, 3e-5, 1e-4, 3e-4, 1e-3, 3e-3, 1e-2, 3e-2]) :
    THETAS

rows = Any[]
for quad in (false, true), mac in (:bh, :offset, :bmax, :relative)
    tree = Octree(8N)
    build_tree!(tree, pos, mass; quadrupole = quad)
    bmax = cell_bmax(tree); off = cell_offset(tree)
    banner("$(quad ? "quadrupole" : "monopole"), MAC = $mac")
    for th in grid(mac)
        errs = zeros(N); nt = zeros(N)
        Threads.@threads for i in 1:N
            ax, ay, az, n = walk_mac(tree, pos, i, th, mac, bmax, off;
                                     quadrupole = quad, aref = amag[i])
            errs[i] = sqrt((ax-adir[1,i])^2 + (ay-adir[2,i])^2 + (az-adir[3,i])^2) / amag[i]
            nt[i] = n
        end
        rec = (; order = quad ? "quadrupole" : "monopole", mac = String(mac),
               theta = th, nterms = short(mean(nt)),
               mean = short(mean(errs)), rms = short(sqrt(mean(errs .^ 2))),
               p95 = short(pct(errs, 0.95)), p99 = short(pct(errs, 0.99)),
               p999 = short(pct(errs, 0.999)), max = short(maximum(errs)),
               cdf = short(sort(errs)[round.(Int, range(1, N, length = 60))]))
        push!(rows, rec)
        @printf("  theta=%.2f  <n>=%7.1f  mean %.2e  rms %.2e  p99 %.2e  max %.2e\n",
                th, mean(nt), rec.mean, rec.rms, rec.p99, rec.max)
    end
end

save_result("mac_compare", (; N, seed = SEED, eps = EPS, thetas = THETAS, rows,
                            cdf_q = short(collect(range(0, 1, length = 60)))))
