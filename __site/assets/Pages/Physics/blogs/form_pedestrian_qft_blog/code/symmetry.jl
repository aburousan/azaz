# This file was generated, do not modify it. # hide
sym_code = """
    Symbols x1,x2,x3,x4,x5;
    Functions S(symmetric), A(antisymmetric), C(cyclic), R(rcyclic);
    Local [S] = S(x2,x3,x4,x1,x5);
    Local [A] = A(x2,x3,x4,x1,x5);
    Local [C] = C(x2,x3,x4,x1,x5);
    Local [R] = R(x2,x3,x4,x1,x5);
"""
println(evaluate_form(sym_code))