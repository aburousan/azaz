# This file was generated, do not modify it. # hide
compton_code = """
    Dimension 4;
    Vectors p, k, pp, kp;
    Indices mu, nu;
    Symbols m, pdotk, pdotkp;

    Local M2 = 
      (g_(1,pp) + m) * (
           g_(1,mu) * (g_(1,p) + g_(1,k) + m) * g_(1,nu) * pdotk^-1 * 2^-1
         + g_(1,nu) * (g_(1,p) - g_(1,kp) + m) * g_(1,mu) * pdotkp^-1 * (-2)^-1
      ) 
      * (g_(1,p) + m) * (
           g_(1,nu) * (g_(1,p) + g_(1,k) + m) * g_(1,mu) * pdotk^-1 * 2^-1
         + g_(1,mu) * (g_(1,p) - g_(1,kp) + m) * g_(1,nu) * pdotkp^-1 * (-2)^-1
      );

    trace4, 1;
    contract;
    
    id p.p = m^2;
    id pp.pp = m^2;
    id k.k = 0;
    id kp.kp = 0;
    
    id p.k = pdotk;
    id pp.kp = pdotk;
    id p.kp = pdotkp;
    id k.pp = pdotkp;
    
    id p.pp = pdotk - pdotkp + m^2;
    id k.kp = pdotk - pdotkp;
    
    Multiply 4^-1;
    
    Bracket pdotk, pdotkp;
"""

println(FormWrapper.evaluate_form(compton_code))