# Figures for the "setting up the problem" page: the Plummer model itself, the
# sampled initial conditions, and the virial theorem.

include(joinpath(@__DIR__, "style.jl"))
include(joinpath(@__DIR__, "..", "src", "TreeCodeH87.jl"))
using .TreeCodeH87
using Statistics, Printf

println("setup figures")
p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)

# ---------------------------------------------------------------- profiles ---
rs = 10 .^ range(-2.5, log10(3.0), length = 300)
rho = [density(p, r) for r in rs]
Mr  = [enclosed_mass(p, r) for r in rs]
psi = [relative_potential(p, r) for r in rs]
sig = [velocity_dispersion(p, r) for r in rs]

write_fig("plummer_profiles",
    [line(rs, rho, "ρ(r)", color = C.blue),
     line(rs, Mr, "M(r)", color = C.orange, yaxis = "y2"),
     line(rs, psi, "−Φ(r)", color = C.green, yaxis = "y2"),
     line(rs, sig, "σ(r)", color = C.red, yaxis = "y2")],
    layout(title = "The Plummer model, r₀ = 0.2",
           xaxis = axis("r", type = "log"),
           yaxis = axis("ρ(r)", type = "log", color = C.blue),
           yaxis2 = merge(axis(""), Dict("overlaying" => "y", "side" => "right",
                                         "showgrid" => false)),
           legend = true,
           shapes = [Dict("type" => "line", "x0" => p.R, "x1" => p.R,
                          "y0" => 0, "y1" => 1, "yref" => "paper",
                          "line" => Dict("color" => GRID, "width" => 1.5,
                                         "dash" => "dot"))],
           annotations = [Dict("x" => log10(p.R), "y" => 1.0, "yref" => "paper",
                               "text" => "cutoff R = 1", "showarrow" => false,
                               "xanchor" => "right", "yanchor" => "top",
                               "font" => Dict("size" => 11, "color" => FONT))]))

# ------------------------------------------------- do the samples match it ---
N = 200_000
pos, vel, mass = plummer_ics(N; p = p, seed = 2026)
r = vec(sqrt.(sum(abs2, pos, dims = 1)))
v = vec(sqrt.(sum(abs2, vel, dims = 1)))

# radial mass profile, sampled against analytic
edges = range(0, p.R, length = 61)
mid = [(edges[i] + edges[i+1]) / 2 for i in 1:length(edges)-1]
counts = zeros(Int, length(mid))
for x in r
    k = min(searchsortedlast(edges, x), length(mid))
    k >= 1 && (counts[k] += 1)
end
dr = step(edges)
# dN/dr from the sample, and 4 pi r^2 rho(r) N / M(R) from theory
sampled = counts ./ (N * dr)
theory = [4pi * x^2 * density(p, x) / enclosed_mass(p, p.R) for x in mid]

write_fig("plummer_sampled_radius",
    [markers(mid, sampled, "sampled, N = 200 000", color = C.blue, size = 5),
     line(mid, theory, "4πr²ρ(r) / M(R)", color = C.orange)],
    layout(title = "Where the particles land",
           xaxis = axis("r"), yaxis = axis("probability density in r")))

# velocity dispersion, sampled against analytic
bins = range(0.01, 0.9, length = 30)
rm = Float64[]; sm = Float64[]
for i in 1:length(bins)-1
    idx = findall(x -> bins[i] <= x < bins[i+1], r)
    length(idx) < 50 && continue
    push!(rm, mean(r[idx]))
    push!(sm, std(vec(vel[:, idx])))
end
write_fig("plummer_sampled_sigma",
    [markers(rm, sm, "sampled", color = C.blue, size = 6),
     line(rs, sig, "σ₀ (1 + (r/r₀)²)^(−1/4)", color = C.orange)],
    layout(title = "One-dimensional velocity dispersion",
           xaxis = axis("r", range = [0, 0.9]), yaxis = axis("σ(r)")))

# the universal speed distribution g(q)
q = v ./ [escape_speed(p, x) for x in r]
qe = range(0, 1, length = 41)
qm = [(qe[i] + qe[i+1]) / 2 for i in 1:length(qe)-1]
qc = zeros(Int, length(qm))
for x in q
    k = min(searchsortedlast(qe, x), length(qm))
    k >= 1 && (qc[k] += 1)
end
gnorm = qc ./ (N * step(qe))
gq = [x^2 * (1 - x^2)^3.5 for x in qm]
gq .*= maximum(gnorm) / maximum(gq)
write_fig("plummer_speed_dist",
    [Dict{String,Any}("type" => "bar", "x" => qm, "y" => gnorm,
                      "name" => "sampled q = v / v_esc",
                      "marker" => Dict("color" => C.blue, "opacity" => 0.55)),
     line(qm, gq, "g(q) ∝ q²(1 − q²)^(7/2)", color = C.orange, width = 2.6)],
    layout(title = "The speed distribution is the same shape at every radius",
           xaxis = axis("q = v / v_escape"), yaxis = axis("probability density"),
           bargap = 0.02))

# ------------------------------------------------------------- 3D snapshot ---
n3 = 4000
write_fig("plummer_3d",
    [Dict{String,Any}("type" => "scatter3d", "mode" => "markers",
                      "x" => round.(pos[1, 1:n3], digits = 4),
                      "y" => round.(pos[2, 1:n3], digits = 4),
                      "z" => round.(pos[3, 1:n3], digits = 4),
                      "name" => "",
                      "hoverinfo" => "skip",
                      "marker" => Dict("size" => 1.8, "opacity" => 0.65,
                                       "color" => r[1:n3],
                                       "colorscale" => "Viridis",
                                       "reversescale" => true,
                                       "showscale" => false))],
    layout(title = "A Plummer sphere, 4000 of the particles",
           legend = false, height = 560,
           margin = Dict("l" => 0, "r" => 0, "t" => 40, "b" => 0),
           scene = Dict("xaxis" => merge(axis("x"), Dict("backgroundcolor" => "rgba(0,0,0,0)")),
                        "yaxis" => merge(axis("y"), Dict("backgroundcolor" => "rgba(0,0,0,0)")),
                        "zaxis" => merge(axis("z"), Dict("backgroundcolor" => "rgba(0,0,0,0)")),
                        "aspectmode" => "cube")))

# ----------------------------------------------------------- virial theorem ---
vir = load("virial")
for (key, tag) in (("as_sampled", "virial_as_sampled"),
                   ("rescaled", "virial_rescaled"))
    d = vir[key]
    write_fig(tag,
        [line(d["time"], d["virial"], "−2K/U", color = C.blue),
         line(d["time"], d["virial_W"], "−2K/W", color = C.orange),
         line([first(d["time"]), last(d["time"])], [1.0, 1.0], "equilibrium",
              color = C.grey, dash = "dash", width = 1.4)],
        layout(title = key == "rescaled" ?
                   "Started exactly on 2K + W = 0" : "Started as sampled",
               xaxis = axis("time"), yaxis = axis("virial ratio",
                                                  range = [0.80, 1.15])))
end

d = vir["as_sampled"]
I0 = first(d["I"])
write_fig("virial_inertia",
    [line(d["time"], d["I"] ./ I0, "I(t) / I(0)", color = C.blue),
     line(d["time"], d["E"] ./ first(d["E"]), "E(t) / E(0)", color = C.green)],
    layout(title = "The moment of inertia settles, and then stops changing",
           xaxis = axis("time"), yaxis = axis("ratio to initial value")))
