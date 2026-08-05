# One cell, one distant particle: how good is the multipole approximation?
#
# A cloud of particles is packed into a cube of side s, and the acceleration it
# produces at distance d is computed three ways -- exactly, keeping only the
# monopole, and keeping the quadrupole too. Sweeping s/d shows the two error
# laws the whole tree method rests on:
#
#     monopole only        error ~ (s/d)^2
#     through quadrupole   error ~ (s/d)^3
#
# The dipole is missing from that list because the expansion is taken about the
# centre of mass, where it vanishes identically.

include(joinpath(@__DIR__, "common.jl"))
using LinearAlgebra

const NCLOUD = 200
const NDIR = 400        # directions averaged over, so the answer is not special

function cloud(s, seed)
    rng = Random.MersenneTwister(seed)
    pts = s .* (rand(rng, 3, NCLOUD) .- 0.5)
    m = fill(1.0 / NCLOUD, NCLOUD)
    c = [sum(m .* pts[k, :]) for k in 1:3]
    pts .-= c                                  # centre of mass at the origin
    return pts, m
end

"Exact acceleration at x from every particle of the cloud."
function exact_accel(pts, m, x)
    a = zeros(3)
    for i in eachindex(m)
        d = x .- pts[:, i]
        r = norm(d)
        a .-= m[i] .* d ./ r^3
    end
    return a
end

"Monopole, and monopole + quadrupole, using eq. (2.4)."
function multipole_accel(pts, m, x, Q, M)
    r = norm(x)
    mono = -M .* x ./ r^3
    quad = mono .+ (Q * x) ./ r^5 .- 2.5 * (x' * Q * x) .* x ./ r^7
    return mono, quad
end

function quadrupole(pts, m)
    Q = zeros(3, 3)
    for i in eachindex(m)
        v = pts[:, i]
        r2 = dot(v, v)
        for a in 1:3, b in 1:3
            Q[a, b] += m[i] * (3v[a] * v[b] - (a == b ? r2 : 0.0))
        end
    end
    return Q
end

const RATIOS = [0.02, 0.03, 0.05, 0.08, 0.12, 0.18, 0.25, 0.35, 0.5, 0.7, 1.0]

emono = Float64[]; equad = Float64[]
rng = Random.MersenneTwister(99)
for sd in RATIOS
    s = 1.0                       # cell side fixed, distance varied instead
    d = s / sd
    pts, m = cloud(s, 12345)
    Q = quadrupole(pts, m)
    M = sum(m)
    em = 0.0; eq = 0.0
    for _ in 1:NDIR
        nx, ny, nz = random_direction(rng)
        x = d .* [nx, ny, nz]
        ex = exact_accel(pts, m, x)
        mo, qu = multipole_accel(pts, m, x, Q, M)
        em += norm(mo .- ex) / norm(ex)
        eq += norm(qu .- ex) / norm(ex)
    end
    push!(emono, em / NDIR); push!(equad, eq / NDIR)
    @printf("  s/d = %.3f   monopole %.3e   quadrupole %.3e\n",
            sd, emono[end], equad[end])
end

fitslope(x, y) = begin
    lx = log.(x); ly = log.(y)
    n = length(x)
    (n * sum(lx .* ly) - sum(lx) * sum(ly)) / (n * sum(lx .^ 2) - sum(lx)^2)
end
# fit on the small-s/d end, where the leading term dominates
k = 6
sm = fitslope(RATIOS[1:k], emono[1:k])
sq = fitslope(RATIOS[1:k], equad[1:k])
@printf("\nfitted slopes: monopole %.2f, quadrupole %.2f\n", sm, sq)

save_result("multipole_error", Dict(
    "s_over_d" => RATIOS, "monopole" => short(emono), "quadrupole" => short(equad),
    "slope_monopole" => short(sm, 4), "slope_quadrupole" => short(sq, 4),
    "ncloud" => NCLOUD, "ndirections" => NDIR))
