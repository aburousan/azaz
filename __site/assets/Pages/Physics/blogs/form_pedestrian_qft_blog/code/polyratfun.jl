# This file was generated, do not modify it. # hide
poly_code = """
    Symbol x;
    CFunction rat;
    PolyRatFun rat;
    Local F = rat(1, x) + rat(1, 1+x);
"""
println(evaluate_form(poly_code))