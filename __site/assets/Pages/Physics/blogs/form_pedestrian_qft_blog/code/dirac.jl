# This file was generated, do not modify it. # hide
trace_code = """
    Dimension 4;
    Indices m,n,r,s;
    Local QEDtrace = g_(1, m) * g_(1, n) * g_(1, r) * g_(1, s);
    trace4, 1;
"""
println(evaluate_form(trace_code))