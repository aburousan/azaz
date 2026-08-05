# Where does the ~1% offset in <n_terms> against the paper come from?
#
# Seed-to-seed scatter is only 0.4-0.6%, so the offset is systematic, not noise.
# The obvious suspect is the geometry of the root cell. My tree uses the tight
# bounding cube of the particles; a code that pads the root, or centres it on
# the origin rather than on the particle distribution, produces a different
# subdivision and therefore accepts a different set of cells.
#
# Padding the root by a factor p and re-measuring tests that directly.

include(joinpath(@__DIR__, "common.jl"))

const N = QUICK ? 4096 : 32768
const PADS = [1.0001, 1.25, 1.5, 2.0, 3.0, 4.0]
const SEEDS = QUICK ? [1987] : [1987, 42, 314]

p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)

"Build a tree whose root cube is `pad` times the tight bounding cube."
function build_padded!(t::Octree, pos, mass, pad; quadrupole = false)
    N = length(mass)
    TreeCodeH87.reset!(t)
    xmin = minimum(view(pos,1,:)); xmax = maximum(view(pos,1,:))
    ymin = minimum(view(pos,2,:)); ymax = maximum(view(pos,2,:))
    zmin = minimum(view(pos,3,:)); zmax = maximum(view(pos,3,:))
    cx = 0.5*(xmin+xmax); cy = 0.5*(ymin+ymax); cz = 0.5*(zmin+zmax)
    L = max(xmax-xmin, ymax-ymin, zmax-zmin) * pad
    TreeCodeH87.newnode!(t, cx, cy, cz, L)
    for i in 1:N
        TreeCodeH87.insert!(t, pos, i)
    end
    TreeCodeH87.fill_moments!(t, pos, mass, 1; quadrupole = quadrupole)
    return t
end

rows = Any[]
for pad in PADS
    nts = Float64[]; errs = Float64[]; depths = Int[]
    for seed in SEEDS
        pos, _, mass = plummer_ics(N; p = p, seed = seed)
        adir = zeros(3, N)
        direct_forces!(adir, pos, mass, 0.0)
        tree = Octree(12N)
        build_padded!(tree, pos, mass, pad)
        a = zeros(3, N)
        nt = tree_forces!(a, tree, pos, mass, 1.0, 0.0)
        push!(nts, nt)
        push!(errs, force_error(a, adir).relative)
        push!(depths, tree_depth(tree))
    end
    @printf("  pad = %6.4f   <n_terms> = %7.2f   error = %.4f%%   depth = %d\n",
            pad, mean(nts), mean(errs), round(Int, mean(depths)))
    push!(rows, Dict("pad" => pad, "nterms" => short(mean(nts)),
                     "error" => short(mean(errs)),
                     "depth" => round(Int, mean(depths))))
end

println("\npaper: <n_terms> = 221, error ~ 1.4% at N = 32768, theta = 1")

save_result("rootcell", Dict("N" => N, "seeds" => SEEDS, "theta" => 1.0,
                             "rows" => rows))
