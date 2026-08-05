# The n = 3 term of the multipole expansion, which the paper stops short of.
#
# Continuing the Legendre series one order further,
#
#     phi_3 = -(G/2) O_ijk d_i d_j d_k / d^7
#
# with the traceless octupole tensor
#
#     O_ijk = sum_m [ 5 s_i s_j s_k - s^2 (s_i delta_jk + s_j delta_ik + s_k delta_ij) ]
#
# Keeping it takes the truncation error from O((s/d)^3) to O((s/d)^4).
#
# Rather than shifting the traceless tensors between levels of the tree, which
# gets unpleasant at rank 3, the *raw* moments are stored,
#
#     M2_ij  = sum m s_i s_j,      M3_ijk = sum m s_i s_j s_k
#
# because those have a clean binomial shifting rule. Q and O are reconstructed
# from them only when a cell is actually used.

"Index into the 6 stored components of a symmetric rank-2 tensor."
const M2IDX = [1 2 3; 2 4 5; 3 5 6]

"Index into the 10 stored components of a symmetric rank-3 tensor."
const M3IDX = begin
    A = zeros(Int, 3, 3, 3)
    ord = Dict((1,1,1)=>1, (1,1,2)=>2, (1,1,3)=>3, (1,2,2)=>4, (1,2,3)=>5,
               (1,3,3)=>6, (2,2,2)=>7, (2,2,3)=>8, (2,3,3)=>9, (3,3,3)=>10)
    for i in 1:3, j in 1:3, k in 1:3
        A[i, j, k] = ord[Tuple(sort([i, j, k]))]
    end
    A
end

"""
    fill_raw_moments!(t, pos, mass, node)

Bottom-up sweep filling the raw second and third moments of every cell about
its own centre of mass. For a parent built from subcells at offsets `R_l`,
writing `y` for a particle's position relative to its own subcell's centre,
`s = R_l + y` gives

    M2'_ij  = sum_l [ M2_ij + m_l R_i R_j ]
    M3'_ijk = sum_l [ M3_ijk + R_i M2_jk + R_j M2_ik + R_k M2_ij + m_l R_i R_j R_k ]

Every term linear in `y` drops out because `sum m y = 0` inside a subcell --
the same cancellation that kills the dipole and makes the parallel-axis
theorem work.
"""
function fill_raw_moments!(t::Octree, pos::AbstractMatrix, mass::AbstractVector,
                           node::Integer)
    p = t.leafpart[node]
    if p != 0
        # A point particle sits at its own centre of mass, so every moment
        # about that point vanishes.
        for k in 1:6;  t.m2[k, node] = 0.0; end
        for k in 1:10; t.m3[k, node] = 0.0; end
        return
    end

    for k in 1:6;  t.m2[k, node] = 0.0; end
    for k in 1:10; t.m3[k, node] = 0.0; end

    for o in 1:8
        c = t.child[o, node]
        c == 0 && continue
        fill_raw_moments!(t, pos, mass, c)
        mc = t.mass[c]
        mc == 0 && continue
        R = (t.com[1, c] - t.com[1, node],
             t.com[2, c] - t.com[2, node],
             t.com[3, c] - t.com[3, node])

        @inbounds for i in 1:3, j in i:3
            t.m2[M2IDX[i, j], node] += t.m2[M2IDX[i, j], c] + mc * R[i] * R[j]
        end
        @inbounds for i in 1:3, j in i:3, k in j:3
            t.m3[M3IDX[i, j, k], node] +=
                t.m3[M3IDX[i, j, k], c] +
                R[i] * t.m2[M2IDX[j, k], c] +
                R[j] * t.m2[M2IDX[i, k], c] +
                R[k] * t.m2[M2IDX[i, j], c] +
                mc * R[i] * R[j] * R[k]
        end
    end
    return
end

"""
    octupole_accel(t, node, dx, dy, dz, d2, r2)

Acceleration contribution of the n = 3 term, given the offset `d` from the
cell's centre of mass, the geometric `d2 = |d|^2`, and the softened
`r2 = d2 + eps^2`. Returns `(ax, ay, az)`.
"""
@inline function octupole_accel(t::Octree, node::Integer, dx, dy, dz, d2, r2)
    @inbounds begin
        m1  = t.m3[1,  node]; m2_  = t.m3[2, node]; m3_ = t.m3[3, node]
        m4  = t.m3[4,  node]; m5   = t.m3[5, node]; m6  = t.m3[6, node]
        m7  = t.m3[7,  node]; m8   = t.m3[8, node]; m9  = t.m3[9, node]
        m10 = t.m3[10, node]
    end
    # T_i = M3_ill, the trace over the last two indices
    T1 = m1 + m4 + m6
    T2 = m2_ + m7 + m9
    T3 = m3_ + m8 + m10

    # A_l = M3_ljk d_j d_k
    dxx = dx * dx; dyy = dy * dy; dzz = dz * dz
    dxy = dx * dy; dxz = dx * dz; dyz = dy * dz
    A1 = m1 * dxx + 2m2_ * dxy + 2m3_ * dxz + m4 * dyy + 2m5 * dyz + m6 * dzz
    A2 = m2_ * dxx + 2m4 * dxy + 2m5 * dxz + m7 * dyy + 2m8 * dyz + m9 * dzz
    A3 = m3_ * dxx + 2m5 * dxy + 2m6 * dxz + m8 * dyy + 2m9 * dyz + m10 * dzz

    B  = A1 * dx + A2 * dy + A3 * dz          # M3_ijk d_i d_j d_k
    Td = T1 * dx + T2 * dy + T3 * dz

    # V_l = O_ljk d_j d_k   and   S3 = O_ijk d_i d_j d_k
    V1 = 5A1 - T1 * d2 - 2Td * dx
    V2 = 5A2 - T2 * d2 - 2Td * dy
    V3 = 5A3 - T3 * d2 - 2Td * dz
    S3 = 5B - 3Td * d2

    r = sqrt(r2)
    r7 = r2 * r2 * r2 * r
    c1 = 1.5 / r7
    c2 = 3.5 * S3 / (r7 * r2)
    return (c1 * V1 - c2 * dx, c1 * V2 - c2 * dy, c1 * V3 - c2 * dz)
end

"""
    quadrupole_from_raw(t, node)

Reconstruct the traceless quadrupole `Q_ij = 3 M2_ij - delta_ij tr(M2)` from
the stored raw moments. Used to check the two routes agree.
"""
function quadrupole_from_raw(t::Octree, node::Integer)
    m = t.m2[:, node]
    tr = m[1] + m[4] + m[6]
    return [3m[1]-tr  3m[2]     3m[3];
            3m[2]     3m[4]-tr  3m[5];
            3m[3]     3m[5]     3m[6]-tr]
end
