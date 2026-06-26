+++
title = "Grassmann Algebra: Multiplying with Area and Orientation"
hascode = true
hasplotly = true
date = Date(2026, 6, 26)
rss = "A friendly, visual introduction to Grassmann (exterior) algebra: the wedge product, bivectors, orientation, multivector grades, and the tensor-algebra quotient definition — with runnable SageMath and SymPy code. The first part of a mini-series leading to Clifford algebras and spinors."

tags = ["mathematics", "algebra", "geometric_algebra", "grassmann", "exterior_algebra", "spinors", "code"]
+++

\newcommand{\col}[2]{~~~<span style="color:~~~#1~~~">~~~!#2~~~</span>~~~}

\toc

# Grassmann Algebra: Multiplying with Area and Orientation

> *This is **Part 1** of a little mini-series. Here we build **Grassmann algebra** (a.k.a. **exterior algebra**) — the gentle stepping stone. In [Part 2](/Pages/Maths/blogs/clifford_algebra/) we upgrade it to **Clifford (geometric) algebra**, the machinery behind spinors in any dimension.*

Hi again!\\
You already know how to *add* vectors. You know two ways to *multiply* them — the dot product (which eats two vectors and spits out a number) and the cross product (which... only works in 3D, and secretly lies to you about being a vector). 

What if there were a *single, honest* multiplication of vectors that worked in **every** dimension, remembered **orientation**, and built up **areas**, **volumes**, and beyond? That is the **wedge product**, and the algebra it generates is **Grassmann algebra**.

\col{Crimson}{Grassmann algebra is what you get when you teach vectors to multiply into oriented areas.}

Let's build it from one idea.

## The one idea: oriented area

Take two vectors $\mathbf{u}$ and $\mathbf{v}$. Their **wedge product**

$$ \mathbf{u} \wedge \mathbf{v} $$

is not a number and not a vector. It is a **bivector**: the *oriented plane segment* (think: parallelogram) spanned by $\mathbf{u}$ and $\mathbf{v}$, with an **orientation** that circulates from $\mathbf{u}$ to $\mathbf{v}$.

If you swap the order, you sweep the *other way* around the parallelogram — same area, opposite orientation:

$$ \mathbf{v}\wedge\mathbf{u} = -\,\mathbf{u}\wedge\mathbf{v}. $$

~~~
<div style="text-align:center; margin: 1.2rem auto;">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Maths/blogs/grassmann_algebra/bivector_3d.svg" alt="Bivector u wedge v in 3D, with coordinate axes, shown for both orderings" style="max-width:min(100%,460px); height:auto;">
  <p style="font-size:0.9em;font-style:italic;color:#666;">The same parallelogram in 3D space (note the x, y, z axes) — only the <b>circulation</b> reverses when you swap the order. That's why <b>u ∧ v = −(v ∧ u)</b>.</p>
</div>
~~~

This **anticommutativity** has an immediate, almost cheeky consequence. A vector wedged with **itself** spans a parallelogram of zero area:

$$ \mathbf{u}\wedge\mathbf{u} = 0. $$

And these two facts — *antisymmetry* and *self-wedge = 0* — are actually the **same fact** in disguise. Watch:

- **Antisymmetry $\Rightarrow$ self-wedge $=0$:** set $\mathbf v = \mathbf u$ in $\mathbf u\wedge\mathbf v=-\mathbf v\wedge\mathbf u$. Then $\mathbf u\wedge\mathbf u = -\mathbf u\wedge\mathbf u$, so it must be $0$.
- **Self-wedge $=0\Rightarrow$ antisymmetry:** expand $(\mathbf u+\mathbf v)\wedge(\mathbf u+\mathbf v)=0$. The two "square" terms vanish, leaving $\mathbf u\wedge\mathbf v+\mathbf v\wedge\mathbf u=0$.

That little equivalence is the whole personality of Grassmann algebra.

## The rules of the game

The wedge product obeys exactly what you'd hope a "multiplication" should, plus the twist above:

| Property | Statement |
| :-- | :-- |
| Antisymmetry | $\mathbf u\wedge\mathbf v = -\,\mathbf v\wedge\mathbf u$ |
| Self-annihilation | $\mathbf u\wedge\mathbf u = 0$ |
| Distributivity | $\mathbf u\wedge(\mathbf v+\mathbf w)=\mathbf u\wedge\mathbf v+\mathbf u\wedge\mathbf w$ |
| Scalar pull-through | $(\lambda\mathbf u)\wedge\mathbf v=\lambda(\mathbf u\wedge\mathbf v)=\mathbf u\wedge(\lambda\mathbf v)$ |
| Associativity | $(\mathbf u\wedge\mathbf v)\wedge\mathbf w=\mathbf u\wedge(\mathbf v\wedge\mathbf w)$ |

Two bivectors are **equal** whenever they have the same area *and* the same orientation — it does **not** matter whether you draw them as a square, a rectangle, a parallelogram, or a blob. Only oriented area counts. (This is worth pausing on: a "$3$-by-$2$" bivector and a "$1$-by-$6$" one are the *same algebraic object* if their orientations match — area is the only invariant.)

The **distributive** law has a lovely picture: gluing $\mathbf u_1$ and $\mathbf u_2$ head-to-tail and wedging with $\mathbf v$ gives the same oriented region as wedging each piece separately and adding the areas:

$$ (\mathbf u_1+\mathbf u_2)\wedge\mathbf v \;=\; \mathbf u_1\wedge\mathbf v \;+\; \mathbf u_2\wedge\mathbf v. $$

~~~
<div style="text-align:center; margin: 1.2rem auto; overflow-x:auto;">
<svg width="540" height="180" viewBox="0 0 540 180" xmlns="http://www.w3.org/2000/svg" aria-label="Distributivity of the wedge product">
  <defs>
    <marker id="d1" markerWidth="9" markerHeight="9" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#2f6d78"/></marker>
    <marker id="d2" markerWidth="9" markerHeight="9" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#9c7a3c"/></marker>
  </defs>
  <!-- u1 ^ v -->
  <polygon points="30,150 120,150 150,80 60,80" fill="#2f6d78" opacity="0.15"/>
  <path d="M30,150 L120,150" stroke="#2f6d78" stroke-width="2.5" marker-end="url(#d1)"/>
  <path d="M30,150 L60,80"   stroke="#444" stroke-width="2" marker-end="url(#d1)"/>
  <text x="70" y="168" fill="#2f6d78" font-style="italic">u₁</text>
  <text x="35" y="105" fill="#444" font-style="italic">v</text>
  <text x="62" y="120" fill="#2f6d78" font-size="12">u₁∧v</text>
  <text x="165" y="120" font-size="20">+</text>
  <!-- u2 ^ v -->
  <polygon points="200,150 270,150 300,80 230,80" fill="#9c7a3c" opacity="0.18"/>
  <path d="M200,150 L270,150" stroke="#9c7a3c" stroke-width="2.5" marker-end="url(#d2)"/>
  <path d="M200,150 L230,80"  stroke="#444" stroke-width="2" marker-end="url(#d1)"/>
  <text x="228" y="168" fill="#9c7a3c" font-style="italic">u₂</text>
  <text x="232" y="120" fill="#9c7a3c" font-size="12">u₂∧v</text>
  <text x="320" y="120" font-size="20">=</text>
  <!-- (u1+u2) ^ v -->
  <polygon points="360,150 510,150 540,80 390,80" fill="#2f6d78" opacity="0.10"/>
  <polygon points="360,150 510,150 540,80 390,80" fill="#9c7a3c" opacity="0.08"/>
  <path d="M360,150 L510,150" stroke="#333" stroke-width="2.5" marker-end="url(#d1)"/>
  <path d="M360,150 L390,80"  stroke="#444" stroke-width="2" marker-end="url(#d1)"/>
  <text x="420" y="168" fill="#333" font-style="italic">u₁+u₂</text>
  <text x="430" y="120" font-size="12">(u₁+u₂)∧v</text>
</svg>
<p style="font-size:0.9em;font-style:italic;color:#666;">Distributivity = areas add. The two parallelograms tile the big one. (A clean three-step build for a slide animation.)</p>
</div>
~~~

### Let's actually compute one

`SageMath` ships a native `ExteriorAlgebra`, so we can let the computer enforce the rules and just *watch*. Here $e_1,e_2,e_3$ are an orthonormal basis and `*` is the wedge product:

```python
# SageMath
E.<e1,e2,e3> = ExteriorAlgebra(QQ)

u = 2*e1 + 3*e2
v = 1*e1 - 1*e2 + 4*e3

print("u ∧ v      =", u*v)
print("v ∧ u      =", v*u)
print("e1 ∧ e1    =", e1*e1)
print("u∧v + v∧u  =", u*v + v*u)
```

which prints

```text
u ∧ v      = -5*e1*e2 + 8*e1*e3 + 12*e2*e3
v ∧ u      = 5*e1*e2 - 8*e1*e3 - 12*e2*e3
e1 ∧ e1    = 0
u∧v + v∧u  = 0
```

**Reading the code, line by line:**

- `E.<e1,e2,e3> = ExteriorAlgebra(QQ)` — `ExteriorAlgebra(QQ)` builds the exterior (Grassmann) algebra over $\mathbb Q$ (the rationals — exact arithmetic, no rounding). The `E.<e1,e2,e3>` part is Sage's *generator-injection* syntax: it names the algebra `E` **and** drops three basis vectors `e1, e2, e3` straight into your namespace, ready to use. Crucially, in this object the symbol `*` **is** the wedge product $\wedge$ — Sage already knows $e_i\wedge e_i=0$ and $e_i\wedge e_j=-e_j\wedge e_i$.
- `u = 2*e1 + 3*e2` and `v = 1*e1 - 1*e2 + 4*e3` — ordinary vectors, written as rational combinations of the basis. (They're grade-1 elements of `E`.)
- `u*v` — asks Sage for the **wedge product** $\mathbf u\wedge\mathbf v$.

**Working out `u*v` by hand** to see *why* the output is what it is. With $\mathbf u=2e_1+3e_2$ and $\mathbf v=e_1-e_2+4e_3$, distribute all $2\times 3=6$ products:

$$
\begin{aligned}
\mathbf u\wedge\mathbf v =\;& 2\!\cdot\!1\,(e_1\wedge e_1) + 2\!\cdot\!(-1)(e_1\wedge e_2) + 2\!\cdot\!4\,(e_1\wedge e_3)\\
&+\,3\!\cdot\!1\,(e_2\wedge e_1) + 3\!\cdot\!(-1)(e_2\wedge e_2) + 3\!\cdot\!4\,(e_2\wedge e_3).
\end{aligned}
$$

Now apply the rules: $e_1\wedge e_1=e_2\wedge e_2=0$, and rewrite $e_2\wedge e_1=-e_1\wedge e_2$:

$$
= -2(e_1\wedge e_2) + 8(e_1\wedge e_3) - 3(e_1\wedge e_2) + 12(e_2\wedge e_3)
= \boxed{-5\,e_1e_2 + 8\,e_1e_3 + 12\,e_2e_3},
$$

exactly Sage's first line (`-5*e1*e2 + 8*e1*e3 + 12*e2*e3`). The other three lines confirm the personality of the algebra: `v*u` is the *negative* (antisymmetry), `e1*e1` is `0` (self-annihilation), and `u*v + v*u` is `0` (the two together). Every rule from the table, confirmed by a machine that has no idea what a parallelogram is.

### The same computation in three systems

One nice thing about the wedge: *every* serious math system speaks it, so you can pick your favourite. Here is the **exact same** $\mathbf u\wedge\mathbf v$ in SageMath, Wolfram, and Julia — all returning the bivector $-5\,e_{12}+8\,e_{13}+12\,e_{23}$.

**SageMath** (what we ran above):

```python
E.<e1,e2,e3> = ExteriorAlgebra(QQ)
(2*e1 + 3*e2) * (1*e1 - 1*e2 + 4*e3)
```
```text
-5*e1*e2 + 8*e1*e3 + 12*e2*e3
```

**Wolfram Language.** Version 15+ ships a native `GrassmannAlgebra`, where `**` is the wedge and `NonCommutativeExpand` reduces it:

```mathematica
galg = GrassmannAlgebra[{x, y, z}];
NonCommutativeExpand[(2 x + 3 y) ** (x - y + 4 z), galg]
```
```text
-5 x ** y + 8 x ** z + 12 y ** z
```

If you're on an older Wolfram (no `GrassmannAlgebra`), the antisymmetry rule is one line — build the matrix $B_{ij}=u_iv_j-u_jv_i$; its independent entries $(B_{12},B_{13},B_{23})$ **are** the bivector components. This version-independent snippet is verified on Wolfram 14.2:

```mathematica
u = {2, 3, 0}; v = {1, -1, 4};
B = Table[u[[i]] v[[j]] - u[[j]] v[[i]], {i, 3}, {j, 3}];
{B[[1,2]], B[[1,3]], B[[2,3]]}   (* components of e12, e13, e23 *)
```
```text
{-5, 8, 12}
```

**Julia** with [`Grassmann.jl`](https://github.com/chakravala/Grassmann.jl) — handy since this very site runs on Julia. After `]add Grassmann`:

```julia
using Grassmann
@basis ℝ^3            # conjures v1,v2,v3 and the wedge operator ∧
u = 2v1 + 3v2
w = 1v1 - 1v2 + 4v3
u ∧ w
```
```text
-5v₁₂ + 8v₁₃ + 12v₂₃        # the same bivector
```

`@basis ℝ^3` is the analogue of Sage's generator-injection — it drops `v1,v2,v3` and `∧` into scope for 3D Euclidean space; `v₁₂` is how Grassmann.jl prints $e_1\wedge e_2$. Three languages, three notations, **one** geometric object.

## Components of a bivector

Let's open up $\mathbf u\wedge\mathbf v$ in coordinates. In 2D with basis $e_1,e_2$, write $\mathbf u=u_1e_1+u_2e_2$, $\mathbf v=v_1e_1+v_2e_2$ and distribute ("FOIL"):

$$
\mathbf u\wedge\mathbf v
= \underbrace{u_1v_1\,e_1\wedge e_1}_{0}
+ u_1v_2\,e_1\wedge e_2
+ u_2v_1\,\underbrace{e_2\wedge e_1}_{-e_1\wedge e_2}
+ \underbrace{u_2v_2\,e_2\wedge e_2}_{0}.
$$

Collecting:

$$ \mathbf u\wedge\mathbf v = (u_1v_2-u_2v_1)\,e_1\wedge e_2. $$

That coefficient $u_1v_2-u_2v_1$ is exactly the **signed area** of the parallelogram (and the $2\times 2$ determinant!). In the $xy$-plane there is only **one** basis bivector, $e_1\wedge e_2$, because there's only one pair of axes.

In **3D** there are three pairs of axes, so three basis bivectors $e_1\wedge e_2,\ e_1\wedge e_3,\ e_2\wedge e_3$. Let SymPy do the bookkeeping symbolically — no special library, just antisymmetry by hand:

```python
# SymPy — wedge of two 3D vectors, the honest way
import sympy as sp
ux,uy,uz,vx,vy,vz = sp.symbols("u_x u_y u_z v_x v_y v_z")
u = sp.Matrix([ux,uy,uz]);  v = sp.Matrix([vx,vy,vz])

# the three independent components (e1∧e2, e1∧e3, e2∧e3):
e12 = ux*vy - uy*vx
e13 = ux*vz - uz*vx
e23 = uy*vz - uz*vy
print("u ∧ v  ->  (e12, e13, e23) =", (e12, e13, e23))
print("cross product            =", list(u.cross(v)))
```

```text
u ∧ v  ->  (e12, e13, e23) = (u_x*v_y - u_y*v_x, u_x*v_z - u_z*v_x, u_y*v_z - u_z*v_y)
cross product             = [u_y*v_z - u_z*v_y, -u_x*v_z + u_z*v_x, u_x*v_y - u_y*v_x]
```

**Line by line:**

- `import sympy as sp` — SymPy is Python's symbolic-math engine; the variables below are *symbols*, not numbers, so everything stays as exact algebra.
- `sp.symbols("u_x u_y u_z v_x v_y v_z")` — creates six symbolic unknowns. The names with underscores (`u_x`) make SymPy print them as subscripts $u_x$.
- `sp.Matrix([...])` — packs the components into column vectors so we can call `.cross()` on them.
- The three lines `e12 = ux*vy - uy*vx`, etc. — we compute the bivector components **by hand** using exactly the FOIL-and-flip rule from above. Each is the $2\times 2$ determinant of the corresponding pair of columns: $\,e_{ij}=u_iv_j-u_jv_i$. No geometric-algebra library needed — that's the point: the rules are simple enough to do with bare arithmetic.
- `u.cross(v)` — SymPy's built-in cross product, for comparison.

**Why the outputs match.** The wedge gives $(e_{12},e_{13},e_{23})=(u_xv_y-u_yv_x,\;u_xv_z-u_zv_x,\;u_yv_z-u_zv_y)$, while `cross` gives $(u_yv_z-u_zv_y,\;-(u_xv_z-u_zv_x),\;u_xv_y-u_yv_x)$. Term-by-term these are the **same three numbers**, merely reordered and with one sign flipped — the cross product lists them in the order $(yz,\,zx,\,xy)$ with the middle one negated, which is precisely the **Hodge-dual** relabelling of the bivector's $(xy,\,xz,\,yz)$ components. Same information, different costume.

\col{Crimson}{Look familiar?} Those are the **same three numbers** as the cross product (just relabeled and re-signed). The cross product is a 3D-only *accident* — the shadow that the honest, dimension-agnostic **bivector** casts when you're lucky enough to live in three dimensions. This is also why the cross product behaves so strangely in a mirror: it's secretly a bivector wearing a vector costume.

~~~
<div style="text-align:center; margin: 1.2rem auto;">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Maths/blogs/grassmann_algebra/cross_dual_3d.svg" alt="The cross product u x v is the normal vector dual to the bivector plane u wedge v" style="max-width:min(100%,340px); height:auto;">
  <p style="font-size:0.9em;font-style:italic;color:#666;">In 3D, the bivector <b>u ∧ v</b> (the shaded plane) has exactly one perpendicular direction. The cross product <b>u × v</b> just points along it. The plane is the real object; the arrow is its <i>dual</i>.</p>
</div>
~~~

### 🕹️ Play with it: an interactive bivector

Enough watching — *drag the sliders* below to set the components of $\mathbf u$ and $\mathbf v$. The plot redraws the two vectors and the parallelogram they span, and the panel shows the live wedge $\mathbf u\wedge\mathbf v$ — its three components $(e_{12},e_{13},e_{23})$ and its area $\lVert\mathbf u\wedge\mathbf v\rVert$. Try making $\mathbf u$ and $\mathbf v$ **parallel** and watch the area collapse to $0$ (self-annihilation, live).

~~~
<div id="biv-widget" style="max-width:760px; margin:1.4rem auto; border:1px solid #d9cdb0; border-radius:10px; padding:0.9rem 1rem; background:rgba(0,0,0,0.015);">
  <!-- big visualization on top -->
  <div id="biv-plot" style="width:100%; height:480px;"></div>
  <!-- sliders + result in a compact row UNDER the plot -->
  <div style="display:flex; flex-wrap:wrap; gap:1.4rem; align-items:flex-start; margin-top:.6rem; border-top:1px solid #e2d8be; padding-top:.7rem;">
    <div style="flex:1 1 180px; min-width:170px;">
      <div style="font-weight:700; color:#2f6d78; margin-bottom:.2rem;">vector u</div>
      <label>u<sub>x</sub> <input type="range" id="ux" min="-4" max="4" step="0.5" value="2"><span id="ux_v">2</span></label><br>
      <label>u<sub>y</sub> <input type="range" id="uy" min="-4" max="4" step="0.5" value="1"><span id="uy_v">1</span></label><br>
      <label>u<sub>z</sub> <input type="range" id="uz" min="-4" max="4" step="0.5" value="0"><span id="uz_v">0</span></label>
    </div>
    <div style="flex:1 1 180px; min-width:170px;">
      <div style="font-weight:700; color:#9c7a3c; margin-bottom:.2rem;">vector v</div>
      <label>v<sub>x</sub> <input type="range" id="vx" min="-4" max="4" step="0.5" value="1"><span id="vx_v">1</span></label><br>
      <label>v<sub>y</sub> <input type="range" id="vy" min="-4" max="4" step="0.5" value="3"><span id="vy_v">3</span></label><br>
      <label>v<sub>z</sub> <input type="range" id="vz" min="-4" max="4" step="0.5" value="1"><span id="vz_v">1</span></label>
    </div>
    <div id="biv-result" style="flex:1 1 190px; min-width:180px; font-family:ui-monospace,Menlo,monospace; font-size:.92rem; line-height:1.55;"></div>
  </div>
</div>
<script>
(function(){
  var ids = ["ux","uy","uz","vx","vy","vz"];
  function val(id){ return parseFloat(document.getElementById(id).value); }
  function dark(){ return document.documentElement.classList.contains("dark-mode"); }
  function draw(){
    if (typeof Plotly === "undefined") { setTimeout(draw, 200); return; }
    var u = [val("ux"),val("uy"),val("uz")];
    var v = [val("vx"),val("vy"),val("vz")];
    ids.forEach(function(id){ document.getElementById(id+"_v").textContent = val(id); });
    // wedge components: e_ij = u_i v_j - u_j v_i
    var e12 = u[0]*v[1]-u[1]*v[0];
    var e13 = u[0]*v[2]-u[2]*v[0];
    var e23 = u[1]*v[2]-u[2]*v[1];
    var area = Math.sqrt(e12*e12 + e13*e13 + e23*e23);
    var f = function(x){ return (Math.round(x*100)/100); };
    document.getElementById("biv-result").innerHTML =
      "<b>u ∧ v =</b><br>" +
      "&nbsp;&nbsp;" + f(e12) + " e<sub>12</sub><br>" +
      "&nbsp;&nbsp;" + (e13>=0?"+ ":"− ") + f(Math.abs(e13)) + " e<sub>13</sub><br>" +
      "&nbsp;&nbsp;" + (e23>=0?"+ ":"− ") + f(Math.abs(e23)) + " e<sub>23</sub><br>" +
      "<b>area</b> ‖u ∧ v‖ = <span style='color:#e52e71'>" + f(area) + "</span>" +
      (area < 1e-9 ? "  ← parallel ⇒ 0!" : "");
    var col = dark() ? "#e3dccd" : "#333";
    var TEAL = "#2f6d78", GOLD = "#9c7a3c";
    // arrow shafts
    var uvec = {type:"scatter3d", mode:"lines", x:[0,u[0]], y:[0,u[1]], z:[0,u[2]],
      line:{color:TEAL, width:8}, hoverinfo:"name", name:"u"};
    var vvec = {type:"scatter3d", mode:"lines", x:[0,v[0]], y:[0,v[1]], z:[0,v[2]],
      line:{color:GOLD, width:8}, hoverinfo:"name", name:"v"};
    // arrowHEADS at the tips (cones), so each is a real pointing vector
    function head(p, c){ return {type:"cone", x:[p[0]], y:[p[1]], z:[p[2]],
      u:[p[0]], v:[p[1]], w:[p[2]], anchor:"tip", sizemode:"absolute", sizeref:0.5,
      showscale:false, colorscale:[[0,c],[1,c]], hoverinfo:"skip"}; }
    // labels at the tips
    var labels = {type:"scatter3d", mode:"text", x:[u[0],v[0]], y:[u[1],v[1]], z:[u[2],v[2]],
      text:["u","v"], textfont:{size:15, color:[TEAL,GOLD]}, hoverinfo:"skip"};
    var para = {type:"mesh3d",
      x:[0,u[0],u[0]+v[0],v[0]], y:[0,u[1],u[1]+v[1],v[1]], z:[0,u[2],u[2]+v[2],v[2]],
      i:[0,0], j:[1,2], k:[2,3], opacity:0.35, color:TEAL, name:"u∧v", hoverinfo:"skip"};
    // Fit a CUBE tightly around just the data (origin, u, v, u+v) and CENTER it
    // on the data — instead of a big origin-centred cube that wastes 3 empty
    // octants. This makes the parallelogram fill most of the view.
    var P = [[0,0,0], u, v, [u[0]+v[0],u[1]+v[1],u[2]+v[2]]];
    function axRange(k){
      var lo = Math.min.apply(null, P.map(function(p){return p[k];}));
      var hi = Math.max.apply(null, P.map(function(p){return p[k];}));
      return [lo, hi, (lo+hi)/2];
    }
    var rx=axRange(0), ry=axRange(1), rz=axRange(2);
    var side = Math.max(rx[1]-rx[0], ry[1]-ry[0], rz[1]-rz[0], 1) * 1.25; // pad 25%
    var half = side/2;
    var rngX=[rx[2]-half, rx[2]+half], rngY=[ry[2]-half, ry[2]+half], rngZ=[rz[2]-half, rz[2]+half];
    var layout = {margin:{l:0,r:0,t:0,b:0}, showlegend:false,
      paper_bgcolor:"rgba(0,0,0,0)", font:{color:col},
      scene:{ xaxis:{title:"x",range:rngX}, yaxis:{title:"y",range:rngY}, zaxis:{title:"z",range:rngZ},
              aspectmode:"cube",
              camera:{eye:{x:1.05, y:1.05, z:0.85}} }};   // closer = bigger
    Plotly.react("biv-plot", [para, uvec, vvec, head(u,TEAL), head(v,GOLD), labels],
      layout, {responsive:true, displayModeBar:false});
  }
  ids.forEach(function(id){ document.getElementById(id).addEventListener("input", draw); });
  if (document.readyState !== "loading") draw();
  else document.addEventListener("DOMContentLoaded", draw);
})();
</script>
~~~

Prefer Wolfram? The same picture is one `Graphics3D` call you can paste into a notebook (or TeXmacs) for a fully rotatable 3D view — the green polygon **is** the bivector $\mathbf v_1\wedge\mathbf v_2$:

```mathematica
v1 = {2, 1, 0}; v2 = {1, 3, 1};
Graphics3D[{
  Thick, Red,  Arrow[{{0,0,0}, v1}],        (* vector v1 *)
        Blue, Arrow[{{0,0,0}, v2}],         (* vector v2 *)
  Opacity[0.3], Green,
  Polygon[{{0,0,0}, v1, v1+v2, v2}]         (* the bivector area v1 ∧ v2 *)
}, Axes -> True, Boxed -> False, PlotLabel -> "Visualizing a Bivector Area"]
```

### A fully worked example: area *is* a determinant

Let's grind one all the way through. Take $\mathbf u = 3e_1 + e_2$ and $\mathbf v = e_1 + 2e_2$ in the plane. Distribute, kill the self-wedges, and flip $e_2\wedge e_1$:

$$
\begin{aligned}
\mathbf u\wedge\mathbf v
&= (3e_1+e_2)\wedge(e_1+2e_2)\\[2pt]
&= 3\underbrace{(e_1\wedge e_1)}_{0} + 6\,(e_1\wedge e_2) + 1\,(e_2\wedge e_1) + 2\underbrace{(e_2\wedge e_2)}_{0}\\[2pt]
&= 6\,(e_1\wedge e_2) - 1\,(e_1\wedge e_2) \;=\; \boxed{5\,(e_1\wedge e_2)}.
\end{aligned}
$$

That coefficient $5$ is the signed area of the parallelogram — and it is *exactly* the determinant

$$ \det\begin{pmatrix} 3 & 1\\ 1 & 2\end{pmatrix} = 3\cdot 2 - 1\cdot 1 = 5. $$

Sage agrees instantly:

```python
# SageMath
E.<e1,e2,e3> = ExteriorAlgebra(QQ)
u = 3*e1 + 1*e2
v = 1*e1 + 2*e2
print("u ∧ v       =", u*v)
print("signed area =", matrix(QQ,[[3,1],[1,2]]).det())
```
```text
u ∧ v       = 5*e1*e2
signed area = 5
```

This is the deep punchline of grade-2: **the wedge of two vectors measures signed area, and that number is a determinant.** Push to three vectors and $\mathbf a\wedge\mathbf b\wedge\mathbf c$ measures *signed volume* — the $3\times 3$ determinant. The exterior algebra is, in a real sense, *where determinants are born*.

```python
# triple wedge = oriented volume = a 3x3 determinant
a = e1 + e2;  b = e2 + e3;  c = e3 + e1
print("a ∧ b ∧ c =", a*b*c)
print("det       =", matrix(QQ,[[1,1,0],[0,1,1],[1,0,1]]).det())
```
```text
a ∧ b ∧ c = 2*e1*e2*e3
det       = 2
```

Here `a*b*c` is the triple wedge $\mathbf a\wedge\mathbf b\wedge\mathbf c$. Because we're in 3D, the *only* surviving grade-3 basis element is $e_1e_2e_3$, so the answer is a single number times it — the **signed volume** of the parallelepiped. `matrix(QQ, [...])` builds the matrix whose **rows are the components of `a`, `b`, `c`**, and `.det()` is its determinant. Both print `2`: the coefficient of $e_1e_2e_3$ in the wedge is, identically, the $3\times3$ determinant. \col{Crimson}{Wedge = determinant} is not an analogy — it's the same computation.

## Physical intuition: angular momentum is *really* a bivector

Here is where this stops being abstract and starts fixing things you were quietly taught wrong.

In intro physics, **angular momentum** $\mathbf L = \mathbf r\times\mathbf p$ is drawn as a vector, conjured with the **right-hand rule**: curl your fingers along the rotation, your thumb "is" $\mathbf L$. It works — but it's a ritual, and rituals should make you suspicious. *Why* should a rotation, which happens **in a plane**, be represented by an arrow **perpendicular** to that plane? In 2D there's no "perpendicular direction" to point along, and in 4D there are *too many*. The arrow is a 3D coincidence.

The honest object is the **bivector** $\mathbf L = \mathbf r\wedge\mathbf p$: the oriented plane in which the circulation actually happens.

```python
# Angular momentum as a bivector, L = r ∧ p
E.<e1,e2,e3> = ExteriorAlgebra(QQ)
r = 2*e1            # position along x
p = 3*e2            # momentum along y
print("L = r ∧ p =", r*p)
```
```text
L = r ∧ p = 6*e1*e2        # circulation in the x–y plane
```

Here `r` points along $x$ and `p` along $y$, so `r*p` $=2\cdot3\,(e_1\wedge e_2)=6\,e_1e_2$ — a **pure bivector lying in the $xy$-plane**, which is exactly the plane the particle orbits in. The coefficient $6$ is the magnitude $|\mathbf r||\mathbf p|\sin\theta = 2\cdot 3\cdot\sin 90^\circ$. No right hand required. The plane of rotation *is* the answer, and its orientation (which way it circulates) is built in.

~~~
<div style="text-align:center; margin: 1.2rem auto;">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Maths/blogs/grassmann_algebra/angmom_3d.svg" alt="Angular momentum as a bivector in the plane of rotation, versus the axial-vector arrow" style="max-width:min(100%,340px); height:auto;">
  <p style="font-size:0.9em;font-style:italic;color:#666;">The honest object is the shaded <b>plane of rotation</b> (the bivector r ∧ p). The familiar "angular-momentum arrow" (dashed, up the z-axis) is just the perpendicular stand-in — and it's the one that misbehaves in a mirror.</p>
</div>
~~~

### The mirror test that exposes the impostor

Now the experiment from the video. Put a spinning disk in front of a **mirror** and reflect it in the plane of the mirror.

~~~
<div style="text-align:center; margin: 1.3rem auto; overflow-x:auto;">
<svg width="560" height="220" viewBox="0 0 560 220" xmlns="http://www.w3.org/2000/svg" aria-label="Mirror reflection of a spinning disk">
  <defs>
    <marker id="bv" markerWidth="9" markerHeight="9" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#2f6d78"/></marker>
    <marker id="rv" markerWidth="9" markerHeight="9" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#e52e71"/></marker>
  </defs>
  <!-- mirror -->
  <line x1="280" y1="10" x2="280" y2="210" stroke="#888" stroke-width="2" stroke-dasharray="6 5"/>
  <text x="262" y="24" fill="#888" font-size="11">mirror</text>
  <!-- left: real disk, counterclockwise -->
  <circle cx="150" cy="110" r="55" fill="#2f6d78" opacity="0.10" stroke="#2f6d78"/>
  <path d="M150,55 a55,55 0 1 0 38,16" fill="none" stroke="#2f6d78" stroke-width="2.5" marker-end="url(#bv)"/>
  <text x="118" y="115" fill="#2f6d78" font-weight="700">spin ↺</text>
  <!-- right: reflected disk, clockwise -->
  <circle cx="410" cy="110" r="55" fill="#e52e71" opacity="0.10" stroke="#e52e71"/>
  <path d="M410,55 a55,55 0 1 1 -38,16" fill="none" stroke="#e52e71" stroke-width="2.5" marker-end="url(#rv)"/>
  <text x="382" y="115" fill="#e52e71" font-weight="700">spin ↻</text>
</svg>
<p style="font-size:0.9em;font-style:italic;color:#666;">The bivector reverses its circulation in the mirror — a sensible, geometric result. The "angular-momentum arrow," by contrast, would point the <b>same</b> way (it's an <i>axial</i> vector), which is the tell-tale sign it isn't an honest vector at all.</p>
</div>
~~~

- The **bivector** $\mathbf r\wedge\mathbf p$ does the natural thing: it reverses its orientation, because the boundary circulation visibly reverses. Clean, predictable, geometric.
- The **arrow** $\mathbf r\times\mathbf p$ misbehaves: under reflection it points the *same* way an ordinary vector wouldn't. Physicists patch this by calling it an **axial vector** (or *pseudovector*) and bolting on extra sign rules. 

Those extra rules are unnecessary the moment you admit the truth: \col{Crimson}{rotation lives in a plane, so its natural home is a bivector, not an arrow.} Magnetic field $\mathbf B$, torque $\boldsymbol\tau$, vorticity — *every* "axial vector" in physics is a bivector that's been flattened into an arrow by the 3D cross-product trick.

### Orientation from the boundary (a Stokes-shaped hint)

How do you even *assign* an orientation to a bivector, a trivector, a $k$-vector? The same way every time: **read it off the boundary.**

Build a bivector by laying vectors tip-to-tail around the rim of a patch; the patch inherits the rim's circulation. Build a trivector from bivector faces of a little cube, with the rule that **neighbouring faces must circulate oppositely across a shared edge** — then "reversing the volume" just means reversing every face.

~~~
<div style="text-align:center; margin: 1.2rem auto;">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Maths/blogs/grassmann_algebra/trivector_3d.svg" alt="Trivector a wedge b wedge c as an oriented parallelepiped with x,y,z axes" style="max-width:min(100%,340px); height:auto;">
  <p style="font-size:0.9em;font-style:italic;color:#666;">A trivector <b>a ∧ b ∧ c</b> is an oriented parallelepiped — a chunk of <i>signed volume</i>. Reverse the orientation of its boundary faces and you negate the whole volume.</p>
</div>
~~~

This "orientation = boundary" idea is not a cute aside — it is the seed of **Stokes' theorem**, $\int_{\partial\Omega}\omega = \int_\Omega d\omega$, the grand unification of the fundamental theorem of calculus, Green's, Gauss's and the curl theorem. Differential forms are just Grassmann algebra with calculus poured on top. (We'll save that feast for its own post.)

## Climbing the grades: vectors → bivectors → trivectors → …

Nothing stops us from wedging a *third* vector on:

$$ \mathbf u\wedge\mathbf v\wedge\mathbf w $$

is a **trivector** — an oriented *volume*. Keep going and you get $k$-vectors of every **grade** $k$. But there's a ceiling: in $n$ dimensions, once you wedge more than $n$ vectors, two of them must "collide" along some axis and the whole thing collapses to zero.

How many independent basis $k$-vectors live in $n$ dimensions? Just count how many ways you can choose $k$ distinct axes out of $n$: that's $\binom{n}{k}$. Stack the grades and you get a **Pascal's-triangle "diamond"** of dimensions, summing to

$$ \sum_{k=0}^{n}\binom{n}{k} = 2^{\,n}. $$

```python
# SageMath — dimension of each grade in n dimensions
for n in range(1, 6):
    grades = [binomial(n, k) for k in range(n+1)]
    print(f"n={n}:  grades {grades}   total 2^{n} = {sum(grades)}")
```

```text
n=1:  grades [1, 1]               total 2^1 = 2
n=2:  grades [1, 2, 1]            total 2^2 = 4
n=3:  grades [1, 3, 3, 1]         total 2^3 = 8
n=4:  grades [1, 4, 6, 4, 1]      total 2^4 = 16
n=5:  grades [1, 5, 10, 10, 5, 1] total 2^5 = 32
```

`binomial(n, k)` is "$n$ choose $k$" $=\binom{n}{k}$ — the number of ways to pick $k$ distinct axes out of $n$, which is exactly how many independent basis $k$-vectors exist. The list comprehension `[binomial(n,k) for k in range(n+1)]` sweeps the grade $k$ from $0$ (scalars) up to $n$ (the top volume). Each row is a **row of Pascal's triangle**, and `sum(grades)` $=\sum_k\binom{n}{k}=2^n$ by the binomial theorem — so an $n$-dimensional space has a $2^n$-dimensional exterior algebra. (Notice the rows are palindromes: grade $k$ and grade $n-k$ always have the same dimension — a hint of **Hodge duality**, the pairing that turns the cross product's bivector back into a vector in 3D.)

~~~
<div style="text-align:center; margin: 1.4rem auto;">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Maths/blogs/grassmann_algebra/grade_diamond.svg" alt="Grade lattice of the 3D exterior algebra: scalar, vectors, bivectors, trivector" style="max-width:min(100%,440px); height:auto;">
  <p style="font-size:0.9em;font-style:italic;color:#666;">The exterior algebra of 3D space, drawn as a lattice: each line means "is contained in." Dimensions <b>1, 3, 3, 1</b> — a Pascal row summing to <b>2³ = 8</b>. The scalar sits at the bottom, the single oriented volume at the top.</p>
</div>
~~~

Notice the **top grade** is always 1-dimensional: in $n$D there's essentially **one** $n$-vector (the oriented volume element), up to a scale — because you can always shuffle the axes back into standard order at the cost of some minus signs.

A general element mixing grades — like $2 + 3e_1 - 5\,e_2\wedge e_3$ — is called a **multivector**. Grassmann algebra is precisely the vector space of all multivectors, with the wedge product gluing the grades together.

### Orientation, all the way up

Every multivector has exactly **two** orientations ($\pm$). For a vector you flip the arrow. For a bivector you reverse the circulation around its boundary. For a trivector you reverse the orientations of all the bivector faces of its little cube — neighbors must disagree across shared edges. The rule "**read orientation off the boundary**" works in every grade. It's the same rule that powers Stokes' theorem, but that's a story for another day.

## The grown-up definition (tensor algebra ÷ a rule)

Here's the slick, "official" construction — skippable on a first read, but it's beautiful and it sets up the Clifford story perfectly.

Start with **everything**: the **tensor algebra** $T(V)$ of a vector space $V$. It contains scalars, vectors, all tensor products $\mathbf u\otimes\mathbf v$, all triples $\mathbf u\otimes\mathbf v\otimes\mathbf w$, and so on, to infinity — an enormous, free playground where nothing simplifies.

Now impose **one rule**: declare every $\mathbf v\otimes\mathbf v$ to be **zero**. Formally, take the quotient by the (two-sided) ideal generated by all $\mathbf v\otimes\mathbf v$:

$$ \boxed{\;\Lambda(V) \;=\; T(V)\,\big/\,\langle\, \mathbf v\otimes\mathbf v \,\rangle\;} $$

The instant you do this, $\mathbf v\otimes\mathbf v=0$ forces $\mathbf u\otimes\mathbf v=-\mathbf v\otimes\mathbf u$ (same proof as before), the infinite tower of tensors collapses, and what survives — for, say, $V=\mathbb R^2$ — is just the four guys $\{1,\,e_1,\,e_2,\,e_1\wedge e_2\}$. That quotient **is** the Grassmann algebra, and $\otimes$ becomes $\wedge$.

\col{Crimson}{Grassmann algebra = the free algebra on a vector space, modulo "anything squared is zero."}

Hold that sentence. In Part 2, we change the right-hand side of that rule from "**zero**" to "**the vector's squared length**" — and *that one tweak* turns areas into the **geometric product**, gives us complex numbers, quaternions, the Pauli and Dirac matrices, and ultimately **spinors**.

## Where this is heading: differential forms, and a cameo in QFT

Two big doors open from here, and both deserve their own posts — so this is just a teaser.

**Door 1 — Differential forms (geometry & gravity).** Pour calculus onto Grassmann algebra and you get **differential $p$-forms**: completely antisymmetric tensors, i.e. wedge products of $1$-forms. Everything we built reappears: the wedge of forms $A\wedge B=(-1)^{pq}B\wedge A$, the **exterior derivative** $\mathrm d$ with the magic identity $\mathrm d^2=0$, **Hodge duality** $\star$ relating $p$-forms to $(n-p)$-forms (remember those palindromic Pascal rows?), and **Stokes' theorem** $\int_{\partial\Omega}\omega=\int_\Omega \mathrm d\omega$. In electromagnetism this is gorgeous: the field strength is a $2$-form $F=\mathrm dA$, and *two* of Maxwell's four equations collapse into the single statement

$$ \mathrm dF = 0. $$

The other two become $\mathrm d{\star}F=J$. The whole of classical E&M, in two lines of Grassmann-with-calculus. (This is the language of general relativity and gauge theory — a future post.)

**Door 2 — Grassmann *numbers* and fermions (quantum field theory).** Here's the cameo that surprises people. In QFT, **fermions** (electrons, quarks, neutrinos) are described in the path integral not by ordinary numbers but by **anticommuting "numbers"** $\theta_i$ with

$$ \theta_i\theta_j = -\theta_j\theta_i, \qquad \theta_i^2 = 0. $$

Those are *exactly* the generators of a Grassmann algebra — the same $\mathbf v\wedge\mathbf v=0$ rule you just learned! And it's not a coincidence: $\theta_i^2=0$ **is** the **Pauli exclusion principle** in algebraic clothing — you can't put two identical fermions in the same state, just as you can't wedge a vector with itself. Integrating over these variables uses the curious **Berezin integral** $\int \mathrm d\theta\,\theta = 1$, which is what makes fermionic path integrals (and the whole machinery of the Standard Model's matter fields) work.

\col{Crimson}{The humble rule "squares vanish" is the same rule that forbids two electrons from sharing a state.} \col{#9c7a3c}{We'll unpack the QFT side properly in a later post.}

## Recap

- The **wedge product** $\mathbf u\wedge\mathbf v$ is an **oriented area** (a *bivector*), with $\mathbf v\wedge\mathbf u=-\mathbf u\wedge\mathbf v$ and $\mathbf u\wedge\mathbf u=0$.
- Antisymmetry and self-annihilation are the **same rule**.
- Bivector components are signed areas / determinants; in 3D they reproduce the **cross product** (which is just a bivector in disguise).
- Wedging builds a tower of **grades**; in $n$D the dimensions are the Pascal row $\binom{n}{k}$, summing to $2^n$.
- Officially, $\Lambda(V)=T(V)/\langle \mathbf v\otimes\mathbf v\rangle$ — "**squares vanish**."

Next time we flip that last rule and meet the algebra that makes spinors stop looking like accidents.

➡️ **Continue to [Part 2 — Clifford (Geometric) Algebra](/Pages/Maths/blogs/clifford_algebra/).**

~~~
<button onclick="window.history.back()">Go Back</button>
~~~

{{comments}}
