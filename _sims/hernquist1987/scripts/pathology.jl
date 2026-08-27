# The configuration Salmon and Warren warn about, built on purpose.
#
# A heavy extended primary sits at the origin. A small, compact, self-bound
# satellite sits far out, straddling a cell boundary of the tree. When the force
# on a satellite particle on one side of that boundary is computed, the cell
# holding the other half of the satellite can pass the Barnes-Hut test, because
# the test only asks whether the CELL is narrow as seen from the particle. The
# satellite then loses part of its own self-gravity.
#
# Three acceptance tests are compared on exactly the same particles.

include(joinpath(@__DIR__, "common.jl"))
using LinearAlgebra

const NPRIM  = QUICK ? 2000 : 20000
const NSAT   = QUICK ?  500 :  4000
const MSAT   = 0.05                 # satellite mass, primary has 1
const RSAT   = 0.05                 # satellite scale
const THETAS = [0.3, 0.5, 0.577, 0.7, 1.0]
const EPS    = 0.0
const T      = TreeCodeH87

include(joinpath(@__DIR__, "mac_lib.jl"))

"Primary plus a compact satellite whose centre sits exactly on a cell face."
function build_system(xsat)
    p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)
    pp, _, mp = plummer_ics(NPRIM; p = p, seed = 11)
    ps = Plummer(M = MSAT, r0 = RSAT, R = 4RSAT)
    qq, _, ms = plummer_ics(NSAT; p = ps, seed = 22)
    qq[1, :] .+= xsat[1]; qq[2, :] .+= xsat[2]; qq[3, :] .+= xsat[3]
    hcat(pp, qq), vcat(mp, ms)
end

banner("sliding a compact satellite across a cell boundary")

# The pathology needs a cell holding the heavy primary AND part of the
# satellite, with that cell's centre of mass dragged away towards the primary.
# We do not try to arrange it by hand: we slide the satellite along a line, which
# is what happens anyway in a real simulation, and watch each criterion.
#
# The direct sum is computed once per position and reused by every criterion, so
# all of them are judged against exactly the same exact answer.

const NSTEP  = QUICK ? 7 : 41
const THGRID = QUICK ? [0.7] : [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.9, 1.1, 1.3]

pct(v, q) = isempty(v) ? NaN : sort(v)[clamp(ceil(Int, q * length(v)), 1, length(v))]

pos0, mass0 = build_system([0.0, 0.4, 0.0])
lo = minimum(pos0, dims = 2); hi = maximum(pos0, dims = 2)
L0 = maximum(hi .- lo)
@printf("reference root side %.4f, %d positions, %d values of theta\n",
        L0, NSTEP, length(THGRID))

rows = Any[]
xs = collect(range(-0.35L0, 0.35L0, length = NSTEP))
for (ix, x) in enumerate(xs)
    pos, mass = build_system([x, 0.28L0, 0.0])
    issat = vcat(falses(NPRIM), trues(NSAT))
    N = length(mass)
    adir = zeros(3, N)
    direct_forces!(adir, pos, mass, EPS)
    amag = [sqrt(adir[1,j]^2 + adir[2,j]^2 + adir[3,j]^2) for j in 1:N]
    tree = Octree(8N)
    build_tree!(tree, pos, mass; quadrupole = true)
    bmax = cell_bmax(tree); off = cell_offset(tree)
    for mac in (:bh, :offset, :bmax, :relative),
        th in (mac === :relative ?
               (QUICK ? [1e-3] : [1e-5, 3e-5, 1e-4, 3e-4, 1e-3, 3e-3, 1e-2]) : THGRID)
        errs = zeros(N); nt = zeros(N)
        Threads.@threads for i in 1:N
            ax, ay, az, n = walk_mac(tree, pos, i, th, mac, bmax, off;
                                     quadrupole = true, aref = amag[i])
            errs[i] = sqrt((ax-adir[1,i])^2 + (ay-adir[2,i])^2 + (az-adir[3,i])^2) / amag[i]
            nt[i] = n
        end
        se = errs[issat]
        push!(rows, (; mac = String(mac), theta = th, x = short(x),
                     nterms = short(mean(nt)),
                     sat_mean = short(mean(se)), sat_p99 = short(pct(se, 0.99)),
                     sat_max = short(maximum(se)),
                     sat_frac20 = short(count(>(0.2), se) / length(se)),
                     all_mean = short(mean(errs)), all_max = short(maximum(errs))))
    end
    @printf("  position %2d/%d done (x = %+8.4f)\n", ix, NSTEP, x)
end

save_result("pathology", (; NPRIM, NSAT, MSAT, RSAT, eps = EPS, rows,
                          thetas = THGRID, xs = short(xs), root_side = short(L0)))
