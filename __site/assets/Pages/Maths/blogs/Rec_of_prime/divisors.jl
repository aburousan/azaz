# This file was generated, do not modify it. # hide
using Primes # will be using this library
function divisor(n)
	d = Int64[1]
	for (p,e) in factor(n)
		t = Int64[]
		r = 1
		for i in 1:e
			r *= p
			for u in d
				push!(t, u*r)
			end
		end
		append!(d,t)
	end
	return sort(d)
end
println("The divisors of 22 is = ",divisor(22))