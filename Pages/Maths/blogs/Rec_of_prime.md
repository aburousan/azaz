+++
title = "Reciprocals of Primes"
hascode = true
date = Date(2023, 6, 30)
rss = "A brief discussion on the fact that taking the reciprocals of primes will generate numbers which repeat after certain digits. Here we will understand why this happens and will write a code to find out the period."
+++


+++
tags = ["code", "mathematics", "Shanks", "prime_numbers", "number_theory"]
+++
<!-- [![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Faburousan.github.io%2Fazazaya%2FPages%2FMaths%2FRec_of_prime%2F&count_bg=%23B461C2&title_bg=%2357521A&icon=atom.svg&icon_color=%23E7E7E7&title=visits&edge_flat=false)](https://hits.seeyoufarm.com) -->
\toc
# The Period of Reciprocals of Primes (work of William Shanks)
You are reading this blog?, This is (even if it's little) you love maths.\\
But **how much?**, Can you invest 3 years just to calculate **Reciprocal of Prime numbers**?...\\
Yes or No?\\
I don't know about you but there was certainly a guy called **William Shanks**, who have done this.
~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/Maths/blogs/Rec_of_prime/shank_work_time.jpeg">
    <p>
    The working period of <b>William Shanks</b> on this topic.
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
Many of my friends ask me why many poeple (specially childrens) love to play around with numbers?, I don't know what is the real reason. But I think...
> Because, Numbers were the first step in mapping our physical world into abstract one.

## Introduction to the problem
Let's first try to undersand what **Shanks** was doing.
Suppose, we have a **prime number** $p$. Now, let's calculate the value of $\frac{1}{p}$.

For an example let's take $p=7$.
~~~
<div class="row">
  <div class="container">
    <img class="center" src="/assets/Maths/blogs/Rec_of_prime/seven_div.jpg"  width="400">
    <p>
    Division of 1 by 7. We all have done this in our childhood. See in the end, we are again getting 1 as we have before.
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
This means **the quotient will repeat after 7** ,i.e., we will get something like 0.142857142857142857......\\
Hence, **The reciprocal of 7 repeats after 6 digits**, i.e., It's **period** is **6**.\\
Why not try the same thing for $p = 23$?, What is the period you getting?..\\
The answer should be **22**. **Don't skip try this for your own understanding**.
## Prove
The proof is pretty easy and can be done using [**Fermat's Little Theorem**](https://brilliant.org/wiki/fermats-little-theorem/). For the proof visit this sources.
* [**Source 1**](https://www.jstor.org/stable/pdf/112821.pdf)
* [**Source 2**](https://qr.ae/py5osl)
* [**Source 3**](https://www.johndcook.com/blog/2016/10/18/periods-of-fractions/)
* [**Source 4**](https://apps.dtic.mil/dtic/tr/fulltext/u2/a233979.pdf)
For more watch this video by **Matt Parker**
~~~
<iframe width="560" height="315" src="https://www.youtube.com/embed/DmfxIhmGPP4" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
~~~
Note: **p must be a prime greater than 5**.
## Our take in finding The period
**Shanks** invested 3 years of his life for this job but in modern time we can just write a few lines of code to achive that in matter of seconds.\\
I just write it while eating snacks and enjoying a beautiful rainy day... we truly are blessed.. Just think about it!...\\
If you try finding the code, you are going to find some of them (eg:[code-1](https://github.com/punitarani/ShanksBot), [code-2](https://github.com/bmantoni/shanks-bot)). But as per I have seen they have some error or the code looks a bit complicated.\\
So, I will try to write a code in julia, which will be elegant and simple and also very fast. Let's start will the algorithm.\\
**Algorithm**\\
* We want to find the smallest n ($n=$ no. of digits after which repeatation happens). This simply means that we want to find smallest $n$ for which $$ 10^n = 1 (\text{mod }p) $$.
* For primes $p$, $n$ is just some divisor of $p-1$.
(TRY to THINK WHY)\\
This means, for any number $p$, we have to,
* Find divisors of $p-1$.
* Then, arrange them in a list of ascending order.
* See for which (smallest) n, equation-1 is satisfied.
Let's see an example. Let's take $p = 23$.\\
The divisors of $23-1 = 22$ are $[1,2,11,22]$. For bigger numbers, we will be using a simple code to find the divisors.
<!-- :./divisors.jl -->
```julia
using Primes # will be using this library
function divisor(n)
	d = Int64[1]
	for (p,e) in factor(n)
		t = Int64[]
		r = 1
		for i in 1:e
			r *= p
			for u in d
				push!(t, u*r)
			end
		end
		append!(d,t)
	end
	return sort(d)
end
println("The divisors of 22 is = ",divisor(22))
```
The output is:
\output{./divisors.jl}
Now, let's calculate $10^{n}$ for $n = 1, 2, 11, 22$. If you do so, you will see only $10^{22} = 1$ under mod($23$). Hence, the result.\\
The full code for implementing this in julia with an example is,
<!-- :./prime_rec.jl -->
```julia
using Primes # will be using this library
function divisor(n)
	d = Int64[1]
	for (p,e) in factor(n)
		t = Int64[]
		r = 1
		for i in 1:e
			r *= p
			for u in d
				push!(t, u*r)
			end
		end
		append!(d,t)
	end
	return sort(d)
end

function period_of_rec_of_prime(p)
	divisors = divisor(p-1)
	res = 0
	for i in divisors
		if big(10)^i % big(p) == big(1)
			res = i
			break
		end
	end
	return res
end
p = 61253
println("The period of $p is = ",period_of_rec_of_prime(p))
```
The output is:
\output{./prime_rec.jl}
This is great as it always give correct answer and is very fast.
Here is a image from shank's notebook:
~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/Maths/blogs/Rec_of_prime/shank_2.jpg">
    <p>
    Few values found by shank. The left ones are prime number and right ones are the periods. As you can see, he had corrected one of the values. Most codes actually give the wrong value but ours will not.
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
We can also plot the data. So, the code in it's full glory (along with table like shank) is,
<!-- :./prime_rec_f.jl -->
```julia
using Primes
using DataFrames
function divisor(n)
	d = Int64[1]
	for (p,e) in factor(n)
		t = Int64[]
		r = 1
		for i in 1:e
			r *= p
			for u in d
				push!(t, u*r)
			end
		end
		append!(d,t)
	end
	return sort(d)
end

function period_of_rec_of_prime(p)
	divisors = divisor(p-1)
	res = 0
	for i in divisors
		if big(10)^i % big(p) == big(1)
			res = i
			break
		end
	end
	return res
end
all_primes = primes(7, 110000)#retrun all primes in range 5 to 1,10,000
periods = period_of_rec_of_prime.(all_primes)
df = DataFrame(Primes = all_primes, Reciprocal_Periods = periods)
print(last(df,50))# give table like shank, just showing last 50
```
The output is:
\output{./prime_rec_f.jl}
To make a plot use,
```julia
using Plots
plot(all_primes, periods, title="Plot of Reciprocal of Primes vs Period",seriestype=:scatter,linewidth=3)
xlabel!("Primes")
ylabel!("Period of Reciprocals")
```

<!-- :./prime_rec_f.jl -->
```julia
#hideall
using Plots
plotlyjs()
p = plot(all_primes, periods, title="Plot of Reciprocal of Primes vs Period",seriestype=:scatter,linewidth=3, label="")
xlabel!("Primes")
ylabel!("Period of Reciprocals")
savefig(p, joinpath(@OUTPUT, "prime_rec.json"))
```

This is create a plot like,
\fig{./prime_rec}

I hope you all like this interesting piece of knowlege. Just think how much blessed we are. We should use all our resources(blessings) to do awesome things.

If you have some question, do let me know in the comments or contact me using my using the informations are given in the page [About Me](/Pages/about_me/).

~~~
<button onclick="window.history.back()">Go Back</button>
~~~

~~~
<div id="disqus_thread"></div>
<script>
    /**
    *  RECOMMENDED CONFIGURATION VARIABLES: EDIT AND UNCOMMENT THE SECTION BELOW TO INSERT DYNAMIC VALUES FROM YOUR PLATFORM OR CMS.
    *  LEARN WHY DEFINING THESE VARIABLES IS IMPORTANT: https://disqus.com/admin/universalcode/#configuration-variables    */
    /*
    var disqus_config = function () {
    this.page.url = https://rousan.netlify.app/pages/maths/blogs/rec_of_prime/;  // Replace PAGE_URL with your page's canonical URL variable
    this.page.identifier = PAGE_IDENTIFIER; // Replace PAGE_IDENTIFIER with your page's unique identifier variable
    };
    */
    (function() { // DON'T EDIT BELOW THIS LINE
    var d = document, s = d.createElement('script');
    s.src = 'https://https-rousan-netlify-app.disqus.com/embed.js';
    s.setAttribute('data-timestamp', +new Date());
    (d.head || d.body).appendChild(s);
    })();
</script>
<noscript>Please enable JavaScript to view the <a href="https://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
~~~
