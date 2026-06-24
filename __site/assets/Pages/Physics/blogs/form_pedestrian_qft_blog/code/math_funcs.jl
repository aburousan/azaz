# This file was generated, do not modify it. # hide
math_code = """
    Symbols x, i;
    Local expx = sum_(i, 0, 5, x^i/fac_(i));
"""
println(evaluate_form(math_code))