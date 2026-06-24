# This file was generated, do not modify it. # hide
include("form.jl")
using .FormWrapper
println(evaluate_form("Symbols x;\nLocal F = x^2;\n"))