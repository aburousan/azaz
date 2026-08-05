# Everything measured about a run: energies, the virial ratio, Lagrangian
# radii, centre-of-mass wander, and the force-error statistics of the paper.

"Centre-of-mass position (3-vector)."
function com_position(pos, mass)
    M = sum(mass)
    return [sum(mass[i] * pos[k, i] for i in eachindex(mass)) / M for k in 1:3]
end

"Centre-of-mass velocity (3-vector)."
com_velocity(vel, mass) = com_position(vel, mass)

"Total angular momentum about the origin (3-vector)."
function angular_momentum(pos, vel, mass)
    L = zeros(3)
    @inbounds for i in eachindex(mass)
        x, y, z = pos[1, i], pos[2, i], pos[3, i]
        vx, vy, vz = vel[1, i], vel[2, i], vel[3, i]
        L[1] += mass[i] * (y * vz - z * vy)
        L[2] += mass[i] * (z * vx - x * vz)
        L[3] += mass[i] * (x * vy - y * vx)
    end
    return L
end

"""
    virial_ratio(pos, vel, mass, eps)

Returns `-2K/U`. A system obeying 2<K> + <U> = 0 sits at 1.
"""
function virial_ratio(pos, vel, mass, eps)
    K = kinetic_energy(vel, mass)
    U = potential_energy(pos, mass, eps)
    return -2K / U
end

"""
    clausius_virial(pos, acc, mass)

The Clausius virial W = sum_i m_i r_i . a_i, which is what actually appears in

    (1/2) d^2 I / dt^2 = 2K + W.

For an unsoftened 1/r force W is exactly the potential energy U, which is why
the virial theorem is usually quoted as 2K + U = 0. With softening the two part
company: each pair contributes -m_i m_j r^2 / (r^2 + eps^2)^(3/2) to W but
-m_i m_j / (r^2 + eps^2)^(1/2) to U, so W/U ~ 1 - eps^2/r^2. A softened system
in equilibrium therefore sits at -2K/U slightly below 1, and at -2K/W = 1.
"""
function clausius_virial(pos, acc, mass)
    W = 0.0
    @inbounds for i in eachindex(mass)
        W += mass[i] * (pos[1, i] * acc[1, i] + pos[2, i] * acc[2, i] +
                        pos[3, i] * acc[3, i])
    end
    return W
end

"""
    lagrangian_radii(pos, mass, fracs; center)

Radii containing the given mass fractions, measured from `center` (by default
the centre of mass). These are the curves in Fig. 2 of the paper: if the model
really is in equilibrium they stay flat.
"""
function lagrangian_radii(pos, mass, fracs = (0.1, 0.5, 0.9);
                          center = nothing)
    c = center === nothing ? com_position(pos, mass) : center
    N = length(mass)
    r = Vector{Float64}(undef, N)
    @inbounds for i in 1:N
        r[i] = sqrt((pos[1, i] - c[1])^2 + (pos[2, i] - c[2])^2 +
                    (pos[3, i] - c[3])^2)
    end
    ord = sortperm(r)
    Mtot = sum(mass)
    cum = 0.0
    out = zeros(length(fracs))
    fi = 1
    for idx in ord
        cum += mass[idx]
        while fi <= length(fracs) && cum >= fracs[fi] * Mtot
            out[fi] = r[idx]
            fi += 1
        end
        fi > length(fracs) && break
    end
    return out
end

"""
    force_error(atree, adirect)

The error statistics of the paper. For each Cartesian component i, eq. (3.4)
gives the mean error over the N particles,

    <da_i> = (1/N) sum_j (a_tree - a_direct),

and eq. (3.5) the mean absolute deviation about it,

    A(da_i) = (1/N) sum_j |a_tree - a_direct - <da_i>|.

The relative error quoted in Figs. 6-8 is A(da_i) / abar_i with
abar_i = (1/N) sum_j |a_direct|. All three components are averaged here.

Returns a named tuple `(mean_error, mad, abar, relative)`, `relative` in percent.
"""
function force_error(atree::AbstractMatrix, adirect::AbstractMatrix)
    N = size(atree, 2)
    mean_err = zeros(3)
    mad = zeros(3)
    abar = zeros(3)
    for k in 1:3
        s = 0.0
        for j in 1:N
            s += atree[k, j] - adirect[k, j]
        end
        mean_err[k] = s / N

        d = 0.0
        a = 0.0
        for j in 1:N
            d += abs(atree[k, j] - adirect[k, j] - mean_err[k])
            a += abs(adirect[k, j])
        end
        mad[k] = d / N
        abar[k] = a / N
    end
    rel = 100 * sum(mad) / sum(abar)
    return (mean_error = mean_err, mad = mad, abar = abar, relative = rel)
end

"""
    relaxation_time(pos, mass, cfg; v0, ntest, rng)

Relaxation time by the Standish & Aksnes (1969) test-particle method used in
section IV of the paper. A massless test particle is launched inward from the
edge of the system and the deflections it picks up while crossing are summed,

    t_r = <dt> / <sin^2 Phi>,

with `dt` the transit time and `Phi` the total deflection angle of the crossing.
In a perfectly smooth potential the particle would come out along a straight
line and t_r would be infinite; the graininess of a finite-N force field is what
makes it finite, so this measures how collisional the force calculation is.
"""
function relaxation_time(pos, mass, cfg::RunConfig;
                         v0::Float64 = sqrt(2) / 2, ntest::Integer = 200,
                         Rsys::Float64 = 1.0, dt::Float64 = 0.001,
                         rng = Random.default_rng())
    tree = Octree(max(8 * length(mass), 1024))
    usetree = !(cfg.direct || cfg.theta == 0)
    usetree && build_tree!(tree, pos, mass; quadrupole = cfg.quadrupole)

    transit = Float64[]
    sin2 = Float64[]
    stack = Int32[]

    for _ in 1:ntest
        # Start on a random point of the bounding sphere, aimed at the centre.
        nx, ny, nz = random_direction(rng)
        x = [Rsys * nx, Rsys * ny, Rsys * nz]
        v = [-v0 * nx, -v0 * ny, -v0 * nz]
        v_in = copy(v)

        t = 0.0
        a = test_accel(tree, pos, mass, x, cfg, usetree, stack)
        while t < 100.0
            @. v += 0.5 * dt * a
            @. x += dt * v
            a = test_accel(tree, pos, mass, x, cfg, usetree, stack)
            @. v += 0.5 * dt * a
            t += dt
            # Stop once the particle is back outside and moving outward.
            if sqrt(x[1]^2 + x[2]^2 + x[3]^2) > Rsys &&
               (x[1] * v[1] + x[2] * v[2] + x[3] * v[3]) > 0
                break
            end
        end

        # Angle between the incoming and outgoing velocity directions.
        c = (v_in[1] * v[1] + v_in[2] * v[2] + v_in[3] * v[3]) /
            (sqrt(sum(abs2, v_in)) * sqrt(sum(abs2, v)))
        c = clamp(c, -1.0, 1.0)
        push!(transit, t)
        push!(sin2, 1 - c^2)
    end
    return Statistics.mean(transit) / Statistics.mean(sin2)
end

"Acceleration on a massless test particle sitting at `x`."
function test_accel(tree, pos, mass, x, cfg::RunConfig, usetree::Bool, stack)
    if usetree
        # Append the test particle as an extra column so the walk can use it.
        return tree_accel_at(tree, x, cfg.theta, cfg.eps;
                             quadrupole = cfg.quadrupole, stack = stack)
    end
    ax = ay = az = 0.0
    eps2 = cfg.eps^2
    @inbounds for j in eachindex(mass)
        dx = x[1] - pos[1, j]
        dy = x[2] - pos[2, j]
        dz = x[3] - pos[3, j]
        r2 = dx * dx + dy * dy + dz * dz + eps2
        f = mass[j] / (r2 * sqrt(r2))
        ax -= f * dx; ay -= f * dy; az -= f * dz
    end
    return [ax, ay, az]
end

"""
    tree_accel_at(t, x, theta, eps; quadrupole, stack)

Same walk as `tree_accel` but for an arbitrary point rather than one of the
particles in the tree, which is what a massless test particle needs.
"""
function tree_accel_at(t::Octree, x, theta::Float64, eps::Float64;
                       quadrupole::Bool = false, stack = Int32[])
    empty!(stack)
    push!(stack, Int32(1))
    ax = ay = az = 0.0
    eps2 = eps * eps
    theta2 = theta * theta
    @inbounds while !isempty(stack)
        node = pop!(stack)
        m = t.mass[node]
        m == 0 && continue
        dx = x[1] - t.com[1, node]
        dy = x[2] - t.com[2, node]
        dz = x[3] - t.com[3, node]
        d2 = dx * dx + dy * dy + dz * dz

        if t.leafpart[node] != 0
            r2 = d2 + eps2
            f = m / (r2 * sqrt(r2))
            ax -= f * dx; ay -= f * dy; az -= f * dz
            continue
        end
        s = t.size[node]
        if d2 <= 0 || s * s >= theta2 * d2
            for o in 1:8
                c = t.child[o, node]
                c != 0 && push!(stack, c)
            end
            continue
        end
        r2 = d2 + eps2
        r = sqrt(r2)
        f = m / (r2 * r)
        ax -= f * dx; ay -= f * dy; az -= f * dz
        if quadrupole
            qxx = t.quad[1, node]; qxy = t.quad[2, node]; qxz = t.quad[3, node]
            qyy = t.quad[4, node]; qyz = t.quad[5, node]; qzz = t.quad[6, node]
            qdx = qxx * dx + qxy * dy + qxz * dz
            qdy = qxy * dx + qyy * dy + qyz * dz
            qdz = qxz * dx + qyz * dy + qzz * dz
            dQd = dx * qdx + dy * qdy + dz * qdz
            r5 = r2 * r2 * r
            c1 = 1 / r5
            c2 = 2.5 * dQd / (r5 * r2)
            ax += c1 * qdx - c2 * dx
            ay += c1 * qdy - c2 * dy
            az += c1 * qdz - c2 * dz
        end
    end
    return [ax, ay, az]
end
