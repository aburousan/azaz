+++
title = "Fast and Curious"
hascode = true
date = Date(2024, 10, 19)
rss = "A blog on comparing speed of different languages."

tags = ["code", "mathematics", "primes", "Numerical_Methods", "c++","fortran","python","R"]
+++

\toc

# Fast and Curious: A speed comparison of different languages

In today's data-driven world, the choice of **programming language** can significantly impact performance and efficiency. As developers and researchers strive to solve increasingly complex problems, the need for speed becomes paramount. But how do different programming languages stack up against each other in terms of execution speed?
~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/Maths/blogs/fast_and_curious/fast_cou.png">
    <p>
    <i></i>.
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
In this blog post, we dive deep into a comparative analysis of five popular programming languages: Python, R, C++, Fortran, and Julia. Each of these languages brings unique strengths to the table, from **\col{green}{Python's ease of use and vast ecosystem}** to **\col{red}{C++'s performance and control over system resources}**. Meanwhile, **\col{blue}{R shines in statistical computing}**, **\col{brown}{Fortran boasts its legacy in numerical analysis}**, and **\col{purple}{Julia has emerged as a powerful contender designed for high-performance computing}**.

Wwe will evaluate how each language performs when tasked with a computationally intensive operation—summing prime numbers. By examining the results, we aim to uncover which language emerges as the fastest.
\note{
    As, I am not an expert, I urge people to maybe help me by sending me more nice examples. I am open to suggestions.
}

## Setting up our test problem

**Prime Numbers** *are natural numbers greater than 1 that have no divisors other than 1 and themselves*. First few prime numbers are $2$, $3$, $5$, $7$, $11$, and so on.\\
The problem of finding prime numbers and summing them within a given range is computationally interesting because, although **\col{purple}{prime numbers themselves are simple to define, their distribution and calculation (especially for large numbers) become increasingly complex as the range expands}**.

What our code does can be just written in 2 points:
1. Find all prime numbers in a given range (e.g. from $2$ to $N$).
2. Sum these numbers to get the sum of all primes in that range.

## Why choosing this?
Initially, I was think about matrix multiplication or maybe solving some ODE/PDE. But the **sum of primes** is really simple and also it has some properties.
1. The problem requires checking each number in the range to determine whether it is prime, and this involves computational steps like trial division or more advanced algorithms. This makes the task computationally expensive for large ranges, ideal for testing the efficiency of different languages.
2. The problem allows you to scale the computational load by increasing the size of $N$, the upper bound of the range. Larger ranges require more processing, giving you the flexibility to test performance under different levels of stress.
3. Unlike complex scientific problems that require specialized libraries, prime number summation is algorithmically simple. This makes the comparison fair, as it primarily tests the core performance of the language, not its library ecosystem.

## Writing the codes
Let's see the codes in all $5$ languages.

### Julia
\note{
    This website is made using Franklin.jl so have to use put julia before any one of others. Sorry ;)
}
```julia
function sieve_of_eratosthenes(N)
    primes = trues(N)
    for p in 2:floor(Int, sqrt(N))
        if primes[p]
            for i in p^2:p:N
                primes[i] = false
            end
        end
    end
    return sum(p for p in 2:N if primes[p])
end
N = 10^8
@time result = sieve_of_eratosthenes(N)
println("Sum of primes: $result")
```
I have saved this file as `primes.jl`.
### Python
Let's see now the python code.
```python
import time
def sieve_of_eratosthenes(N):
    primes = [True] * (N + 1)
    p = 2
    while p * p <= N:
        if primes[p]:
            for i in range(p * p, N + 1, p):
                primes[i] = False
        p += 1
    return sum(p for p in range(2, N+1) if primes[p])
N = 10**8
start_time = time.time()
result = sieve_of_eratosthenes(N)
end_time = time.time()
print(f"Sum of primes: {result}")
print(f"Time taken: {end_time - start_time} seconds")
```
Save this one as `primes.py`.
### C++
For c++, ;),
```cpp
#include <iostream>
#include <vector>
#include <cmath>
#include <chrono>
long long sieve_of_eratosthenes(int N) {
    std::vector<bool> primes(N + 1, true);
    long long sum = 0;
    for (int p = 2; p * p <= N; ++p) {
        if (primes[p]) {
            for (int i = p * p; i <= N; i += p)
                primes[i] = false;
        }
    }
    for (int p = 2; p <= N; ++p) {
        if (primes[p]) {
            sum += p;
        }
    }
    return sum;
}
int main() {
    int N = 100000000;
    auto start = std::chrono::high_resolution_clock::now();
    long long result = sieve_of_eratosthenes(N);
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> duration = end - start;
    std::cout << "Sum of primes: " << result << std::endl;
    std::cout << "Time taken: " << duration.count() << " seconds" << std::endl;
    return 0;
}
```
Saving this as `primes.cpp`.
### Fortran
For this one,
```fortran
program sum_of_primes
    implicit none
    integer :: N, p, i
    integer(8) :: sum
    logical, allocatable :: primes(:)
    integer :: start, finish, count_rate
    N = 100000000
    allocate(primes(N+1))
    primes = .true.
    sum = 0
    call system_clock(start, count_rate)

    do p = 2, int(sqrt(real(N)))
        if (primes(p)) then
            do i = p*p, N, p
                primes(i) = .false.
            end do
        end if
    end do

    do p = 2, N
        if (primes(p)) sum = sum + p
    end do
    call system_clock(finish, count_rate)
    print *, "Sum of primes: ", sum
    print *, "Time taken: ", real(finish - start) / real(count_rate), " seconds"
end program sum_of_primes
```
Save this one as `primes.f90`
### R
For R, the code is,
```R
sieve_of_eratosthenes <- function(N) {
  primes <- rep(TRUE, N)
  p <- 2
  while (p^2 <= N) {
    if (primes[p]) {
      for (i in seq(p^2, N, p)) {
        primes[i] <- FALSE
      }
    }
    p <- p + 1
  }
  return(sum(which(primes == TRUE)[2:N]))
}
N <- 10^8
system.time({
  result <- sieve_of_eratosthenes(N)
})
print(result)
```
Save this final one as `primes.R`.

## Running and Result
Let's see the running commands and results.
### Running the code
To run the codes, I will use a `bash` script. Here it is:
```shell
#!/bin/bash
rm -f primes_cpp primes_fortran
g++ primes.cpp -o primes_cpp
if [ $? -ne 0 ]; then
    echo "C++ compilation failed"
    exit 1
fi
gfortran primes.f90 -o primes_fortran
if [ $? -ne 0 ]; then
    echo "Fortran compilation failed"
    exit 1
fi
for i in {1..11}
do
    echo "Running Python iteration $i"
    python3 primes.py >> output_python.txt
    echo "Iteration $i completed" >> output_python.txt
    echo "-----------------------------------" >> output_python.txt
    
    echo "Running Julia iteration $i"
    julia primes.jl >> output_julia.txt
    echo "Iteration $i completed" >> output_julia.txt
    echo "-----------------------------------" >> output_julia.txt

    echo "Running C++ iteration $i"
    ./primes_cpp >> output_cpp.txt
    echo "Iteration $i completed" >> output_cpp.txt
    echo "-----------------------------------" >> output_cpp.txt
    
    echo "Running Fortran iteration $i"
    ./primes_fortran >> output_fortran.txt
    echo "Iteration $i completed" >> output_fortran.txt
    echo "-----------------------------------" >> output_fortran.txt
    
    echo "Running R iteration $i"
    Rscript primes.R >> output_r.txt
    echo "Iteration $i completed" >> output_r.txt
    echo "-----------------------------------" >> output_r.txt
done
echo "All iterations completed."
```
Save this as `run_tests.sh` in the same folder as all the previous code.\\
To run this, use the two commands:
```
chmod +x run_tests.sh
./run_tests.sh
```
This will run all the codes $11$ times and save each iteration output in the respective output txt files.
Once done, we have the results(this is due to what happens when we run julia for first time. We will use last $10$).

### Results
Let's see results of each one:
1. For `Fortran`:
| Iteration | Sum of Primes          | Time Taken (seconds)        |
|-----------|------------------------|-----------------------------|
| $1$       | $279209790387276$       | $1.070785$                  |
| $2$       | $279209790387276$       | $1.068295$                  |
| $3$       | $279209790387276$       | $1.089001$                  |
| $4$       | $279209790387276$       | $1.070244$                  |
| $5$       | $279209790387276$       | $1.081850$                  |
| $6$       | $279209790387276$       | $1.065128$                  |
| $7$       | $279209790387276$       | $1.072845$                  |
| $8$       | $279209790387276$       | $1.061545$                  |
| $9$       | $279209790387276$       | $1.102363$                  |
| $10$      | $279209790387276$       | $1.090591$                  |
Clearly, we can see who is the winner.
2. For `julia`:
| Iteration | Sum of Primes          | Time Taken (seconds)        |
|-----------|------------------------|-----------------------------|
| $1$       | $279209790387276$       | $1.63499994$                |
| $2$       | $279209790387276$       | $1.47800002$                |
| $3$       | $279209790387276$       | $1.61299999$                |
| $4$       | $279209790387276$       | $1.49499998$                |
| $5$       | $279209790387276$       | $1.49699996$                |
| $6$       | $279209790387276$       | $1.63900001$                |
| $7$       | $279209790387276$       | $1.62799997$                |
| $8$       | $279209790387276$       | $1.61999996$                |
| $9$       | $279209790387276$       | $1.49999998$                |
| $10$      | $279209790387276$       | $1.61700006$                |
3. For `c++`:
| Iteration | Sum of Primes          | Time Taken (seconds)        |
|-----------|------------------------|-----------------------------|
| $1$       | $279209790387276$       | $10.8402$                   |
| $2$       | $279209790387276$       | $11.0474$                   |
| $3$       | $279209790387276$       | $12.0759$                   |
| $4$       | $279209790387276$       | $11.1812$                   |
| $5$       | $279209790387276$       | $11.1218$                   |
| $6$       | $279209790387276$       | $11.1408$                   |
| $7$       | $279209790387276$       | $11.1379$                   |
| $8$       | $279209790387276$       | $10.9725$                   |
| $9$       | $279209790387276$       | $11.0904$                   |
| $10$      | $279209790387276$       | $11.0407$                   |
Unexpected!... I don't know it is this slow due to my machine or not. Can someone verify this?
4. For `R`:
| Iteration | Sum of Primes        | Time Taken (seconds) |
|-----------|----------------------|----------------------|
| $1$       | $279209790387276$     | $18.054$             |
| $2$       | $279209790387276$     | $16.135$             |
| $3$       | $279209790387276$     | $16.216$             |
| $4$       | $279209790387276$     | $15.998$             |
| $5$       | $279209790387276$     | $16.240$             |
| $6$       | $279209790387276$     | $15.995$             |
| $7$       | $279209790387276$     | $16.319$             |
| $8$       | $279209790387276$     | $16.181$             |
| $9$       | $279209790387276$     | $16.078$             |
| $10$      | $279209790387276$     | $16.028$             |
5. For `python`:
| Iteration | Sum of Primes          | Time Taken (seconds)        |
|-----------|------------------------|-----------------------------|
| $1$       | $279209790387276$       | $20.6143$                   |
| $2$       | $279209790387276$       | $20.8444$                   |
| $3$       | $279209790387276$       | $20.6110$                   |
| $4$       | $279209790387276$       | $22.8873$                   |
| $5$       | $279209790387276$       | $20.4012$                   |
| $6$       | $279209790387276$       | $20.5705$                   |
| $7$       | $279209790387276$       | $20.4197$                   |
| $8$       | $279209790387276$       | $20.7123$                   |
| $9$       | $279209790387276$       | $20.4700$                   |
| $10$      | $279209790387276$       | $20.6882$                   |

Let's see a plot which shows all of these:
```julia:./fast_curious.jl
using Plots; plotlyjs()
fortran_times = [1.070785, 1.068295, 1.089001, 1.070244, 1.081850, 1.065128, 1.072845, 1.061545, 1.102363, 1.090591]
julia_times = [1.63499994, 1.47800002, 1.61299999, 1.49499998, 1.49699996, 1.63900001, 1.62799997, 1.61999996, 1.49999998, 1.61700006]
cpp_times = [10.8402, 11.0474, 12.0759, 11.1812, 11.1218, 11.1408, 11.1379, 10.9725, 11.0904, 11.0407]
r_times = [18.054, 16.135, 16.216, 15.998, 16.240, 15.995, 16.319, 16.181, 16.078, 16.028]
python_times = [20.6143, 20.8444, 20.6110, 22.8873, 20.4012, 20.5705, 20.4197, 20.7123, 20.4700, 20.6882]
iterations = 1:10
p = plot(iterations, fortran_times, label="Fortran", lw=2, marker=:o, markersize=6)
plot!(iterations, julia_times, label="Julia", lw=2, marker=:o, markersize=6)
plot!(iterations, cpp_times, label="C++", lw=2, marker=:o, markersize=6)
plot!(iterations, r_times, label="R", lw=2, marker=:o, markersize=6)
plot!(iterations, python_times, label="Python", lw=2, marker=:o, markersize=6)
xlabel!("Iterations")
ylabel!("Time Taken (seconds)")
title!("Time Comparison of Sum of Primes Across Different Languages")
plot!(legend=:topright)
```
\fig{output/fast_cou1}
It very clearly shows which one is superior and which is not for this particular code. Now, we can modify the codes for more efficiency and optimization (like using Numpy/Numba, StaticArray, Eigen, OpenMP , etc), but here for this blog I think it's enough. We will continue for discussion in some other blog.

---
Wihout the system information it's really not a speed test. So, Here is my information:\\
**\col{red}{System Information:}**\\
===================\\
Operating System: GNU/Linux\\
Kernel Version: 6.8.0-45-generic\\
CPU: Model name: Intel(R) Core(TM) i5-8250U CPU @ 1.60GHz\\
Architecture: x86_64\\
Number of Cores: 8\\
Shell: /usr/bin/zsh\\
**\col{red}{Language Versions:}**\\
===================\\
Fortran Version: GNU Fortran (conda-forge gcc 12.4.0-0) 12.4.0\\
C++ Version: g++ (conda-forge gcc 12.4.0-0) 12.4.0\\
R Version: R version 4.4.1 (2024-06-14) -- "Race for Your Life"\\
Python Version: Python 3.12.2\\
Julia Version: julia version 1.11.1\\

---
To generate this use the following script:
```shell
#!/bin/bash
output_file="system_info.txt"
{
    echo "System Information:"
    echo "==================="
    echo "Operating System: $(uname -o)"
    echo "Kernel Version: $(uname -r)"
    echo "CPU: $(lscpu | grep 'Model name')"
    echo "Architecture: $(uname -m)"
    echo "Number of Cores: $(nproc)"
    echo "Shell: $SHELL"
    echo "Home Directory: $HOME"
    echo ""
    echo "Language Versions:"
    echo "==================="
    if command -v gfortran &> /dev/null; then
        echo -n "Fortran Version: "
        gfortran --version | head -n 1
    else
        echo "Fortran: Not installed"
    fi
    if command -v g++ &> /dev/null; then
        echo -n "C++ Version: "
        g++ --version | head -n 1
    else
        echo "C++: Not installed"
    fi
    if command -v R &> /dev/null; then
        echo -n "R Version: "
        R --version | head -n 1
    else
        echo "R: Not installed"
    fi
    if command -v python &> /dev/null; then
        echo -n "Python Version: "
        python --version
    else
        echo "Python: Not installed"
    fi
    if command -v julia &> /dev/null; then
        echo -n "Julia Version: "
        julia --version
    else
        echo "Julia: Not installed"
    fi
} > "$output_file"
echo "System information and language versions have been saved to $output_file"

```
I have you have learnt something new and enjoyed it.
\note{
    Just a request. If possible please run the codes and let me know what you get!
}
If you have some queries, do let me know in the comments or contact me using my using the informations that are given on the page [About Me](/Pages/about_me/).

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
    this.page.url = https://rousan.netlify.app/pages/math/blogs/fast_and_curious/;  // Replace PAGE_URL with your page's canonical URL variable
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