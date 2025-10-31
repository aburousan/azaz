# This file was generated, do not modify it. # hide
monomials = [x^i for i in 0:5]
hermite_polynomials = gram_schmidt(monomials,-oo,oo;w=exp(-x^2))
her_f = normalized.(hermite_polynomials)
println("Without normalization:")
for (i, poly) in enumerate(hermite_polynomials)
    println("H_$(i-1)(x) = $poly")
end
println("With Normalization:")
for (i, poly) in enumerate(her_f)
    println("H'_$(i-1)(x) = $poly")
end