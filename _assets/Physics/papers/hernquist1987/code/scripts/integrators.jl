# Why leapfrog, and not something that looks more accurate?
#
# A single particle on an eccentric Kepler orbit around a fixed mass, integrated
# four different ways. Explicit Euler and RK4 are not symplectic and lose (or
# gain) energy steadily; leapfrog wobbles but never drifts, which is what a
# simulation run for thousands of steps actually needs.

include(joinpath(@__DIR__, "common.jl"))

const GM = 1.0
accel(x, y) = begin
    r2 = x * x + y * y
    r3 = r2 * sqrt(r2)
    (-GM * x / r3, -GM * y / r3)
end
energy(x, y, vx, vy) = 0.5 * (vx^2 + vy^2) - GM / sqrt(x^2 + y^2)

# Start at apocentre of an ellipse with eccentricity 0.5.
const X0, Y0 = 1.0, 0.0
const VX0, VY0 = 0.0, sqrt(GM / 1.0 * 0.5)     # a = 2/3, e = 0.5
const TPERIOD = 2pi * (2 / 3)^1.5

function integrate(method::Symbol, dt, tmax)
    x, y, vx, vy = X0, Y0, VX0, VY0
    ax, ay = accel(x, y)
    E0 = energy(x, y, vx, vy)
    ts = Float64[0.0]; xs = [x]; ys = [y]; dE = [0.0]
    t = 0.0
    nsave = max(1, round(Int, (tmax / dt) / 1200))
    step = 0
    while t < tmax
        if method === :euler
            # everything evaluated at the old point
            nx = x + dt * vx; ny = y + dt * vy
            vx += dt * ax;    vy += dt * ay
            x, y = nx, ny
            ax, ay = accel(x, y)
        elseif method === :symplectic_euler
            # velocity first, then use the *new* velocity to move
            vx += dt * ax; vy += dt * ay
            x += dt * vx;  y += dt * vy
            ax, ay = accel(x, y)
        elseif method === :leapfrog
            vx += 0.5dt * ax; vy += 0.5dt * ay
            x += dt * vx;     y += dt * vy
            ax, ay = accel(x, y)
            vx += 0.5dt * ax; vy += 0.5dt * ay
        elseif method === :rk4
            f(s) = begin
                a1, a2 = accel(s[1], s[2])
                (s[3], s[4], a1, a2)
            end
            s = (x, y, vx, vy)
            k1 = f(s)
            k2 = f(s .+ (dt / 2) .* k1)
            k3 = f(s .+ (dt / 2) .* k2)
            k4 = f(s .+ dt .* k3)
            s = s .+ (dt / 6) .* (k1 .+ 2 .* k2 .+ 2 .* k3 .+ k4)
            x, y, vx, vy = s
            ax, ay = accel(x, y)
        end
        t += dt; step += 1
        if step % nsave == 0
            push!(ts, t); push!(xs, x); push!(ys, y)
            push!(dE, (energy(x, y, vx, vy) - E0) / abs(E0))
        end
    end
    return ts, xs, ys, dE
end

const METHODS = [:euler, :symplectic_euler, :leapfrog, :rk4]

banner("orbits over 200 periods, dt = T/200")
orbits = Dict{String,Any}()
for m in METHODS
    ts, xs, ys, dE = integrate(m, TPERIOD / 200, 200 * TPERIOD)
    @printf("  %-18s final dE/E = %+.3e, max |dE/E| = %.3e\n",
            m, dE[end], maximum(abs, dE))
    orbits[String(m)] = Dict("t" => short(ts ./ TPERIOD, 5),
                             "x" => short(xs, 5), "y" => short(ys, 5),
                             "dE" => short(dE, 5))
end

banner("how the energy error scales with the step size")
scaling = Dict{String,Any}()
dts = [TPERIOD / n for n in (50, 100, 200, 400, 800, 1600)]
for m in METHODS
    errs = Float64[]
    for dt in dts
        _, _, _, dE = integrate(m, dt, 5 * TPERIOD)
        # for the drifting methods this is the drift, for leapfrog the wobble
        push!(errs, maximum(abs, dE))
    end
    slope = (log(errs[end]) - log(errs[1])) / (log(dts[end]) - log(dts[1]))
    @printf("  %-18s apparent order = %.2f\n", m, slope)
    scaling[String(m)] = Dict("dt" => short(dts, 5), "error" => short(errs, 5),
                              "order" => short(slope, 4))
end

save_result("integrators", Dict("period" => short(TPERIOD),
                                "orbits" => orbits, "scaling" => scaling))
