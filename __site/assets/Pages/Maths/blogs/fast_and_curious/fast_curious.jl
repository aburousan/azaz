# This file was generated, do not modify it. # hide
using Plots; plotlyjs()
fortran_times = [1.070785, 1.068295, 1.089001, 1.070244, 1.081850, 1.065128, 1.072845, 1.061545, 1.102363, 1.090591]
julia_times = [1.63499994, 1.47800002, 1.61299999, 1.49499998, 1.49699996, 1.63900001, 1.62799997, 1.61999996, 1.49999998, 1.61700006]
cpp_times = [10.8402, 11.0474, 12.0759, 11.1812, 11.1218, 11.1408, 11.1379, 10.9725, 11.0904, 11.0407]
r_times = [18.054, 16.135, 16.216, 15.998, 16.240, 15.995, 16.319, 16.181, 16.078, 16.028]
python_times = [20.6143, 20.8444, 20.6110, 22.8873, 20.4012, 20.5705, 20.4197, 20.7123, 20.4700, 20.6882]
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