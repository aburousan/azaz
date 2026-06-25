# This file was generated, do not modify it. # hide
using LinearAlgebra
σ1 = [0 1; 1 0];  σ2 = [0 -im; im 0];  σ3 = [1 0; 0 -1]    # Pauli matrices
T  = [σ1, σ2, σ3] ./ 2                                       # weak-isospin generators
comm(A,B) = A*B - B*A
ε(a,b,c) = ((a-b)*(b-c)*(c-a)) ÷ 2                           # Levi-Civita on (1,2,3)

ok = all(comm(T[a],T[b]) ≈ im*sum(ε(a,b,c)*T[c] for c in 1:3) for a in 1:3, b in 1:3)
println("SU(2) algebra  [Tᵃ,Tᵇ] = i εᵃᵇᶜ Tᶜ  holds: ", ok)

Tplus = T[1] + im*T[2]                                       # raising operator
eL = [0, 1]                                                  # lower member of the doublet
println("T⁺ · e_L = ", real(Tplus*eL), "  → ν_L   (this is a W⁺ emission)")

Casimir = T[1]^2 + T[2]^2 + T[3]^2
println("Casimir T² = ", real(Casimir[1,1]), "·I = (½)(½+1)·I   ⇒ isospin ½")