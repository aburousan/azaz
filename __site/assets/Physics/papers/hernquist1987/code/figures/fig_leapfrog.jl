# Figures for the integrator page.

include(joinpath(@__DIR__, "style.jl"))

println("leapfrog figures")
d = load("integrators")

const NAMES = ["euler" => ("forward Euler", C.red),
               "symplectic_euler" => ("symplectic Euler", C.orange),
               "leapfrog" => ("leapfrog", C.blue),
               "rk4" => ("Runge-Kutta 4", C.green)]

# --------------------------------------------------------------- the orbits ---
# Only the first few orbits, otherwise the drifting methods paint the whole box.
function firstturns(o, nturn)
    t = collect(Float64, o["t"])
    k = findlast(<=(nturn), t)
    k === nothing && (k = length(t))
    return collect(Float64, o["x"])[1:k], collect(Float64, o["y"])[1:k]
end

traces = Any[]
for (key, (label, col)) in NAMES
    x, y = firstturns(d["orbits"][key], 12)
    push!(traces, line(x, y, label; color = col, width = 1.6))
end
push!(traces, markers([0.0], [0.0], "central mass"; color = C.yellow, size = 11))
write_fig("integrator_orbits", traces,
    layout(title = "The same orbit, twelve times round, four integrators",
           xaxis = axis("x", scaleanchor = "y", scaleratio = 1),
           yaxis = axis("y"), height = 520))

# ------------------------------------------------------- the energy history ---
traces = Any[]
for (key, (label, col)) in NAMES
    o = d["orbits"][key]
    dE = abs.(collect(Float64, o["dE"]))
    dE = max.(dE, 1e-12)                      # so the log axis has something to do
    push!(traces, line(o["t"], dE, label; color = col, width = 1.8))
end
write_fig("integrator_energy", traces,
    layout(title = "Energy error over 200 orbits",
           xaxis = axis("orbits completed"),
           yaxis = axis("|ΔE / E|", type = "log")))

# --------------------------------------------------- order of the methods -----
traces = Any[]
for (key, (label, col)) in NAMES
    s = d["scaling"][key]
    push!(traces, line(s["dt"], s["error"],
                       label * "  (slope " * string(round(Float64(s["order"]), digits = 2)) * ")";
                       color = col, width = 2.0))
    push!(traces, markers(s["dt"], s["error"], ""; color = col, size = 6,
                          showlegend = false))
end
write_fig("integrator_order", traces,
    layout(title = "How the error responds to a smaller step",
           xaxis = axis("δt", type = "log"),
           yaxis = axis("max |ΔE / E| over 5 orbits", type = "log")))
