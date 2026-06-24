# This file was generated, do not modify it. # hide
#hideall
using RCall
lines = replace("""2+2""", r"(^|\n)([^\n]+)\n?$" => s"\1res <- \2")
R"""
$$lines
"""
println(R"res")