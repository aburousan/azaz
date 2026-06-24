# This file was generated, do not modify it. # hide
using Plots; plotlyjs()
fortran_times = [1.26400006, 1.28699994, 1.28999996, 1.27499998, 1.51300001, 1.54900002, 1.55400002, 1.33500004, 1.38000000, 1.36699998]
julia_times = [0.914137, 0.916980, 0.917002, 0.915913, 0.929013, 0.920761, 0.924105, 0.919019, 0.917901, 0.919431]
cpp_times = [0.887531, 0.896439, 0.889580, 0.890078, 1.133180, 0.894600, 0.919426, 0.938797, 0.915501, 0.892737]
r_times = [14.953, 14.750, 14.780, 14.753, 14.952, 15.129, 14.956, 14.788, 14.970, 15.529]
python_times = [19.59793257713318, 19.903280019760132, 19.65820622444153, 19.870051622390747, 19.976346492767334, 19.489915370941162, 19.572935581207275, 19.436674118041992, 19.50352454185486, 19.746686935424805]
iterations = 1:10
p = plot(iterations, fortran_times, label="Fortran", lw=2, marker=:o, markersize=6)
plot!(iterations, julia_times, label="Julia", lw=2, marker=:o, markersize=6)
plot!(iterations, cpp_times, label="C++", lw=2, marker=:o, markersize=6)
plot!(iterations, r_times, label="R", lw=2, marker=:o, markersize=6)
plot!(iterations, python_times, label="Python", lw=2, marker=:o, markersize=6)
xlabel!("Iterations")
ylabel!("Time Taken (seconds)")
title!("Time Comparison of Sum of Primes Across Different Languages")
plot!(legend=:topright)
savefig(p, joinpath(@OUTPUT, "fast_cou10.json"))