# This file was generated, do not modify it. # hide
tensor_code = """
    Vectors u,v;
    Indices i,j;
    Function f;
    Index k=0;
    
    Local dot = u(i) * v(i);
    Local schoonschip = f(i,j) * u(i) * v(j);
    
* Overruling contraction using dimension 0
    Local nocontract = u(k) * v(k);
    
    contract;
"""
println(evaluate_form(tensor_code))