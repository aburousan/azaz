# Data for the animated explainers.
#
# These do not measure anything new. They are re-runs of things that already
# appear on the pages as static plots, recorded frame by frame so a reader can
# watch the mechanism happen instead of reading a description of it.

include(joinpath(@__DIR__, "common.jl"))

banner("animations")

# ============================================================ 1. the sampler ===
# Rejection sampling, one dart at a time. The reader has already been told the
# recipe (throw into the box, keep what lands under the curve); this records an
# actual run of it so the box and the two outcomes are visible.

const NDARTS = 900

g(q) = q^2 * (1 - q^2)^3.5
const GBOX = 0.1                       # the bound the sampler actually uses

let rng = Random.MersenneTwister(11)
    qs = Float64[]; ys = Float64[]; keep = Bool[]
    for _ in 1:NDARTS
        q = rand(rng); y = GBOX * rand(rng)
        push!(qs, q); push!(ys, y); push!(keep, y <= g(q))
    end
    acc = count(keep) / NDARTS
    @printf("darts: %d thrown, %d kept, acceptance %.1f%% (exact 7pi/512 / 0.1 = %.1f%%)\n",
            NDARTS, count(keep), 100acc, 100 * (7pi / 512) / GBOX)

    # The curve itself, and the histogram the kept darts build up.
    qgrid = collect(range(0, 1, length = 201))
    edges = collect(range(0, 1, length = 26))
    centres = (edges[1:end-1] .+ edges[2:end]) ./ 2

    "Counts of the first n kept darts, scaled to sit under the curve."
    function hist_upto(n)
        h = zeros(Int, length(centres))
        for i in 1:n
            keep[i] || continue
            k = min(length(centres), 1 + floor(Int, qs[i] / (edges[2] - edges[1])))
            h[k] += 1
        end
        tot = sum(h)
        tot == 0 && return zeros(length(centres))
        # Normalise to the same area as g so the two are directly comparable.
        area_g = sum(g.(qgrid)) * (qgrid[2] - qgrid[1])
        return h .* (area_g / (tot * (edges[2] - edges[1])))
    end

    steps = [30, 60, 100, 150, 220, 300, 400, 500, 650, 800, NDARTS]
    save_result("anim_sampler", Dict(
        "q" => short(qs, 5), "y" => short(ys, 5), "keep" => keep,
        "qgrid" => short(qgrid, 5), "g" => short(g.(qgrid), 5),
        "gbox" => GBOX, "centres" => short(centres, 5),
        "steps" => steps,
        "hists" => [short(hist_upto(n), 5) for n in steps],
        "kept_upto" => [count(keep[1:n]) for n in steps],
        "acceptance" => short(acc, 4)))
end

# ============================================================ 2. tree build ====
# The quadtree from treeviz.jl, but recorded after each particle goes in, so the
# subdivision can be watched happening rather than inspected after the fact.

mutable struct BCell
    x0::Float64; y0::Float64; s::Float64
    level::Int
    children::Vector{Int}
    part::Int
end

"Insert particles one at a time, snapshotting the cell list as we go."
function build_recording(px, py, snapshots)
    lo = min(minimum(px), minimum(py)) - 1e-6
    hi = max(maximum(px), maximum(py)) + 1e-6
    cells = [BCell(lo, lo, hi - lo, 0, Int[], 0)]
    frames = Any[]

    function insert!(ci, i)
        for _ in 1:64
            c = cells[ci]
            if c.part == 0 && isempty(c.children)
                c.part = i
                return
            end
            if c.part != 0
                j = c.part
                c.part = 0
                h = c.s / 2
                for (dx, dy) in ((0, 0), (1, 0), (0, 1), (1, 1))
                    push!(cells, BCell(c.x0 + dx * h, c.y0 + dy * h, h,
                                       c.level + 1, Int[], 0))
                    push!(c.children, length(cells))
                end
                insert!(ci, j)
            end
            c = cells[ci]
            k = 1 + (px[i] > c.x0 + c.s / 2) + 2 * (py[i] > c.y0 + c.s / 2)
            ci = c.children[k]
        end
        error("too deep")
    end

    for i in eachindex(px)
        insert!(1, i)
        if i in snapshots
            # Only cells that exist and are not empty interiors are worth drawing.
            live = [c for c in cells if c.part != 0 || !isempty(c.children)]
            push!(frames, Dict(
                "n" => i,
                "ncells" => length(live),
                "depth" => maximum(c.level for c in live),
                "cells" => [Dict("x0" => short(c.x0, 5), "y0" => short(c.y0, 5),
                                 "s" => short(c.s, 5)) for c in live]))
        end
    end
    return frames
end

let
    p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)
    pos3, _, _ = plummer_ics(120; p = p, seed = 4)
    px = pos3[1, :]; py = pos3[2, :]
    snaps = [1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64, 90, 120]
    frames = build_recording(px, py, snaps)
    for f in frames
        @printf("  after %3d particles: %3d cells, depth %d\n",
                f["n"], f["ncells"], f["depth"])
    end
    save_result("anim_treebuild", Dict(
        "x" => short(px, 5), "y" => short(py, 5),
        "snapshots" => snaps, "frames" => frames))
end

# ====================================================== 3. integrator drift ====
# One particle on one Kepler orbit, stepped three ways, recorded in time. The
# static figure overlays 200 finished orbits; this shows the drift appearing.

"Acceleration for a unit point mass at the origin."
kepler_acc(x, y) = begin
    r2 = x * x + y * y
    r3 = r2 * sqrt(r2)
    (-x / r3, -y / r3)
end

function run_euler(x, y, vx, vy, dt, nsteps)
    X = Float64[]; Y = Float64[]
    for n in 1:nsteps
        ax, ay = kepler_acc(x, y)
        x += vx * dt; y += vy * dt          # positions from the OLD velocity
        vx += ax * dt; vy += ay * dt
        push!(X, x); push!(Y, y)
    end
    X, Y
end

function run_leapfrog(x, y, vx, vy, dt, nsteps)
    X = Float64[]; Y = Float64[]
    ax, ay = kepler_acc(x, y)
    for n in 1:nsteps
        vx += 0.5dt * ax; vy += 0.5dt * ay
        x += vx * dt;     y += vy * dt
        ax, ay = kepler_acc(x, y)
        vx += 0.5dt * ax; vy += 0.5dt * ay
        push!(X, x); push!(Y, y)
    end
    X, Y
end

function run_rk4(x, y, vx, vy, dt, nsteps)
    X = Float64[]; Y = Float64[]
    f(s) = begin
        ax, ay = kepler_acc(s[1], s[2])
        (s[3], s[4], ax, ay)
    end
    add(a, b, h) = ntuple(i -> a[i] + h * b[i], 4)
    s = (x, y, vx, vy)
    for n in 1:nsteps
        k1 = f(s); k2 = f(add(s, k1, dt / 2))
        k3 = f(add(s, k2, dt / 2)); k4 = f(add(s, k3, dt))
        s = ntuple(i -> s[i] + dt / 6 * (k1[i] + 2k2[i] + 2k3[i] + k4[i]), 4)
        push!(X, s[1]); push!(Y, s[2])
    end
    X, Y
end

let
    # Mildly eccentric orbit, period 2pi for a = 1.
    x0, y0, vx0, vy0 = 1.0, 0.0, 0.0, 0.9
    dt = 0.12
    norbits = 60
    nsteps = round(Int, norbits * 2pi / dt)

    ex, ey = run_euler(x0, y0, vx0, vy0, dt, nsteps)
    lx, ly = run_leapfrog(x0, y0, vx0, vy0, dt, nsteps)
    rx, ry = run_rk4(x0, y0, vx0, vy0, dt, nsteps)

    # One frame per few orbits: the trail so far, thinned for file size.
    marks = [1, 2, 3, 5, 8, 12, 17, 23, 30, 38, 47, 60]
    every = 3
    frames = Any[]
    for m in marks
        k = min(nsteps, round(Int, m * 2pi / dt))
        idx = 1:every:k
        push!(frames, Dict(
            "orbits" => m,
            "ex" => short(ex[idx], 4), "ey" => short(ey[idx], 4),
            "lx" => short(lx[idx], 4), "ly" => short(ly[idx], 4),
            "rx" => short(rx[idx], 4), "ry" => short(ry[idx], 4)))
        @printf("  %2d orbits: euler r = %.3f, leapfrog r = %.3f, rk4 r = %.3f\n",
                m, hypot(ex[k], ey[k]), hypot(lx[k], ly[k]), hypot(rx[k], ry[k]))
    end

    save_result("anim_integrators", Dict(
        "dt" => dt, "marks" => marks, "frames" => frames,
        "nsteps" => nsteps))
end

println("\ndone")
