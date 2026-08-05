using JSON3, Printf, Statistics, Random
include(joinpath(@__DIR__, "..", "src", "TreeCodeH87.jl"))
using .TreeCodeH87

const DATA = joinpath(@__DIR__, "..", "data")
mkpath(DATA)

"Pass --quick on the command line to run cut-down versions while testing."
const QUICK = "--quick" in ARGS

"Write a result to data/<name>.json."
function save_result(name::AbstractString, obj)
    path = joinpath(DATA, name * ".json")
    open(path, "w") do io
        JSON3.write(io, obj)
    end
    @printf("wrote %s (%.1f kB)\n", path, filesize(path) / 1024)
    return path
end

"Round to keep the JSON files small; plots do not need 17 digits."
short(x::Real, n = 6) = round(float(x), sigdigits = n)
short(v::AbstractArray, n = 6) = short.(v, n)

banner(msg) = println("\n", "="^70, "\n", msg, "\n", "="^70)
