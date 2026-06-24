# This file was generated, do not modify it. # hide
gamma_code = """
    Symbols D;
    Dimension D;
    Indices m, a;
    Local C1 = g_(1, m) * g_(1, m);
    Local C2 = g_(1, m) * g_(1, a) * g_(1, m) * g_(1, a);
    trace4, 1;
"""
println(evaluate_form(gamma_code))