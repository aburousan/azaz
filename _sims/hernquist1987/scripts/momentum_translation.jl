# Momentum conservation and translation covariance checks for the article.

include(joinpath(@__DIR__, "common.jl"))

const N = QUICK ? 1024 : 8192
const SEEDS = QUICK ? [1987] : [1987, 42, 314]
const THETAS = [0.5, 1.0]
const EPS = 0.0
const SHIFT = [0.371, -0.229, 0.483]

function accelerations(pos, mass; theta, quadrupole, direct)
    acc = zeros(3, length(mass))
    if direct
        direct_forces!(acc, pos, mass, EPS)
        return acc, 0.0
    end
    tree = Octree(8 * length(mass))
    build_tree!(tree, pos, mass; quadrupole = quadrupole)
    nt = tree_forces!(acc, tree, pos, mass, theta, EPS; quadrupole = quadrupole)
    return acc, nt
end

rows = Any[]
for seed in SEEDS
    pos, _, mass = plummer_ics(N; seed = seed)
    pos_shifted = copy(pos)
    for k in 1:3
        pos_shifted[k, :] .+= SHIFT[k]
    end

    for (label, theta, quadrupole, direct) in (
        ("direct", 0.0, false, true),
        ("tree theta=0.5", 0.5, true, false),
        ("tree theta=1.0", 1.0, true, false),
    )
        acc, nt = accelerations(pos, mass; theta, quadrupole, direct)
        acc_shifted, nt_shifted =
            accelerations(pos_shifted, mass; theta, quadrupole, direct)

        diffs = [sqrt((acc_shifted[1, i] - acc[1, i])^2 +
                      (acc_shifted[2, i] - acc[2, i])^2 +
                      (acc_shifted[3, i] - acc[3, i])^2) /
                 max(sqrt(acc[1, i]^2 + acc[2, i]^2 + acc[3, i]^2), eps())
                 for i in 1:N]

        row = Dict(
            "seed" => seed,
            "label" => label,
            "theta" => theta,
            "quadrupole" => quadrupole,
            "direct" => direct,
            "nterms" => short(nt),
            "nterms_shifted" => short(nt_shifted),
            "eta_P" => short(net_force_fraction(acc, mass), 8),
            "eta_P_shifted" => short(net_force_fraction(acc_shifted, mass), 8),
            "translation_mean" => short(mean(diffs), 8),
            "translation_max" => short(maximum(diffs), 8),
        )
        push!(rows, row)
        @printf("seed %d  %-15s  eta_P %.3e  translation mean %.3e max %.3e\n",
                seed, label, row["eta_P"], row["translation_mean"],
                row["translation_max"])
    end
end

summary = Any[]
for label in ("direct", "tree theta=0.5", "tree theta=1.0")
    subset = [r for r in rows if r["label"] == label]
    push!(summary, Dict(
        "label" => label,
        "eta_P_mean" => short(mean(r["eta_P"] for r in subset), 8),
        "eta_P_max" => short(maximum(r["eta_P"] for r in subset), 8),
        "translation_mean" => short(mean(r["translation_mean"] for r in subset), 8),
        "translation_max" => short(maximum(r["translation_max"] for r in subset), 8),
        "nterms_mean" => short(mean(r["nterms"] for r in subset)),
    ))
end

save_result("momentum_translation", Dict(
    "N" => N,
    "seeds" => SEEDS,
    "eps" => EPS,
    "shift" => SHIFT,
    "rows" => rows,
    "summary" => summary,
))
