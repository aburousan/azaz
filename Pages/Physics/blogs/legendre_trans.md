+++
title = "Legendre's Tranformation: A intuitive approach"
hascode = true
date = Date(2025, 10, 31)
rss = "A brief discussion on Legendre Transformation"

tags = ["code", "Legendre_Tranform", "Special_Function", "Hamiltonian", "Lagrangian", "Thermodynamics"]
+++

\toc
# Legendre's Tranformation: An Intuitive Approach
\newcommand{\col}[2]{~~~<span style="color:~~~#1~~~">~~~!#2~~~</span>~~~}

**\col{purple}{Legendre Transformation}** is an involutive transformation on real-valued functions that are convex on a real variable. Specifically, if a real-valued multivariable function is convex on one of its independent real variables, then the Legendre transform with respect to this variable is applicable to the function.

This uses the fact that **\col{blue}{points and lines are related by some sort of duality}**, which let's us relate different ideas of physics to each other. Although, we learn it just as a transformation in Classical Mechanics & Thermodynamics, it is really simple and intuitive. 

In this blog, we will undertand exactly that.\\

\poem{
**A curve of thought, so smooth, so sly,\\
Hides truth in tangents passing by.\\
Each slope a whisper, each line a clue,\\
Trade x for p — the world feels new.\\
In mirrors of math, two forms agree,\\
Lagrange and Hamilton — duality’s key.\\
Where physics and geometry softly rhyme,\\
Lives the Legendre’s timeless design..**\\

                                      ---K.A.Rousan
}

## Introduction
Suppose we have some function $y=f(x)$. We can draw it as some curve on x-y plane. So, all the information of the function is stored in that graph. But as It can be seen below if we just draw all the tangent lines of the graph, we can get the curve itself, i.e., **\col{blue}{All the information of the curve is stored in it's tangent lines}**. To be more precise **\col{red}{y intercepts of it's tangent lines }**(but not for all type of functions).
~~~
<!-- Load JSXGraph + MathJax -->
<script type="text/javascript" charset="UTF-8"
 src="https://cdn.jsdelivr.net/npm/jsxgraph/distrib/jsxgraphcore.js"></script>
<link rel="stylesheet"
 type="text/css" href="https://cdn.jsdelivr.net/npm/jsxgraph/distrib/jsxgraph.css" />
<script id="MathJax-script" async
 src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>

<!-- Container -->
<div style="text-align:center; margin-bottom:10px;">
  <label for="funcSelect"><b>Select a function:</b></label>
  <select id="funcSelect" style="font-size:1rem; padding:4px;">
    <option value="x*x">f(x) = x²</option>
    <option value="x*x*x*x">f(x) = x⁴</option>
    <option value="Math.exp(-x)">f(x) = exp(-x)</option>
    <option value="Math.exp(x)">f(x) = exp(x)</option>
  </select>
</div>

<div id="board" class="jxgbox" style="width:500px; height:500px; margin:auto; border:2px solid #aaa;"></div>

<script>
  JXG.Options.text.useMathJax = true;

  // Initialize JSXGraph board
  var board = JXG.JSXGraph.initBoard("board", {
    boundingbox: [-5, 10, 5, -5],
    axis: true,
    showCopyright: false,
    showNavigation: false
  });

  let mainCurve = null;
  let tangents = [];

  // Function to draw selected function and its tangents
  function drawFunction(funcStr) {
    // Clear previous drawings
    if (mainCurve) board.removeObject(mainCurve);
    tangents.forEach(t => board.removeObject(t));
    tangents = [];

    // Create the function f(x)
    const f = (x) => eval(funcStr);

    // Plot the main curve
    mainCurve = board.create('functiongraph', [f, -4, 4], {
      strokeWidth: 2,
      strokeColor: '#0047AB'
    });

    // Plot tangent lines at many x-values
    const N = 40;
    const dx = 0.001;
    for (let i = 0; i <= N; i++) {
      const x0 = -4 + (8 * i) / N;
      const y0 = f(x0);
      const slope = (f(x0 + dx) - f(x0 - dx)) / (2 * dx); // numerical derivative
      const tangent = (x) => slope * (x - x0) + y0;
      const t = board.create('functiongraph', [tangent, -5, 5], {
        strokeColor: '#bd0a0aff',
        strokeWidth: 1,
        opacity: 0.5
      });
      tangents.push(t);
    }
  }

  // Draw initial function
  drawFunction("x*x");

  // Update when the dropdown changes
  document.getElementById("funcSelect").addEventListener("change", function() {
    drawFunction(this.value);
  });
</script>
~~~
### Transforming one function into another without information loss
To go further, let's start with the function:
$$
f(x) = x^2
$$
What kind of information is present here? The answer is for any value $x$ on the real number we have a value $f(x)=x^2$. Our goal is to transform $f$ from depending on $x$ to a new function $g$ such that it depends on $p$. But the catch is: **\col{purple}{we don't want to loose any information in the process}**. 

This is done through derivative. If we take the derivative of $f(x)$, we get,
$$
p(x) = \frac{df}{dx} = 2x
$$

~~~
<!-- Load JSXGraph -->
<script type="text/javascript" src="https://cdn.jsdelivr.net/npm/jsxgraph/distrib/jsxgraphcore.js"></script>
<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/jsxgraph/distrib/jsxgraph.css" />

<div id="tangentBoard" class="jxgbox" style="width:550px; height:500px; margin:auto; border:2px solid #aaa;"></div>

<script>
  JXG.Options.text.useMathJax = true;

  var boardd = JXG.JSXGraph.initBoard('tangentBoard', {
    boundingbox: [-5, 10, 5, -5],
    axis: true,
    showCopyright: false,
    showNavigation: false
  });

  // --- Function f(x) = x^2 ---
  const f = x => x * x;
  const df = x => 2 * x;

  // --- Plot f(x) ---
  const curve = boardd.create('functiongraph', [f, -4, 4],
    { strokeColor: '#0047AB', strokeWidth: 2 });

  // --- Slider for x0 ---
  const slider = boardd.create('slider', [[-4.5, 9], [4.5, 9], [-4, 0, 4]],
    { name: 'x₀', snapWidth: 0.1 });

  // --- Movable point P(x0, f(x0)) ---
  const P = boardd.create('point', [
    () => slider.Value(),
    () => f(slider.Value())
  ], {
    name: 'P',
    size: 3,
    color: '#D13F32',
    fixed: true
  });

  // --- Tangent line at P ---
  const tangent = boardd.create('line', [
    () => [slider.Value(), f(slider.Value())],
    () => [slider.Value() + 1, f(slider.Value()) + df(slider.Value())]
  ], {
    strokeColor: '#1CA9C9',
    strokeWidth: 2
  });

  // --- Y-intercept (0, b) ---
  const intercept = boardd.create('point', [
    0,
    () => f(slider.Value()) - df(slider.Value()) * slider.Value()
  ], {
    name: () => {
      let x0 = slider.Value();
      let b = f(x0) - df(x0) * x0;
      return `(0, ${b.toFixed(2)})`;
    },
    color: '#E65C00',
    size: 2,
    label: { offset: [10, -10] }
  });

  // --- Trail of previous tangents ---
  let tangentTrail = [];
  const maxTrail = 20;

  slider.on('drag', function() {
    const x0 = slider.Value();
    const y0 = f(x0);
    const slope = df(x0);
    const b = y0 - slope * x0;

    // Create faint tangent for the trail
    const t = boardd.create('functiongraph', [
      x => slope * x + b, -5, 5
    ], {
      strokeColor: '#1CA9C9',
      strokeWidth: 1,
      opacity: 0.25,
      fixed: true
    });

    tangentTrail.push(t);
    if (tangentTrail.length > maxTrail) {
      boardd.removeObject(tangentTrail.shift());
    }

    boardd.update();
  });
</script>
~~~

So, $p$ gives the slope of the tangent line at every $x$. In this specific example, for every value of $x$ we get a specific value of $p$, i.e., **\col{blue}{there is a 1 to 1 corresondance between $x$ and $p$}**. This allows us to to consider another function $x(p)$, i.e.,
$$
x(p) = \frac{p}{2}
$$
Hence, we have two ways of understanding:
1. Either $p$ as a function of $x$.
2. Or $x$ as a function of $p$.
We can then plug $x$ as a function of $p$ directly into $f$, making it now function of $p$. This gives us:
$$
f(x(p)) = \frac{p^2}{4} = g(p)
$$
It seems we have suceed in transforming $f$ from a function that depends on $x$ to a new function that depends on $p$ without lossing any information. But sadly it's not that simple.
### Finding the lost information
To understand this now consider,
$$
f(x) = (x-d)^2
$$
In this case $dy/dx = 2(x-d) = p$. If we plug it back, we get,
$$
f(p) = \frac{p^2}{4}
$$
again! So, **\col{red}{whatever value we choose for $d$ }**, we will get the same end function. **\col{blue}{The information about $d$ is lost in the procedure we are currently following}**. The reason it happens is very simple. This happens because we have only been considering the tangent lines of each function which turns out to be the same everywhere just shifted.
~~~
<div style="text-align:center; margin-bottom:6px;">
  <label><b>Branch:</b></label>
  <select id="branchSelect" style="font-size:1rem; padding:4px;">
    <option value="1">Right branch (+√y)</option>
    <option value="-1">Left branch (−√y)</option>
  </select>
</div>

<div id="fullParabolaBoard" class="jxgbox"
     style="width:650px;height:500px;margin:auto;border:2px solid #aaa;"></div>

<script>
(function() {
  const brd = JXG.JSXGraph.initBoard('fullParabolaBoard', {
    boundingbox: [-6, 20, 10, -6],
    axis: true,
    showNavigation: false,
    showCopyright: false
  });

  // Functions
  const f1 = x => x*x;
  const f2 = x => (x-4)*(x-4);
  const df1 = x => 2*x;
  const df2 = x => 2*(x-4);

  // Draw both parabolas
  brd.create('functiongraph', [f1, -5, 9],
    { strokeColor: '#0047AB', strokeWidth: 2 });
  brd.create('functiongraph', [f2, -1, 9],
    { strokeColor: '#178F3E', strokeWidth: 2 });

  // Slider for HEIGHT
  const s = brd.create('slider', [[-5,18],[8,18],[0,4,16]],
    { name:'y₀', snapWidth:0.1 });

  // Get branch sign from dropdown
  let branch = 1; // +√y default
  document.getElementById("branchSelect").addEventListener("change", e => {
    branch = parseInt(e.target.value);
    brd.update();
  });

  // Points at same height (left or right branch)
  const P1 = brd.create('point', [
    ()=>branch * Math.sqrt(s.Value()),
    ()=>s.Value()
  ], { name:'P₁', color:'#D13F32', size:3, fixed:true });

  const P2 = brd.create('point', [
    ()=>4 + branch * Math.sqrt(s.Value()),
    ()=>s.Value()
  ], { name:'P₂', color:'#E6B800', size:3, fixed:true });

  // Tangents at those points
  const T1 = brd.create('line', [
    ()=>[branch * Math.sqrt(s.Value()), s.Value()],
    ()=>[branch * Math.sqrt(s.Value()) + 1,
         s.Value() + df1(branch * Math.sqrt(s.Value()))]
  ], { strokeColor:'#1CA9C9', strokeWidth:2 });

  const T2 = brd.create('line', [
    ()=>[4 + branch * Math.sqrt(s.Value()), s.Value()],
    ()=>[4 + branch * Math.sqrt(s.Value()) + 1,
         s.Value() + df2(4 + branch * Math.sqrt(s.Value()))]
  ], { strokeColor:'#7FD16C', strokeWidth:2 });

  // Trails
  let trail1=[], trail2=[];
  const maxTrail=25;

  s.on('drag', ()=>{
    const y0 = s.Value();
    const xA = branch * Math.sqrt(y0);
    const xB = 4 + branch * Math.sqrt(y0);

    const m1 = df1(xA);
    const m2 = df2(xB);
    const b1 = y0 - m1 * xA;
    const b2 = y0 - m2 * xB;

    const t1 = brd.create('functiongraph',[x=>m1*x+b1,-6,10],
      {strokeColor:'#1CA9C9',strokeWidth:1,opacity:0.25,fixed:true});
    trail1.push(t1);
    if(trail1.length>maxTrail) brd.removeObject(trail1.shift());

    const t2 = brd.create('functiongraph',[x=>m2*x+b2,-6,10],
      {strokeColor:'#7FD16C',strokeWidth:1,opacity:0.25,fixed:true});
    trail2.push(t2);
    if(trail2.length>maxTrail) brd.removeObject(trail2.shift());

    brd.update();
  });

  // Labels
  brd.create('text', [-5.5, 16, 'Blue: f₁(x)=x²'], {fontSize:15, color:'#0047AB'});
  brd.create('text', [-5.5, 15, 'Green: f₂(x)=(x−4)²'], {fontSize:15, color:'#178F3E'});
  brd.create('text', [-5.5, 14, 'Tangents remain parallel at equal heights'], {fontSize:14, color:'#333'});
})();
</script>
~~~
Fortunately, there is a closely related quantity that is able to capture the **\col{red}{uniqueness}** of each of these functions and that is the $y$ intercepts of the tangent line which we can see actually do differ depending on the original function. So, taking that into account, we can solve this problem.

Let's say $(x,y)=(x,f)$ is a point on the parabola ($y=f(x)=x^2$). Then, as mentioned slope is $df/dx = p$ and the **\col{red}{$y$ intercept is g}**. This $g$ can be given by,
$$
p = \frac{f + g}{x - 0} \implies g = px - f
$$
This truely captures all the information of the function.
\note{
    Here as the intercept is always negative, I have already taken the intercept to be $(0,-g)$. So, above $g$ is the distance from origin to intercept.
}
## Legendre Transformation
### Introduction
Finally, in general if we have a function $f(x)$, then **\col{purple}{Legendre Transformation}** of it is,
$$
g(p) = p\cdot x(p) - f(x(p))
$$
i.e., a transformation which converts one function into another such that the information remains same and whose parameter is slope of the previous one.

For our two functions $f_1(x) = x^2$ and $f_2(x) = (x-d)^2$. We get,
$$
g_1(p) = \frac{p}{4} \text{ \ \ and\ \  } g_2(p) = \frac{p^2}{4} + pd
$$

We have now included information of $y$ intercept too, so each of the original functions of $x$ maps to a unique function of $p$. Also, beacuse no information has been lost in this, we can also find the Legendre transform of $g$ and get back original functions $f$'s. 
\prob{
    Try showing that if we start from $g_1$ and $g_2$, we can recover the original functions $g_1$ and $g_2$.
}
We now truly have two ways of expressing the same information. One that depends on $x$ and other on $p$, providing **\col{purple}{a beautiful duality between points and lines}**. This mapping is 1-to-1, i.e., unique.

### What functions respect legendre transformation?
Now the question is **\col{green}{does it works for all functions}**?, sadly the answer is no!

To motivate the answer let's start with the function $f(x) = x^3$. We do the exact same things, we have done before,
$$
f(x) = x^3 \implies f'(x) = 3x^2 = p(x) \implies x = \pm \Big(\frac{p}{3}\Big)^{1/2}
$$
Immediately we run into a problem. This is not a function (not bijective). Any value we put for $p$ will gives us two different values of $x$. This means, there are many airs of points that have same slope. We can see it in the interactive plot below. With the exception of the origin(not Gojo Saturo), we are always able to find two points that have exact same value. In terms of $f(x)$, these values correspond to producing the exact same slope for tangent lines.
~~~
<div id="equalSlopeBoard" class="jxgbox"
     style="width:650px;height:500px;margin:auto;border:2px solid #aaa;"></div>

<script>
(function() {
  const brd = JXG.JSXGraph.initBoard('equalSlopeBoard', {
    boundingbox: [-4, 12, 4, -8],
    axis: true,
    showNavigation: false,
    showCopyright: false
  });

  // Define f(x)=x^3 and derivative p(x)=3x^2
  const f = x => x*x*x;
  const df = x => 3*x*x;

  // Plot f(x)
  brd.create('functiongraph', [f, -3, 3],
    {strokeColor:'#0047AB', strokeWidth:2});

  // Plot derivative curve p(x)=3x^2
  brd.create('functiongraph', [df, -3, 3],
    {strokeColor:'#E75480', strokeWidth:2, dash:1});

  // Slider for slope p = 3x^2
  const s = brd.create('slider', [[-3.5,10],[3,10],[0,3,9]],
    {name:'p (slope)', snapWidth:0.1});

  // Compute x-values corresponding to slope p = 3x^2
  function xFromSlope(p) {
    return Math.sqrt(p/3);
  }

  // Points where slope is same (x and -x)
  const P1 = brd.create('point', [
    ()=>xFromSlope(s.Value()),
    ()=>f(xFromSlope(s.Value()))
  ], {name:'x₁',color:'#D13F32',size:3,fixed:true});

  const P2 = brd.create('point', [
    ()=>-xFromSlope(s.Value()),
    ()=>f(-xFromSlope(s.Value()))
  ], {name:'x₂',color:'#D13F32',size:3,fixed:true});

  // Tangents at both points
  const T1 = brd.create('line', [
    ()=>[xFromSlope(s.Value()), f(xFromSlope(s.Value()))],
    ()=>[xFromSlope(s.Value())+1,
         f(xFromSlope(s.Value())) + s.Value()]
  ], {strokeColor:'#1CA9C9', strokeWidth:2, dash:0});

  const T2 = brd.create('line', [
    ()=>[-xFromSlope(s.Value()), f(-xFromSlope(s.Value()))],
    ()=>[-xFromSlope(s.Value())+1,
         f(-xFromSlope(s.Value())) + s.Value()]
  ], {strokeColor:'#1CA9C9', strokeWidth:2, dash:0});

  // Visual guide lines linking to derivative
  const guide1 = brd.create('segment', [
    ()=>[xFromSlope(s.Value()), 0],
    ()=>[xFromSlope(s.Value()), s.Value()]
  ], {strokeColor:'#33B8A0', strokeWidth:1, dash:2});

  const guide2 = brd.create('segment', [
    ()=>[-xFromSlope(s.Value()), 0],
    ()=>[-xFromSlope(s.Value()), s.Value()]
  ], {strokeColor:'#33B8A0', strokeWidth:1, dash:2});

  // Trail memory (faint tangent history)
  let trails = [];
  const maxTrail = 15;

  s.on('drag', ()=>{
    const p = s.Value();
    const xA = xFromSlope(p);
    const xB = -xA;
    const yA = f(xA), yB = f(xB);

    const t1 = brd.create('functiongraph',[x=>p*(x-xA)+yA,-4,4],
      {strokeColor:'#1CA9C9',strokeWidth:1,opacity:0.25,fixed:true});
    const t2 = brd.create('functiongraph',[x=>p*(x-xB)+yB,-4,4],
      {strokeColor:'#1CA9C9',strokeWidth:1,opacity:0.25,fixed:true});

    trails.push(t1,t2);
    if(trails.length>maxTrail*2) {
      brd.removeObject(trails.shift());
      brd.removeObject(trails.shift());
    }
    brd.update();
  });

  // Labels
  brd.create('text', [-3.8,9.2,'f(x)=x³ (blue),  p(x)=3x² (pink)'], {fontSize:14});
  brd.create('text', [-3.8,8.3,'Two tangents share the same slope p'], {fontSize:14});
})();
</script>
~~~
This gives us the key thing we need in order to be able to find the **legendre transform** of a given function. **\col{red}{We need all the slopes of tangent lines to be unique}** and this will happen if the **\col{red}{function's derivative is always increasing or decreasing, i.e., monotonically increasing or decreasing}**. From $f$'s point of view, for **f** to have legendre transformation, **\col{red}{f(x) must be convex}**, means if we connect any two points on the curve, the line is always on the same side of the curve. To check if any function is **\col{red}{convex}**, we can just find it's second derivative and then if,
$$
f''(x)\geq 0 \text{ \ \ \ \ \ for all } x \text{ \ in the domain}
$$
then $f(x)$ is convex. With all of these, we now know what is **Legendre Transform** and on which functions we can apply it on.

But does it only works on single variable functions?, Well no!, we can apply the idea on multivariable functions too! and also there can be some variables which don't participate in the transformation. Let's see this:

### Legendre Transform of multi-variable functions
Suppose we have a function $f(x_1,x_2,\cdots, x_n, u_1,u_2,\cdots,u_m)$ then let's say we want to create a function for studying the same system but with $p_1,p_2,p_3,\cdots , p_n$ where $p_i = \partial f/\partial x_i$ and keep $u_i$'s as they are. Then, the Legendre Transform is,
$$
g(p_1,p_2,\cdots,p_m,u_1,u_2,\cdots,u_m) = \sum_{i=1}^{n} p_i x_i - f(x_1(p_1),x_2(p_2),\cdots, x_n(p_n),u_1,u_2,\cdots,u_m)
$$
We can easily show that $g$ will only be function of $p$'s and $u$'s only.
\note{
    Visit this [page](https://notes.myscript.com/page/86a4f8eb-d648-4f77-8cce-0641d6ec619e) for the proof. \\Here for multivariable case, we check the Hessian Matrix (positive semi-definite then convex) for convex check.
}

## Application of Legendre Transform
There are many applications of this transformation. But the most iconic ones are in **Classical Mechanics** and **Thermodynamics**. As thermodyanics one is much more popular, we will see that one here.

As we know internal energy($U$) of s system is a function of state which means that a system undergoes the same change in $U$ when we move it from one equilibrium state to another, irrespetive of which route we take through parameter space. This makes $U$ a very useful quantity. But we know $U = U(V,S)$, i.e., it's function of **entropy** and **volume**(keeping particle number constant).

But to be honest $S$ is very hard to control. Rather controlling $T$ and $p$ is much more easy. But then what we do?

To truly undertsand it let's start with $U$. From 1st law of thermodynamics,
$$
dU = \Bigg(\frac{\partial U}{\partial S}\Bigg)_V dS+ \Bigg(\frac{\partial U}{\partial V}\Bigg)_S dV = T\ dS - p\ dV
$$
This gives us,
$$
T = \Bigg(\frac{\partial U}{\partial S}\Bigg)_V \text{\ \ \ and \ \ \ } p = -\Bigg(\frac{\partial U}{\partial S}\Bigg)_S
$$
So, for constant volume process of our system, $dU = T\ dS$ and much more.\\

But now we want to study a system where the temperature is constant. How are we going to study such systems?.. How are we going to study the energy change?

The answer just find a function which is also energy but one of it's parameters are $T$. As we know $S$ and $T$ are related and as we just showed they are related by derivative(like $p$ and $x$ in previous examples). This should shout the name of our legendary **Legendre Transformation**.

So, we will define,
$$
F = U - TS
$$
(We can also use $TS-U$ but then the physical interpretations will not be straight-forward, so we use this convention of using $U-TS$). This then tells us,
$$
dF = T\ dS - p\ dV - T\ dS - S\ dT = -S\ dT - p\ dV
$$
This implies that the natural variables for $F$ are $V$ and $T$, i.e., $F=F(V,T)$. Then for a Isothermal process, we have,
$$
dF = -p\ dV \implies \Delta F = -\int_{V_1}^{V_2}p\ dV
$$
Hence, a positive change in $F$ represents reversible work done on the system by the surroundings, while a negative change in $F$ means reversible work done on the surrounding by the system.

We can also see as $dF = dU - T\ dS$ (for constant $T$) and $dW\geq dU - T\ dS$ (equality holds for reversible process). So, we have,
$$
dW\geq dF
$$
What it means is, adding work to the system increases the system's F(called Helmholtz energy). In a reversible process, $dW = dF$ and the work added to the system goes directly into increasing the Helmholtz energy. If we extract a certain amount of work from system($dW<0$), then this will be associated with at least as big a drop in the system's $F$.

This shows how powerful Legendre Transformation is. Using it we just found something $F$ which is also energy(check the dimension) and not just any energy, It represent a very powerful energy, i.e., free energy. This tells us **\col{purple}{how much energy we can extract from the system, i.e., how much energy is avaliable for us to extract from the system}**.

In this way, we can find many more useful things. Maybe in another blog I will discuss them.
\prob{
    Suppose, we want to study our system under isobaric process ($P=$ constant). Try creating a new type of energy for that from $U(S,V)$.

    Also, try finding what will be it's physical interpretation.
}

If you guys are interested read:
1. A Student's Guide to Entropy by Lemons
2. An Introductory Course of Statistical Mechanics by P.B. Pal
3. [Making sense of the Legendre transform](https://arxiv.org/pdf/0806.1147). American Journal of Physics. 77 (7): 614, Zia, R. K. P.; Redish, E. F.; McKay, S. R. (2009)
I have mainly followed 3rd one along with 2nd one.

_________________________________________________

I hope you learn something new and enjoyed this article.

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
    this.page.url = https://rousan.netlify.app/pages/physics/blogs/legendre_trans/;  // Replace PAGE_URL with your page's canonical URL variable
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