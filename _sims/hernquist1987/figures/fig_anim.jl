# The animated explainers.
#
# Each of these sits next to a static figure that already makes the same point.
# The animation is there for the mechanism: what the sampler is doing, what the
# tree is doing while it is being built, what "the orbit drifts" looks like.

include(joinpath(@__DIR__, "style.jl"))

println("animations")

const Gap2 = Union{Float64,Nothing}

# ------------------------------------------------------- 1. the sampler -------
sa = load("anim_sampler")
q = collect(Float64, sa["q"]); yy = collect(Float64, sa["y"])
keep = collect(Bool, sa["keep"])
qgrid = collect(Float64, sa["qgrid"]); gg = collect(Float64, sa["g"])
gbox = Float64(sa["gbox"])
centres = collect(Float64, sa["centres"])
steps = collect(Int, sa["steps"])
hists = [collect(Float64, h) for h in sa["hists"]]
kept = collect(Int, sa["kept_upto"])

# The box is drawn as a plain rectangle so it reads as the thing you throw into.
boxx = Gap2[0.0, 1.0, 1.0, 0.0, 0.0]
boxy = Gap2[0.0, 0.0, gbox, gbox, 0.0]

function dart_traces(n)
    inside = [i for i in 1:n if keep[i]]
    outside = [i for i in 1:n if !keep[i]]
    return [
        line(boxx, boxy, "the box we throw into";
             color = C.grey, width = 1.4, dash = "dot", hoverinfo = "skip"),
        line(qgrid, gg, "g(q) = q²(1−q²)^{7/2}"; color = C.blue, width = 2.4),
        markers(q[outside], yy[outside], "thrown away";
                color = "rgba(229,100,110,0.55)", size = 4),
        markers(q[inside], yy[inside], "kept";
                color = "rgba(63,191,143,0.85)", size = 4),
        Dict{String,Any}("type" => "bar", "x" => centres, "y" => hists[1],
                         "name" => "speeds kept so far",
                         "marker" => Dict("color" => C.orange, "opacity" => 0.35))]
end

# The bar trace is the one that changes shape per frame, so rebuild all five
# traces each time rather than trying to be clever about which ones moved.
function frame_traces(k)
    n = steps[k]
    tr = dart_traces(n)
    tr[5]["y"] = hists[k]
    return tr
end

names_s = [string(n) for n in steps]
sliders_s, menus_s = animation_controls(names_s; label = "darts thrown = ",
                                        duration = 700)
frames_s = [Dict("name" => names_s[k], "data" => frame_traces(k),
                 "layout" => Dict("title" => Dict("text" =>
                     "$(steps[k]) darts thrown, $(kept[k]) kept " *
                     "($(round(100 * kept[k] / steps[k], digits = 1))%)")))
            for k in eachindex(steps)]

write_fig("anim_sampler",
    frame_traces(1),
    layout(title = "$(steps[1]) darts thrown, $(kept[1]) kept " *
                   "($(round(100 * kept[1] / steps[1], digits = 1))%)",
           height = 520, legend = true,
           xaxis = axis("q = v / v_escape", range = [-0.02, 1.02]),
           yaxis = axis("height in the box", range = [0, gbox * 1.08]),
           barmode = "overlay", bargap = 0.06,
           sliders = sliders_s, updatemenus = menus_s),
    frames = frames_s)

# --------------------------------------------------- 2. building the tree -----
tb = load("anim_treebuild")
tx = collect(Float64, tb["x"]); ty = collect(Float64, tb["y"])
tframes = collect(tb["frames"])

function build_traces(fr)
    xs = Gap2[]; ys = Gap2[]
    for c in fr["cells"]
        x0 = Float64(c["x0"]); y0 = Float64(c["y0"]); s = Float64(c["s"])
        append!(xs, Gap2[x0, x0 + s, x0 + s, x0, x0, nothing])
        append!(ys, Gap2[y0, y0, y0 + s, y0 + s, y0, nothing])
    end
    n = Int(fr["n"])
    return [
        line(xs, ys, "cells"; color = "rgba(138,143,152,0.6)", width = 0.8,
             hoverinfo = "skip"),
        markers(tx[1:n-1], ty[1:n-1], "already in the tree";
                color = C.blue, size = 5),
        markers([tx[n]], [ty[n]], "just inserted";
                color = C.red, size = 11)]
end

names_t = [string(fr["n"]) for fr in tframes]
sliders_t, menus_t = animation_controls(names_t; label = "particles inserted = ",
                                        duration = 700)
frames_t = [Dict("name" => names_t[k], "data" => build_traces(tframes[k]),
                 "layout" => Dict("title" => Dict("text" =>
                     "$(tframes[k]["n"]) particles in, $(tframes[k]["ncells"]) cells, " *
                     "$(tframes[k]["depth"]) levels deep")))
            for k in eachindex(tframes)]

write_fig("anim_treebuild",
    build_traces(tframes[1]),
    layout(title = "$(tframes[1]["n"]) particles in, $(tframes[1]["ncells"]) cells, " *
                   "$(tframes[1]["depth"]) levels deep",
           height = 580, legend = true,
           xaxis = axis("x", scaleanchor = "y", scaleratio = 1),
           yaxis = axis("y"),
           sliders = sliders_t, updatemenus = menus_t),
    frames = frames_t)

# ------------------------------------------------ 3. the drift appearing ------
ai = load("anim_integrators")
aframes = collect(ai["frames"])

# Fixed axes. Euler leaves the frame entirely after a few orbits, which is the
# honest picture: letting it set the range would squash the other two into dots.
const LIM = 2.6

function orbit_traces(fr)
    return [
        line(collect(Float64, fr["ex"]), collect(Float64, fr["ey"]),
             "forward Euler"; color = C.red, width = 1.0),
        line(collect(Float64, fr["rx"]), collect(Float64, fr["ry"]),
             "Runge-Kutta 4"; color = C.orange, width = 1.2),
        line(collect(Float64, fr["lx"]), collect(Float64, fr["ly"]),
             "leapfrog"; color = C.blue, width = 1.2),
        markers([0.0], [0.0], "the mass being orbited";
                color = C.yellow, size = 10)]
end

names_i = [string(fr["orbits"]) for fr in aframes]
sliders_i, menus_i = animation_controls(names_i; label = "orbits = ",
                                        duration = 800)
frames_i = [Dict("name" => names_i[k], "data" => orbit_traces(aframes[k]),
                 "layout" => Dict("title" => Dict("text" =>
                     "after $(aframes[k]["orbits"]) orbits")))
            for k in eachindex(aframes)]

write_fig("anim_integrators",
    orbit_traces(aframes[1]),
    layout(title = "after $(aframes[1]["orbits"]) orbits",
           height = 560, legend = true,
           xaxis = axis("x", range = [-LIM, LIM], scaleanchor = "y",
                        scaleratio = 1),
           yaxis = axis("y", range = [-LIM, LIM]),
           sliders = sliders_i, updatemenus = menus_i),
    frames = frames_i)

println("done")
