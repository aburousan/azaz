+++
title = "A Pedestrian's Guide to FORM for Particle Physics (via Julia)"
date = Date(2026, 6, 24)
tags = ["qft", "particle-physics", "julia", "form"]
+++

\toc
\newcommand{\col}[2]{~~~<span style="color:~~~#1~~~">~~~!#2~~~</span>~~~}

# Symbolic Manipulation in QFT: A Pedestrian's Guide to FORM via Julia

\poem{
**Mathematica dreams, Sage likes to play,\\
FORM grinds the billion terms away.\\
Where memory breaks and others deform,\\
loops bow down to the will of FORM.**\\

                                      ---K.A.Rousan
}

In Quantum Field Theory (QFT), computing scattering amplitudes often involves evaluating traces of dozens of Dirac gamma matrices, contracting hundreds of Lorentz indices, and wrangling millions of algebraic terms. General-purpose computer algebra systems (CAS) like Mathematica or SymPy often choke on memory or speed when dealing with these "real computations."

## What is FORM and Why is it Different?

Enter **FORM**. Developed over decades by Jos Vermaseren at NIKHEF, FORM is the spiritual successor to SCHOONSCHIP (one of the very first dedicated programs for high-energy physics, created in the 1960s). It is not a general-purpose computer algebra system. Instead, it was explicitly built to tackle massive **\col{red}{real computations}** on **\col{blue}{real computers}**. 

\note{
When you compute the square of a Feynman diagram with many loops, you can easily generate millions of terms. General-purpose systems (which try to hold the entire expression and its structure in memory simultaneously) will often crash. FORM avoids this by sequentially processing expressions **term by term**.
}

This local operational mode means:
* **Memory Efficiency:** Only the active term needs to be in memory, allowing computations with billions of terms.
* **Speed:** Operations are aggressively optimized for tensor contractions, Dirac algebra, and pattern-matching substitutions.
* **No Built-in Factorization:** Because factorization requires seeing the *whole* expression at once, FORM does not do it automatically. You guide it using specific bracket commands or substitutions.

In this post, we will look at how to leverage FORM's QFT capabilities directly from the **Julia programming language** using Franklin.jl.

## Installing and Running FORM

Before connecting it to Julia, you might wonder how to install and run FORM natively. 

### Native Installation
FORM is open-source and hosted on GitHub (`github.com/vermaseren/form`). You can compile it from source on most Unix-like systems (Linux, macOS) using standard GNU build tools:
```bash
git clone https://github.com/vermaseren/form.git
cd form
autoreconf -i
./configure
make
sudo make install
```

### Running FORM from the Command Line
Once installed, you run FORM by creating a script with the `.frm` extension (e.g., `calc.frm`) and executing it via your terminal:
```bash
form calc.frm
```
This reads the script, evaluates the algebra, and prints the result to standard output. 

## The Julia-FORM Bridge

While FORM has its own syntax, it is highly convenient to orchestrate the generation of diagrams and parsing of results in Julia. We can use the `FORM_jll.jl` package to guarantee the `form` binary is available on any system. 

Let's define a simple wrapper in Julia to evaluate FORM code:

```julia:setup
using FORM_jll

function evaluate_form(script::String)
    # We append 'Format 255;' to use the full horizontal width, 'Off statistics;' to hide execution times, and '.end' to terminate the FORM script.
    full_script = "Format 255;\nOff statistics;\n" * script * "\nPrint;\n.end\n"
    
    # Create a temporary directory to store our script file safely
    mktempdir() do dir
        frm_path = joinpath(dir, "calc.frm")
        
        # Write our FORM code to the temporary file
        write(frm_path, full_script)
        
        out = IOBuffer()
        
        # form() provides the path to the FORM executable.
        # We run it in quiet mode (-q) to suppress startup text, and capture the output.
        form() do form_exe
            run(pipeline(`$form_exe -q $frm_path`, stdout=out))
        end
        
        # Convert the captured bytes into a Julia String and return it
        return String(take!(out))
    end
end
```
## Understanding FORM Syntax (The Basics)

Before we dive into heavy QFT, let's briefly break down the FORM syntax you will see in the upcoming code blocks. FORM is a statement-based language; every command ends with a semicolon (`;`).

* **Declarations (`Symbols`, `Vectors`, `Indices`, `Functions`):** FORM needs to know exactly what mathematical objects it is dealing with. You must declare scalars as `Symbols`, four-vectors as `Vectors`, spacetime/color indices as `Indices`, and non-commutative operators as `Functions`.
* **Defining Expressions (`Local`):** The `Local` keyword defines an algebraic expression that FORM will actively evaluate and store in memory.
* **Dirac Matrices (`g_`):** The building block of QFT fermion lines! In FORM, `g_(spin_line, index)` represents $\gamma^\mu$. `g_(1, m)` is the gamma matrix $\gamma^\mu$ on fermion line 1. You can also write slash momenta as `g_(1, p)` ($\not{p}$).
* **Kronecker Delta / Metric Tensor (`d_`):** FORM uses `d_(m, n)` to represent both the Kronecker delta $\delta_{mn}$ and the Minkowski metric $\eta_{\mu\nu}$.
* **Traces (`trace4`):** `trace4, 1;` tells FORM to take the Dirac trace over the gamma matrices residing on fermion line `1` in 4 dimensions.
* **Contractions (`contract`):** `contract;` tells FORM to sum over repeated dummy indices in the expression (e.g., Einstein summation convention).
* **Pattern Matching (`id`):** The `id` (identify) command applies algebraic substitutions. For example, `id p.k = s/2;` substitutes the dot product $p \cdot k$ with $s/2$. You can use wildcards like `id d_(i?, i?) = N;` to substitute any repeated index $i$ with $N$.
* **Factorization (`Bracket`):** FORM expands everything by default. If you want to group terms together based on certain variables (like propagators), you use `Bracket Ds, Du;`.

Now, let's see these in action!

## Example 1: Tensor Contractions & The Levi-Civita Tensor

In QFT, we often contract antisymmetric tensors $\epsilon_{\mu\nu\rho\sigma}$. Let's compute the contraction of two Levi-Civita tensors in 4 dimensions: 

$$
\epsilon_{\mu\nu\rho\sigma}\epsilon^{\mu\nu\rho\sigma} = 4! = 24
$$

```julia:tensor
form_code = """
    Dimension 4;
    Indices m,n,r,s;
    Local result = e_(m,n,r,s) * e_(m,n,r,s);
    contract;
"""
println(evaluate_form(form_code))
```
\output{tensor}

## Example 2: Traces of Dirac Gamma Matrices

The bread and butter of evaluating Feynman diagrams with fermions is the Dirac algebra. Let's compute a standard QED trace: 

$$
\text{Tr}(\gamma^\mu \gamma^\nu \gamma^\rho \gamma^\sigma) = 4 (\eta^{\mu\nu}\eta^{\rho\sigma} - \eta^{\mu\rho}\eta^{\nu\sigma} + \eta^{\mu\sigma}\eta^{\nu\rho})
$$

```julia:dirac
trace_code = """
    Dimension 4;
    Indices m,n,r,s;
    Local QEDtrace = g_(1, m) * g_(1, n) * g_(1, r) * g_(1, s);
    trace4, 1;
"""
println(evaluate_form(trace_code))
```
\output{dirac}

## Example 3: Symmetry Properties of Functions

FORM natively handles function symmetries. You can declare functions as `symmetric`, `antisymmetric`, `cyclic`, or `rcyclic`. FORM will automatically sort their arguments into standard order and apply the correct minus signs for antisymmetric permutations!

```julia:symmetry
sym_code = """
    Symbols x1,x2,x3,x4,x5;
    Functions S(symmetric), A(antisymmetric), C(cyclic), R(rcyclic);
    Local [S] = S(x2,x3,x4,x1,x5);
    Local [A] = A(x2,x3,x4,x1,x5);
    Local [C] = C(x2,x3,x4,x1,x5);
    Local [R] = R(x2,x3,x4,x1,x5);
"""
println(evaluate_form(sym_code))
```
\output{symmetry}

## Example 4: Built-in Mathematical Functions & Sums

FORM comes packed with implemented mathematical functions for factorials (`fac_`), binomial coefficients (`binom_`), Kronecker deltas (`delta_`), and even arbitrary summations (`sum_`). 

Let's quickly sum the Taylor series of $e^x$ up to $x^5$:
```julia:math_funcs
math_code = """
    Symbols x, i;
    Local expx = sum_(i, 0, 5, x^i/fac_(i));
"""
println(evaluate_form(math_code))
```
\output{math_funcs}

## Example 5: Tensors and SCHOONSCHIP Notation

FORM distinguishes between `Vectors`, `Indices`, and `Tensors` (or `CTensors` for commuting components). It also utilizes the highly elegant **SCHOONSCHIP notation**: when an index is summed over and is the argument of a vector, the vector itself replaces the index!

For instance, $\sum_i u_i v_i$ evaluates directly to the dot product $u \cdot v$.

```julia:tensors
tensor_code = """
    Vectors u,v;
    Indices i,j;
    Function f;
    Index k=0;
    
    Local dot = u(i) * v(i);
    Local schoonschip = f(i,j) * u(i) * v(j);
    
* Overruling contraction using dimension 0
    Local nocontract = u(k) * v(k);
    
    contract;
"""
println(evaluate_form(tensor_code))
```
\output{tensors}

\note{
You can explicitly force summation over uncontracted dimension-zero indices using the `sum k;` command.
}

## Example 6: Vector Calculus and Cross Products

Using the Levi-Civita tensor `e_`, we can perform 3D vector calculus trivially. Let's compute the double cross product $\vec{u} \times (\vec{v} \times \vec{w})$ and verify the classic "BAC-CAB" vector identity rule!

```julia:cross_product
cross_code = """
    Dimension 3;
    Vectors u,v,w;
    Indices i,j,k,m,n;
    
* Cross product definition using Levi-Civita
    Local [ux(vxw)] = e_(i,j,k) * u(i) * (e_(m,n,j) * v(m) * w(n));
    contract;
"""
println(evaluate_form(cross_code))
```
\output{cross_product}

## Example 7: Gram Determinants and AutoDeclare

FORM is the absolute king of determinants. To compute the Gram determinant of $n$ vectors, we square the Levi-Civita tensor. For 10 vectors, the expanded Gram determinant has $10! = 3,628,800$ terms, which FORM chews through in minutes. 

Let's compute the Gram determinant for 3 vectors using `AutoDeclare` (which tells FORM to automatically assume all undeclared variables starting with `v` are vectors) and the `...` sequence generation operator:

```julia:gram
gram_code = """
    AutoDeclare Vector v;
    Local G3 = e_(v1,...,v3)^2;
    contract;
"""
println(evaluate_form(gram_code))
```
\output{gram}

## Example 8: Mandelstam Variables and Scattering Kinematics

For Bhabha scattering kinematics ($e^+ e^- \to e^+ e^-$), we evaluate traces and substitute the Mandelstam invariants. In the limit where we ignore the electron mass, $s+t+u=0$. The differential cross section is given by:

$$
\frac{d\sigma}{d\cos\theta} = \frac{\pi\alpha^2}{s} \left[ u^2 \left(\frac{1}{s} + \frac{1}{t}\right)^2 + \left(\frac{t}{s}\right)^2 + \left(\frac{s}{t}\right)^2 \right]
$$

With Mandelstam variables defined as:
$$
s = (p+k)^2, \quad t = (p-p')^2, \quad u = (p-k')^2
$$

~~~
<div style="text-align: center; margin-bottom: 2rem;">
  <img class="math-diagram" src="/assets/Physics/blogs/form_pedestrian_qft_blog/bhabha.svg" alt="Bhabha Scattering Feynman Diagrams" style="max-width: 100%; height: auto; border-radius: 8px;">
</div>
~~~

```julia:mandelstam
mandelstam_code = """
    Dimension 4;
    Vectors p, k, pp, kp;
    Indices m, n;
    Symbols s, t, u;
    
    Local M2 = g_(1, m) * g_(1, p) * g_(1, n) * g_(1, k) 
             * g_(2, m) * g_(2, pp)* g_(2, n) * g_(2, kp);
             
    trace4, 1;
    trace4, 2;
    contract;
    
    id p.p = 0;
    id k.k = 0;
    id pp.pp = 0;
    id kp.kp = 0;
    
    id p.k = s/2;
    id pp.kp = s/2;
    id p.pp = -t/2;
    id k.kp = -t/2;
    id p.kp = -u/2;
    id k.pp = -u/2;
"""
println(evaluate_form(mandelstam_code))
```
\output{mandelstam}

## Example 9: A Full QFT Calculation — Compton Scattering

Let's compute the unpolarized squared matrix element for **Compton Scattering** ($e^-(p) + \gamma(k) \to e^-(p') + \gamma(k')$). 

The scattering amplitude $\mathcal{M}$ is the sum of the $s$-channel and $u$-channel Feynman diagrams:

$$
\mathcal{M} = \mathcal{M}_s + \mathcal{M}_u 
$$

~~~
<div style="text-align: center; margin-bottom: 2rem;">
  <img class="math-diagram" src="/assets/Physics/blogs/form_pedestrian_qft_blog/compton.svg" alt="Compton Scattering Feynman Diagrams" style="max-width: 100%; height: auto; border-radius: 8px;">
</div>
~~~

Where the invariant matrix element (derived from the Feynman rules of QED) is given by:

$$
i\mathcal{M} = \bar{u}(p') (-ie\gamma^\mu) \epsilon_\mu^*(k') \frac{i(\not{p} + \not{k} + m)}{(p+k)^2 - m^2} (-ie\gamma^\nu) \epsilon_\nu(k) u(p) + \bar{u}(p') (-ie\gamma^\nu) \epsilon_\nu(k) \frac{i(\not{p} - \not{k}' + m)}{(p-k')^2 - m^2} (-ie\gamma^\mu) \epsilon_\mu^*(k') u(p)
$$

Which simplifies to:

$$
i\mathcal{M} = -ie^2 \epsilon_\mu^*(k') \epsilon_\nu(k) \bar{u}(p') \left[ \frac{\gamma^\mu(\not{p} + \not{k} + m)\gamma^\nu}{(p+k)^2 - m^2} + \frac{\gamma^\nu(\not{p} - \not{k}' + m)\gamma^\mu}{(p-k')^2 - m^2} \right] u(p)
$$

Squaring this amplitude involves taking the trace over the fermion lines and summing over the final state photon polarizations $\sum \epsilon_\mu \epsilon_\nu^* \to -g_{\mu\nu}$. Averaging over initial electron and photon spins, and summing over final states gives:

$$
\frac{1}{4} \sum_{\text{spins}} |\mathcal{M}|^2 = \frac{e^4}{4} g_{\mu\rho} g_{\nu\sigma} \cdot \text{tr}\left\{ (\not{p}' + m) \left[ \frac{\gamma^\mu(\not{p}+\not{k}+m)\gamma^\nu}{2p\cdot k} + \frac{\gamma^\nu(\not{p}-\not{k}'+m)\gamma^\mu}{-2p\cdot k'} \right] (\not{p} + m) \left[ \dots \right] \right\}
$$

Doing this by hand requires pages of trace theorems to get the final Klein-Nishina result:

$$
\frac{1}{4} \sum_{\text{spins}} |\mathcal{M}|^2 = 2e^4 \left[ \frac{p \cdot k'}{p \cdot k} + \frac{p \cdot k}{p \cdot k'} + 2m^2 \left( \frac{1}{p \cdot k} - \frac{1}{p \cdot k'} \right) + m^4 \left( \frac{1}{p \cdot k} - \frac{1}{p \cdot k'} \right)^2 \right]
$$

\note{
FORM handles these massive intermediate traces and tensor contractions instantly, ensuring we never drop a minus sign or miss a factor of 2!
}

```julia:compton
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

println(evaluate_form(compton_code))
```
\output{compton}

### Reconciling the Output with the Textbook

Because we used `pdotk` for $p \cdot k$ and `pdotkp` for $p \cdot k'$, and applied `Multiply 4^-1;` to account for the $\frac{1}{4}$ initial state spin-averaging, FORM's final result is a **perfect term-by-term match** with the expanded version of the textbook's Klein-Nishina formula!

For example, the textbook has the term $2m^4 \left( \frac{1}{p\cdot k} - \frac{1}{p\cdot k'} \right)^2$. When expanded, this gives:
$$ \frac{2m^4}{(p \cdot k)^2} + \frac{2m^4}{(p \cdot k')^2} - \frac{4m^4}{(p \cdot k)(p \cdot k')} $$
Which is exactly what FORM prints out natively as `pdotk^-2 * 2*m^4`, `pdotkp^-2 * 2*m^4`, and `pdotk^-1*pdotkp^-1 * -4*m^4`.

You literally just type the Feynman rules, and FORM hands you the final physical answer.

## Example 10: QCD and Color Algebra ($SU(N)$)

In QCD, calculations require taking traces over $SU(3)$ color matrices. We often need to evaluate the standard color factor $C_F$:

$$
\sum_a \left(T^a T^a\right)_{ij} = C_F \delta_{ij} \implies \text{Tr}(T^a T^a) = C_F \text{Tr}(\mathbf{1}) = C_F N
$$

Using the $SU(N)$ Fierz identity, we know:

$$
C_F = \frac{N^2 - 1}{2N}
$$

Let's derive this using FORM's pattern matching and non-commutative functions:

```julia:qcd
qcd_code = """
    Symbols N, CF, TR;
    Dimension N;
    Indices a, b, c, i, j, k, l;
    
    Functions T;
    
    Local ColorTrace = T(a, i, j) * T(a, j, i);
    Local ColorFactor = ColorTrace * N^-1;
    
    id T(a?, i?, j?) * T(a?, k?, l?) = TR * ( d_(i,l)*d_(j,k) - d_(i,j)*d_(k,l)*N^-1 );
    
    contract;
    
    id TR = 1/2;
"""

println(evaluate_form(qcd_code))
```
\output{qcd}

## Conclusion

FORM isn't just an archaic tool; it is a hyper-optimized engine that outpaces modern algebra systems for the specific mathematical structures of Particle Physics. By calling it seamlessly from Julia, we get the best of both worlds: Julia's modern package management and flow control, and FORM's raw power for the QFT heavy lifting.
