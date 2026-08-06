# The Plummer model: density-potential pair, and how to draw particles from it.
#
# Hernquist (1987) uses, in his eq. (3.1),
#
#     rho(r) = (3M / 4pi) * r0^2 / (r^2 + r0^2)^(5/2)
#
# with M = 1, r0 = 0.2, G = 1 and a cutoff radius R = 1.

"""
Parameters of a Plummer sphere in the units used throughout: G = 1.

`M` total mass, `r0` scale length, `R` cutoff radius outside which no particle
is placed.
"""
Base.@kwdef struct Plummer
    M::Float64 = 1.0
    r0::Float64 = 0.2
    R::Float64 = 1.0
end

"Mass density at radius `r`."
density(p::Plummer, r) = 3p.M / (4pi) * p.r0^2 / (r^2 + p.r0^2)^2.5

"Mass enclosed inside radius `r`."
enclosed_mass(p::Plummer, r) = p.M * r^3 / (r^2 + p.r0^2)^1.5

"Gravitational potential at radius `r` (negative everywhere)."
potential(p::Plummer, r) = -p.M / sqrt(r^2 + p.r0^2)

"Relative potential psi = -phi, which is what the distribution function eats."
relative_potential(p::Plummer, r) = p.M / sqrt(r^2 + p.r0^2)

"Escape speed at radius `r`."
escape_speed(p::Plummer, r) = sqrt(2 * relative_potential(p, r))

"""
Isotropic distribution function of the Plummer sphere,

    f(E) = (24 sqrt(2) / (7 pi^3)) * (r0^2 / (G^5 M^4)) * (-E)^(7/2),

for -GM/r0 <= E <= 0 and zero otherwise. `E` is the energy per unit mass.
This is the normalisation that comes out of Eddington's inversion; see the
symbolic check on the setup page.
"""
function distribution_function(p::Plummer, E)
    E >= 0 && return 0.0
    E <= -p.M / p.r0 && return 0.0
    return 24 * sqrt(2) / (7 * pi^3) * p.r0^2 / p.M^4 * (-E)^3.5
end

"""
One-dimensional velocity dispersion of the isotropic Plummer model,

    sigma(r) = sigma0 / (1 + (r/r0)^2)^(1/4),   sigma0^2 = GM / (6 r0).
"""
function velocity_dispersion(p::Plummer, r)
    sigma0 = sqrt(p.M / (6 * p.r0))
    return sigma0 / (1 + (r / p.r0)^2)^0.25
end

"""
    sample_radius(p, u)

Invert the cumulative mass profile, truncated at the cutoff radius `R`, for a
uniform deviate `u` in [0, 1). Setting m = M(r)/M and solving

    m = r^3 / (r^2 + r0^2)^(3/2)   =>   r = r0 * m^(1/3) / sqrt(1 - m^(2/3)).
"""
function sample_radius(p::Plummer, u::Float64)
    mmax = enclosed_mass(p, p.R) / p.M
    m = u * mmax
    return p.r0 * cbrt(m) / sqrt(1 - cbrt(m)^2)
end

"""
    sample_speed_fraction(rng)

Draw q = v / v_escape from the Plummer speed distribution. Since f ~ (-E)^(7/2)
and -E = psi(r)(1 - q^2) at fixed radius, the speed distribution at every radius
collapses onto the single universal shape

    g(q) ~ q^2 (1 - q^2)^(7/2),   0 <= q <= 1,

whose maximum is 0.0922 at q = sqrt(2/9). The area under it is 7*pi/512, so von
Neumann rejection against the bound 0.1 accepts (7*pi/512)/0.1 = 43% of the
trials, which is cheap enough.
"""
function sample_speed_fraction(rng)
    while true
        q = rand(rng)
        y = 0.1 * rand(rng)
        if y <= q^2 * (1 - q^2)^3.5
            return q
        end
    end
end

"Random unit vector, uniform on the sphere."
function random_direction(rng)
    z = 2 * rand(rng) - 1
    phi = 2pi * rand(rng)
    s = sqrt(1 - z^2)
    return (s * cos(phi), s * sin(phi), z)
end

"""
    plummer_ics(N; p = Plummer(), seed = 1987)

Build `N` equal-mass particles distributed according to the Plummer model `p`.
Positions come from inverting the truncated mass profile, speeds from the exact
distribution function by rejection, and directions are isotropic. The centre of
mass position and velocity are subtracted at the end so the system starts at
rest at the origin.

Returns `(pos, vel, mass)` with `pos` and `vel` of size 3 x N.
"""
function plummer_ics(N::Integer; p::Plummer = Plummer(), seed::Integer = 1987)
    rng = Random.MersenneTwister(seed)
    pos = zeros(3, N)
    vel = zeros(3, N)
    mass = fill(p.M / N, N)

    for i in 1:N
        r = sample_radius(p, rand(rng))
        nx, ny, nz = random_direction(rng)
        pos[1, i] = r * nx
        pos[2, i] = r * ny
        pos[3, i] = r * nz

        v = sample_speed_fraction(rng) * escape_speed(p, r)
        ux, uy, uz = random_direction(rng)
        vel[1, i] = v * ux
        vel[2, i] = v * uy
        vel[3, i] = v * uz
    end

    # Put the centre of mass at rest at the origin.
    for k in 1:3
        pos[k, :] .-= sum(mass .* pos[k, :]) / p.M
        vel[k, :] .-= sum(mass .* vel[k, :]) / p.M
    end
    return pos, vel, mass
end

"""
    uniform_sphere_ics(N; R = 1, M = 1, seed = 1987)

`N` equal-mass particles spread uniformly through a sphere of radius `R`, at
rest. The paper uses this as the contrasting density profile: no central
concentration, so the tree stays shallow and every particle sees a similar
number of cells.
"""
function uniform_sphere_ics(N::Integer; R::Float64 = 1.0, M::Float64 = 1.0,
                            seed::Integer = 1987)
    rng = Random.MersenneTwister(seed)
    pos = zeros(3, N)
    mass = fill(M / N, N)
    for i in 1:N
        r = R * cbrt(rand(rng))
        nx, ny, nz = random_direction(rng)
        pos[1, i] = r * nx; pos[2, i] = r * ny; pos[3, i] = r * nz
    end
    for k in 1:3
        pos[k, :] .-= sum(mass .* pos[k, :]) / M
    end
    return pos, zeros(3, N), mass
end

"Mean interparticle separation of a uniform sphere, lambda = n^(-1/3)."
uniform_lambda(N::Integer, R::Float64 = 1.0) = (N / (4pi / 3 * R^3))^(-1 / 3)

"""
    mean_interparticle_separation(p, N)

Mean separation `lambda` evaluated at the half-mass radius, which is the natural
scale for the softening length. Taking `n` as the mean number density inside the
half-mass radius, lambda = n^(-1/3). For the truncated model used here
(r0 = 0.2, R = 1) the half-mass radius is 1.24 r0, which gives
lambda = 2.5 r0 N^(-1/3), i.e. 0.031 for N = 4096.
"""
function mean_interparticle_separation(p::Plummer, N::Integer)
    rh = half_mass_radius(p)
    n = (N / 2) / (4pi / 3 * rh^3)
    return n^(-1 / 3)
end

"""
Half-mass radius of the truncated model, found by bisection on M(r) = M(R)/2.
For R -> infinity this tends to the familiar 1.3048 r0.
"""
function half_mass_radius(p::Plummer)
    target = enclosed_mass(p, p.R) / 2
    lo, hi = 0.0, p.R
    for _ in 1:200
        mid = 0.5 * (lo + hi)
        enclosed_mass(p, mid) < target ? (lo = mid) : (hi = mid)
    end
    return 0.5 * (lo + hi)
end
