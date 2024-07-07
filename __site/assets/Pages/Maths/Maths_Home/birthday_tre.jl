# This file was generated, do not modify it. # hide
arr = [2,6,2,10]
arr.==2
sum(arr.==2)
begin
  function prob(n::Int)
    favour = 0
    for ex_num=1:n
      months = rand(1:12,20)
      nums = [sum(months.==i) for i=1:12]
      if sum(nums.==3)==4 && sum(nums.==2)==4
        favour += 1
      end
    end
    probability = favour/n
  end
end
println("The output, probability is = ",prob(10_000_000))