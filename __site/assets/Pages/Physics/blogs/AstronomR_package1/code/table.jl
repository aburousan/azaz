# This file was generated, do not modify it. # hide
#hideall
names = (:Taimur, :Catherine, :Maria, :Arvind, :Jose, :Minjie)
numbers = (1525, 5134, 4214, 9019, 8918, 5757)
println("Name | Number")
println(":--- | :---")
println.("$name | $number" for (name, number) in zip(names, numbers))