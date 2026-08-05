using Test
using Random, Statistics, LinearAlgebra
include(joinpath(@__DIR__, "..", "src", "TreeCodeH87.jl"))
using .TreeCodeH87

@testset "Plummer model" begin
    p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)

    # Poisson equation: laplacian(phi) = 4 pi G rho, checked numerically.
    for r in (0.05, 0.15, 0.4, 0.8)
        h = 1e-4
        # radial laplacian = (1/r^2) d/dr (r^2 dphi/dr)
        f(x) = x^2 * (potential(p, x + h) - potential(p, x - h)) / (2h)
        lap = (f(r + h) - f(r - h)) / (2h) / r^2
        @test isapprox(lap, 4pi * density(p, r); rtol = 1e-4)
    end

    # M(r) is the integral of rho.
    for r in (0.1, 0.5, 1.0)
        n = 20000
        s = 0.0
        for k in 1:n
            x = r * (k - 0.5) / n
            s += 4pi * x^2 * density(p, x) * (r / n)
        end
        @test isapprox(s, enclosed_mass(p, r); rtol = 1e-4)
    end

    # The half-mass radius of the truncated model should land near 1.24 r0.
    @test isapprox(half_mass_radius(p) / p.r0, 1.24; atol = 0.01)

    # ... and the softening scale near 2.5 r0 N^(-1/3) = 0.031 for N = 4096.
    @test isapprox(mean_interparticle_separation(p, 4096), 0.0314; atol = 0.002)

    # The distribution function must integrate back to the density,
    # rho(r) = 4 pi int_0^{v_esc} v^2 f(psi - v^2/2) dv.
    for r in (0.1, 0.3, 0.7)
        psi = relative_potential(p, r)
        ve = escape_speed(p, r)
        n = 40000
        s = 0.0
        for k in 1:n
            v = ve * (k - 0.5) / n
            s += 4pi * v^2 * distribution_function(p, -(psi - v^2 / 2)) * (ve / n)
        end
        @test isapprox(s, density(p, r); rtol = 1e-3)
    end
end

@testset "sampled initial conditions" begin
    p = Plummer()
    N = 20000
    pos, vel, mass = plummer_ics(N; p = p, seed = 7)

    @test isapprox(sum(mass), 1.0; rtol = 1e-12)
    @test all(abs.(com_position(pos, mass)) .< 1e-12)
    @test all(abs.(com_velocity(vel, mass)) .< 1e-12)

    r = [sqrt(sum(abs2, view(pos, :, i))) for i in 1:N]
    @test maximum(r) < 1.05 * p.R

    # The sampled mass profile should follow M(r), normalised to the cutoff.
    Mtot = enclosed_mass(p, p.R)
    for rt in (0.1, 0.2, 0.4, 0.8)
        frac = count(<(rt), r) / N
        @test isapprox(frac, enclosed_mass(p, rt) / Mtot; atol = 0.01)
    end

    # And the velocity dispersion should follow sigma(r) = sigma0 (1+(r/r0)^2)^(-1/4).
    for (lo, hi) in ((0.05, 0.15), (0.2, 0.3), (0.4, 0.6))
        idx = findall(x -> lo < x < hi, r)
        vs = vec(vel[:, idx])
        rm = mean(r[idx])
        @test isapprox(std(vs), velocity_dispersion(p, rm); rtol = 0.1)
    end
end

@testset "tree reproduces the direct sum" begin
    p = Plummer()
    N = 2000
    pos, vel, mass = plummer_ics(N; p = p, seed = 11)
    eps = mean_interparticle_separation(p, N)

    adir = zeros(3, N)
    direct_forces!(adir, pos, mass, eps)

    t = Octree(8N)

    # theta = 0 opens every cell, so the walk must give the direct answer to
    # round-off. This is the single most important check on the tree.
    build_tree!(t, pos, mass; quadrupole = false)
    a0 = zeros(3, N)
    tree_forces!(a0, t, pos, mass, 0.0, eps)
    @test maximum(abs.(a0 .- adir)) < 1e-10 * maximum(abs.(adir))

    # The tree must not lose or double-count mass.
    @test isapprox(t.mass[1], sum(mass); rtol = 1e-12)
    @test all(abs.(t.com[:, 1] .- com_position(pos, mass)) .< 1e-12)

    # The root quadrupole must equal the brute-force sum over all particles.
    # This is the real test of the parallel-axis recursion, eq. (2.5): the root
    # never sees a particle directly, it only ever adds up its eight children.
    build_tree!(t, pos, mass; quadrupole = true)
    c = com_position(pos, mass)
    Q = zeros(3, 3)
    for i in 1:N, a in 1:3, b in 1:3
        xa = pos[a, i] - c[a]
        xb = pos[b, i] - c[b]
        r2 = sum((pos[k, i] - c[k])^2 for k in 1:3)
        Q[a, b] += mass[i] * (3xa * xb - (a == b ? r2 : 0.0))
    end
    Qt = [t.quad[1,1] t.quad[2,1] t.quad[3,1]
          t.quad[2,1] t.quad[4,1] t.quad[5,1]
          t.quad[3,1] t.quad[5,1] t.quad[6,1]]
    @test maximum(abs.(Q .- Qt)) < 1e-10 * maximum(abs.(Q))
    @test abs(tr(Qt)) < 1e-10 * maximum(abs.(Q))   # traceless by construction

    # Errors should shrink as theta shrinks, and quadrupoles should beat
    # monopoles at the same theta.
    prev = Inf
    for theta in (1.0, 0.7, 0.5, 0.3)
        build_tree!(t, pos, mass; quadrupole = false)
        am = zeros(3, N)
        tree_forces!(am, t, pos, mass, theta, eps)
        em = force_error(am, adir).relative
        @test em < prev
        prev = em

        build_tree!(t, pos, mass; quadrupole = true)
        aq = zeros(3, N)
        tree_forces!(aq, t, pos, mass, theta, eps; quadrupole = true)
        eq = force_error(aq, adir).relative
        @test eq < em
    end
end

@testset "quadrupole acceleration is minus grad of the potential" begin
    # Take a small cloud, and compare the analytic multipole acceleration
    # against a numerical gradient of the multipole potential, far away.
    rng = MersenneTwister(3)
    pos = 0.05 .* randn(rng, 3, 40)
    mass = fill(1 / 40, 40)
    c = com_position(pos, mass)
    Q = zeros(3, 3)
    for i in 1:40, a in 1:3, b in 1:3
        xa = pos[a, i] - c[a]; xb = pos[b, i] - c[b]
        r2 = sum((pos[k, i] - c[k])^2 for k in 1:3)
        Q[a, b] += mass[i] * (3xa * xb - (a == b ? r2 : 0.0))
    end
    M = sum(mass)

    phi(x) = begin
        d = x .- c
        r = norm(d)
        -M / r - 0.5 * (d' * Q * d) / r^5
    end
    accel(x) = begin
        d = x .- c
        r = norm(d)
        -M * d / r^3 + Q * d / r^5 - 2.5 * (d' * Q * d) * d / r^7
    end

    for x0 in ([1.0, 0.3, -0.7], [0.0, 0.0, 2.0], [-1.5, 0.4, 0.2])
        num = zeros(3)
        h = 1e-6
        for k in 1:3
            xp = copy(x0); xp[k] += h
            xm = copy(x0); xm[k] -= h
            num[k] = -(phi(xp) - phi(xm)) / (2h)
        end
        @test isapprox(num, accel(x0); rtol = 1e-6)
    end
end

@testset "leapfrog" begin
    # A two-body circular orbit is the cleanest test of the integrator:
    # after one period the particles must come back to where they started.
    mass = [0.5, 0.5]
    r = 1.0
    # Each particle circles the common centre at radius r, so its centripetal
    # acceleration v^2/r must equal G m_other / (2r)^2.
    v = sqrt(mass[2] / (4r))
    pos = zeros(3, 2); pos[1, 1] = r; pos[1, 2] = -r
    vel = zeros(3, 2); vel[2, 1] = v; vel[2, 2] = -v
    T = 2pi * sqrt((2r)^3 / sum(mass))

    cfg = RunConfig(theta = 0.0, eps = 0.0, direct = true)
    nsteps = 20000
    evolve!(pos, vel, mass, cfg; dt = T / nsteps, nsteps = nsteps)
    @test isapprox(pos[1, 1], r; atol = 1e-4)
    @test isapprox(pos[2, 1], 0.0; atol = 1e-4)

    # On an eccentric orbit the energy visibly wobbles, largest at pericentre,
    # but it stays bounded instead of drifting -- that is what makes leapfrog
    # worth using. The size of the wobble is second order, so halving dt should
    # cut it by about four.
    errs = Float64[]
    for dt in (0.02, 0.01)
        pos = zeros(3, 2); pos[1, 1] = r; pos[1, 2] = -r
        vel = zeros(3, 2); vel[2, 1] = 0.6v; vel[2, 2] = -0.6v
        E0 = kinetic_energy(vel, mass) + potential_energy(pos, mass, 0.0)
        worst = 0.0
        watch = (step, t, p, vv, a) -> begin
            E = kinetic_energy(vv, mass) + potential_energy(p, mass, 0.0)
            worst = max(worst, abs((E - E0) / E0))
        end
        evolve!(pos, vel, mass, cfg; dt = dt, nsteps = round(Int, 3T / dt),
                callback = watch)
        push!(errs, worst)
    end
    @test 3.0 < errs[1] / errs[2] < 5.0
end

@testset "virial theorem" begin
    # Sampled from its own distribution function with no cutoff, the Plummer
    # sphere sits on 2K + U = 0.
    pos, vel, mass = plummer_ics(30000; p = Plummer(r0 = 0.2, R = 20.0), seed = 21)
    @test isapprox(virial_ratio(pos, vel, mass, 0.0), 1.0; atol = 0.01)

    # The model the paper actually uses is cut off at R = 1, which holds 94.3%
    # of the mass of the full Plummer sphere. Renormalising that to unit mass
    # deepens the potential while the velocities were drawn for the shallower
    # one, so the start is slightly sub-virial. This is the "brief transient"
    # the paper mentions before the model settles down -- not an error.
    pos, vel, mass = plummer_ics(30000; p = Plummer(r0 = 0.2, R = 1.0), seed = 21)
    q = virial_ratio(pos, vel, mass, 0.0)
    @test 0.94 < q < 0.98
end

@testset "octupole" begin
    p = Plummer()
    N = 2000
    pos, _, mass = plummer_ics(N; p = p, seed = 11)
    eps = 0.0

    adir = zeros(3, N)
    direct_forces!(adir, pos, mass, eps)
    t = Octree(8N)

    # The raw moments must reproduce the independently-computed quadrupole.
    build_tree!(t, pos, mass; quadrupole = true, octupole = true)
    Qraw = quadrupole_from_raw(t, 1)
    Qtree = [t.quad[1,1] t.quad[2,1] t.quad[3,1]
             t.quad[2,1] t.quad[4,1] t.quad[5,1]
             t.quad[3,1] t.quad[5,1] t.quad[6,1]]
    @test maximum(abs.(Qraw .- Qtree)) < 1e-9 * maximum(abs.(Qtree))

    # The root's raw third moment must equal a brute-force sum over particles.
    c = com_position(pos, mass)
    M3 = zeros(3, 3, 3)
    for n in 1:N, i in 1:3, j in 1:3, k in 1:3
        M3[i,j,k] += mass[n] * (pos[i,n]-c[i]) * (pos[j,n]-c[j]) * (pos[k,n]-c[k])
    end
    worst = 0.0
    for i in 1:3, j in 1:3, k in 1:3
        worst = max(worst, abs(M3[i,j,k] - t.m3[TreeCodeH87.M3IDX[i,j,k], 1]))
    end
    @test worst < 1e-9 * maximum(abs.(M3))

    # Octupole must strictly beat quadrupole, which must beat monopole.
    for theta in (1.0, 0.7, 0.5)
        build_tree!(t, pos, mass; quadrupole = false)
        am = zeros(3, N); tree_forces!(am, t, pos, mass, theta, eps)
        em = force_error(am, adir).relative

        build_tree!(t, pos, mass; quadrupole = true)
        aq = zeros(3, N); tree_forces!(aq, t, pos, mass, theta, eps; quadrupole = true)
        eq = force_error(aq, adir).relative

        build_tree!(t, pos, mass; quadrupole = true, octupole = true)
        ao = zeros(3, N)
        tree_forces!(ao, t, pos, mass, theta, eps; quadrupole = true, octupole = true)
        eo = force_error(ao, adir).relative

        @test eq < em
        @test eo < eq
    end
end

@testset "fourth-order integrator" begin
    # Same two-body test as leapfrog, but the error should now fall like dt^4.
    mass = [0.5, 0.5]
    r = 1.0
    v = sqrt(mass[2] / (4r))
    T = 2pi * sqrt((2r)^3 / sum(mass))
    cfg = RunConfig(theta = 0.0, eps = 0.0, direct = true)

    errs = Float64[]
    for dt in (0.08, 0.04)
        pos = zeros(3, 2); pos[1, 1] = r; pos[1, 2] = -r
        vel = zeros(3, 2); vel[2, 1] = 0.6v; vel[2, 2] = -0.6v
        E0 = kinetic_energy(vel, mass) + potential_energy(pos, mass, 0.0)
        worst = 0.0
        watch = (step, tt, p, vv, a) -> begin
            E = kinetic_energy(vv, mass) + potential_energy(p, mass, 0.0)
            worst = max(worst, abs((E - E0) / E0))
        end
        evolve4!(pos, vel, mass, cfg; dt = dt, nsteps = round(Int, 3T / dt),
                 callback = watch)
        push!(errs, worst)
    end
    # halving dt should cut the error by ~16 for a fourth-order scheme
    @test 10.0 < errs[1] / errs[2] < 25.0
end
