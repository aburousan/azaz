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
function sum_of_primes(N)
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
sum_of_primes(1)
@time result = sum_of_primes(N)
println("Sum of primes: $result")
```
I have saved this file as `primes.jl`.
### Python
Let's see now the python code.
```python
import time
def sum_of_primes(N):
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
result = sum_of_primes(N)
end_time = time.time()
print(f"Sum of primes: {result}")
print(f"Time taken: {end_time - start_time} seconds")
```
Save this one as `primes.py`.
### C++
For C++, ;),
```cpp
#include <iostream>
#include <chrono>
#include <cstring>

long long sum_of_primes(int N) {
    unsigned char* primes = new unsigned char[N + 1];
    memset(primes, 1, N + 1);
    long long sum = 0;
    for (int p = 2; p * p <= N; ++p) {
        if (primes[p]) {
            for (int i = p * p; i <= N; i += p)
                primes[i] = 0;
        }
    }
    for (int p = 2; p <= N; ++p) {
        if (primes[p]) {
            sum += p;
        }
    }
    delete[] primes;
    return sum;
}
int main() {
    int N = 100000000;
    auto start = std::chrono::high_resolution_clock::now();
    long long result = sum_of_primes(N);
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> duration = end - start;
    std::cout << "Sum of primes: " << result << std::endl;
    std::cout << "Time taken: " << duration.count() << " seconds" << std::endl;
    return 0;
}
```
\note{
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
    This was the previous code.}
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
sum_of_primes <- function(N) {
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
  result <- sum_of_primes(N)
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
g++ -O3 -march=native -std=c++11 primes.cpp -o primes_cpp
if [ $? -ne 0 ]; then
    echo "C++ compilation failed"
    exit 1
fi
gfortran -O3 -march=native primes.f90 -o primes_fortran
if [ $? -ne 0 ]; then
    echo "Fortran compilation failed"
    exit 1
fi
for i in {1..10}
do
    echo "Running Python iteration $i"
    python3 primes.py >> output_python.txt
    if [ $? -eq 0 ]; then
        echo "Iteration $i completed" >> output_python.txt
        echo "-----------------------------------" >> output_python.txt
    else
        echo "Python iteration $i failed" >> output_python.txt
    fi

    echo "Running Julia iteration $i"
    julia primes.jl >> output_julia.txt
    if [ $? -eq 0 ]; then
        echo "Iteration $i completed" >> output_julia.txt
        echo "-----------------------------------" >> output_julia.txt
    else
        echo "Julia iteration $i failed" >> output_julia.txt
    fi

    echo "Running C++ iteration $i"
    ./primes_cpp >> output_cpp.txt
    if [ $? -eq 0 ]; then
        echo "Iteration $i completed" >> output_cpp.txt
        echo "-----------------------------------" >> output_cpp.txt
    else
        echo "C++ iteration $i failed" >> output_cpp.txt
    fi
    echo "Running Fortran iteration $i"
    ./primes_fortran >> output_fortran.txt
    if [ $? -eq 0 ]; then
        echo "Iteration $i completed" >> output_fortran.txt
        echo "-----------------------------------" >> output_fortran.txt
    else
        echo "Fortran iteration $i failed" >> output_fortran.txt
    fi
    echo "Running R iteration $i"
    Rscript primes.R >> output_r.txt
    if [ $? -eq 0 ]; then
        echo "Iteration $i completed" >> output_r.txt
        echo "-----------------------------------" >> output_r.txt
    else
        echo "R iteration $i failed" >> output_r.txt
    fi
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
Once done, we have the results.
\note{
    Thanks to Mose Giordano from julia community for pointing out few facts about running `c++` and `fortran` code. For detail see: [Link](https://julialang.slack.com/archives/C67910KEH/p1729373335723409?thread_ts=1729371119.007759&cid=C67910KEH) 
}

### Results
Let's see results of each one:
1. For `C++`:
| Iteration | Sum of Primes          | Time Taken (seconds)        |
|-----------|------------------------|-----------------------------|
| $1$       | $279209790387276$       | $0.887531$                  |
| $2$       | $279209790387276$       | $0.896439$                  |
| $3$       | $279209790387276$       | $0.889580$                  |
| $4$       | $279209790387276$       | $0.890078$                  |
| $5$       | $279209790387276$       | $1.133180$                  |
| $6$       | $279209790387276$       | $0.894600$                  |
| $7$       | $279209790387276$       | $0.919426$                  |
| $8$       | $279209790387276$       | $0.938797$                  |
| $9$       | $279209790387276$       | $0.915501$                  |
| $10$      | $279209790387276$       | $0.892737$                  |
Clearly, we can see who is the winner.
\note{

| Iteration | Sum of Primes          | Time Taken (seconds)         |\\
|-----------|------------------------|------------------------------|\\
| $1$       | $279209790387276$       | $10.8402$                   |\\
| $2$       | $279209790387276$       | $11.0474$                   |\\
| $3$       | $279209790387276$       | $12.0759$                   |\\
| $4$       | $279209790387276$       | $11.1812$                   |\\
| $5$       | $279209790387276$       | $11.1218$                   |\\
| $6$       | $279209790387276$       | $11.1408$                   |\\
| $7$       | $279209790387276$       | $11.1379$                   |\\
| $8$       | $279209790387276$       | $10.9725$                   |\\
| $9$       | $279209790387276$       | $11.0904$                   |\\
| $10$      | $279209790387276$       | $11.0407$                   |\\
Unexpected!... I don't know it is this slow due to my machine or not. Can someone verify this?

This is previously here. I was not able to understand why C++ is slow!. But a nice person in the comment point that out.(See the comment of Yolhan).
}
2. For `Julia`:

| Iteration | Sum of Primes          | Time Taken (seconds)        | Allocations                      | Compilation Time (%) |
|-----------|------------------------|-----------------------------|----------------------------------|----------------------|
| $1$       | $279209790387276$       | $0.914137$                  | $230.34 \, \text{k}$, $23.432 \, \text{MiB}$ | $6.80$               |
| $2$       | $279209790387276$       | $0.916980$                  | $230.34 \, \text{k}$, $23.432 \, \text{MiB}$ | $6.79$               |
| $3$       | $279209790387276$       | $0.917002$                  | $230.34 \, \text{k}$, $23.432 \, \text{MiB}$ | $6.80$               |
| $4$       | $279209790387276$       | $0.915913$                  | $230.34 \, \text{k}$, $23.432 \, \text{MiB}$ | $6.86$               |
| $5$       | $279209790387276$       | $0.929013$                  | $230.34 \, \text{k}$, $23.432 \, \text{MiB}$ | $6.83$               |
| $6$       | $279209790387276$       | $0.920761$                  | $230.34 \, \text{k}$, $23.432 \, \text{MiB}$ | $6.85$               |
| $7$       | $279209790387276$       | $0.924105$                  | $230.34 \, \text{k}$, $23.432 \, \text{MiB}$ | $6.81$               |
| $8$       | $279209790387276$       | $0.919019$                  | $230.34 \, \text{k}$, $23.432 \, \text{MiB}$ | $6.79$               |
| $9$       | $279209790387276$       | $0.917901$                  | $230.34 \, \text{k}$, $23.432 \, \text{MiB}$ | $6.73$               |
| $10$      | $279209790387276$       | $0.919431$                  | $230.34 \, \text{k}$, $23.432 \, \text{MiB}$ | $6.78$               |

3. For `Fortran`:

| Iteration | Sum of Primes          | Time Taken (seconds)        |
|-----------|------------------------|-----------------------------|
| $1$       | $279209790387276$       | $1.26400006$                |
| $2$       | $279209790387276$       | $1.28699994$                |
| $3$       | $279209790387276$       | $1.28999996$                |
| $4$       | $279209790387276$       | $1.27499998$                |
| $5$       | $279209790387276$       | $1.51300001$                |
| $6$       | $279209790387276$       | $1.54900002$                |
| $7$       | $279209790387276$       | $1.55400002$                |
| $8$       | $279209790387276$       | $1.33500004$                |
| $9$       | $279209790387276$       | $1.38000000$                |
| $10$      | $279209790387276$       | $1.36699998$                |

4. For `R`:
Here Elapsed Time is the Time Taken.

| Iteration | Elapsed Time (seconds) | User Time (seconds) | System Time (seconds) |
|-----------|------------------------|---------------------|-----------------------|
| $1$       | $14.953$               | $13.075$            | $1.866$               |
| $2$       | $14.750$               | $12.848$            | $1.903$               |
| $3$       | $14.780$               | $12.897$            | $1.885$               |
| $4$       | $14.753$               | $12.840$            | $1.913$               |
| $5$       | $14.952$               | $13.098$            | $1.856$               |
| $6$       | $15.129$               | $13.192$            | $1.938$               |
| $7$       | $14.956$               | $13.067$            | $1.890$               |
| $8$       | $14.788$               | $12.882$            | $1.908$               |
| $9$       | $14.970$               | $13.090$            | $1.880$               |
| $10$      | $15.529$               | $13.632$            | $1.898$               |

5. For `python`:
| Iteration | Sum of Primes           | Time Taken (seconds)   |
|-----------|-------------------------|------------------------|
| $1$       | $279209790387276$        | $19.59793257713318$    |
| $2$       | $279209790387276$        | $19.903280019760132$   |
| $3$       | $279209790387276$        | $19.65820622444153$    |
| $4$       | $279209790387276$        | $19.870051622390747$   |
| $5$       | $279209790387276$        | $19.976346492767334$   |
| $6$       | $279209790387276$        | $19.489915370941162$   |
| $7$       | $279209790387276$        | $19.572935581207275$   |
| $8$       | $279209790387276$        | $19.436674118041992$   |
| $9$       | $279209790387276$        | $19.50352454185486$    |
| $10$      | $279209790387276$        | $19.746686935424805$   |

Let's see a plot which shows all of these:
```julia:./fast_curious.jl
using Plots; plotlyjs()
fortran_times = [1.26400006, 1.28699994, 1.28999996, 1.27499998, 1.51300001, 1.54900002, 1.55400002, 1.33500004, 1.38000000, 1.36699998]
julia_times = [0.914137, 0.916980, 0.917002, 0.915913, 0.929013, 0.920761, 0.924105, 0.919019, 0.917901, 0.919431]
cpp_times = [0.887531, 0.896439, 0.889580, 0.890078, 1.133180, 0.894600, 0.919426, 0.938797, 0.915501, 0.892737]
r_times = [14.953, 14.750, 14.780, 14.753, 14.952, 15.129, 14.956, 14.788, 14.970, 15.529]
python_times = [19.59793257713318, 19.903280019760132, 19.65820622444153, 19.870051622390747, 19.976346492767334, 19.489915370941162, 19.572935581207275, 19.436674118041992, 19.50352454185486, 19.746686935424805]
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
savefig(p, joinpath(@OUTPUT, "fast_cou10.json"))
```
\fig{output/fast_cou10}
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
### Extra Remark
After positing this, many people get offended. I get your point, but many people has done same and also many languages show this as their strength. Also, I will keep this blog as I am learning new things from good peoples(like the one in the comments).

\note{
From a physics student or teacher's point of view, comparing the speed of different programming languages is not necessarily misleading but needs to be done with proper context.

Different languages have different strengths and are suited to different tasks. For instance, in computational physics, the speed of a language can be crucial for simulations or large-scale numerical problems. Comparing languages based on speed can be useful for choosing the right tool for specific problems.

However, it is important to keep in mind that speed isn't the only factor. Other considerations, like ease of development, the availability of scientific libraries, and the ability to handle complex algorithms, are also important in physics. Therefore, speed comparisons can be informative as long as they are done with a clear understanding of the problem being solved and the resources available.
}

Also, let's write a code which uses libraries and uses the strength of each of the languages. I will just run $1$ iteration (I was planning to do this in some seperate blog but whatever).

1. `C++`\\
```cpp
#include <iostream>
#include <chrono>
#include <vector>
#include <primesieve.hpp>
int main() {
    int N = 100000000;
    std::vector<uint64_t> primes;
    auto start = std::chrono::high_resolution_clock::now();
    primesieve::generate_primes(N, &primes);
    uint64_t sum = 0;
    for (const auto& prime : primes) {
        sum += prime;
    }
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> duration = end - start;
    std::cout << "Sum of primes: " << sum << std::endl;
    std::cout << "Time taken: " << duration.count() << " seconds" << std::endl;
    return 0;
}
```
Output is : 
```
Sum of primes: 279209790387276
Time taken: 0.108293 seconds
```
2. `Julia`\\
```
using Primes
function sum_of_primes(N::Int)
    return sum(primes(2,N))
end
N = 10^8
sum_of_primes(1)
@time result = sum_of_primes(N)
println("Sum of primes: $result")
```
Output is : 
```
0.307588 seconds (9 allocations: 69.530 MiB, 11.76% gc time)
Sum of primes: 279209790387276
```
3. `Fortran`\\
```fortran
program sum_of_primes
    implicit none
    integer, parameter :: N = 100000000
    logical, allocatable :: primes(:)
    integer :: sum, p
    integer :: start_time, end_time, count_rate
    allocate(primes(N + 1))
    primes = .true.  ! Assume all numbers are prime initially
    primes(1) = .false.  ! 1 is not a prime number
    call system_clock(start_time, count_rate)
    do p = 2, int(sqrt(real(N)))
        if (primes(p)) then
            primes(p*p:N) = .false.
        end if
    end do
    sum = 0
    do p = 2, N
        if (primes(p)) sum = sum + p
    end do
    call system_clock(end_time, count_rate)
    print *, "Sum of primes up to ", N, " is: ", sum
    print *, "Time taken: ", real(end_time - start_time) / real(count_rate), " seconds"
    deallocate(primes)
end program sum_of_primes
```
Output is : 
```
 Sum of primes up to    100000000  is:            5
 Time taken:   0.370000005      seconds
```
4. `R`\\
```R
library(primes)
sum_of_primes <- function(N) {
  prime_numbers <- generate_primes(2, N)
  return(sum(prime_numbers))
}
N <- 10^8
system.time({
  result <- sum_of_primes(N)
})
print(result)
```
Output is :
```
user  system elapsed 
0.493   0.028   0.520 
[1] 2.792098e+14
```
5. `Python`\\
```python
import time
import numpy as np
from numba import jit
@jit(nopython=True)
def sum_of_primes(n):
    """Returns an array of primes, 3 <= p < n using bit array and loop unrolling"""
    sieve_bound = (n // 2)
    sieve = np.ones(sieve_bound, dtype=np.uint8)
    crosslimit = int(n**0.5) // 2
    for i in range(1, crosslimit + 1):
        if sieve[i]:
            start = 2 * i * (i + 1)
            step = 2 * i + 1
            for j in range(start, sieve_bound, step):
                sieve[j] = 0
    primes = 2 * np.nonzero(sieve)[0][1:] + 1
    return sum(primes)+2
N = 10**8
start_time = time.time()
result = sum_of_primes(N)
end_time = time.time()
print(f"Sum of primes: {result}")
print(f"Time taken: {end_time - start_time} seconds")
```
Output is : 
```
Sum of primes: 279209790387276
Time taken: 1.6742537021636963 seconds
```
\note{
    For python, initially I had used `primePy` library but it was much slower than this code for some reason.
}
Well...Now `C++` is the boss now!\\
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