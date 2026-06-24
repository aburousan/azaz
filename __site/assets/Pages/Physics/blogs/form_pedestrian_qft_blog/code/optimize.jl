# This file was generated, do not modify it. # hide
opt_code = """
    Symbols a, b, c;
    Local F = (a+b+c)^3;
    .sort
    Format O2;
"""
println(evaluate_form(opt_code))