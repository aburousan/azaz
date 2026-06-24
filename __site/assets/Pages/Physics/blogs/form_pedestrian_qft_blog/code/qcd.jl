# This file was generated, do not modify it. # hide
qcd_code = """
    Symbols N, CF, TR;
    Dimension N;
    Indices a, b, c, i, j, k, l;
    
    Functions T;
    
    Local ColorTrace = T(a, i, j) * T(a, j, i);
    Local ColorFactor = ColorTrace * N^-1;
    
    id T(a?, i?, j?) * T(a?, k?, l?) = TR * ( d_(i,l)*d_(j,k) - d_(i,j)*d_(k,l)*N^-1 );
    
    contract;
    
    id TR = 1/2;
"""

println(evaluate_form(qcd_code))