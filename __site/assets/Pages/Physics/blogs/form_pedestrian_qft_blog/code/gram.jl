# This file was generated, do not modify it. # hide
gram_code = """
    AutoDeclare Vector v;
    Local G3 = e_(v1,...,v3)^2;
    contract;
"""
println(evaluate_form(gram_code))