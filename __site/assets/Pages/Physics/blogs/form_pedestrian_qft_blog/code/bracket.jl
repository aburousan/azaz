# This file was generated, do not modify it. # hide
bracket_code = """
    Symbols a, b, x;
    Local E = a*x^2 + b*x^2 + a*x + 7*x;
    Bracket x;
"""
println(evaluate_form(bracket_code))