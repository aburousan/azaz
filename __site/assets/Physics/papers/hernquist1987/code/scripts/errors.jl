# Figs. 6 and 7: how wrong the tree force is, measured against a direct sum.
#
# Fig. 6  relative error against theta, for several N, monopole only, eps = 0
# Fig. 7  ratio of quadrupole error to monopole error, Plummer and uniform
#
# The error measure is the one defined in eqs. (3.4) and (3.5): the mean
# absolute deviation of the acceleration about its mean offset, divided by the
# mean absolute acceleration.

include(joinpath(@__DIR__, "common.jl"))

const NS = QUICK ? [1024] : [1024, 4096, 16384, 32768]
const THETAS = QUICK ? [0.5, 1.0] :
    [0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65,
     0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.8, 2.0]
const EPS = 0.0     # the paper's Figs. 6 and 7 use no softening

function error_curve(pos, mass, thetas; eps = EPS)
    N = length(mass)
    adir = zeros(3, N)
    direct_forces!(adir, pos, mass, eps)
    tree = Octree(8N)
    mono = Float64[]; quad = Float64[]
    ntm = Float64[]; ntq = Float64[]
    for th in thetas
        build_tree!(tree, pos, mass; quadrupole = false)
        am = zeros(3, N)
        nm = tree_forces!(am, tree, pos, mass, th, eps; quadrupole = false)
        push!(mono, force_error(am, adir).relative); push!(ntm, nm)

        build_tree!(tree, pos, mass; quadrupole = true)
        aq = zeros(3, N)
        nq = tree_forces!(aq, tree, pos, mass, th, eps; quadrupole = true)
        push!(quad, force_error(aq, adir).relative); push!(ntq, nq)

        @printf("    theta=%.2f  monopole %.4f%% (<n>=%.0f)  quadrupole %.4f%% (<n>=%.0f)\n",
                th, mono[end], ntm[end], quad[end], ntq[end])
    end
    return mono, quad, ntm, ntq
end

plummer_curves = Any[]
for N in NS
    banner("Plummer, N = $N")
    p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)
    pos, _, mass = plummer_ics(N; p = p, seed = 1987)
    m, q, nm, nq = error_curve(pos, mass, THETAS)
    push!(plummer_curves, Dict("N" => N, "theta" => THETAS,
                               "monopole" => short(m), "quadrupole" => short(q),
                               "nterms_monopole" => short(nm),
                               "nterms_quadrupole" => short(nq)))
end

banner("uniform sphere, N = $(NS[end])")
posU, _, massU = uniform_sphere_ics(NS[end]; seed = 1987)
mU, qU, nmU, nqU = error_curve(posU, massU, THETAS)

# Does the error really fall off like N^(-1/5), as the paper reports?
banner("error against N at fixed theta")
scaling = Any[]
for th in (0.5, 1.0)
    Ns = QUICK ? [512, 1024] : [1024, 2048, 4096, 8192, 16384, 32768]
    errs = Float64[]
    for N in Ns
        p = Plummer(M = 1.0, r0 = 0.2, R = 1.0)
        pos, _, mass = plummer_ics(N; p = p, seed = 1987)
        adir = zeros(3, N); direct_forces!(adir, pos, mass, EPS)
        tree = Octree(8N); build_tree!(tree, pos, mass; quadrupole = false)
        a = zeros(3, N); tree_forces!(a, tree, pos, mass, th, EPS)
        push!(errs, force_error(a, adir).relative)
        @printf("    theta=%.1f N=%6d  %.4f%%\n", th, N, errs[end])
    end
    push!(scaling, Dict("theta" => th, "N" => Ns, "error" => short(errs)))
end

save_result("errors", Dict("plummer" => plummer_curves,
                           "uniform" => Dict("N" => NS[end], "theta" => THETAS,
                                             "monopole" => short(mU),
                                             "quadrupole" => short(qU),
                                             "nterms_monopole" => short(nmU),
                                             "nterms_quadrupole" => short(nqU)),
                           "scaling_with_N" => scaling))
