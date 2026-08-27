# One frozen picture of the failure that Salmon and Warren describe.
#
# scripts/pathology.jl slides a compact satellite across the cells of the tree
# and reports how bad the worst satellite particle gets. That is a curve. This
# script stops at the worst position, finds the particle that suffers most, and
# records which single accepted cell did the damage, together with the particles
# sitting inside that cell. The result is a picture of the mechanism rather than
# a number.

include(joinpath(@__DIR__, "common.jl"))
using LinearAlgebra

const NPRIM = QUICK ? 2000 : 20000
const NSAT  = QUICK ?  500 :  4000
const MSAT  = 0.05
const RSAT  = 0.05
const EPS   = 0.0
const THETA = 1.3

include(joinpath(@__DIR__, "mac_lib.jl"))

function build_system(xsat)
    p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)
    pp, _, mp = plummer_ics(NPRIM; p = p, seed = 11)
    ps = Plummer(M = MSAT, r0 = RSAT, R = 4RSAT)
    qq, _, ms = plummer_ics(NSAT; p = ps, seed = 22)
    qq[1, :] .+= xsat[1]; qq[2, :] .+= xsat[2]; qq[3, :] .+= xsat[3]
    hcat(pp, qq), vcat(mp, ms)
end

"Every particle sitting inside a cell, found by descending to the leaves."
function cell_particles(t, node)
    out = Int[]
    stack = Int[node]
    while !isempty(stack)
        n = pop!(stack)
        t.mass[n] == 0 && continue
        p = t.leafpart[n]
        if p != 0
            push!(out, p)
        else
            for o in 1:8
                c = t.child[o, n]
                c != 0 && push!(stack, c)
            end
        end
    end
    out
end

"The Barnes-Hut walk again, this time keeping the list of accepted cells."
function walk_record(t, pos, i, theta)
    stack = Int32[1]
    acc = Int[]
    while !isempty(stack)
        node = pop!(stack)
        t.mass[node] == 0 && continue
        dx = pos[1, i] - t.com[1, node]
        dy = pos[2, i] - t.com[2, node]
        dz = pos[3, i] - t.com[3, node]
        d = sqrt(dx*dx + dy*dy + dz*dz)
        p = t.leafpart[node]
        if p != 0
            p == i || push!(acc, node)
            continue
        end
        if t.size[node] < theta * d &&
           !inside_cell(t, node, pos[1, i], pos[2, i], pos[3, i])
            push!(acc, node)
        else
            for o in 1:8
                c = t.child[o, node]
                c != 0 && push!(stack, c)
            end
        end
    end
    acc
end

"Monopole plus quadrupole acceleration of one cell on one particle."
function cell_accel(t, pos, i, node)
    dx = pos[1, i] - t.com[1, node]
    dy = pos[2, i] - t.com[2, node]
    dz = pos[3, i] - t.com[3, node]
    r2 = dx*dx + dy*dy + dz*dz
    r = sqrt(r2)
    f = t.mass[node] / (r2 * r)
    ax = -f*dx; ay = -f*dy; az = -f*dz
    if t.leafpart[node] == 0
        qxx = t.quad[1,node]; qxy = t.quad[2,node]; qxz = t.quad[3,node]
        qyy = t.quad[4,node]; qyz = t.quad[5,node]; qzz = t.quad[6,node]
        qdx = qxx*dx + qxy*dy + qxz*dz
        qdy = qxy*dx + qyy*dy + qyz*dz
        qdz = qxz*dx + qyz*dy + qzz*dz
        dQd = dx*qdx + dy*qdy + dz*qdz
        r5 = r2*r2*r; r7 = r5*r2
        ax += qdx/r5 - 2.5*dQd*dx/r7
        ay += qdy/r5 - 2.5*dQd*dy/r7
        az += qdz/r5 - 2.5*dQd*dz/r7
    end
    (ax, ay, az)
end

"Exact acceleration on particle i from the particles of one cell."
function exact_accel(pos, mass, i, plist)
    ax = ay = az = 0.0
    for j in plist
        j == i && continue
        dx = pos[1, i] - pos[1, j]
        dy = pos[2, i] - pos[2, j]
        dz = pos[3, i] - pos[3, j]
        r2 = dx*dx + dy*dy + dz*dz
        f = mass[j] / (r2 * sqrt(r2))
        ax -= f*dx; ay -= f*dy; az -= f*dz
    end
    (ax, ay, az)
end

banner("one frozen picture of a detonating satellite")

pos0, _ = build_system([0.0, 0.4, 0.0])
lo = minimum(pos0, dims = 2); hi = maximum(pos0, dims = 2)
const L0 = maximum(hi .- lo)

# Slide the satellite as pathology.jl does, and keep the position where the
# worst satellite particle is worst.
xs = collect(range(-0.35L0, 0.35L0, length = QUICK ? 7 : 41))
best = (worst = -1.0, x = 0.0)
for x in xs
    pos, mass = build_system([x, 0.28L0, 0.0])
    N = length(mass)
    adir = zeros(3, N)
    direct_forces!(adir, pos, mass, EPS)
    tree = Octree(8N)
    build_tree!(tree, pos, mass; quadrupole = true)
    bmax = cell_bmax(tree); off = cell_offset(tree)
    worst = 0.0
    Threads.@threads for i in (NPRIM+1):N
        ax, ay, az, _ = walk_mac(tree, pos, i, THETA, :bh, bmax, off;
                                 quadrupole = true)
        am = sqrt(adir[1,i]^2 + adir[2,i]^2 + adir[3,i]^2)
        e = sqrt((ax-adir[1,i])^2 + (ay-adir[2,i])^2 + (az-adir[3,i])^2) / am
        e > worst && (worst = e)
    end
    worst > best.worst && (global best = (worst = worst, x = x))
    @printf("  x = %+8.4f   worst satellite error %7.3f%%\n", x, 100worst)
end
@printf("\nworst position x = %.5f, worst error %.1f%%\n", best.x, 100best.worst)

# Rebuild that one configuration and take it apart.
pos, mass = build_system([best.x, 0.28L0, 0.0])
N = length(mass)
adir = zeros(3, N)
direct_forces!(adir, pos, mass, EPS)
tree = Octree(8N)
build_tree!(tree, pos, mass; quadrupole = true)
bmax = cell_bmax(tree); off = cell_offset(tree)

errs = zeros(N)
Threads.@threads for i in 1:N
    ax, ay, az, _ = walk_mac(tree, pos, i, THETA, :bh, bmax, off; quadrupole = true)
    am = sqrt(adir[1,i]^2 + adir[2,i]^2 + adir[3,i]^2)
    errs[i] = sqrt((ax-adir[1,i])^2 + (ay-adir[2,i])^2 + (az-adir[3,i])^2) / am
end
itgt = argmax(view(errs, (NPRIM+1):N)) + NPRIM
@printf("worst particle %d, error %.1f%%, at (%.4f, %.4f, %.4f)\n",
        itgt, 100errs[itgt], pos[1,itgt], pos[2,itgt], pos[3,itgt])

# Which single accepted cell hurt it most?
acc = walk_record(tree, pos, itgt, THETA)
amag = sqrt(adir[1,itgt]^2 + adir[2,itgt]^2 + adir[3,itgt]^2)
worstnode = 0; worstdiff = -1.0
for node in acc
    tree.leafpart[node] == 0 || continue
    plist = cell_particles(tree, node)
    ap = cell_accel(tree, pos, itgt, node)
    ae = exact_accel(pos, mass, itgt, plist)
    dfm = hypot(ap[1]-ae[1], ap[2]-ae[2], ap[3]-ae[3])
    if dfm > worstdiff
        global worstdiff = dfm; global worstnode = node
    end
end
plist = cell_particles(tree, worstnode)
nsat_in = count(>(NPRIM), plist)
@printf("worst cell %d: side %.4f, %d particles of which %d are satellite, ",
        worstnode, tree.size[worstnode], length(plist), nsat_in)
@printf("its error alone is %.1f%% of the true force\n", 100worstdiff / amag)

# Keep the picture small: all of the satellite, a sample of the primary.
satidx = collect((NPRIM+1):N)
primidx = collect(1:20:NPRIM)

save_result("detonate_snapshot", (;
    theta = THETA, x = short(best.x), root_side = short(L0),
    NPRIM, NSAT, target = itgt - NPRIM,
    target_err = short(errs[itgt]),
    sat_x = short(pos[1, satidx]), sat_y = short(pos[2, satidx]),
    sat_z = short(pos[3, satidx]), sat_err = short(errs[satidx]),
    prim_x = short(pos[1, primidx]), prim_y = short(pos[2, primidx]),
    cell_x0 = short(tree.center[1, worstnode] - 0.5tree.size[worstnode]),
    cell_y0 = short(tree.center[2, worstnode] - 0.5tree.size[worstnode]),
    cell_s = short(tree.size[worstnode]),
    cell_comx = short(tree.com[1, worstnode]), cell_comy = short(tree.com[2, worstnode]),
    cell_mass = short(tree.mass[worstnode]),
    cell_nsat = nsat_in, cell_npart = length(plist),
    cell_err_frac = short(worstdiff / amag),
    inx = short(pos[1, plist]), iny = short(pos[2, plist]),
    insat = [p > NPRIM for p in plist]))
