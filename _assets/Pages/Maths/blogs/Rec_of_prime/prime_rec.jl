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

function period_of_rec_of_prime(p)
	divisors = divisor(p-1)
	res = 0
	for i in divisors
		if big(10)^i % big(p) == big(1)
			res = i
			break
		end
	end
	return res
end
p = 61253
println("The period of $p is = ",period_of_rec_of_prime(p))