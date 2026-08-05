# Fig. 8: the force error against the softening length, measured in units of
# the mean interparticle separation lambda.
#
# The point of the figure is that softening and the multipole expansion fight
# each other. The expansion of a cell's potential assumes point masses; once
# eps becomes comparable to the distance to the cell, that assumption fails and
# the quadrupole correction stops helping.

include(joinpath(@__DIR__, "common.jl"))

const N = QUICK ? 2048 : 16384
const RATIOS = QUICK ? [0.0, 1.0] :
    [0.0, 0.005, 0.01, 0.02, 0.05, 0.075, 0.1, 0.15, 0.2, 0.3, 0.4, 0.5,
     0.65, 0.8, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0, 3.5, 4.0, 5.0]
const THETAS = [0.5, 1.0]

p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)
lambda = mean_interparticle_separation(p, N)
pos, _, mass = plummer_ics(N; p = p, seed = 1987)
@printf("N = %d, lambda = %.5f\n", N, lambda)

tree = Octree(8N)
out = Any[]
for th in THETAS, quad in (false, true)
    errs = Float64[]
    for ratio in RATIOS
        eps = ratio * lambda
        # The comparison is against a direct sum with the *same* softening, so
        # what is measured is purely the error of the tree approximation.
        adir = zeros(3, N)
        direct_forces!(adir, pos, mass, eps)
        build_tree!(tree, pos, mass; quadrupole = quad)
        a = zeros(3, N)
        tree_forces!(a, tree, pos, mass, th, eps; quadrupole = quad)
        push!(errs, force_error(a, adir).relative)
        @printf("  theta=%.1f quad=%-5s eps/lambda=%.2f  %.4f%%\n",
                th, quad, ratio, errs[end])
    end
    push!(out, Dict("theta" => th, "quadrupole" => quad,
                    "eps_over_lambda" => RATIOS, "error" => short(errs)))
end

save_result("softening", Dict("N" => N, "lambda" => short(lambda),
                              "curves" => out))
