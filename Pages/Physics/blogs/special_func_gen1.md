+++
title = "Special Function and it's generation"
hascode = true
date = Date(2024, 11, 07)
rss = "A brief discussion on Introduction on how to generate special functions using the tools of linear algebra."

tags = ["code", "Linear_Algebra", "Special_Function", "Gram-Schmidt_Orthogonalization", "Hilbert_Space"]
+++

\toc
# Formation of Orthogonal Polynomials (Special Functions) using tools of Linear Algebra
\newcommand{\col}[2]{~~~<span style="color:~~~#1~~~">~~~!#2~~~</span>~~~}

**\col{purple}{Special Functions}** refer to a set of mathematical functions that arise frequently in various physical contexts, particularly in solving differential equations that describe physical phenomena.

But do we really need to solve the differential equations to get those functions/polynomials? or **\col{blue}{is there something more fundamental related to the functional sapce itself?}**

As we know, these functions are distributed through-out the whole physics world. To analyze most of the problems people need to know them. Well this is hard specially for students. So, is there any work around?\\
Well, the answer is yes! But how? \\
**\col{purple}{In this blog we are going to learn the answers of the previous questions}.**
\poem{
**In the realm where numbers flow,\\
Special functions start to grow.\\
\col{red}{Bessel} hums with gentle grace,\\
In vibrating strings, finds its place.\\
 \\
\col{red}{Legendre} climbs the heights so tall,\\
Solving spheres, answering the call.\\
\col{red}{Hermite}’s waves, in quantum fields,\\
Guide the paths that nature yields.\\
 \\
\col{red}{Laguerre} whispers in the night,\\
Where hydrogen’s glow burns bright.\\
Hypergeometric, vast and grand,\\
Unifying the cosmic strand.\\
 \\
In this dance of math and light,\\
Physics soars to unknown heights.\\
Each function, a key so fine,\\
Unlocking secrets, divine.**
}

## Introduction to Gram-Schmidt Orthogonalization
In most of the physics problems, we use an \col{red}{inner product space} and in most cases we choose a basis in which the basis vectors are orthonormal to one another. Further, we also choose the norm of each vector to be unity.\\
So, if we have basis vectors $|e_i \rangle $ then,
$$
\langle e_i | e_j \rangle = \delta_{ij}
$$
where $$
\delta_{ij} = 
     \begin{cases}
       1 &\quad\text{if } i=j\\
       0 &\quad\text{if } i\neq j \\
     \end{cases}
$$
Here $|e_i \rangle $ are called **Orthonormal Basis**.

Now, let's say we have some arbitrary linearly independent vectors $| u_i \rangle$ which are not necessarily orthogonal to each other. It is required to obtain a set of orthogonal vectors $| v_i \rangle$ starting from the original set of vectors.

\note{An important thing to notice is that we really don't need $|u_i\rangle$ and $|v_i \rangle$ to be normalized.}

**\col{purple}{Method to generate $| v_i \rangle$}:**
We proceed as following:
1. Take $|v_1 \rangle = |u_1 \rangle$, i.e., choose the anyone of the vectors as the new vector.
2. Let $|v_2 \rangle = |u_2 \rangle + a_{21} |v_1 \rangle$ with the unknown constant $a_{21}$.
3. This $a_{21}$ is found by forcing the condition $\langle v_1,v_2 \rangle=0$. This gives us $$ a_{21} = -\frac{\langle v_1|u_2 \rangle}{\langle v_1|v_1 \rangle}$$ Thus, we have two orthogonal vectors $|v_1 \rangle$ and $|v_2 \rangle$.
4. Again, we define $|v_3 \rangle = |u_3 \rangle + a_{31}|v_1 \rangle + a_{32}|v_2 \rangle$ where $a_{31}$ and $a_{32}$ are constants.
5. Again, using $\langle v_1 | v_3 \rangle = 0$ and $\langle v_2 | v_3 \rangle = 0$. This implies $$ a_{31} = -\frac{\langle v_1|u_3 \rangle}{\langle v_1|v_1 \rangle}$$ $$ a_{32} = -\frac{\langle v_2|u_3 \rangle}{\langle v_2|v_2 \rangle}$$
6. Proceed with the same method. In the $i^{th}$ step, we will have,$$ |v_i \rangle = |u_i \rangle + a_{i1} |v_1 \rangle + a_{i2} |v_2 \rangle +\cdots a_{i,i-1}|v_{i-1}\rangle $$ Finally give the condition that all the previous vectors are orthogonal to the new one.

Let's see an example.
\exam{
    Let's take two vectors $|u_1\rangle = 1\hat{i} + 3\hat{j}$ and $|u_2\rangle = 4\hat{i} + 2\hat{j}$. Then using the previous formulas,
    $$
    |v_1 \rangle = |u_1\rangle = 1\hat{i} + 3\hat{j}
    $$
    Then, $$ a_{21} = -\frac{\langle v_1|u_2 \rangle}{\langle v_1|v_1 \rangle} = -\frac{1\times 4 + 3 \times 2}{1 \times 1 + 3\times 3} = -1$$
    Finally, we have $$|v_2 \rangle = |u_2\rangle -1\times |v_1 \rangle = 3\hat{i} - \hat{j}$$
    See the interactive example below. The initial points represent the example here.
}
~~~
<script type="text/javascript" charset="UTF-8"
 src="https://cdn.jsdelivr.net/npm/jsxgraph/distrib/jsxgraphcore.js"></script>
<link rel="stylesheet"
 type="text/css" href="https://cdn.jsdelivr.net/npm/jsxgraph/distrib/jsxgraph.css" />
<script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
<div id="board" class="jxgbox" style="width:400px; height:400px;"></div>
<script>
    JXG.Options.text.useMathJax = true;
    var board = JXG.JSXGraph.initBoard(
        "board",
        {
            boundingbox: [-5, 5, 5, -5],
            axis: true
        }
    );
    // Define two movable points
    const A = board.create('point', [1, 3], {name: 'A', size: 2});
    const B = board.create('point', [4, 2], {name: 'B', size: 2});
    
    // Initial lines for the vectors
    const v1 = board.create('line', [[0, 0], A], {straightFirst: false, straightLast: false, strokeColor: 'blue'});
    const v2 = board.create('line', [[0, 0], B], {straightFirst: false, straightLast: false, strokeColor: 'green'});

    // Orthogonalized vectors (arrows)
    const U1 = board.create('arrow', [[0, 0], [0, 0]], {strokeColor: 'red'});
    const U2 = board.create('arrow', [[0, 0], [0, 0]], {strokeColor: 'purple'});

    // Function to compute the dot product
    function dotProduct(u, v) {
      return u[0] * v[0] + u[1] * v[1];
    }

    // Function to compute the vector magnitude
    function magnitude(v) {
      return Math.sqrt(v[0] * v[0] + v[1] * v[1]);
    }

    // Function to subtract vectors
    function subtract(u, v) {
      return [u[0] - v[0], u[1] - v[1]];
    }

    // Function to multiply vector by a scalar
    function scalarMultiply(scalar, v) {
      return [scalar * v[0], scalar * v[1]];
    }

    // Function to format vectors for display
    function formatVector(v) {
      return `(${v[0].toFixed(2)}, ${v[1].toFixed(2)})`;
    }

    // Add text elements for the formulas
    const formulaU1 = board.create('text', [-4.7, 4, function() {
      return `\\(\\mathbf{u}_1 = \\mathbf{v}_1 = ${formatVector([A.X(), A.Y()])}\\)`;
    }], {fontSize: 18});

    const formulaU2 = board.create('text', [-4.8, -4, function() {
      const proj = scalarMultiply(dotProduct([B.X(), B.Y()], [A.X(), A.Y()]) / dotProduct([A.X(), A.Y()], [A.X(), A.Y()]), [A.X(), A.Y()]);
      const u2 = subtract([B.X(), B.Y()], proj);
      return `\\(\\mathbf{v}_2 = \\mathbf{u}_2 - \\text{proj}_{\\mathbf{v}_1}\\mathbf{u}_2 = ${formatVector(u2)}\\)`;
    }], {fontSize: 18});

    // Add text element for the angle between the vectors
    const angleText = board.create('text', [2, 3, function() {
      const dot = dotProduct([A.X(), A.Y()], [B.X(), B.Y()]);
      const magA = magnitude([A.X(), A.Y()]);
      const magB = magnitude([B.X(), B.Y()]);
      const angleRad = Math.acos(dot / (magA * magB));
      const angleDeg = (angleRad * 180 / Math.PI).toFixed(2);
      return `\\(\\theta = ${angleDeg}^\\circ\\)`;
    }], {fontSize: 18});

    // Update function to recalculate and redraw the orthogonalized vectors
    function updateOrthogonalVectors() {
      const u1 = [A.X(), A.Y()];
      const proj = scalarMultiply(dotProduct([B.X(), B.Y()], u1) / dotProduct(u1, u1), u1);
      const u2 = subtract([B.X(), B.Y()], proj);

      U1.point2.setPosition(JXG.COORDS_BY_USER, u1);
      U2.point2.setPosition(JXG.COORDS_BY_USER, u2);
      
      board.update();
    }

    // Add event listeners to update the orthogonal vectors when points A or B are moved
    A.on('drag', updateOrthogonalVectors);
    B.on('drag', updateOrthogonalVectors);

    // Initial update
    updateOrthogonalVectors();
</script>
~~~
So, we have created **\col{red}{two orthogonal vectors}** from two non-orthogonal vectors. If we can also take the vectors to be normalized. But like mentioned before, it really doesn't matter.
<!-- ```julia:./mandel.jl
function mandel_check(c,max_ita=1000)
    z = 0
    for i in 1:max_ita
        z = z^2 + c
        if abs(z) >= 2
            print(c," is not in mandelbrot set upto set iter no.")
            break
        else
            if i==max_ita && abs(z)<2
                print(c," is in mandelbrot set upto set iter no.")
            end
        end
    end
end
mandel_check(1)
``` -->
<!-- The output is:
\output{./mandel.jl}
For $c = 0.3 + 0.2\mathbb{i}$,

```julia:./mandel.jl
mandel_check(0.3+0.2im)
``` -->
<!-- \output{./mandel.jl} -->



## Orthogonal Polynomials
Before discussing the **\col{purple}{Orthogonal Polynomials}** we have to define the inner product once again(wft again!... yes but for infinite dimensional vector spaces).

An inner product on a vector space as we know is a map $I:V \times V \to \mathbb{C}$ that has certain properties. Here I will not discuss the properties(will assume you know if not then maybe read Afken's book or maybe Balakrishnan's book). So, let's define the inner product:

Suppose we are considering functions in the interval $x_1 \leq x \leq x_2$. An \col{purple}{inner product} of two such functions $f(x)$ and $g(x)$ can be defined as,
$$
\langle f|g \rangle = \int_{x_1}^{x_2}dx w(x)f^*(x)g(x)
$$
where $w(x)$ is called the **\col{blue}{weight function}** and $f^*(x)$ represent complex conjugate of $f(x)$.
\note{$w(x)\geq 0$ must be assumed as without it any function can't have positive norm. This is sort of metric of the functional space.}

With this we are now ready to see how to generate special functions.

---

As we know polynomials form a function space. If we restrict our attention to functions of $1$ real variables, we can ask **\col{red}{what could be a convenient basis in these function space}. Maybe you can say it is 
$$
1,x,x^2,x^3,\cdots, x^n,\cdots
$$
However, this is not necessarily an orthogonal basis as it depends upon $w(x)$. Then how do we find it?, well well.. just use **\col{purple}{Gram-Schmidt orthogonalization}**. Let's see it in detail.

### Procedure to generate

Given any weight function $w(x)$ and interval $x_1\leq x \leq x_2$, we start with,
1. $f_0(x) =1$ --> We don't really care about the normalization in any arbitrary stage of iteration.
2. For the next function choose $f_1(x) = A_1(a_{10}+x)$ where just like before we have two unknown constants which we have to find. Also note $A_1\neq 0$.
3. Now, we do $$\int_{x_1}^{x_2}dx w(x) (a_{10}+x) = 0$$ This gives us $$a_{10}I_0 + I_1 = 0 \label{first1}$$.
Here we have defined the notation,$$
I_n = \int_{x_1}^{x_2}dx w(x) x^n
$$
4. Apart from $A_1$ we find $a_{10}$ from eqn-\eqref{first1}.
5. For the next one, $f_2(x) = A_2(a_{20}+a_{21}x+x^2)$ with $A_2\neq 0$.
6. Then we have two condition,$$\int_{x_1}^{x_2}dx w(x)(a_{20} + a_{21}x+x^2)=0$$ and $$\int_{x_1}^{x_2}dx w(x)(a_{20} + a_{21}x+x^2)(a_{10}+x)=0$$
7. This two gives us, $$ a_{20}I_0 + a_{21}I_1 +I_0 = 0 $$ and $$a_{20}a_{10}I_0 + (a_{20}+a_{21}a_{10})I_1 + (a_{21}+a_{10})I_2 + I_3 = 0$$
8. Use this two to find $a_{20}$ and $a_{21}$. Repeat this process depending on how many terms you need.
\note{If the weight function as well as the limits are symmetric, i.e., if $$w(x) = w(-x) \text{ \ and \ } x_1 = -x_2$$ then each polynomial will contains **\col{red}{either only the even powers or only the odd powers} of $x$. This means $$f_n(-x) = (-1)^nf_n(x)$$

Another interesting thing is, the condtions are same as the discrete version. To see this just write the inner product in bra-ket notation or see the julia code below.
}

Let's see the application of this theory.

## Generating Special Functions
Let's see few of the well-known ones.
### Legendre Polynomials
We know Legendre Polynomials are defined in the range $-1\leq x \leq 1$. Also, take $w(x) = 1$.
1. Start with $P_0(x) = 1$. Then using eqn-\eqref{first1} we have $$a_{10} = -\frac{I_1}{I_0} = 0$$.
2. Then, $P_1(x) = A_1x$. We set the normalization $A_1 = 1$, this gives us $P_1(x) = x$.
3. For the next one we get $a_{21}=0$ and $a_{20} = -1/3$. Again taking $A_2 = 1$ gives $P_2(x) = -1/3 + x^2$.
 We can go as long as we want. This are exactly \col{red}{Legendre Polynomials}.\\
 It should be noted that we have not taken proper normalization. We can certainly do that. To do that just choose the coefficients such that the sum of them is $1$.

 As an example, coefficients of $P_2(x)$ are $1$ and $-1/3$. Multiply by a factor of $\alpha$ and solve such that the sum of all the coefficient is $1$. This is $\alpha + (-\frac{\alpha}{3}) = 1$ which gives $\alpha = 3/2$. This gives $P_2(x) = \frac{1}{2}(3x^2-1)$.

Let's write a code in julia for this.
```julia:./orthogonal_poly.jl
function inner_product(f, g, a ,b, w)
    return integrate(f * g * w, (x, a, b))
end

function gram_schmidt(funcs,a,b;w=1)
    orthogonal_polynomials = []

    for i in 1:length(funcs)
        f_i = funcs[i]
        for j in 1:(i-1)
            proj = inner_product(orthogonal_polynomials[j], f_i, a,b,w) /
                   inner_product(orthogonal_polynomials[j], orthogonal_polynomials[j], a,b,w)
            f_i -= simplify(proj * orthogonal_polynomials[j])
        end
        push!(orthogonal_polynomials, simplify(f_i))
    end
    return orthogonal_polynomials
end

function normalized(p)
    k = sympy.poly(p,x)
    pp = k.coeffs()
    return p/sum(pp)
end
```
These are the functions we are going to use. Let's use this for recreating the result.
```julia:./orthogonal_poly.jl
using SymPy
x = Sym("x")
monomials = [x^i for i in 0:5]
legendre_polynomials = gram_schmidt(monomials,-1,1;w=x^0)
leg_f = normalized.(legendre_polynomials)
println("Without normalization:")
for (i, poly) in enumerate(legendre_polynomials)
    println("P_$(i-1)(x) = $poly")
end
println("With Normalization:")
for (i, poly) in enumerate(leg_f)
    println("P'_$(i-1)(x) = $poly")
end
```
which gives,
\output{./orthogonal_poly.jl}

Let's see one more example:
### Hermite Polynomials
We know Legendre Polynomials are defined in the range $-\infty < x <\infty $. Also, take $w(x) = \exp(-x^2)$.
1. Start with $H_0(x) = 1$. Then using eqn-\eqref{first1} we have $$a_{10} = -\frac{I_1}{I_0} = 0$$.
2. Then, $H_1(x) = A_1x$. We set the normalization $A_1 = 1$, this gives us $H_1(x) = x$.
3. For the next one we get $a_{21}=0$ and $a_{20} = -\frac{1}{2}$. Again taking $A_2 = 1$ gives $H_2(x) = x^2 - \frac{1}{2}$.
4. Again we can normalize it in the similar way as before which gives us $H_2(x) = 2x^2-1$.
 We can go as long as we want. This are exactly \col{red}{Legendre Polynomials}.\\
 It should be noted that we have not taken proper normalization. We can certainly do that. To do that just choose the coefficients such that the sum of them is $1$.

 Our code gives us,
 ```julia:./orthogonal_poly.jl
monomials = [x^i for i in 0:5]
hermite_polynomials = gram_schmidt(monomials,-oo,oo;w=exp(-x^2))
her_f = normalized.(hermite_polynomials)
println("Without normalization:")
for (i, poly) in enumerate(hermite_polynomials)
    println("H_$(i-1)(x) = $poly")
end
println("With Normalization:")
for (i, poly) in enumerate(her_f)
    println("H'_$(i-1)(x) = $poly")
end
```
which gives,
\output{./orthogonal_poly.jl}

\prob{Consider $$w(x) = \frac{1}{\sqrt{1-x^2}}$$ along with $-1\leq x \leq 1$. Find the first three values using the method. Don't use the code in the beginning. Also guess what special function it is?

Do the same for the same range of $x$ but with $$w(x) = (1-x^2)^{\beta -1/2}$$ This generates **\col{purple}{Gegenbauer Polynomial}**.
}

## Differential Equations for the polynomials
So, those **Special Functions** are really something born from the structure of **metric** and **hibert-space**. But this implies that **\col{blue}{differential equtions corresponding to the special functions should be derivable from the $w(x)$ itself}**. Let's see how to do that!
### Method
Let's say we have an **eigenvalue equation** as,
$$
a(x)\frac{d^2y}{dx^2}+b(x)\frac{dy}{dx} + cy = 0
\label{diff_get_1}
$$
A bit of analysis tells us,
$$
\frac{d}{dx}[w(x)a(x)]=w(x)b(x)
\label{diff_get_2}
$$
Also the **solutions pertaining to different allowed values of $c$ are orthogonal**.

So, given a set of **orthogonal polynomials**, we find the differential equation using the following ways:

1. A constant function is always an eigenfunction, with the eigenvalue $c_0=0$.
2. An overall factor in the coefficients $a$, $b$ and $c$ is arbitrary, since eigenvalue equation is homogeneous. We can fix this arbitrariness by choosing $c_1$ to anything we like.
3. Once $c_1$ is fixed, $a$ and $b$ are fixed without any freedom. For $n=1$, we have from eqn-\eqref{diff_get_2} is $$b(x)\frac{df_1}{dx} = -c_1f_1$$
4. Using the form of $f_1(x)=A_1(a_{10}+x)$, we get $$b(x)=-c_1(a_{10}+x) \label{b_val_1}$$ which determines $b(x)$.
\note{If the polynomials are alternately even and odd, i.e., when the limits as well as the weight function are symmetric about $x=0$, then $a_{10}=0$ and so $$b(x)=-c_1x$$}
5. Now, eqn-\eqref{diff_get_2} can be used to find $a(x)$. Any integration constant can aslo be obtained by $$w(x_1)a(x_1)=w(x_2)a(x_2)=0\label{a_val_pro}$$
6. Finally we can find $c_n$ for arbitrary $n$ by putting the value of the **orthogonal polynomial**.

### Example
Let's see an example for this.

For $w(x)=1$ and $x_1=-1$ & $x_2=1$, we have,
$$
\frac{d}{dx}[1\times a(x)] = 1\times b(x) \implies \frac{da}{dx}=b
$$
Previously we showed that $a_{10}=0$ so $b$ is given by eqn-\eqref{b_val_1} as $b_1 = -c_1 x$.

This implies $a = -c_1 x^2/2 + k$ where $k$ is some unknown constant of integration. Choosing $c_1 = 2$, we have
$$
b = -2x \text{\ \ and \ \ } a = -x^2 + k
$$
Finally using eqn-\eqref{a_val_pro}, we get,
$$
1\times (k-x_1^2) = 1\times (k-x_2^2)=0 \implies k=1
$$
This gives,
$$
a = 1-x^2
$$
So, we have the equation:
$$
(1-x^2)\frac{d^2 P_n}{dx^2} - 2x\frac{dP_n}{dx}+c_n P_n = 0
$$
Now, we can plug $P_n$ value of get the $c_n$ with $n>1$. But there is a nicer way,
Use
$$
P_n(x) = \sum_{r=0}^{n}A_{nr}x^r
$$
Plugging this into the equation and equating the power of $x^n$ gives us,
$$c_n = n(n+1)$$
\exam{
  Briefly let's see one more. Take $w(x) = e^{-x^2}$ with $-\infty < x < +\infty$. Here we will have, $$\frac{da}{dx}-2xa = b \implies \frac{da}{dx}=2x(a-1)$$
  Here similar to previous case we have $a_{10} = 0$, which gives $b = -c_1x$ and again we have chosen $c_1 = 2$. 
  For $a$ we get,
  $$
  a-1 = ke^{-x^2} \text{\ \ }k \text{ is integration constant}
  $$
  using eqn-\eqref{a_val_pro}, we have $k=0$, giving us $a=1$.
  This gives us,
  $$
  \frac{d^2 H_n}{dx^2} - 2x\frac{dH_n}{dx} +c_nH_n=0
  $$
  Now for the final touch, just put a power series expansion and compare the coefficients of $x^n$, which will gives us $c_n=2n$.
}

\prob{Consider $$w(x) = \frac{1}{\sqrt{1-x^2}}$$ along with $-1\leq x \leq 1$. Find it's differential equation.

Why not try the same for the same range of $x$ but with $$w(x) = (1-x^2)^{\beta -1/2}$$
}
Isn't it nice?
_________________________________________________

I hope you learn something new and enjoyed this article.

If you have some queries, do let me know in the comments (you need github account) or contact me using my using the informations that are given on the page [About Me](/Pages/about_me/).


~~~
<div id="disqus_thread"></div>
<script>
    /**
    *  RECOMMENDED CONFIGURATION VARIABLES: EDIT AND UNCOMMENT THE SECTION BELOW TO INSERT DYNAMIC VALUES FROM YOUR PLATFORM OR CMS.
    *  LEARN WHY DEFINING THESE VARIABLES IS IMPORTANT: https://disqus.com/admin/universalcode/#configuration-variables    */
    /*
    var disqus_config = function () {
    this.page.url = https://rousan.netlify.app/pages/physics/blogs/special_func_gen1/;  // Replace PAGE_URL with your page's canonical URL variable
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