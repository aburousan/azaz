# This file was generated, do not modify it. # hide
E1 = 10.0; E2 = 5.0
steps = 100
energies_1, energies_2, temperatures_1, temperatures_2 = heat_transfer(E1, E2, steps)
plot(energies_1, label="Energy of Body 1 (E1)", xlabel="Steps", ylabel="Energy", lw=2,title="Energy Transfer between Bodies")
p1 = plot!(energies_2,lw=2, label="Energy of Body 2 (E2)")
savefig(p1, joinpath(@OUTPUT, "plotlytemp_stat01.json"))
plot(temperatures_1, lw=2, label="Temperature of Body 1 (T1)", xlabel="Steps", ylabel="Temperature", title="Temperature Equilibration between Bodies")
p2 = plot!(temperatures_2,lw=2, label="Temperature of Body 2 (T2)")
savefig(p2, joinpath(@OUTPUT, "plotlytemp_stat02.json"))