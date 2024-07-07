# This file was generated, do not modify it. # hide
using Distributions, DataFrames

function Inte_monte1D(f,N,a,b)
    x_v = rand(Uniform(a,b),N)
    return ((b-a)/N)*sum(f.(x_v))
end

inte_results = Float64[]
error = Float64[]
N_vals = Int64[]
a = -1; b = 1;
g(x) = sqrt(1-x^2)
for i in 1:8
    vv = Inte_monte1D(g,10^i,-1,1)
    actual_val = pi/2
    append!(inte_results,vv)
    append!(error,abs(actual_val-vv))
    append!(N_vals,10^i)
end

df = DataFrame(N = N_vals, Integration_Result = inte_results, Error = error)
print(df)