# This file was generated, do not modify it. # hide
prepro_code = """
    Symbol x;
    Local Geom = 0
    #do i=1,5
       + x^`i'
    #enddo
    ;
"""
println(evaluate_form(prepro_code))