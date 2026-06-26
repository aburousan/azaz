# This file was generated, do not modify it. # hide
function cal_pi(epsilon)
    setprecision(300)
    c = BigFloat(0.25) + BigFloat(epsilon)
    z = BigFloat(0.0)
    steps = 0
    while abs(z)<2
        z = z^2 + c
        steps += 1
    end
    return steps
end