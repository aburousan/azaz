# This file was generated, do not modify it. # hide
cond_code = """
    Symbols x, y;
    Local P = (x+y)^4;
    if (count(x,1) != 2) Discard;
"""
println(evaluate_form(cond_code))