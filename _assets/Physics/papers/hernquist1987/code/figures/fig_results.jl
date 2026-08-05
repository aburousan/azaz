# Figures recreating the paper's own plots: timing, errors, conservation and
# relaxation.

include(joinpath(@__DIR__, "style.jl"))
using Printf, Statistics

println("results figures")

# =========================================================== the simulation ===
ev = load("evolution")
run1 = ev["theta1.0"]

# --- Fig. 1: the model, evolving -------------------------------------------
snapkeys = sort(collect(String.(keys(run1["snapshots"]))), by = x -> parse(Float64, x))
const NSHOW = 2500

function snap_trace(k)
    s = run1["snapshots"][Symbol(k)]
    x = collect(Float64, s["x"]); y = collect(Float64, s["y"])
    n = min(NSHOW, length(x))
    return markers(x[1:n], y[1:n], "";
                   color = "rgba(76,141,246,0.55)", size = 2.4,
                   hoverinfo = "skip", showlegend = false)
end

frames = [Dict("name" => k, "data" => [snap_trace(k)],
               "layout" => Dict("title" => Dict("text" => "t = $k")))
          for k in snapkeys]
sliders, menus = animation_controls(snapkeys; label = "t = ", duration = 600)
write_fig("evolution_anim", [snap_trace(snapkeys[1])],
    layout(title = "t = $(snapkeys[1])", legend = false, height = 620,
           xaxis = axis("x", range = [-1.2, 1.2], scaleanchor = "y",
                        scaleratio = 1),
           yaxis = axis("y", range = [-1.2, 1.2]),
           sliders = sliders, updatemenus = menus),
    frames = frames)

# --- Fig. 2: Lagrangian radii ----------------------------------------------
fracs = collect(Float64, run1["lagrangian_fracs"])
lag = run1["lagrangian"]
t = collect(Float64, run1["time"])
traces = Any[]
for (i, f) in enumerate(fracs)
    y = [Float64(row[i]) for row in lag]
    push!(traces, line(t, y, "$(round(Int, 100f))% of the mass";
                       color = SEQ[i], width = 2.0))
end
write_fig("lagrangian_radii", traces,
    layout(title = "Radii holding a fixed fraction of the mass, θ = 1",
           xaxis = axis("time"), yaxis = axis("radius", range = [0, 1.0])))

# --- energy, and where it goes ---------------------------------------------
traces = Any[]
for (key, label, col) in (("direct", "direct sum", C.grey),
                          ("theta0.5", "θ = 0.5", C.green),
                          ("theta1.0", "θ = 1.0", C.blue),
                          ("theta1.0q", "θ = 1.0, quadrupole", C.orange))
    d = ev[key]
    E = collect(Float64, d["E"])
    push!(traces, line(d["time"], 100 .* (E .- E[1]) ./ abs(E[1]), label;
                       color = col, width = 2.0))
end
write_fig("energy_conservation", traces,
    layout(title = "Energy drift over 1000 steps, N = 4096",
           xaxis = axis("time"), yaxis = axis("ΔE / E  (%)")))

# --- Fig. 9: the centre of mass wanders off --------------------------------
traces = Any[]
for (key, label, col) in (("theta1.0", "θ = 1.0", C.blue),
                          ("theta0.5", "θ = 0.5", C.orange))
    d = ev[key]
    tt = collect(Float64, d["time"])
    keep = findall(>(0.3), tt)
    push!(traces, line(tt[keep], collect(Float64, d["r_cm"])[keep],
                       "r_cm, $label"; color = col, width = 2.0))
    push!(traces, line(tt[keep], collect(Float64, d["v_cm"])[keep],
                       "v_cm, $label"; color = col, width = 1.5, dash = "dot"))
end
write_fig("com_drift", traces,
    layout(title = "Newton's third law is not obeyed, so the centre of mass drifts",
           xaxis = axis("time", type = "log"),
           yaxis = axis("displacement / speed", type = "log")))

# ================================================================= timing ====
tm = load("timing")
tree = collect(tm["tree"])
mono = [r for r in tree if r["quadrupole"] == false]
quad = [r for r in tree if r["quadrupole"] == true]

# --- Fig. 3: cost against N ------------------------------------------------
thetas = sort(unique(Float64[r["theta"] for r in mono]))
traces = Any[]
for (i, th) in enumerate(thetas)
    rows = sort([r for r in mono if r["theta"] == th], by = r -> r["N"])
    length(rows) < 2 && continue
    x = [log10(Float64(r["N"])) for r in rows]
    y = [Float64(r["per_particle"]) for r in rows]
    push!(traces, line(x, y, "θ = $th";
                       color = SEQ[mod1(i, length(SEQ))],
                       dash = th <= 0.3 ? "dash" : nothing))
    push!(traces, markers(x, y, ""; color = SEQ[mod1(i, length(SEQ))], size = 5,
                          showlegend = false))
end
write_fig("timing_vs_N", traces,
    layout(title = "Cost of one force evaluation, monopole only",
           xaxis = axis("log₁₀ N"),
           yaxis = axis("seconds per step per particle", type = "log"),
           height = 520))

# --- Fig. 4: cost against theta --------------------------------------------
Ns = sort(unique(Int[r["N"] for r in mono]))
traces = Any[]
for (i, N) in enumerate(Ns)
    rows = sort([r for r in mono if r["N"] == N], by = r -> r["theta"])
    x = [Float64(r["theta"]) for r in rows]
    y = [log10(Float64(r["per_particle"])) for r in rows]
    push!(traces, line(x, y, "N = $N"; color = SEQ[mod1(i, length(SEQ))]))
end
write_fig("timing_vs_theta", traces,
    layout(title = "Opening the cells wider costs less, up to a point",
           xaxis = axis("θ"),
           yaxis = axis("log₁₀ (seconds per step per particle)")))

# --- where the tree overtakes the direct sum -------------------------------
dir = sort(collect(tm["direct"]), by = r -> r["N"])
traces = [line([Float64(r["N"]) for r in dir],
               [Float64(r["per_particle"]) for r in dir],
               "direct sum, O(N²)"; color = C.red, width = 2.4)]
for (th, col) in ((0.5, C.green), (1.0, C.blue))
    rows = sort([r for r in mono if r["theta"] == th], by = r -> r["N"])
    push!(traces, line([Float64(r["N"]) for r in rows],
                       [Float64(r["per_particle"]) for r in rows],
                       "tree, θ = $th"; color = col, width = 2.4))
end
write_fig("tree_vs_direct", traces,
    layout(title = "Per particle per step: when is the tree worth it?",
           xaxis = axis("N", type = "log"),
           yaxis = axis("seconds per step per particle", type = "log")))

# --- what the quadrupole costs ---------------------------------------------
traces = Any[]
for (i, th) in enumerate([0.5, 1.0])
    rm = sort([r for r in mono if r["theta"] == th], by = r -> r["N"])
    rq = sort([r for r in quad if r["theta"] == th], by = r -> r["N"])
    x = [Float64(r["N"]) for r in rm]
    y = [Float64(rq[j]["per_particle"]) / Float64(rm[j]["per_particle"])
         for j in eachindex(rm)]
    push!(traces, line(x, y, "θ = $th"; color = SEQ[i], width = 2.2))
end
write_fig("quadrupole_cost", traces,
    layout(title = "Cost of keeping the quadrupole, relative to monopole only",
           xaxis = axis("N", type = "log"),
           yaxis = axis("time ratio, quadrupole / monopole")))

# ================================================================= errors ====
er = load("errors")

# --- Fig. 6: error against theta -------------------------------------------
traces = Any[]
for (i, c) in enumerate(er["plummer"])
    push!(traces, line(c["theta"], log10.(collect(Float64, c["monopole"])),
                       "N = $(c["N"])"; color = SEQ[i], width = 2.2))
end
write_fig("error_vs_theta", traces,
    layout(title = "Typical error in the tree force, monopole only, ε = 0",
           xaxis = axis("θ"),
           yaxis = axis("log₁₀ (relative error, %)")))

# --- monopole against quadrupole at the same theta -------------------------
c = last(er["plummer"])
write_fig("error_mono_vs_quad",
    [line(c["theta"], log10.(collect(Float64, c["monopole"])), "monopole only";
          color = C.blue, width = 2.4),
     line(c["theta"], log10.(collect(Float64, c["quadrupole"])),
          "through quadrupole"; color = C.orange, width = 2.4)],
    layout(title = "Adding the quadrupole, N = $(c["N"])",
           xaxis = axis("θ"), yaxis = axis("log₁₀ (relative error, %)")))

# --- Fig. 7: the ratio of the two ------------------------------------------
uni = er["uniform"]
write_fig("error_ratio",
    [line(c["theta"],
          log10.(collect(Float64, c["quadrupole"]) ./ collect(Float64, c["monopole"])),
          "Plummer model"; color = C.blue, width = 2.4),
     line(uni["theta"],
          log10.(collect(Float64, uni["quadrupole"]) ./ collect(Float64, uni["monopole"])),
          "uniform sphere"; color = C.orange, width = 2.4),
     line([0.0, 2.0], [0.0, 0.0], "no gain"; color = C.grey, dash = "dash",
          width = 1.4)],
    layout(title = "How much the quadrupole buys you",
           xaxis = axis("θ"),
           yaxis = axis("log₁₀ (quadrupole error / monopole error)")))

# --- the error against N ---------------------------------------------------
traces = Any[]
for (i, s) in enumerate(er["scaling_with_N"])
    Nv = collect(Float64, s["N"]); ev_ = collect(Float64, s["error"])
    push!(traces, markers(Nv, ev_, "θ = $(s["theta"])"; color = SEQ[i], size = 7))
    guide = ev_[1] .* (Nv ./ Nv[1]) .^ (-1 / 5)
    push!(traces, line(Nv, guide, "N^(−1/5)"; color = SEQ[i], dash = "dot",
                       width = 1.4, showlegend = i == 1))
end
write_fig("error_vs_N", traces,
    layout(title = "The error fades only very slowly with particle number",
           xaxis = axis("N", type = "log"),
           yaxis = axis("relative error (%)", type = "log")))

# --- Fig. 8: error against softening ---------------------------------------
sf = load("softening")
traces = Any[]
for (i, c) in enumerate(sf["curves"])
    lbl = "θ = $(c["theta"]), " * (c["quadrupole"] ? "quadrupole" : "monopole")
    push!(traces, line(c["eps_over_lambda"],
                       log10.(collect(Float64, c["error"])), lbl;
                       color = SEQ[i], width = 2.2,
                       dash = c["quadrupole"] ? "dash" : nothing))
end
write_fig("error_vs_softening", traces,
    layout(title = "Softening and the multipole expansion fight each other, N = $(sf["N"])",
           xaxis = axis("ε / λ"), yaxis = axis("log₁₀ (relative error, %)")))

# ============================================================== relaxation ===
rx = load("relaxation")
traces = Any[]
for (i, c) in enumerate(rx["curves"])
    lbl = (c["eps_mode"] == "zero" ? "ε = 0" : "ε = λ") * ", " *
          (c["quadrupole"] ? "quadrupole" : "monopole")
    push!(traces, merge(
        line(c["theta"], c["ratio"], lbl; color = SEQ[i], width = 2.0),
        Dict{String,Any}("mode" => "lines+markers",
                         "marker" => Dict("size" => 6, "color" => SEQ[i]),
                         "error_y" => Dict("type" => "data",
                                           "array" => c["ratio_err"],
                                           "visible" => true,
                                           "color" => SEQ[i], "thickness" => 1.2,
                                           "width" => 3))))
end
push!(traces, line([0.0, 1.4], [1.0, 1.0], "as collisional as a direct sum";
                   color = C.grey, dash = "dash", width = 1.4))
write_fig("relaxation", traces,
    layout(title = "Relaxation time relative to a direct calculation, N = $(rx["N"])",
           xaxis = axis("θ"), yaxis = axis("t_r(θ) / t_r(0)", range = [0.4, 1.5])))

# --- terms per particle against theta, from the timing sweep ---------------
traces = Any[]
for (i, N) in enumerate(Ns)
    rows = sort([r for r in mono if r["N"] == N && r["theta"] > 0],
                by = r -> r["theta"])
    push!(traces, line([Float64(r["theta"]) for r in rows],
                       [Float64(r["nterms"]) for r in rows], "N = $N";
                       color = SEQ[mod1(i, length(SEQ))], width = 2.0))
end
write_fig("nterms_vs_theta", traces,
    layout(title = "Terms per particle as the opening angle is relaxed",
           xaxis = axis("θ"), yaxis = axis("⟨n_terms⟩", type = "log")))
