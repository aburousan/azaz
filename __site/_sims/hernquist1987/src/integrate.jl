# Leapfrog, in the kick-drift-kick form.
#
#     v(t + dt/2) = v(t)        + (dt/2) a(t)
#     r(t + dt)   = r(t)        +  dt    v(t + dt/2)
#     v(t + dt)   = v(t + dt/2) + (dt/2) a(t + dt)
#
# One force evaluation per step if the last kick's acceleration is carried over,
# which is what `acc` does here.

"""
Everything a run needs to know about itself: which force method, how strong the
softening, whether quadrupole moments are kept.
"""
Base.@kwdef struct RunConfig
    theta::Float64 = 1.0
    eps::Float64 = 0.032
    quadrupole::Bool = false
    forced_subdivision::Bool = true
    direct::Bool = false          # if true, ignore the tree and sum all pairs
end

"""
    compute_forces!(acc, tree, pos, mass, cfg)

Dispatch to the direct sum or to a freshly built tree, and report the mean
number of terms per particle (zero for the direct sum, where it is just N-1).
"""
function compute_forces!(acc, tree::Octree, pos, mass, cfg::RunConfig)
    if cfg.direct || cfg.theta == 0
        direct_forces!(acc, pos, mass, cfg.eps)
        return float(length(mass) - 1)
    end
    build_tree!(tree, pos, mass; quadrupole = cfg.quadrupole)
    return tree_forces!(acc, tree, pos, mass, cfg.theta, cfg.eps;
                        quadrupole = cfg.quadrupole,
                        forced_subdivision = cfg.forced_subdivision)
end

"""
    leapfrog_step!(pos, vel, acc, tree, mass, dt, cfg)

Advance the system by one step. `acc` must hold a(t) on entry and holds
a(t + dt) on exit.
"""
function leapfrog_step!(pos, vel, acc, tree::Octree, mass, dt::Float64,
                        cfg::RunConfig)
    N = length(mass)
    half = 0.5 * dt
    @inbounds for i in 1:N, k in 1:3
        vel[k, i] += half * acc[k, i]      # kick
    end
    @inbounds for i in 1:N, k in 1:3
        pos[k, i] += dt * vel[k, i]        # drift
    end
    nt = compute_forces!(acc, tree, pos, mass, cfg)
    @inbounds for i in 1:N, k in 1:3
        vel[k, i] += half * acc[k, i]      # kick
    end
    return nt
end

"""
    evolve!(pos, vel, mass, cfg; dt, nsteps, callback, every)

Run the system for `nsteps` leapfrog steps. `callback(step, t, pos, vel, acc)`
is called every `every` steps, and at step 0, so diagnostics can be collected
without the integrator knowing anything about them.
"""
function evolve!(pos, vel, mass, cfg::RunConfig;
                 dt::Float64 = 0.025, nsteps::Integer = 1000,
                 callback = nothing, every::Integer = 1)
    N = length(mass)
    acc = zeros(3, N)
    tree = Octree(max(8N, 1024))
    compute_forces!(acc, tree, pos, mass, cfg)
    callback === nothing || callback(0, 0.0, pos, vel, acc)
    for step in 1:nsteps
        leapfrog_step!(pos, vel, acc, tree, mass, dt, cfg)
        if callback !== nothing && (step % every == 0 || step == nsteps)
            callback(step, step * dt, pos, vel, acc)
        end
    end
    return pos, vel, acc
end
