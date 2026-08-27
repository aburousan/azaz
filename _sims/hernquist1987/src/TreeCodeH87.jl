"""
    TreeCodeH87

A Julia recreation of the Barnes-Hut tree code analysed in

    Hernquist, L. 1987, ApJS, 64, 715, "Performance Characteristics of Tree Codes"

Units are the ones the paper uses: G = 1, total mass M = 1, and lengths measured
in units of the cutoff radius of the Plummer sphere.
"""
module TreeCodeH87

using LinearAlgebra
using Printf
using Random
using Statistics

export Plummer, plummer_ics, density, enclosed_mass, potential,
       relative_potential, escape_speed, distribution_function,
       velocity_dispersion, half_mass_radius, mean_interparticle_separation,
       uniform_sphere_ics, uniform_lambda, random_direction,
       Octree, build_tree!, tree_accel, tree_forces!, tree_accel_at,
       direct_forces!, potential_energy, kinetic_energy,
       RunConfig, compute_forces!, leapfrog_step!, evolve!,
       com_position, com_velocity, angular_momentum, virial_ratio,
       clausius_virial, net_force, net_force_fraction,
       lagrangian_radii, force_error, relaxation_time,
       tree_depth, node_count,
       fill_raw_moments!, octupole_accel, quadrupole_from_raw, yoshida4_step!, evolve4!

include("plummer.jl")
include("tree.jl")
include("octupole.jl")
include("direct.jl")
include("integrate.jl")
include("diagnostics.jl")

"Number of nodes actually used by the tree."
node_count(t::Octree) = t.nnodes

"Depth of the deepest leaf, counting the root as level 1."
function tree_depth(t::Octree, node::Integer = 1, level::Integer = 1)
    t.leafpart[node] != 0 && return level
    d = level
    for o in 1:8
        c = t.child[o, node]
        c == 0 && continue
        d = max(d, tree_depth(t, c, level + 1))
    end
    return d
end

end # module
