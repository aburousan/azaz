# This file was generated, do not modify it. # hide
repeat_code = """
    Symbol n;
    CFunction f;
    Local Fact = f(5);
    repeat;
      id f(n?pos_) = n*f(n-1);
    endrepeat;
    id f(0) = 1;
"""
println(evaluate_form(repeat_code))