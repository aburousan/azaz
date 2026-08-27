# Where does the tree's force error actually come from?
#
# The single-cell test in part 3 says one accepted cell is wrong by (s/d)^k,
# with k = 2, 3, 4 for monopole, quadrupole, octupole. But the error of the
# *whole walk* measured against theta comes out roughly one power steeper,
# theta^(k+1). Something in the way the errors of the individual cells add up is
# not captured by the single-cell law.
#
# So take one particle, and instead of only the total, record every accepted
# cell separately: its multipole contribution, the exact contribution from the
# particles it contains, and the difference between them. That gives
#
#   * the coherence  kappa = |sum of the cell errors| / sqrt(sum of |cell error|^2)
#     kappa ~ 1 means the cell errors point in random directions and add in
#     quadrature; kappa ~ sqrt(n_cells) means they conspire.
#   * which cells carry the error, as a function of s/d.
#
# Nothing here is approximated: summing the exact contributions of the accepted
# cells reproduces the direct sum exactly, because the accepted cells partition
# the particles.

include(joinpath(@__DIR__, "common.jl"))

const N       = QUICK ? 4096 : 32768
const THETAS  = QUICK ? [0.5, 1.0] : [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 1.0]
const NTARGET = QUICK ? 32 : 256
const SEED    = 1987
const EPS     = 0.0

const T = TreeCodeH87

inside_cell(t, node, x, y, z) = begin
    h = 0.5 * t.size[node]
    abs(x - t.center[1, node]) <= h && abs(y - t.center[2, node]) <= h &&
        abs(z - t.center[3, node]) <= h
end

"Every particle index sitting anywhere below `node`."
function gather!(out::Vector{Int}, t, node::Integer)
    p = t.leafpart[node]
    if p != 0
        push!(out, Int(p)); return out
    end
    for o in 1:8
        c = t.child[o, node]
        c != 0 && t.mass[c] > 0 && gather!(out, t, c)
    end
    return out
end

"""
Walk the tree for particle `i` and return, for every cell that was *accepted*
(so not resolved into single particles), the multipole acceleration it
contributed, the exact acceleration its particles produce, and s/d.
"""
function dissect(t, pos, mass, i, theta, eps; quadrupole, octupole)
    eps2 = eps * eps; theta2 = theta * theta
    stack = Int32[1]
    # exact part that came from cells resolved down to single particles
    ex = ey = ez = 0.0
    cells = NamedTuple[]
    buf = Int[]

    while !isempty(stack)
        node = pop!(stack)
        m = t.mass[node]
        m == 0 && continue

        dx = pos[1, i] - t.com[1, node]
        dy = pos[2, i] - t.com[2, node]
        dz = pos[3, i] - t.com[3, node]
        d2 = dx*dx + dy*dy + dz*dz

        p = t.leafpart[node]
        if p != 0
            p == i && continue
            r2 = d2 + eps2
            f = m / (r2 * sqrt(r2))
            ex -= f*dx; ey -= f*dy; ez -= f*dz     # a leaf is exact by definition
            continue
        end

        s = t.size[node]
        opened = d2 <= 0 || s*s >= theta2 * d2
        opened || (opened = inside_cell(t, node, pos[1,i], pos[2,i], pos[3,i]))
        if opened
            for o in 1:8
                c = t.child[o, node]
                c != 0 && push!(stack, c)
            end
            continue
        end

        # --- accepted: what the tree uses ---
        r2 = d2 + eps2; r = sqrt(r2); f = m / (r2 * r)
        ax = -f*dx; ay = -f*dy; az = -f*dz
        if quadrupole
            qxx = t.quad[1,node]; qxy = t.quad[2,node]; qxz = t.quad[3,node]
            qyy = t.quad[4,node]; qyz = t.quad[5,node]; qzz = t.quad[6,node]
            qdx = qxx*dx + qxy*dy + qxz*dz
            qdy = qxy*dx + qyy*dy + qyz*dz
            qdz = qxz*dx + qyz*dy + qzz*dz
            dQd = dx*qdx + dy*qdy + dz*qdz
            r5 = r2*r2*r; r7 = r5*r2
            c1 = 1/r5; c2 = 2.5*dQd/r7
            ax += c1*qdx - c2*dx; ay += c1*qdy - c2*dy; az += c1*qdz - c2*dz
        end
        if octupole
            ox, oy, oz = octupole_accel(t, node, dx, dy, dz, d2, r2)
            ax += ox; ay += oy; az += oz
        end

        # --- accepted: what it should have been ---
        empty!(buf); gather!(buf, t, node)
        tx = ty = tz = 0.0
        for j in buf
            ddx = pos[1,i] - pos[1,j]; ddy = pos[2,i] - pos[2,j]; ddz = pos[3,i] - pos[3,j]
            rr2 = ddx*ddx + ddy*ddy + ddz*ddz + eps2
            g = mass[j] / (rr2 * sqrt(rr2))
            tx -= g*ddx; ty -= g*ddy; tz -= g*ddz
        end

        push!(cells, (; s_over_d = s / sqrt(d2), mass = m, npart = length(buf),
                      ax, ay, az, tx, ty, tz,
                      ex_ = ax - tx, ey_ = ay - ty, ez_ = az - tz))
    end
    return cells, (ex, ey, ez)
end

rng = MersenneTwister(20260822)
pos, vel, mass = plummer_ics(N; seed = SEED)
targets = randperm(rng, N)[1:NTARGET]

adir = zeros(3, N)
direct_forces!(adir, pos, mass, EPS)

# s/d bins for "which cells carry the error"
const EDGES = collect(range(0.0, 1.0; length = 21))

out = Any[]
for (label, quad, oct, k) in (("monopole", false, false, 2),
                              ("quadrupole", true, false, 3),
                              ("octupole", true, true, 4))
    tree = Octree(8N)
    build_tree!(tree, pos, mass; quadrupole = quad, octupole = oct)
    banner("$label  (single-cell law: error per cell ~ (s/d)^$k)")

    for th in THETAS
        κs = Float64[]; ncell = Float64[]
        tot_err = Float64[]; quad_sum = Float64[]; abs_sum = Float64[]
        amag = Float64[]
        binned = zeros(length(EDGES) - 1)      # sum of |cell error|^2 per s/d bin
        binnedn = zeros(length(EDGES) - 1)
        worst_frac = Float64[]

        for i in targets
            cells, (ex, ey, ez) = dissect(tree, pos, mass, i, th, EPS;
                                          quadrupole = quad, octupole = oct)
            isempty(cells) && continue
            sx = sum(c.ex_ for c in cells); sy = sum(c.ey_ for c in cells)
            sz = sum(c.ez_ for c in cells)
            q  = sum(c.ex_^2 + c.ey_^2 + c.ez_^2 for c in cells)
            a1 = sum(sqrt(c.ex_^2 + c.ey_^2 + c.ez_^2) for c in cells)
            etot = sqrt(sx^2 + sy^2 + sz^2)
            aex = sqrt(adir[1,i]^2 + adir[2,i]^2 + adir[3,i]^2)

            push!(κs, etot / sqrt(q)); push!(ncell, length(cells))
            push!(tot_err, etot); push!(quad_sum, sqrt(q)); push!(abs_sum, a1)
            push!(amag, aex)

            # error carried by the cells closest to the acceptance boundary
            top = sum(sqrt(c.ex_^2 + c.ey_^2 + c.ez_^2)
                      for c in cells if c.s_over_d > 0.8 * th; init = 0.0)
            push!(worst_frac, top / max(a1, eps()))

            for c in cells
                b = searchsortedlast(EDGES, c.s_over_d / th)
                1 <= b <= length(binned) || continue
                binned[b] += c.ex_^2 + c.ey_^2 + c.ez_^2
                binnedn[b] += 1
            end
        end

        rec = (; order = label, k, theta = th,
               kappa = short(mean(κs)), kappa_sd = short(std(κs)),
               ncells = short(mean(ncell)),
               sqrt_ncells = short(sqrt(mean(ncell))),
               rel_error = short(mean(tot_err ./ amag)),
               rel_quadrature = short(mean(quad_sum ./ amag)),
               rel_abssum = short(mean(abs_sum ./ amag)),
               frac_from_boundary = short(mean(worst_frac)),
               bin_edges = short(EDGES), bin_err2 = short(binned ./ max(sum(binned), eps())),
               bin_count = binnedn)
        push!(out, rec)
        @printf("  theta=%.2f  <n_cells>=%6.0f  kappa=%.3f (sqrt n = %.1f)  |err|/a=%.3e  frac from s/d>0.8theta = %.2f\n",
                th, mean(ncell), mean(κs), sqrt(mean(ncell)),
                mean(tot_err ./ amag), mean(worst_frac))
    end
end

save_result("error_anatomy", (; N, seed = SEED, ntarget = NTARGET, eps = EPS, rows = out))
