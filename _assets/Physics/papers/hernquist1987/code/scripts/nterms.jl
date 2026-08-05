# Fig. 5: the distribution of the number of force terms per particle, for a
# centrally concentrated Plummer model and for a uniform sphere, both at
# N = 32768 and theta = 1.

include(joinpath(@__DIR__, "common.jl"))

const N = QUICK ? 4096 : 32768
const THETA = 1.0

function nterm_distribution(pos, mass, eps; theta = THETA, quadrupole = false)
    N = length(mass)
    tree = Octree(8N)
    build_tree!(tree, pos, mass; quadrupole = quadrupole)
    acc = zeros(3, N)
    counts = zeros(Int, N)
    tree_forces!(acc, tree, pos, mass, theta, eps;
                 quadrupole = quadrupole, nterms = counts)
    r = [sqrt(sum(abs2, view(pos, :, i))) for i in 1:N]
    return counts, r, tree
end

p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)
epsP = mean_interparticle_separation(p, N)
posP, _, massP = plummer_ics(N; p = p, seed = 1987)
cP, rP, treeP = nterm_distribution(posP, massP, epsP)

posU, _, massU = uniform_sphere_ics(N; seed = 1987)
epsU = uniform_lambda(N)
cU, rU, treeU = nterm_distribution(posU, massU, epsU)

@printf("Plummer:  <nterms> = %.1f  (nodes %d, depth %d)\n",
        mean(cP), node_count(treeP), tree_depth(treeP))
@printf("uniform:  <nterms> = %.1f  (nodes %d, depth %d)\n",
        mean(cU), node_count(treeU), tree_depth(treeU))

"Histogram with fixed bin width, in the style of the paper's Fig. 5."
function histo(counts; width = 10)
    hi = maximum(counts)
    edges = 0:width:(hi + width)
    h = zeros(Int, length(edges) - 1)
    for c in counts
        h[min(fld(c, width) + 1, length(h))] += 1
    end
    return collect(edges[1:end-1]) .+ width / 2, h
end

centersP, histP = histo(cP)
centersU, histU = histo(cU)

# n_terms against radius shows *why* the Plummer distribution has a tail:
# particles out in the sparse halo see fewer cells.
function profile(r, counts; nbin = 40)
    rmax = maximum(r)
    edges = range(0, rmax; length = nbin + 1)
    mid = Float64[]; avg = Float64[]
    for k in 1:nbin
        idx = findall(x -> edges[k] <= x < edges[k+1], r)
        isempty(idx) && continue
        push!(mid, (edges[k] + edges[k+1]) / 2)
        push!(avg, mean(counts[idx]))
    end
    return mid, avg
end
rmP, avP = profile(rP, cP)
rmU, avU = profile(rU, cU)

save_result("nterms", Dict(
    "N" => N, "theta" => THETA,
    "plummer" => Dict("mean" => short(mean(cP)), "centers" => centersP,
                      "counts" => histP, "nodes" => node_count(treeP),
                      "depth" => tree_depth(treeP),
                      "radius" => short(rmP), "nterms_of_r" => short(avP)),
    "uniform" => Dict("mean" => short(mean(cU)), "centers" => centersU,
                      "counts" => histU, "nodes" => node_count(treeU),
                      "depth" => tree_depth(treeU),
                      "radius" => short(rmU), "nterms_of_r" => short(avU))))
