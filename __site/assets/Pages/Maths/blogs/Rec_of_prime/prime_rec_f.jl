# This file was generated, do not modify it. # hide
using Primes
using DataFrames
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
all_primes = primes(7, 110000)#retrun all primes in range 5 to 1,10,000
periods = period_of_rec_of_prime.(all_primes)
df = DataFrame(Primes = all_primes, Reciprocal_Periods = periods)
print(last(df,50))# give table like shank, just showing last 50