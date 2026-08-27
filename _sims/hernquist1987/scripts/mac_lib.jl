# Shared by scripts/mac_compare.jl and scripts/pathology.jl.
using LinearAlgebra

inside_cell(t, node, x, y, z) = begin
    h = 0.5 * t.size[node]
    abs(x - t.center[1, node]) <= h && abs(y - t.center[2, node]) <= h &&
        abs(z - t.center[3, node]) <= h
end

"""
    cell_bmax(tree)

For every cell, the distance from its centre of mass to the furthest particle
inside it. Built by recursion: a parent's bound is the largest of
|child centre of mass - parent centre of mass| + child bound.
"""
function cell_bmax(t)
    b = zeros(t.nnodes)
    function walk(node)
        p = t.leafpart[node]
        p != 0 && return 0.0            # a leaf is its own centre of mass
        m = 0.0
        for o in 1:8
            c = t.child[o, node]
            (c == 0 || t.mass[c] == 0) && continue
            bc = walk(c)
            R = hypot(t.com[1, c] - t.com[1, node], t.com[2, c] - t.com[2, node],
                      t.com[3, c] - t.com[3, node])
            m = max(m, R + bc)
        end
        b[node] = m
        return m
    end
    walk(1)
    return b
end

"Distance from a cell's centre of mass to its geometric centre."
function cell_offset(t)
    d = zeros(t.nnodes)
    for n in 1:t.nnodes
        t.mass[n] == 0 && continue
        d[n] = hypot(t.com[1, n] - t.center[1, n], t.com[2, n] - t.center[2, n],
                     t.com[3, n] - t.center[3, n])
    end
    d
end

"""
    walk_mac(t, pos, i, theta, mac, bmax, off; quadrupole, aref)

One walk, with the acceptance test chosen by `mac`:

  :bh        s/d < theta                  the 1987 geometric test
  :offset    d > s/theta + |com-centre|   allow for a lopsided cell
  :bmax      bmax/d < theta               the honest expansion parameter
  :relative  G M s^2 / d^4 < theta * aref an estimate of the error the
                                          acceptance would actually commit

The last one needs a reference acceleration `aref` for the target particle,
which in a real run is simply the value from the previous step. Here it comes
from one cheap preliminary walk.
"""
function walk_mac(t, pos, i, theta, mac, bmax, off; quadrupole, aref = 1.0)
    stack = Int32[1]
    ax = ay = az = 0.0
    nterms = 0
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
            f = m / (d2 * sqrt(d2))
            ax -= f*dx; ay -= f*dy; az -= f*dz
            nterms += 1
            continue
        end
        s = t.size[node]
        d = sqrt(d2)
        ok = if mac === :bh
            s < theta * d
        elseif mac === :offset
            d > s / theta + off[node]
        elseif mac === :bmax
            bmax[node] < theta * d
        else
            # the size of the term we would be throwing away, against a
            # tolerance times the size of the acceleration itself
            m * s * s / (d2 * d2) < theta * aref
        end
        ok &= !inside_cell(t, node, pos[1, i], pos[2, i], pos[3, i])
        if !ok
            for o in 1:8
                c = t.child[o, node]
                c != 0 && push!(stack, c)
            end
            continue
        end
        r = d; r2 = d2
        f = m / (r2 * r)
        ax -= f*dx; ay -= f*dy; az -= f*dz
        if quadrupole
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
        nterms += 1
    end
    return ax, ay, az, nterms
end

