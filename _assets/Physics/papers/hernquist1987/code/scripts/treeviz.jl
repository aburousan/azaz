# A picture of what the tree walk actually does.
#
# Everything here is two-dimensional -- a quadtree instead of an octree -- for
# no reason other than that a 2D picture can be looked at. The logic is
# identical: subdivide until every cell holds at most one particle, then walk
# from the root and accept a cell as a single term whenever s/d < theta.

include(joinpath(@__DIR__, "common.jl"))

const NPTS = 500

# ---------------------------------------------------------------- quadtree ---
mutable struct QCell
    x0::Float64; y0::Float64; s::Float64   # lower-left corner and width
    level::Int
    children::Vector{Int}                  # indices into the cell list, or empty
    part::Int                              # particle index for a leaf, 0 otherwise
    mass::Float64
    comx::Float64; comy::Float64
end

function build_quadtree(px, py, mass)
    lo = min(minimum(px), minimum(py)) - 1e-6
    hi = max(maximum(px), maximum(py)) + 1e-6
    cells = [QCell(lo, lo, hi - lo, 0, Int[], 0, 0.0, 0.0, 0.0)]

    function insert!(ci, i)
        for _ in 1:64
            c = cells[ci]
            if c.part == 0 && isempty(c.children)
                c.part = i
                return
            end
            if c.part != 0                       # split an occupied leaf
                j = c.part
                c.part = 0
                h = c.s / 2
                for (dx, dy) in ((0, 0), (1, 0), (0, 1), (1, 1))
                    push!(cells, QCell(c.x0 + dx * h, c.y0 + dy * h, h,
                                       c.level + 1, Int[], 0, 0.0, 0.0, 0.0))
                    push!(c.children, length(cells))
                end
                insert!(ci, j)
            end
            c = cells[ci]
            k = 1 + (px[i] > c.x0 + c.s / 2) + 2 * (py[i] > c.y0 + c.s / 2)
            ci = c.children[k]
        end
        error("quadtree too deep")
    end

    for i in eachindex(px)
        insert!(1, i)
    end

    function moments!(ci)
        c = cells[ci]
        if c.part != 0
            c.mass = mass[c.part]; c.comx = px[c.part]; c.comy = py[c.part]
            return
        end
        M = 0.0; sx = 0.0; sy = 0.0
        for k in c.children
            moments!(k)
            M += cells[k].mass
            sx += cells[k].mass * cells[k].comx
            sy += cells[k].mass * cells[k].comy
        end
        c.mass = M
        if M > 0
            c.comx = sx / M; c.comy = sy / M
        end
        return
    end
    moments!(1)
    return cells
end

"""
Walk the quadtree for particle `i` and report which cells were swallowed whole
and which particles had to be summed one by one.
"""
function walk(cells, px, py, i, theta)
    accepted = Int[]; singles = Int[]
    stack = [1]
    while !isempty(stack)
        ci = pop!(stack)
        c = cells[ci]
        c.mass == 0 && continue
        if c.part != 0
            c.part == i || push!(singles, c.part)
            continue
        end
        d = sqrt((px[i] - c.comx)^2 + (py[i] - c.comy)^2)
        if d > 0 && c.s / d < theta &&
           !(c.x0 <= px[i] <= c.x0 + c.s && c.y0 <= py[i] <= c.y0 + c.s)
            push!(accepted, ci)
        else
            append!(stack, c.children)
        end
    end
    return accepted, singles
end

# ------------------------------------------------------------------- data ----
p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)
pos3, _, mass = plummer_ics(NPTS; p = p, seed = 4)
px = pos3[1, :]; py = pos3[2, :]

cells = build_quadtree(px, py, mass)
@printf("%d points -> %d cells, deepest level %d\n",
        NPTS, length(cells), maximum(c.level for c in cells))

# A target particle out in the halo, where the tree does the most work.
r = sqrt.(px .^ 2 .+ py .^ 2)
target = findmin(abs.(r .- 0.45))[2]
@printf("target particle %d at (%.3f, %.3f), r = %.3f\n",
        target, px[target], py[target], r[target])

allcells = [Dict("x0" => short(c.x0, 5), "y0" => short(c.y0, 5),
                 "s" => short(c.s, 5), "level" => c.level,
                 "leaf" => c.part != 0) for c in cells if c.mass > 0]

THETAS = [0.2, 0.3, 0.4, 0.5, 0.6, 0.8, 1.0, 1.2, 1.5]
walks = Any[]
for th in THETAS
    acc, sing = walk(cells, px, py, target, th)
    @printf("  theta = %.1f -> %3d cells + %3d single particles = %3d terms\n",
            th, length(acc), length(sing), length(acc) + length(sing))
    push!(walks, Dict(
        "theta" => th,
        "nterms" => length(acc) + length(sing),
        "ncells" => length(acc), "nsingles" => length(sing),
        "cells" => [Dict("x0" => short(cells[k].x0, 5),
                         "y0" => short(cells[k].y0, 5),
                         "s" => short(cells[k].s, 5),
                         "comx" => short(cells[k].comx, 5),
                         "comy" => short(cells[k].comy, 5)) for k in acc],
        "singles" => sing))
end

save_result("treeviz", Dict(
    "x" => short(px, 5), "y" => short(py, 5),
    "target" => target, "cells" => allcells, "thetas" => THETAS,
    "walks" => walks, "N" => NPTS))
