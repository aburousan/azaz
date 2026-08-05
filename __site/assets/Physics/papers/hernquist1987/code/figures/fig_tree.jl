# Figures for the tree and multipole page.

include(joinpath(@__DIR__, "style.jl"))

println("tree figures")

# ------------------------------------------------- what the subdivision does ---
tv = load("treeviz")
px = collect(Float64, tv["x"]); py = collect(Float64, tv["y"])

"Cell outlines drawn as one scatter trace with gaps, which is far lighter than
 one shape per cell. `nothing` is the JSON null that plotly reads as a break."
const Gap = Union{Float64,Nothing}

function cell_outline(cells; maxlevel = 99)
    xs = Gap[]; ys = Gap[]
    for c in cells
        c["level"] > maxlevel && continue
        x0 = Float64(c["x0"]); y0 = Float64(c["y0"]); s = Float64(c["s"])
        append!(xs, Gap[x0, x0 + s, x0 + s, x0, x0, nothing])
        append!(ys, Gap[y0, y0, y0 + s, y0 + s, y0, nothing])
    end
    return xs, ys
end

xs, ys = cell_outline(tv["cells"])
write_fig("quadtree_cells",
    [line(xs, ys, "cells"; color = "rgba(138,143,152,0.55)", width = 0.7,
          hoverinfo = "skip"),
     markers(px, py, "particles"; color = C.blue, size = 3.5)],
    layout(title = "Subdivide until every cell holds at most one particle",
           legend = false, height = 560,
           xaxis = axis("x", scaleanchor = "y", scaleratio = 1),
           yaxis = axis("y")))

# ------------------------------------------------------- the walk, vs theta ---
# One frame per theta: the cells that were accepted whole, and the particles
# that had to be summed individually.
tx = px[tv["target"]]; ty = py[tv["target"]]

function walk_traces(w)
    cx = Gap[]; cy = Gap[]
    comx = Float64[]; comy = Float64[]
    for c in w["cells"]
        x0 = Float64(c["x0"]); y0 = Float64(c["y0"]); s = Float64(c["s"])
        append!(cx, Gap[x0, x0 + s, x0 + s, x0, x0, nothing])
        append!(cy, Gap[y0, y0, y0 + s, y0 + s, y0, nothing])
        push!(comx, Float64(c["comx"])); push!(comy, Float64(c["comy"]))
    end
    singles = collect(Int, w["singles"])
    return [
        line(cx, cy, "cells used whole"; color = C.orange, width = 1.3,
             hoverinfo = "skip"),
        markers(comx, comy, "their centres of mass"; color = C.orange, size = 5),
        markers(px[singles], py[singles], "summed one by one";
                color = C.red, size = 5),
        markers([tx], [ty], "the particle being pulled on";
                color = C.blue, size = 13,
                marker = Dict("color" => C.blue, "size" => 13,
                              "symbol" => "star"))]
end

walks = collect(tv["walks"])
names = [string(w["theta"]) for w in walks]
frames = [Dict("name" => names[i], "data" => walk_traces(walks[i]),
               "layout" => Dict("title" => Dict("text" =>
                   "θ = $(walks[i]["theta"]) → $(walks[i]["nterms"]) terms " *
                   "($(walks[i]["ncells"]) cells + $(walks[i]["nsingles"]) particles)")))
          for i in eachindex(walks)]
sliders, menus = animation_controls(names; label = "θ = ", duration = 500)

# Open on the smallest theta, so the figure and the slider handle (which
# plotly always puts at the left) agree, and the reader watches the walk get
# coarser as they drag right.
start = 1
write_fig("treewalk_theta",
    vcat([markers(px, py, "all particles"; color = C.grey, size = 3,
                  opacity = 0.45, showlegend = false)],
         walk_traces(walks[start])),
    layout(title = "θ = $(walks[start]["theta"]) → $(walks[start]["nterms"]) terms " *
                   "($(walks[start]["ncells"]) cells + $(walks[start]["nsingles"]) particles)",
           height = 600, legend = true,
           xaxis = axis("x", scaleanchor = "y", scaleratio = 1),
           yaxis = axis("y"),
           sliders = sliders, updatemenus = menus),
    frames = [Dict("name" => f["name"],
                   "data" => vcat([markers(px, py, "all particles";
                                           color = C.grey, size = 3,
                                           opacity = 0.45, showlegend = false)],
                                  f["data"]),
                   "layout" => f["layout"]) for f in frames])

# ---------------------------------------- error of the expansion itself -------
me = load("multipole_error")
sd = collect(Float64, me["s_over_d"])
mono = collect(Float64, me["monopole"]); quad = collect(Float64, me["quadrupole"])
guide2 = mono[1] .* (sd ./ sd[1]) .^ 2
guide3 = quad[1] .* (sd ./ sd[1]) .^ 3
write_fig("multipole_error",
    [markers(sd, mono, "monopole only"; color = C.blue, size = 7),
     line(sd, guide2, "(s/d)²"; color = C.blue, dash = "dot", width = 1.4),
     markers(sd, quad, "through quadrupole"; color = C.orange, size = 7),
     line(sd, guide3, "(s/d)³"; color = C.orange, dash = "dot", width = 1.4)],
    layout(title = "Truncation error of one cell's expansion",
           xaxis = axis("s / d", type = "log"),
           yaxis = axis("relative error in the acceleration", type = "log")))

# ------------------------------------------------- how many terms per particle ---
nt = load("nterms")
pl = nt["plummer"]; un = nt["uniform"]
write_fig("nterms_hist",
    [Dict{String,Any}("type" => "bar", "x" => pl["centers"], "y" => pl["counts"],
                      "name" => "Plummer,  ⟨n⟩ = $(pl["mean"])",
                      "marker" => Dict("color" => C.blue, "opacity" => 0.6)),
     Dict{String,Any}("type" => "bar", "x" => un["centers"], "y" => un["counts"],
                      "name" => "uniform sphere,  ⟨n⟩ = $(un["mean"])",
                      "marker" => Dict("color" => C.orange, "opacity" => 0.6))],
    layout(title = "Force terms per particle, N = $(nt["N"]), θ = $(nt["theta"])",
           xaxis = axis("n_terms"), yaxis = axis("number of particles"),
           barmode = "overlay", bargap = 0.02))

write_fig("nterms_radius",
    [line(pl["radius"], pl["nterms_of_r"], "Plummer"; color = C.blue),
     line(un["radius"], un["nterms_of_r"], "uniform sphere"; color = C.orange)],
    layout(title = "Particles in the sparse outskirts see fewer cells",
           xaxis = axis("radius"), yaxis = axis("mean n_terms")))
