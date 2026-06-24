# This file was generated, do not modify it. # hide
using Distributions

function Inte_monte1D_thread(f,N,a,b,th_num=Threads.nthreads())
    tempo = zeros(Float64, th_num)
    n = Int(floor(N/th_num))
    Threads.@threads for i in eachindex(tempo)
        xv = rand(Uniform(a,b),n)
        tempo[Threads.threadid()] += sum(f.(xv))
    end
    return ((b-a)/N)*sum(tempo)
end

function Inte_monte1D(f,N,a,b)
    xv = rand(Uniform(a,b),N)
    return ((b-a)/N)*sum(f.(xv))
end

a = -1; b = 1;
h(x) = sqrt(1-x^2)
N =10^8
println("Single thread")
@time Inte_monte1D(h,N,-1,1)
pi/2
println("----------------------------")
println("Multithreading-- No. of Thread = ",Threads.nthreads())
@time Inte_monte1D_thread(h,N,-1,1)