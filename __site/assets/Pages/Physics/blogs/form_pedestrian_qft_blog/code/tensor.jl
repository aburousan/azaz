# This file was generated, do not modify it. # hide
form_code = """
    Dimension 4;
    Indices m,n,r,s;
    Local result = e_(m,n,r,s) * e_(m,n,r,s);
    contract;
"""
println(evaluate_form(form_code))