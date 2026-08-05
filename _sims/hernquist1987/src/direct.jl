# The honest O(N^2) sum, used as the yardstick everything else is measured
# against. Softened Kepler pair potential, Hernquist's eq. (2.1),
#
#     phi(r) = - m1 m2 / (r^2 + eps^2)^(1/2).

"""
    direct_forces!(acc, pos, mass, eps)

Every pair, no approximations. This is the `theta = 0` answer.
"""
function direct_forces!(acc::AbstractMatrix, pos::AbstractMatrix,
                        mass::AbstractVector, eps::Float64)
    N = length(mass)
    eps2 = eps * eps
    fill!(acc, 0.0)
    nchunks = min(Threads.nthreads(), N)
    Threads.@sync for c in 1:nchunks
        Threads.@spawn begin
            for i in c:nchunks:N
                ax = ay = az = 0.0
                xi = pos[1, i]; yi = pos[2, i]; zi = pos[3, i]
                @inbounds for j in 1:N
                    j == i && continue
                    dx = xi - pos[1, j]
                    dy = yi - pos[2, j]
                    dz = zi - pos[3, j]
                    r2 = dx * dx + dy * dy + dz * dz + eps2
                    f = mass[j] / (r2 * sqrt(r2))
                    ax -= f * dx; ay -= f * dy; az -= f * dz
                end
                acc[1, i] = ax; acc[2, i] = ay; acc[3, i] = az
            end
        end
    end
    return acc
end

"""
    potential_energy(pos, mass, eps)

Total potential energy, counting each pair once:

    U = - sum_{i<j} m_i m_j / (r_ij^2 + eps^2)^(1/2).
"""
function potential_energy(pos::AbstractMatrix, mass::AbstractVector, eps::Float64)
    N = length(mass)
    eps2 = eps * eps
    nchunks = min(Threads.nthreads(), N)
    partial = zeros(nchunks)
    Threads.@sync for c in 1:nchunks
        Threads.@spawn begin
            s = 0.0
            for i in c:nchunks:N
                xi = pos[1, i]; yi = pos[2, i]; zi = pos[3, i]
                @inbounds for j in (i + 1):N
                    dx = xi - pos[1, j]
                    dy = yi - pos[2, j]
                    dz = zi - pos[3, j]
                    s -= mass[i] * mass[j] / sqrt(dx * dx + dy * dy + dz * dz + eps2)
                end
            end
            partial[c] = s
        end
    end
    return sum(partial)
end

"Total kinetic energy, sum of (1/2) m v^2."
function kinetic_energy(vel::AbstractMatrix, mass::AbstractVector)
    K = 0.0
    @inbounds for i in eachindex(mass)
        K += 0.5 * mass[i] * (vel[1, i]^2 + vel[2, i]^2 + vel[3, i]^2)
    end
    return K
end
