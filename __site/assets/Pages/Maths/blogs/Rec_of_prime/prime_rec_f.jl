# This file was generated, do not modify it. # hide
#hideall
using Plots
plotlyjs()
p = plot(all_primes, periods, title="Plot of Reciprocal of Primes vs Period",seriestype=:scatter,linewidth=3, label="")
xlabel!("Primes")
ylabel!("Period of Reciprocals")
savefig(p, joinpath(@OUTPUT, "prime_rec.json"))