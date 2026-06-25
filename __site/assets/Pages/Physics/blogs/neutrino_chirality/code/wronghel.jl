# This file was generated, do not modify it. # hide
# (Energy E and mass m both in eV)
sources = [("Solar (pp)", 0.42e6, 0.05),
           ("Reactor",    4.0e6,  0.05),
           ("Accelerator", 1.0e9, 0.05),
           ("KATRIN max",  1.0e6,  0.45)]

naive(r)  = 1 - sqrt(1 - r^2)              # loses precision for tiny r
stable(r) = r^2 / (1 + sqrt(1 - r^2))      # algebraically identical, numerically safe

println(rpad("Source",13), rpad("1-v/c (naive)",16), rpad("1-v/c (stable)",16), "P_wrong=(m/2E)²")
for (name, E, m) in sources
    r  = m / E
    Pw = (m / (2E))^2
    println(rpad(name,13),
            rpad(string(round(naive(r),  sigdigits=2)),16),
            rpad(string(round(stable(r), sigdigits=2)),16),
            round(Pw, sigdigits=2))
end