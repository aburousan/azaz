# This file was generated, do not modify it. # hide
using Distributions

function Inte_monte1D(f,N,a,b)
    x_v = rand(Uniform(a,b),N)
    return ((b-a)/N)*sum(f.(x_v))
end
g(x) = sqrt(1 - x^2)
N = 1000; a = -1; b = 1;
vv = Inte_monte1D(g,N,a,b)
println("The area of semi-circle for N = $N , a = $a and b = $b is ",vv)