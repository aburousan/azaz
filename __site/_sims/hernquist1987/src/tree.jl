# The Barnes-Hut octree, with monopole and quadrupole moments.
#
# Nodes live in flat arrays instead of a linked structure of objects, so the
# whole tree is a handful of contiguous vectors. Node 1 is always the root.
# A node is one of three things:
#
#   * empty      -> mass = 0, no children, no particle
#   * a leaf     -> holds exactly one particle, `leafpart[node] > 0`
#   * internal   -> holds 8 children, some of which may be empty
#
# The quadrupole tensor is symmetric and traceless, so six numbers per node are
# stored (xx, xy, xz, yy, yz, zz).

mutable struct Octree
    child::Matrix{Int32}      # 8 x nmax, 0 means "no child"
    leafpart::Vector{Int32}   # particle index for leaves, 0 otherwise
    mass::Vector{Float64}
    com::Matrix{Float64}      # 3 x nmax, centre of mass of the node
    quad::Matrix{Float64}     # 6 x nmax, quadrupole about the node's own COM
    center::Matrix{Float64}   # 3 x nmax, geometric centre of the cell
    size::Vector{Float64}     # full width of the cell
    nnodes::Int
end

function Octree(nmax::Integer)
    Octree(zeros(Int32, 8, nmax), zeros(Int32, nmax), zeros(nmax),
           zeros(3, nmax), zeros(6, nmax), zeros(3, nmax), zeros(nmax), 0)
end

function reset!(t::Octree)
    t.nnodes = 0
    return t
end

function newnode!(t::Octree, cx, cy, cz, size)
    n = t.nnodes + 1
    if n > length(t.mass)
        grow!(t, max(2 * length(t.mass), 1024))
    end
    t.nnodes = n
    @inbounds begin
        for k in 1:8; t.child[k, n] = 0; end
        t.leafpart[n] = 0
        t.mass[n] = 0.0
        for k in 1:3; t.com[k, n] = 0.0; end
        for k in 1:6; t.quad[k, n] = 0.0; end
        t.center[1, n] = cx; t.center[2, n] = cy; t.center[3, n] = cz
        t.size[n] = size
    end
    return n
end

function grow!(t::Octree, nmax::Integer)
    old = length(t.mass)
    t.child = hcat(t.child, zeros(Int32, 8, nmax - old))
    t.leafpart = vcat(t.leafpart, zeros(Int32, nmax - old))
    t.mass = vcat(t.mass, zeros(nmax - old))
    t.com = hcat(t.com, zeros(3, nmax - old))
    t.quad = hcat(t.quad, zeros(6, nmax - old))
    t.center = hcat(t.center, zeros(3, nmax - old))
    t.size = vcat(t.size, zeros(nmax - old))
    return t
end

"Which of the 8 octants of `node` does the point (x, y, z) fall in? 1-based."
@inline function octant(t::Octree, node::Integer, x, y, z)
    @inbounds begin
        o = 1
        x > t.center[1, node] && (o += 1)
        y > t.center[2, node] && (o += 2)
        z > t.center[3, node] && (o += 4)
    end
    return o
end

"Geometric centre of octant `o` of `node`."
@inline function child_center(t::Octree, node::Integer, o::Integer)
    @inbounds begin
        q = 0.25 * t.size[node]
        cx = t.center[1, node] + ((o - 1) & 1 == 1 ? q : -q)
        cy = t.center[2, node] + ((o - 1) & 2 == 2 ? q : -q)
        cz = t.center[3, node] + ((o - 1) & 4 == 4 ? q : -q)
    end
    return cx, cy, cz
end

"""
    build_tree!(t, pos, mass; quadrupole = true)

Insert every particle into the tree and then fill in the multipole moments.
The root cell is the smallest cube containing all the particles.
"""
function build_tree!(t::Octree, pos::AbstractMatrix, mass::AbstractVector;
                     quadrupole::Bool = true)
    N = length(mass)
    reset!(t)

    xmin = minimum(view(pos, 1, :)); xmax = maximum(view(pos, 1, :))
    ymin = minimum(view(pos, 2, :)); ymax = maximum(view(pos, 2, :))
    zmin = minimum(view(pos, 3, :)); zmax = maximum(view(pos, 3, :))
    cx = 0.5 * (xmin + xmax); cy = 0.5 * (ymin + ymax); cz = 0.5 * (zmin + zmax)
    # A hair of padding keeps a particle sitting exactly on a face inside.
    L = max(xmax - xmin, ymax - ymin, zmax - zmin) * 1.0001
    L <= 0 && (L = 1.0)
    newnode!(t, cx, cy, cz, L)

    for i in 1:N
        insert!(t, pos, i)
    end
    fill_moments!(t, pos, mass, 1; quadrupole = quadrupole)
    return t
end

"Push particle `i` down the tree until it lands in an empty cell."
function insert!(t::Octree, pos::AbstractMatrix, i::Integer)
    node = 1
    depth = 0
    x = pos[1, i]; y = pos[2, i]; z = pos[3, i]
    while true
        depth += 1
        depth > 128 && error("tree depth exceeded 128 while inserting particle $i; " *
                             "two particles are probably at identical positions")
        if t.leafpart[node] == 0 && all(t.child[k, node] == 0 for k in 1:8)
            # Empty cell: park the particle here and stop.
            t.leafpart[node] = i
            return
        elseif t.leafpart[node] != 0
            # Occupied leaf: it has to become internal, so the sitting tenant
            # is pushed one level down first.
            j = t.leafpart[node]
            t.leafpart[node] = 0
            oj = octant(t, node, pos[1, j], pos[2, j], pos[3, j])
            ccx, ccy, ccz = child_center(t, node, oj)
            c = newnode!(t, ccx, ccy, ccz, 0.5 * t.size[node])
            t.child[oj, node] = c
            t.leafpart[c] = j
            # ... and now carry on with particle i in the same cell.
        else
            o = octant(t, node, x, y, z)
            if t.child[o, node] == 0
                ccx, ccy, ccz = child_center(t, node, o)
                c = newnode!(t, ccx, ccy, ccz, 0.5 * t.size[node])
                t.child[o, node] = c
                t.leafpart[c] = i
                return
            end
            node = t.child[o, node]
        end
    end
end

"""
    fill_moments!(t, pos, mass, node; quadrupole)

Walk the tree bottom-up and set the mass, centre of mass and quadrupole tensor
of every node. For an internal node the moments follow from its children by the
parallel-axis theorem, Hernquist's eq. (2.5),

    Q = sum_l Q_l + sum_l m_l (3 R_l R_l - R_l^2 1),

where R_l is the offset of subcell l's centre of mass from the parent's.
"""
function fill_moments!(t::Octree, pos::AbstractMatrix, mass::AbstractVector,
                       node::Integer; quadrupole::Bool = true)
    p = t.leafpart[node]
    if p != 0
        # A single particle carries mass and position but no shape.
        t.mass[node] = mass[p]
        for k in 1:3
            t.com[k, node] = pos[k, p]
        end
        for k in 1:6
            t.quad[k, node] = 0.0
        end
        return
    end

    M = 0.0
    cx = cy = cz = 0.0
    for o in 1:8
        c = t.child[o, node]
        c == 0 && continue
        fill_moments!(t, pos, mass, c; quadrupole = quadrupole)
        mc = t.mass[c]
        M += mc
        cx += mc * t.com[1, c]
        cy += mc * t.com[2, c]
        cz += mc * t.com[3, c]
    end
    t.mass[node] = M
    if M > 0
        t.com[1, node] = cx / M
        t.com[2, node] = cy / M
        t.com[3, node] = cz / M
    end

    quadrupole || return
    qxx = qxy = qxz = qyy = qyz = qzz = 0.0
    for o in 1:8
        c = t.child[o, node]
        c == 0 && continue
        mc = t.mass[c]
        mc == 0 && continue
        Rx = t.com[1, c] - t.com[1, node]
        Ry = t.com[2, c] - t.com[2, node]
        Rz = t.com[3, c] - t.com[3, node]
        R2 = Rx * Rx + Ry * Ry + Rz * Rz
        # the child's own shape ...
        qxx += t.quad[1, c]; qxy += t.quad[2, c]; qxz += t.quad[3, c]
        qyy += t.quad[4, c]; qyz += t.quad[5, c]; qzz += t.quad[6, c]
        # ... plus the shape it acquires by sitting off-centre.
        qxx += mc * (3Rx * Rx - R2)
        qxy += mc * (3Rx * Ry)
        qxz += mc * (3Rx * Rz)
        qyy += mc * (3Ry * Ry - R2)
        qyz += mc * (3Ry * Rz)
        qzz += mc * (3Rz * Rz - R2)
    end
    t.quad[1, node] = qxx; t.quad[2, node] = qxy; t.quad[3, node] = qxz
    t.quad[4, node] = qyy; t.quad[5, node] = qyz; t.quad[6, node] = qzz
    return
end

"Is the point (x, y, z) geometrically inside the cell `node`?"
@inline function inside_cell(t::Octree, node::Integer, x, y, z)
    h = 0.5 * t.size[node]
    @inbounds return abs(x - t.center[1, node]) <= h &&
                    abs(y - t.center[2, node]) <= h &&
                    abs(z - t.center[3, node]) <= h
end

"""
    tree_accel(t, pos, i, theta, eps; quadrupole, forced_subdivision, stack)

Acceleration on particle `i` from a walk of the tree. A node is accepted as a
single term when Hernquist's eq. (1.1) is satisfied,

    s / d < theta,

with `s` the width of the cell and `d` the distance from the particle to the
cell's centre of mass; otherwise the walk descends into the children.
`theta = 0` never accepts anything and so reduces to a direct sum.

Returns `(ax, ay, az, nterms)`, where `nterms` counts how many terms went into
the sum -- that is the quantity plotted in Fig. 5 of the paper.

With `forced_subdivision = true` a cell containing the particle itself is always
opened. Without it a particle near the edge of a large cell can satisfy the
opening criterion for its own cell and end up pulling on itself, which is the
spurious self-acceleration the paper warns about for theta >~ 1.
"""
function tree_accel(t::Octree, pos::AbstractMatrix, i::Integer,
                    theta::Float64, eps::Float64;
                    quadrupole::Bool = false,
                    forced_subdivision::Bool = true,
                    stack::Vector{Int32} = Int32[])
    empty!(stack)
    push!(stack, Int32(1))
    ax = ay = az = 0.0
    nterms = 0
    eps2 = eps * eps
    theta2 = theta * theta

    @inbounds while !isempty(stack)
        node = pop!(stack)
        m = t.mass[node]
        m == 0 && continue

        dx = pos[1, i] - t.com[1, node]
        dy = pos[2, i] - t.com[2, node]
        dz = pos[3, i] - t.com[3, node]
        d2 = dx * dx + dy * dy + dz * dz

        p = t.leafpart[node]
        if p != 0
            p == i && continue          # a particle feels no force from itself
            r2 = d2 + eps2
            f = m / (r2 * sqrt(r2))
            ax -= f * dx; ay -= f * dy; az -= f * dz
            nterms += 1
            continue
        end

        s = t.size[node]
        opened = d2 <= 0 || s * s >= theta2 * d2
        if !opened && forced_subdivision
            opened = inside_cell(t, node, pos[1, i], pos[2, i], pos[3, i])
        end
        if opened
            for o in 1:8
                c = t.child[o, node]
                c != 0 && push!(stack, c)
            end
            continue
        end

        # The cell is far enough away: replace it by its multipoles.
        r2 = d2 + eps2
        r = sqrt(r2)
        f = m / (r2 * r)
        ax -= f * dx; ay -= f * dy; az -= f * dz

        if quadrupole
            qxx = t.quad[1, node]; qxy = t.quad[2, node]; qxz = t.quad[3, node]
            qyy = t.quad[4, node]; qyz = t.quad[5, node]; qzz = t.quad[6, node]
            # Q . d
            qdx = qxx * dx + qxy * dy + qxz * dz
            qdy = qxy * dx + qyy * dy + qyz * dz
            qdz = qxz * dx + qyz * dy + qzz * dz
            # d . Q . d
            dQd = dx * qdx + dy * qdy + dz * qdz
            r5 = r2 * r2 * r
            r7 = r5 * r2
            c1 = 1 / r5
            c2 = 2.5 * dQd / r7
            ax += c1 * qdx - c2 * dx
            ay += c1 * qdy - c2 * dy
            az += c1 * qdz - c2 * dz
        end
        nterms += 1
    end
    return ax, ay, az, nterms
end

"""
    tree_forces!(acc, t, pos, mass, theta, eps; kwargs...)

Fill `acc` (3 x N) with the tree accelerations for every particle and return the
mean number of terms per particle. Particles are independent once the tree is
built, so the loop threads trivially.
"""
function tree_forces!(acc::AbstractMatrix, t::Octree, pos::AbstractMatrix,
                      mass::AbstractVector, theta::Float64, eps::Float64;
                      quadrupole::Bool = false,
                      forced_subdivision::Bool = true,
                      nterms::Union{Nothing,Vector{Int}} = nothing)
    N = length(mass)
    counts = zeros(Int, N)
    nchunks = min(Threads.nthreads(), N)
    Threads.@sync for c in 1:nchunks
        Threads.@spawn begin
            # One scratch stack per task, so nothing is shared between threads.
            stack = Int32[]
            sizehint!(stack, 1024)
            for i in c:nchunks:N
                ax, ay, az, nt = tree_accel(t, pos, i, theta, eps;
                                            quadrupole = quadrupole,
                                            forced_subdivision = forced_subdivision,
                                            stack = stack)
                acc[1, i] = ax; acc[2, i] = ay; acc[3, i] = az
                counts[i] = nt
            end
        end
    end
    nterms === nothing || copyto!(nterms, counts)
    return sum(counts) / N
end
