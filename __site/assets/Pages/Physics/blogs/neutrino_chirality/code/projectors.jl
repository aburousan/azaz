# This file was generated, do not modify it. # hide
using LinearAlgebra
I2 = Matrix{Int}(I, 2, 2);  Z2 = zeros(Int, 2, 2)
γ5 = [-I2  Z2;  Z2  I2]                 # chiral basis:  diag(-I, +I)
Id = Matrix{Int}(I, 4, 4)
P_L = (Id - γ5) .÷ 2                     # (1 - γ5)/2
P_R = (Id + γ5) .÷ 2                     # (1 + γ5)/2

println("γ5² = I            : ", γ5^2 == Id)
println("P_L + P_R = I       : ", P_L + P_R == Id)
println("P_L is a projector  : ", P_L^2 == P_L)      # P_L² = P_L
println("P_R is a projector  : ", P_R^2 == P_R)
println("P_L P_R = 0 (orthog): ", all(P_L*P_R .== 0))
println("\ndiag(P_L) = ", diag(P_L), "   # keeps the UPPER block → ψ_L")
println("diag(P_R) = ", diag(P_R), "   # keeps the LOWER block → ψ_R")