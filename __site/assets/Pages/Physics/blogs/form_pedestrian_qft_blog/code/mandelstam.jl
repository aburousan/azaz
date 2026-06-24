# This file was generated, do not modify it. # hide
mandelstam_code = """
    Dimension 4;
    Vectors p, k, pp, kp;
    Indices m, n;
    Symbols s, t, u;
    
    Local M2 = g_(1, m) * g_(1, p) * g_(1, n) * g_(1, k) 
             * g_(2, m) * g_(2, pp)* g_(2, n) * g_(2, kp);
             
    trace4, 1;
    trace4, 2;
    contract;
    
    id p.p = 0;
    id k.k = 0;
    id pp.pp = 0;
    id kp.kp = 0;
    
    id p.k = s/2;
    id pp.kp = s/2;
    id p.pp = -t/2;
    id k.kp = -t/2;
    id p.kp = -u/2;
    id k.pp = -u/2;
"""
println(evaluate_form(mandelstam_code))