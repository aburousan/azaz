# This file was generated, do not modify it. # hide
using Plots; plotlyjs()
fortran_times = [1.53100002, 1.54400003, 1.53999996, 1.53499997, 1.53799999, 1.53100002, 1.53600001, 1.54299998, 1.54600000, 1.53999996]
julia_times = [0.914137, 0.916980, 0.917002, 0.915913, 0.929013, 0.920761, 0.924105, 0.919019, 0.917901, 0.919431]
cpp_times = [1.29177, 1.23304, 1.23141, 1.23800, 1.23524, 1.23862, 1.23189, 1.23681, 1.23351, 1.23072]
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
savefig(p, joinpath(@OUTPUT, "fast_cou11.json"))