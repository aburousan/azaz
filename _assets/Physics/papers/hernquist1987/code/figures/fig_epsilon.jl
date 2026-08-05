# The softening study: what eps does to the virial theorem and to energy
# conservation. Run on the server over a factor of 64 in eps.

include(joinpath(@__DIR__, "style.jl"))

println("epsilon figures")
es = load("epsilon_study")
runs = collect(es["runs"])
ratios = [Float64(r["eps_over_lambda"]) for r in runs]
pred = Dict(Float64(q["eps_over_lambda"]) => Float64(q["one_minus_mean"])
            for q in es["prediction"])

# --- the virial ratio, both ways, against the softening -------------------
write_fig("epsilon_virial",
    [line(ratios, [Float64(r["virial_U_late"]) for r in runs], "−2K/U";
          color = C.blue, width = 2.4, mode = "lines+markers",
          marker = Dict("size" => 7, "color" => C.blue),
          error_y = Dict("type" => "data",
                         "array" => [Float64(r["virial_U_std"]) for r in runs],
                         "visible" => true, "color" => C.blue,
                         "thickness" => 1.2, "width" => 4)),
     line(ratios, [Float64(r["virial_W_late"]) for r in runs], "−2K/W";
          color = C.orange, width = 2.4, mode = "lines+markers",
          marker = Dict("size" => 7, "color" => C.orange),
          error_y = Dict("type" => "data",
                         "array" => [Float64(r["virial_W_std"]) for r in runs],
                         "visible" => true, "color" => C.orange,
                         "thickness" => 1.2, "width" => 4)),
     line(ratios, [pred[r] for r in ratios], "predicted 1 − ⟨ε²/r²⟩";
          color = C.green, dash = "dash", width = 1.8),
     line([minimum(ratios), maximum(ratios)], [1.0, 1.0], "equilibrium";
          color = C.grey, dash = "dot", width = 1.4)],
    layout(title = "The virial ratio against softening, N = $(es["N"])",
           xaxis = axis("ε / λ", type = "log"),
           yaxis = axis("virial ratio", range = [0.80, 1.06])))

# --- energy conservation falls apart when eps gets small ------------------
drift = [abs(Float64(r["energy_drift_percent"])) for r in runs]
write_fig("epsilon_energy",
    [line(ratios, max.(drift, 1e-4), "|ΔE/E| after $(es["nsteps"]) steps";
          color = C.red, width = 2.4, mode = "lines+markers",
          marker = Dict("size" => 8, "color" => C.red)),
     line([1.0, 1.0], [1e-4, 100.0], "ε = λ";
          color = C.grey, dash = "dash", width = 1.4)],
    layout(title = "Shrinking ε does not make the simulation better",
           xaxis = axis("ε / λ", type = "log"),
           yaxis = axis("|ΔE / E|  (%)", type = "log")))

# --- the energy histories themselves --------------------------------------
traces = Any[]
for (i, r) in enumerate(runs)
    E = collect(Float64, r["E"])
    push!(traces, line(r["time"], 100 .* (E .- E[1]) ./ abs(E[1]),
                       "ε/λ = $(r["eps_over_lambda"])";
                       color = SEQ[mod1(i, length(SEQ))], width = 2.0))
end
write_fig("epsilon_energy_history", traces,
    layout(title = "Energy against time, for each softening length",
           xaxis = axis("time"), yaxis = axis("ΔE / E  (%)")))

# --- why my numbers differ from the paper's: n_terms is not a fixed number ---
wd = load("why_different")
write_fig("nterms_of_time",
    [line(wd["time"], wd["nterms_of_time"], "my run, N = 4096, θ = 1";
          color = C.blue, width = 2.2),
     line([0.0, 25.0], [171.5, 171.5], "paper: 170–175 early";
          color = C.orange, dash = "dash", width = 1.6),
     line([0.0, 25.0], [197.5, 197.5], "paper: 195–200 later";
          color = C.green, dash = "dash", width = 1.6)],
    layout(title = "⟨n_terms⟩ is not a property of the model — it drifts as the cluster relaxes",
           xaxis = axis("time"), yaxis = axis("⟨n_terms⟩", range = [160, 210])))

fs = collect(wd["forced_subdivision"])
th = sort(unique(Float64[r["theta"] for r in fs]))
write_fig("forced_subdivision",
    [line(th, [Float64([r for r in fs if r["theta"]==t && r["forced"]][1]["error"]) for t in th],
          "forced subdivision on"; color = C.blue, width = 2.2,
          mode = "lines+markers", marker = Dict("size" => 7, "color" => C.blue)),
     line(th, [Float64([r for r in fs if r["theta"]==t && !r["forced"]][1]["error"]) for t in th],
          "off (self-attraction allowed)"; color = C.red, width = 2.2, dash = "dash",
          mode = "lines+markers", marker = Dict("size" => 7, "color" => C.red))],
    layout(title = "Self-attraction only matters past θ ≈ 1.2",
           xaxis = axis("θ"), yaxis = axis("force error (%)", type = "log")))
