# This file was generated, do not modify it. # hide
cross_code = """
    Dimension 3;
    Vectors u,v,w;
    Indices i,j,k,m,n;
    
* Cross product definition using Levi-Civita
    Local [ux(vxw)] = e_(i,j,k) * u(i) * (e_(m,n,j) * v(m) * w(n));
    contract;
"""
println(evaluate_form(cross_code))