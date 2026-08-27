# Difference between the historical softened quadrupole patch and the exact
# Taylor expansion of the Plummer-softened kernel.

include(joinpath(@__DIR__, "common.jl"))
using LinearAlgebra

const NCLOUD = QUICK ? 80 : 400
const ED = QUICK ? [0.03, 0.1, 0.3] :
    round.(10 .^ range(log10(0.01), log10(0.5), length = 20), sigdigits = 6)
const SD = 0.25
const D = 1.0

function linfit(x, y)
    xb = mean(x)
    yb = mean(y)
    b = sum((x .- xb) .* (y .- yb)) / sum((x .- xb) .^ 2)
    a = yb - b * xb
    return (; a, b)
end

rng = Random.MersenneTwister(822)
pos = SD .* D .* (rand(rng, 3, NCLOUD) .- 0.5)
mass = fill(1.0 / NCLOUD, NCLOUD)
c = com_position(pos, mass)
for k in 1:3
    pos[k, :] .-= c[k]
end

target = reshape([D, 0.37D, -0.19D], 3, 1)
tree = Octree(8NCLOUD)
build_tree!(tree, pos, mass; quadrupole = true, raw_second = true)

rows = Any[]
for ed in ED
    eps = ed * D
    ap = tree_accel(tree, target, 1, 10.0, eps; quadrupole = true)
    ae = tree_accel(tree, target, 1, 10.0, eps; quadrupole = true,
                    exact_softened_quadrupole = true)
    am = tree_accel(tree, target, 1, 10.0, eps; quadrupole = false)
    patch = [ap[1], ap[2], ap[3]]
    exact = [ae[1], ae[2], ae[3]]
    mono = [am[1], am[2], am[3]]
    delta = norm(exact - patch) / norm(mono)
    scale = ed^2 * SD^2
    push!(rows, Dict("eps_over_d" => ed, "delta_over_monopole" => short(delta, 8),
                     "expected_scale" => short(scale, 8),
                     "ratio" => short(delta / scale, 8)))
    @printf("eps/d %.4f  |exact-patch|/mono %.3e  divided by scale %.3e\n",
            ed, delta, delta / scale)
end

fit = linfit(log.([r["eps_over_d"] for r in rows]),
             log.([r["delta_over_monopole"] for r in rows]))
@printf("log-log slope against eps/d: %.3f\n", fit.b)

save_result("softened_quadrupole_patch", Dict(
    "N" => NCLOUD,
    "s_over_d" => SD,
    "rows" => rows,
    "slope_eps_over_d" => short(fit.b, 6),
))
