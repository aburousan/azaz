+++
title = "Test"
+++

```julia:form_eval
include("form.jl")
using .FormWrapper
println("Block 1 output")
```
\output{form_eval}

```julia:form_eval
println("Block 2 output")
```
\output{form_eval}
