# Figures for the "doing better than 1987" page.

include(joinpath(@__DIR__, "style.jl"))

println("beyond figures")
b = load("beyond")

const MODECOL = Dict("monopole" => C.blue, "quadrupole" => C.orange,
                     "octupole" => C.green)

# --- one cell, three orders of expansion ----------------------------------
cell = b["cell"]
sd = collect(Float64, cell["s_over_d"])
traces = Any[]
for (name, key, n) in (("monopole", "monopole", 2), ("quadrupole", "quadrupole", 3),
                       ("octupole", "octupole", 4))
    y = collect(Float64, cell[key])
    push!(traces, markers(sd, y, name; color = MODECOL[name], size = 7))
    push!(traces, line(sd, y[1] .* (sd ./ sd[1]) .^ n, "(s/d)^$n";
                       color = MODECOL[name], dash = "dot", width = 1.4))
end
write_fig("multipole_error_3", traces,
    layout(title = "Truncation error of one cell: slopes $(cell["slope_monopole"]), $(cell["slope_quadrupole"]), $(cell["slope_octupole"])",
           xaxis = axis("s / d", type = "log"),
           yaxis = axis("relative error in the acceleration", type = "log")))

# --- error against theta in the real tree ---------------------------------
curves = collect(b["curves"])
write_fig("error_vs_theta_3",
    [line(c["theta"], c["error"], c["name"]; color = MODECOL[c["name"]],
          width = 2.4, mode = "lines+markers",
          marker = Dict("size" => 6, "color" => MODECOL[c["name"]]))
     for c in curves],
    layout(title = "Force error against θ, N = $(b["N"])",
           xaxis = axis("θ"),
           yaxis = axis("relative error (%)", type = "log")))

# --- the plot that actually decides it: accuracy per unit cost -------------
write_fig("pareto",
    [line(c["cost"], c["error"], c["name"]; color = MODECOL[c["name"]],
          width = 2.4, mode = "lines+markers",
          marker = Dict("size" => 7, "color" => MODECOL[c["name"]]))
     for c in curves],
    layout(title = "Accuracy bought per second of force evaluation (down and left is better)",
           xaxis = axis("seconds per force evaluation", type = "log"),
           yaxis = axis("relative error (%)", type = "log")))

# --- leapfrog against the fourth-order scheme at equal cost ----------------
ints = collect(b["integrators"])
lf = [r for r in ints if r["method"] == "leapfrog"]
y4 = [r for r in ints if r["method"] == "yoshida4"]
sortby(v) = sort(v, by = r -> Float64(r["force_evals"]))
lf = sortby(lf); y4 = sortby(y4)
write_fig("integrator_equal_cost",
    [line([Float64(r["force_evals"]) for r in lf],
          [Float64(r["max_dE"]) for r in lf], "leapfrog (2nd order)";
          color = C.blue, width = 2.4, mode = "lines+markers",
          marker = Dict("size" => 7, "color" => C.blue)),
     line([Float64(r["force_evals"]) for r in y4],
          [Float64(r["max_dE"]) for r in y4], "Yoshida (4th order)";
          color = C.orange, width = 2.4, mode = "lines+markers",
          marker = Dict("size" => 7, "color" => C.orange))],
    layout(title = "Energy error against total force evaluations, N = $(b["N_evol"]), θ = 0.5",
           xaxis = axis("force evaluations", type = "log"),
           yaxis = axis("max |ΔE / E|", type = "log")))

# ================================================================= large N ===
ln = load("largeN")
tm = collect(ln["timing"])
thetas = sort(unique(Float64[r["theta"] for r in tm]))

write_fig("largeN_timing",
    vcat([line([Float64(r["N"]) for r in sort([x for x in tm if x["theta"]==th], by=x->x["N"])],
               [Float64(r["per_particle"]) for r in sort([x for x in tm if x["theta"]==th], by=x->x["N"])],
               "θ = $th"; color = SEQ[i], width = 2.4, mode = "lines+markers",
               marker = Dict("size" => 6, "color" => SEQ[i]))
          for (i, th) in enumerate(thetas)]),
    layout(title = "Cost per particle out to a million bodies",
           xaxis = axis("N", type = "log"),
           yaxis = axis("seconds per step per particle", type = "log")))

# n_terms should be linear in log N if the counting argument is right
write_fig("largeN_nterms",
    [line([log10(Float64(r["N"])) for r in sort([x for x in tm if x["theta"]==th], by=x->x["N"])],
          [Float64(r["nterms"]) for r in sort([x for x in tm if x["theta"]==th], by=x->x["N"])],
          "θ = $th"; color = SEQ[i], width = 2.4, mode = "lines+markers",
          marker = Dict("size" => 6, "color" => SEQ[i]))
     for (i, th) in enumerate(thetas)],
    layout(title = "⟨n_terms⟩ against log N — straight lines mean N log N is real",
           xaxis = axis("log₁₀ N"), yaxis = axis("⟨n_terms⟩")))

er = collect(ln["errors"])
traces = Any[]
for (i, mode) in enumerate(("monopole", "quadrupole", "octupole"))
    rows = sort([r for r in er if r["mode"] == mode && Float64(r["theta"]) == 1.0],
                by = r -> r["N"])
    isempty(rows) && continue
    Nv = [Float64(r["N"]) for r in rows]; ev = [Float64(r["error"]) for r in rows]
    push!(traces, line(Nv, ev, mode; color = MODECOL[mode], width = 2.4,
                       mode = "lines+markers",
                       marker = Dict("size" => 7, "color" => MODECOL[mode])))
    push!(traces, line(Nv, ev[1] .* (Nv ./ Nv[1]) .^ (-1/5), "N^(−1/5)";
                       color = MODECOL[mode], dash = "dot", width = 1.3,
                       showlegend = i == 1))
end
write_fig("largeN_error", traces,
    layout(title = "Force error against N at θ = 1, over 1.2 decades more than the paper",
           xaxis = axis("N", type = "log"),
           yaxis = axis("relative error (%)", type = "log")))

# --- where the energy error actually comes from ---------------------------
eb = load("error_budget")
cols = Dict("direct" => C.grey, "theta=0.3" => C.blue, "theta=0.5" => C.green,
            "theta=0.7" => C.orange, "theta=1.0" => C.red)
write_fig("error_budget",
    [line(c["dt"], c["error"],
          c["label"] == "direct" ? "exact forces (direct sum)" : "θ = " * split(c["label"], "=")[2];
          color = cols[c["label"]], width = 2.4, mode = "lines+markers",
          marker = Dict("size" => 7, "color" => cols[c["label"]]),
          dash = c["label"] == "direct" ? "dash" : nothing)
     for c in eb["curves"]],
    layout(title = "Shrinking δt only helps until you hit the force-error floor (N = $(eb["N"]))",
           xaxis = axis("δt", type = "log"),
           yaxis = axis("max |ΔE / E|", type = "log")))
