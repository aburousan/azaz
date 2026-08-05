+++
title = "Tree Codes 3: The Tree and the Multipole Expansion"
hascode = true
date = Date(2026, 8, 4)
rss = "Part 3 of recreating Hernquist (1987): building an octree, the opening criterion, and the multipole expansion derived term by term from the Legendre generating function."

tags = ["Julia", "physics", "papers", "N-body", "multipole", "Barnes-Hut", "algorithms"]
+++

\toc

# 3. The tree and the multipole expansion

Part 3 of my recreation of [Hernquist (1987)](/Pages/Physics/papers/hernquist1987/). This is the long one, and the one that actually contains the physics of the method. Everything so far was setup.

The question: **how do I compute the force on $N$ particles without doing $N^2$ work?**

## The idea, in one picture

Suppose I want the force on one particular star, and there is a globular cluster of ten thousand stars sitting a long way away. Do I need all ten thousand terms?

Obviously not. From far enough away the cluster is just a lump of mass $M$ at a particular place. One term instead of ten thousand.

The question is: **how far is far enough?** And the answer must be relative — a cluster of size $s$ seen from distance $d$ looks compact if $s \ll d$. So the natural thing to compare is the ratio $s/d$, and that is exactly the paper's eq. (1.1):

$$
\frac{s}{d} < \theta
$$

\defn{
    **Opening angle $\theta$**: the tolerance parameter of the method. A cell of size $s$ whose centre of mass is at distance $d$ from the particle is treated as a single lump if $s/d < \theta$; otherwise it is "opened" and we look at its subcells instead. Small $\theta$ = fussy = accurate = slow. Large $\theta$ = relaxed = approximate = fast. $\theta = 0$ means never approximate anything, which recovers the direct sum exactly.
}

Notice that $s/d$ is roughly the angle the cell subtends on the sky. So $\theta$ is literally "how big is a clump allowed to look before I stop treating it as a point".

Here is the picture. A cell of width $s$ sitting at distance $d$ covers an angle of roughly $s/d$ on your sky. The test asks whether that angle is small enough to ignore what is inside it.

~~~
<div style="max-width:660px;margin:1.5rem auto">
<svg viewBox="0 0 660 300" xmlns="http://www.w3.org/2000/svg" style="width:100%;height:auto">
  <defs>
    <marker id="ah" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto">
      <path d="M0,0 L8,4 L0,8 z" fill="#8A8F98"/>
    </marker>
  </defs>
  <!-- observer particle -->
  <circle cx="60" cy="150" r="7" fill="#4C8DF6"/>
  <text x="60" y="182" fill="#8A8F98" font-size="13" text-anchor="middle">the particle</text>

  <!-- NEAR cell: big angle -> opened -->
  <rect x="215" y="96" width="108" height="108" fill="none" stroke="#E5646E" stroke-width="2"/>
  <line x1="60" y1="150" x2="215" y2="96" stroke="#E5646E" stroke-width="1.2" stroke-dasharray="4 3"/>
  <line x1="60" y1="150" x2="215" y2="204" stroke="#E5646E" stroke-width="1.2" stroke-dasharray="4 3"/>
  <path d="M100 135 A 45 45 0 0 1 100 165" fill="none" stroke="#E5646E" stroke-width="1.6"/>
  <text x="127" y="155" fill="#E5646E" font-size="14">big angle</text>
  <text x="269" y="86" fill="#E5646E" font-size="13" text-anchor="middle">s/d &gt; &#952;</text>
  <text x="269" y="228" fill="#E5646E" font-size="14" text-anchor="middle" font-weight="bold">OPEN it</text>
  <text x="269" y="248" fill="#8A8F98" font-size="12" text-anchor="middle">look at the 8 children</text>

  <!-- FAR cell: small angle -> accepted -->
  <rect x="520" y="126" width="52" height="52" fill="none" stroke="#3FBF8F" stroke-width="2"/>
  <line x1="60" y1="150" x2="520" y2="126" stroke="#3FBF8F" stroke-width="1.2" stroke-dasharray="4 3"/>
  <line x1="60" y1="150" x2="520" y2="178" stroke="#3FBF8F" stroke-width="1.2" stroke-dasharray="4 3"/>
  <circle cx="546" cy="152" r="4" fill="#3FBF8F"/>
  <text x="546" y="116" fill="#3FBF8F" font-size="13" text-anchor="middle">s/d &lt; &#952;</text>
  <text x="546" y="202" fill="#3FBF8F" font-size="14" text-anchor="middle" font-weight="bold">ACCEPT it</text>
  <text x="546" y="222" fill="#8A8F98" font-size="12" text-anchor="middle">one term, use its multipoles</text>
</svg>
</div>
~~~

\defn{
    So $\theta$ is really a rule about **eyesight**. Small $\theta$ is sharp eyes — you insist on resolving individuals until they are very far away, which is accurate and slow. Large $\theta$ is squinting — you lump things together aggressively, which is fast and crude.
}

Notice the criterion is an *angle*, not a distance. A clump twice as wide may be treated as one lump only if it is also twice as far away. That is exactly how vision works, and it is why $s/d$ — rather than $s$ or $d$ on its own — is the right thing to test.

To turn this into an algorithm I need two things: a way to organise the particles into nested clumps of every size (**the tree**), and a way to describe a clump by more than just its total mass (**the multipole expansion**). Let me do the tree first, because it is the easy half.

## Building the tree

The Barnes-Hut recipe is a recursive subdivision of space:

1. Put a cube around all the particles. This is the **root**.
2. If a cell has more than one particle in it, cut it into 8 equal sub-cubes (in 3D — an **octree**) and hand each particle to whichever sub-cube contains it.
3. Repeat until every cell has at most one particle.

The result is a hierarchy of cells: one enormous cell containing everything, eight cells of half the size, sixty-four of a quarter, and so on down to individual particles. Cells in dense regions get subdivided many times; cells in empty regions stop early.

Here is what that looks like in 2D (a **quadtree**, four children per cell instead of eight — same logic, just easier to look at). 500 particles drawn from the Plummer sphere:

\fig{/assets/Physics/papers/hernquist1987/quadtree_cells}

You can see the structure immediately: the tree is deep and finely divided in the dense middle, and shallow out in the sparse halo. That is exactly the behaviour you want — the subdivision automatically follows the density, with nobody having to tell it where the interesting regions are. This is what makes tree codes so much more flexible than grid methods, which have to pick a resolution in advance.

\note{
    Empty cells are never stored. So the number of nodes stays proportional to $N$, not to the volume. For my $N = 32768$ Plummer model the tree has $48515$ nodes and is 14 levels deep; the uniform sphere with the same $N$ has $49061$ nodes but only 11 levels, because it has no dense core to keep subdividing.
}

The Julia is a straightforward insert-one-particle-at-a-time loop. The one subtlety is that when a particle arrives at a cell that already holds one, the sitting particle has to be pushed down a level first:

```julia
function insert!(t::Octree, pos::AbstractMatrix, i::Integer)
    node = 1
    while true
        if t.leafpart[node] == 0 && all(t.child[k, node] == 0 for k in 1:8)
            t.leafpart[node] = i          # empty cell: park it here
            return
        elseif t.leafpart[node] != 0
            # occupied leaf: push the sitting tenant down one level first
            j = t.leafpart[node]
            t.leafpart[node] = 0
            oj = octant(t, node, pos[1, j], pos[2, j], pos[3, j])
            c = newnode!(t, child_center(t, node, oj)..., 0.5 * t.size[node])
            t.child[oj, node] = c
            t.leafpart[c] = j
            # ... and carry on with particle i in the same cell
        else
            o = octant(t, node, pos[1,i], pos[2,i], pos[3,i])
            if t.child[o, node] == 0
                c = newnode!(t, child_center(t, node, o)..., 0.5 * t.size[node])
                t.child[o, node] = c
                t.leafpart[c] = i
                return
            end
            node = t.child[o, node]
        end
    end
end
```

Building the tree costs $O(N\log N)$, and in practice it is a small fraction of the total time — Hernquist quotes under 10%, and I find the same.

## Walking the tree

With the tree built, computing the force on particle $i$ is a walk from the root:

* If the cell is **empty**, skip it.
* If the cell holds a **single particle**, add the ordinary pairwise force (and skip it if it is particle $i$ itself).
* Otherwise compute $s/d$. If $s/d < \theta$, **accept** the cell — add one term for the whole thing and do not look inside. If not, **open** it and put its eight children on the stack.

Here is that walk, made visible. This is the same 500-particle quadtree, and the star marks the particle we are computing the force on. Orange boxes are cells that got swallowed whole; red dots are particles that had to be summed one by one. **Drag the slider to change $\theta$**:

\fig{/assets/Physics/papers/hernquist1987/treewalk_theta}

Watch what happens as $\theta$ grows. At $\theta = 0.2$ the walk is fussy: 161 terms, and it descends nearly to individual particles even quite far away. At $\theta = 1.5$ it is 15 terms — one enormous box covers the whole far side of the cluster.

Also notice the *spatial pattern*: nearby particles are always handled individually, and the cells used get bigger the further away they are. The method automatically spends its effort where the force is largest and the geometry matters most.

## The multipole expansion

Now the real content. When we "accept" a cell, what exactly do we replace it with?

The crude answer is: a point mass at its centre of mass. That is the **monopole** approximation, and it is what the original Barnes-Hut paper used. But we can do better, and doing better is what Hernquist's paper is largely about. Let me derive the whole thing carefully, because this is the part sir wanted understood properly.

### The setup

Take one cell. Put the origin at its **centre of mass**. The cell contains particles of mass $m_k$ at positions $\vec s_k$ (these are small — of order the cell size $s$). We want the potential at a field point $\vec d$ which is far away ($d \gg s$). Let $\gamma_k$ be the angle between $\vec d$ and $\vec s_k$.

The exact potential is just the sum over particles:

$$
\varphi(\vec d) = -G\sum_k \frac{m_k}{\left|\vec d - \vec s_k\right|}
$$

Everything now comes from expanding that denominator.

### Expanding $1/|\vec d - \vec s|$

Write the distance out using the cosine rule:

$$
\left|\vec d - \vec s\right| = \sqrt{d^2 - 2ds\cos\gamma + s^2}
$$

so

$$
\frac{1}{|\vec d - \vec s|} = \frac{1}{d}\,\frac{1}{\sqrt{1 - 2\left(\frac{s}{d}\right)\cos\gamma + \left(\frac{s}{d}\right)^2}}
$$

Now — and this is the moment where the whole thing becomes beautiful — that square root is *exactly* the generating function of the **Legendre polynomials**:

$$
\frac{1}{\sqrt{1-2xt+t^2}} = \sum_{n=0}^{\infty}P_n(x)\,t^n, \qquad |t|<1
$$

Rather than assert that, let me get the first few terms by hand, because it takes four lines and it makes the structure concrete. Write the thing under the root as $1 + A$ with

$$
A = -2xt + t^2
$$

and use the binomial series $(1+A)^{-1/2} = 1 - \tfrac{1}{2}A + \tfrac{3}{8}A^2 - \tfrac{5}{16}A^3 + \dots$. We want everything up to $t^2$, so we need $A$ in full and $A^2$ only to leading order:

$$
A = -2xt + t^2, \qquad A^2 = 4x^2t^2 + \mathcal{O}(t^3)
$$

Substituting:

$$
(1+A)^{-1/2} = 1 - \frac{1}{2}\left(-2xt + t^2\right) + \frac{3}{8}\left(4x^2t^2\right) + \mathcal{O}(t^3)
= 1 + xt + \left(\frac{3x^2}{2} - \frac{1}{2}\right)t^2 + \mathcal{O}(t^3)
$$

and reading off the coefficients:

$$
P_0(x) = 1, \qquad P_1(x) = x, \qquad P_2(x) = \frac{3x^2-1}{2}
$$

which are exactly the first three Legendre polynomials. Setting $t = s/d$ and $x = \cos\gamma$:

$$
\boxed{\;\frac{1}{|\vec d - \vec s|} = \frac{1}{d}\sum_{n=0}^{\infty}\left(\frac{s}{d}\right)^n P_n(\cos\gamma)\;}
$$

\note{
    This is why Legendre polynomials turn up everywhere in electrostatics and gravity. They are not imposed on the problem — they *are* the expansion of $1/r$, and every multipole expansion you have seen is this one identity in disguise.
}

Note also the convergence condition $|t| < 1$, that is $s < d$. The series simply **does not converge** if the field point is inside the cell. That is not a technicality to wave away — it is why $\theta$ has to be kept below about 1, and it shows up later as a measured effect.

I checked the general term in Mathematica rather than trusting my memory beyond $n=2$:

```mathematica
$Assumptions = d > 0 && s > 0 && -1 <= ct <= 1;
Table[FullSimplify[SeriesCoefficient[1/Sqrt[d^2 - 2 d s ct + s^2], {s, 0, n}]
                   - LegendreP[n, ct]/d^(n + 1)], {n, 0, 4}]
(* -> {0, 0, 0, 0, 0} *)
```

### Term by term

Substituting back into the potential:

$$
\varphi(\vec d) = -\frac{G}{d}\left[\underbrace{\sum_k m_k}_{n=0} + \frac{1}{d}\underbrace{\sum_k m_k s_k\cos\gamma_k}_{n=1} + \frac{1}{d^2}\underbrace{\sum_k m_k s_k^2\,\frac{3\cos^2\gamma_k-1}{2}}_{n=2} + \dots\right]
$$

Let me take these one at a time.

**$n=0$, the monopole.** This one is trivial:

$$
\sum_k m_k = M
$$

the total mass of the cell. This gives $-GM/d$ — the cell treated as a point. Nothing about the shape of the cell survives here.

**$n=1$, the dipole.** Write $\hat n = \vec d/d$ for the direction to the field point. Then $s_k\cos\gamma_k = \hat n\cdot\vec s_k$, so

$$
\sum_k m_k s_k\cos\gamma_k = \hat n\cdot\sum_k m_k\vec s_k
$$

And now the payoff for a decision made way back at the start. We put the origin **at the centre of mass**, which is defined by precisely $\sum_k m_k\vec s_k = 0$.

$$
\boxed{\text{The dipole term vanishes identically.}}
$$

\note{
    This is the single most important structural fact about the whole method, and it is easy to skate past. Because we expand about the centre of mass, the first correction to "treat it as a point" is not of order $s/d$ — it is of order $(s/d)^2$. We get an entire order of accuracy for **free**, just by choosing the expansion centre sensibly. If we had expanded about the geometric centre of the cell instead, there would be a dipole term and the method would be far worse.
}

**$n=2$, the quadrupole.** This is the first term that actually survives, so it deserves care. Again using $s_k\cos\gamma_k = \hat n\cdot\vec s_k$:

$$
s_k^2\,\frac{3\cos^2\gamma_k - 1}{2} = \frac{3(\hat n\cdot\vec s_k)^2 - s_k^2}{2}
$$

Write it in index notation, with $\hat n\cdot\vec s_k = \hat n_i s_{k,i}$ (summing over repeated indices) and using $\hat n_i\hat n_j\delta_{ij} = |\hat n|^2 = 1$:

$$
\frac{3(\hat n_i s_{k,i})(\hat n_j s_{k,j}) - s_k^2}{2} = \frac{1}{2}\hat n_i\hat n_j\left(3s_{k,i}s_{k,j} - s_k^2\delta_{ij}\right)
$$

Summing over the particles in the cell, everything that depends on the cell's internal arrangement collects into a single object:

$$
\boxed{\;Q_{ij} = \sum_k m_k\left(3\,s_{k,i}\,s_{k,j} - s_k^2\,\delta_{ij}\right)\;}
$$

which is exactly the paper's eq. (2.3). The $n=2$ term is then $\tfrac{1}{2}\hat n\cdot\mathbf{Q}\cdot\hat n$.

I verified this collapse symbolically too, since it is easy to drop a factor:

```mathematica
nh = {n1, n2, n3}; xk = {a1, a2, a3}; s2 = xk . xk;
legTerm = s2 LegendreP[2, (xk . nh)/Sqrt[s2]];
Qk = Table[mk (3 xk[[i]] xk[[j]] - s2 KroneckerDelta[i, j]), {i, 3}, {j, 3}];
FullSimplify[(mk legTerm - (1/2) nh . Qk . nh) /. n3 -> Sqrt[1 - n1^2 - n2^2]]
(* -> 0 *)
```

### What these terms actually mean

Before pushing on, it is worth stopping to ask what we have just built, because the algebra hides a very simple physical picture.

**The multipole expansion is a way of describing a lump of matter by progressively finer features**, in the same way you might describe a person from further and further away:

| term | what it measures | what you would say |
| --- | --- | --- |
| $n=0$, monopole | total mass $M$ | "there is something there, and this is how heavy it is" |
| $n=1$, dipole | where the mass sits | "and it is over *there*, not where you said" |
| $n=2$, quadrupole | is it a cigar or a pancake? | "and it is squashed this way" |
| $n=3$, octupole | is it lopsided? | "and it is fatter at one end than the other" |

Each term is a finer detail than the last, and each matters less the further away you stand. That is precisely what the factors of $(s/d)^n$ are saying: **detail costs distance.** From far enough away, everything is a point.

You have met this ladder before, probably several times without it being labelled:

* **The Earth's gravity field.** The Earth bulges at the equator, and that bulge is exactly a quadrupole — satellite people call its coefficient $J_2$, and every GPS orbit accounts for it.
* **Tides.** The Moon pulls harder on the near side of the Earth than the far side. Subtract the average and what is left *is* the quadrupole field.
* **The CMB.** Decomposing the microwave sky into $\ell = 0, 1, 2, \dots$ is this same Legendre expansion on a sphere. $\ell=1$ is the dipole from our own motion.
* **Nuclear physics.** Deformed nuclei are catalogued by their electric quadrupole moment — same tensor, different force.

\note{
    It is the same mathematics every time, because it is really a statement about $1/r$ and the Laplacian rather than about gravity specifically.
}

### Why the error is second order, intuitively

The $(s/d)^2$ law deserves a picture rather than just a derivation.

Treating a cell as a point mass at its centre gets the *average* distance right but nothing else. Now ask what you got wrong. Particles on the near side of the cell are closer than you assumed, so they pull **more** than your point-mass estimate; particles on the far side are further, so they pull **less**.

To first order in the cell size, those two errors are equal and opposite, and they **cancel** — because the centre of mass sits exactly at the balance point. That is the dipole vanishing, seen from the other side.

What does *not* cancel is that $1/r$ is **curved**. The extra pull you gain by moving a bit closer is bigger than the pull you lose by moving the same bit further away. So the near side wins by a little, and that residue — the *curvature* of $1/r$, not its slope — is the quadrupole.

$$
\underbrace{\text{slope of } 1/r}_{\text{cancels: dipole} = 0} \qquad
\underbrace{\text{curvature of } 1/r}_{\text{survives: quadrupole} \sim (s/d)^2}
$$

\tip{
    This is why a spherical cell has $\mathbf{Q} = 0$ exactly: for a sphere, the "near side wins" effect in one direction is cancelled by an identical effect in every other direction. There is nothing left over. That is Newton's shell theorem, arrived at by thinking about cancellation rather than by doing an integral.
}

### What the quadrupole tensor means

$\mathbf{Q}$ is a symmetric $3\times3$ matrix, so it has six independent components. It is also **traceless**:

$$
\text{tr}\,\mathbf{Q} = \sum_k m_k\left(3s_k^2 - 3s_k^2\right) = 0
$$

(the $\delta_{ii} = 3$ in three dimensions), which knocks it down to five.

Physically, $\mathbf{Q}$ measures **how far from spherical the cell is**. Here is the cleanest way to see it: if the particles in a cell are distributed with perfect spherical symmetry, then by symmetry $\sum_k m_k s_{k,i}s_{k,j} = \tfrac{1}{3}\delta_{ij}\sum_k m_k s_k^2$, and substituting gives $Q_{ij} = 0$ exactly.

\note{
    So for a spherical clump, the monopole approximation is not an approximation at all — it is **exact**. That is Newton's shell theorem, falling out of the multipole expansion as the statement $\mathbf{Q}=0$. The quadrupole is precisely the leading correction for the fact that a real cubical cell full of particles is *lumpy and not round*.
}

### The result

Putting the surviving terms together, and using $\hat n\cdot\mathbf{Q}\cdot\hat n = \vec d\cdot\mathbf{Q}\cdot\vec d / d^2$:

$$
\boxed{\;\varphi(\vec d) = -\frac{GM}{d} - \frac{1}{2}\frac{G}{d^5}\,\vec d\cdot\mathbf{Q}\cdot\vec d\;}
$$

which is the paper's eq. (2.2). And the acceleration follows by $\vec a = -\nabla\varphi$. Let me do that gradient properly in index notation, since it is the sort of thing that is easy to get wrong by a factor of two.

We need $\partial_k$ of $S/d^5$, where $S \equiv d_iQ_{ij}d_j$. Two ingredients. First, the derivative of the distance itself:

$$
d = \sqrt{d_ld_l} \;\Longrightarrow\; \partial_k d = \frac{d_k}{d} \;\Longrightarrow\; \partial_k\left(d^{-5}\right) = -5d^{-6}\cdot\frac{d_k}{d} = -\frac{5d_k}{d^7}
$$

Second, the derivative of the quadratic form. Using $\partial_k d_i = \delta_{ki}$ and the symmetry $Q_{ij}=Q_{ji}$:

$$
\partial_k S = \partial_k\left(d_iQ_{ij}d_j\right) = \delta_{ki}Q_{ij}d_j + d_iQ_{ij}\delta_{kj} = Q_{kj}d_j + d_iQ_{ik} = 2Q_{kj}d_j
$$

The two terms are equal *because* $\mathbf{Q}$ is symmetric — that is where the factor of 2 comes from. Now the product rule:

$$
\partial_k\left(\frac{S}{d^5}\right) = \frac{\partial_k S}{d^5} + S\,\partial_k\left(d^{-5}\right)
= \frac{2Q_{kj}d_j}{d^5} - \frac{5\,S\,d_k}{d^7}
$$

Therefore, remembering the $-\tfrac12 G$ prefactor in $\varphi$ and the overall minus in $\vec a = -\nabla\varphi$, the two signs cancel and the $\tfrac12$ eats the 2:

$$
a_k^{\text{quad}} = -\partial_k\left(-\frac{G}{2}\frac{S}{d^5}\right) = \frac{G}{2}\left(\frac{2Q_{kj}d_j}{d^5} - \frac{5Sd_k}{d^7}\right) = \frac{G\,Q_{kj}d_j}{d^5} - \frac{5G}{2}\frac{S\,d_k}{d^7}
$$

The monopole part is the familiar $-GMd_k/d^3$. Putting them together and pulling out unit vectors with $\hat r = \vec d/d$ (so $Q_{kj}d_j/d^5 = Q_{kj}\hat r_j/d^4$ and $Sd_k/d^7 = (\hat r\cdot\mathbf{Q}\cdot\hat r)\hat r_k/d^4$),

$$
\boxed{\;\vec a = -\frac{GM}{d^2}\hat r + \frac{G}{d^4}\mathbf{Q}\cdot\hat r - \frac{5G}{2}\left(\hat r\cdot\mathbf{Q}\cdot\hat r\right)\frac{\hat r}{d^4}\;}
$$

which is the paper's eq. (2.4). I checked that this really is minus the gradient of the potential above, rather than taking it on trust:

```mathematica
Qm = {{q11, q12, q13}, {q12, q22, q23}, {q13, q23, q33}};
rv = {x, y, z}; rr = Sqrt[x^2 + y^2 + z^2];
phi = -Mc/rr - (1/2) (rv . Qm . rv)/rr^5;
accelPaper = -Mc rv/rr^3 + (Qm . rv)/rr^5 - (5/2) (rv . Qm . rv) rv/rr^7;
FullSimplify[-Grad[phi, {x, y, z}] - accelPaper]
(* -> {0, 0, 0} *)
```

Good. The paper's equations are consistent.

### How good is it?

The expansion is a power series in $s/d$. Since the dipole vanishes, the leading term we throw away is:

* **monopole only** — we drop the $n=2$ term, so the error is $\mathcal{O}\!\left((s/d)^2\right)$
* **through quadrupole** — we drop the $n=3$ term, so the error is $\mathcal{O}\!\left((s/d)^3\right)$

That is a *prediction*, so let me test it. I took a cloud of 200 particles packed into a cube of side $s$, computed the acceleration it produces at distance $d$ exactly, and compared against both approximations, averaging over 400 directions:

\fig{/assets/Physics/papers/hernquist1987/multipole_error}

Fitting slopes on the small-$s/d$ end gives **2.00** for the monopole and **3.03** for the quadrupole. Exactly as derived. I was pleased with this one — it is a clean case of theory predicting a number and the computer producing it.

You can also see *why* $\theta$ has to be kept below about 1. The expansion parameter is $s/d$, and the series is only guaranteed to converge for $s/d < 1$. Push $\theta$ past that and you are asking a divergent series for an answer, so adding more terms need not help — which is exactly what the paper finds, and what I will show [in the results](/Pages/Physics/papers/hernquist1987/04_results/).

## Building $\mathbf{Q}$ for every cell, cheaply

There is a practical problem left. Every cell in the tree needs its own $\mathbf{Q}$, and computing each one directly from its particles would cost $O(N\log N)$ per level. Wasteful.

The fix is a **parallel-axis theorem** for the quadrupole. A parent cell's $\mathbf{Q}$ can be assembled from its children's, and the paper gives it as eq. (2.5):

$$
\mathbf{Q} = \sum_{l}\mathbf{Q}_l + \sum_{l}m_l\left(3\vec R_l\vec R_l - R_l^2\mathbf{1}\right)
$$

where $l$ runs over the subcells, $m_l$ is the subcell's mass, and $\vec R_l$ is the offset of subcell $l$'s centre of mass from the parent's.

Let me derive it, since the cancellation that makes it work is the same one that killed the dipole. Take a particle $k$ in subcell $l$. Its position relative to the *parent's* centre of mass is

$$
\vec s_k = \vec R_l + \vec y_k
$$

where $\vec y_k$ is measured from the *subcell's* own centre of mass. Substituting into the definition of $\mathbf{Q}$ and summing over the particles of that one subcell:

$$
\sum_{k\in l} m_k\Big[3\left(R_{l,i}+y_{k,i}\right)\left(R_{l,j}+y_{k,j}\right) - \left|\vec R_l + \vec y_k\right|^2\delta_{ij}\Big]
$$

Expand both pieces. The first:

$$
3\left(R_{l,i}+y_{k,i}\right)\left(R_{l,j}+y_{k,j}\right) = 3R_{l,i}R_{l,j} + 3R_{l,i}y_{k,j} + 3y_{k,i}R_{l,j} + 3y_{k,i}y_{k,j}
$$

and the second, using $|\vec R_l+\vec y_k|^2 = R_l^2 + 2\vec R_l\cdot\vec y_k + y_k^2$:

$$
-\left(R_l^2 + 2\vec R_l\cdot\vec y_k + y_k^2\right)\delta_{ij}
$$

Now sort the seven terms by how many powers of $\vec y_k$ they carry, and sum over $k\in l$:

* **No $\vec y$**: $\;\sum_k m_k\left(3R_{l,i}R_{l,j} - R_l^2\delta_{ij}\right) = m_l\left(3R_{l,i}R_{l,j} - R_l^2\delta_{ij}\right)$, since $\sum_{k\in l}m_k = m_l$.
* **Linear in $\vec y$**: $\;3R_{l,i}\sum_k m_ky_{k,j} + 3R_{l,j}\sum_k m_ky_{k,i} - 2R_{l,m}\delta_{ij}\sum_k m_ky_{k,m}$. Every one of these contains $\sum_{k\in l}m_k\vec y_k$, which is **zero by the definition of the subcell's centre of mass**. All three vanish.
* **Quadratic in $\vec y$**: $\;\sum_k m_k\left(3y_{k,i}y_{k,j} - y_k^2\delta_{ij}\right)$, which is precisely $\mathbf{Q}_l$, the subcell's own quadrupole about its own centre of mass.

So the whole subcell contributes

$$
\underbrace{m_l\left(3R_{l,i}R_{l,j} - R_l^2\delta_{ij}\right)}_{\text{subcell treated as a point mass}} \;+\; \underbrace{\mathbf{Q}_l}_{\text{its own internal shape}}
$$

and summing over the eight subcells gives eq. (2.5).

\note{
    Notice this is the *same* cancellation that killed the dipole: the linear moment $\sum m\vec y$ vanishes when measured from a centre of mass. It does double duty — once to buy an extra order of accuracy, once here to make the recursion clean. If the tree stored geometric cell centres instead, neither would work.
}

It is also exactly the parallel-axis theorem you met for moments of inertia in mechanics, $I = I_{\text{cm}} + Md^2$: a "shape about its own centre" piece plus a "point mass displaced" piece. Same algebra, same reason. So the whole tree's moments are filled in with a single bottom-up sweep, costing $O(N)$ in total:

```julia
for o in 1:8
    c = t.child[o, node]
    c == 0 && continue
    mc = t.mass[c]
    Rx = t.com[1, c] - t.com[1, node]
    Ry = t.com[2, c] - t.com[2, node]
    Rz = t.com[3, c] - t.com[3, node]
    R2 = Rx*Rx + Ry*Ry + Rz*Rz
    # the child's own shape ...
    qxx += t.quad[1, c]; qxy += t.quad[2, c]; qxz += t.quad[3, c]
    qyy += t.quad[4, c]; qyz += t.quad[5, c]; qzz += t.quad[6, c]
    # ... plus the shape it acquires by sitting off-centre
    qxx += mc * (3Rx*Rx - R2);  qxy += mc * (3Rx*Ry)
    qxz += mc * (3Rx*Rz);       qyy += mc * (3Ry*Ry - R2)
    qyz += mc * (3Ry*Rz);       qzz += mc * (3Rz*Rz - R2)
end
```

\tip{
    This recursion is the easiest place in the whole code to make a silent mistake, because a wrong $\mathbf{Q}$ still produces plausible-looking forces. My test suite checks it by building the tree and then comparing the **root** node's quadrupole against a brute-force sum over all $N$ particles. The root never sees a particle directly — it only ever adds up its eight children — so if the recursion is wrong at any level, the root will be wrong. It agrees to $10^{-10}$, and the trace comes out zero to the same precision.
}

## Why this gives $N\log N$

Stand on a rooftop and look at a city. The houses on your own street you see one by one; a few streets away you see blocks; further out, neighbourhoods; on the horizon, one smudge. Now count how many *things* you are looking at in each of those bands — roughly the same number in each, because things further away are bigger but subtend the same angle.

\note{
    A tree walk is exactly this. Each level of the tree is one band of distance, and each contributes about the same number of terms. Making the city ten times bigger does not multiply your work by ten, it just adds a couple more bands on the horizon — and that is the whole reason the method is $N\log N$ instead of $N^2$.
}

Here is the counting argument, which I found less obvious than the textbooks make it sound. Let me do it carefully.

Fix one particle and walk down the tree level by level. At level $\ell$, cells have size

$$
s_\ell = \frac{L}{2^\ell}
$$

where $L$ is the size of the root cell. A cell at that level is **accepted** when $s_\ell/d < \theta$, i.e. when its distance satisfies $d > s_\ell/\theta$, and it is **opened** otherwise. So the cells actually used at level $\ell$ are those which are accepted while their parent was not — parents live at level $\ell-1$ with size $2s_\ell$, and were opened when $d < 2s_\ell/\theta$. The cells contributing terms at level $\ell$ therefore sit in the spherical shell

$$
\frac{s_\ell}{\theta} < d < \frac{2s_\ell}{\theta}
$$

Now count how many cells of size $s_\ell$ fit into that shell. The shell's volume is

$$
V_\ell = \frac{4\pi}{3}\left[\left(\frac{2s_\ell}{\theta}\right)^3 - \left(\frac{s_\ell}{\theta}\right)^3\right] = \frac{4\pi}{3}\cdot\frac{7s_\ell^3}{\theta^3}
$$

and each cell occupies volume $s_\ell^3$, so the number of them is

$$
n_\ell \approx \frac{V_\ell}{s_\ell^3} = \frac{28\pi}{3\theta^3}
$$

**The $s_\ell$ has cancelled completely.** Every level of the tree contributes the same number of terms, controlled only by $\theta$. That is the crux: doubling the resolution adds one more level, and one more level costs a constant.

The tree has $\sim\log_8 N$ levels, so

$$
n_{\text{terms}} \sim \frac{28\pi}{3\theta^3}\log_8 N = C(\theta)\log N \quad\Longrightarrow\quad \text{total cost} \sim N\log N
$$

\tip{
    The estimate also predicts the *strength* of the $\theta$ dependence: $n_\text{terms}\propto\theta^{-3}$. Testing that on my data at $N=32768$: going from $\theta=1$ to $\theta=0.5$ should cost a factor $2^3 = 8$, and I measure $1053/218 = 4.8$. The right order, but not exact — which is fair, since real cells are not uniformly distributed in a shell and the innermost levels are not full. The scaling *with $N$* is the part the argument gets right, and that is what the timing curves confirm.
}

That is the entire promise of the method. And it makes a sharp prediction I can test: **doubling $N$ should add a constant amount to $n_{\text{terms}}$, not double it.** Here is my measurement, at $\theta = 1$:

| $N$ | $\langle n_\text{terms}\rangle$ | change |
| --- | --- | --- |
| 1024 | 124.0 | — |
| 2048 | 150.8 | +26.8 |
| 4096 | 171.5 | +20.7 |
| 8192 | 191.5 | +20.0 |
| 16384 | 205.3 | +13.8 |
| 32768 | 217.6 | +12.3 |

Compare with the direct sum, where the same column would read 1023, 2047, 4095, 8191, 16383, 32767. Thirty-two times more particles cost me 1.75 times more work per particle. That is the whole game.

## What one particle actually sees

The average hides a lot of structure. Here is the full distribution of $n_\text{terms}$ across all 32768 particles, for the Plummer model and for a uniform sphere with the same $N$ — this is the paper's Fig. 5:

\fig{/assets/Physics/papers/hernquist1987/nterms_hist}

Two things stand out, and both are physics rather than numerics.

The uniform sphere gives a **tight, symmetric** distribution centred on 122. Every particle sits in a similar neighbourhood, so every particle does a similar amount of work.

The Plummer model is centred higher (218) and has a long **tail towards smaller values**. The reason becomes obvious when you plot $n_\text{terms}$ against radius:

\fig{/assets/Physics/papers/hernquist1987/nterms_radius}

Particles out in the sparse halo need far fewer terms — the tree above them is shallow, and the whole cluster is far away, so a handful of big cells covers everything. Particles in the dense core need the most, because there are many levels of subdivision right next to them. The tree spends its effort where the structure is, without being told to.

My numbers here are $217.6$ and $122.2$; the paper reports $221$ and $121$. Given that this is a completely independent implementation from a written description, I am happy with that.

## One trap: a particle pulling on itself

There is a subtle bug that the paper warns about in section II, and it is worth knowing because it is invisible unless you look for it.

Consider a particle sitting near the **edge** of a large cell that it is itself inside. The cell's centre of mass could be at the far edge, so $d$ is large-ish and $s/d < \theta$ might be satisfied — for $\theta \gtrsim 1$ this really can happen. The walk then accepts the cell as a single lump... but the particle's own mass is part of that lump. **The particle exerts a force on itself.**

The fix is a geometric check: if the particle lies inside the cell, always open it, regardless of $s/d$.

```julia
opened = d2 <= 0 || s * s >= theta2 * d2
if !opened && forced_subdivision
    opened = inside_cell(t, node, pos[1, i], pos[2, i], pos[3, i])
end
```

I have this on by default. The paper investigates it and finds the effect negligible for $\theta \lesssim 1.2$, which matches what I see, but it costs almost nothing to be correct.

## The walk, in full

Putting it all together, here is the complete force calculation for one particle — the piece of code that dominates the entire runtime:

```julia
function tree_accel(t::Octree, pos, i, theta, eps; quadrupole = false,
                    forced_subdivision = true, stack = Int32[])
    empty!(stack); push!(stack, Int32(1))
    ax = ay = az = 0.0
    nterms = 0
    eps2 = eps * eps; theta2 = theta * theta

    while !isempty(stack)
        node = pop!(stack)
        m = t.mass[node]
        m == 0 && continue

        dx = pos[1,i] - t.com[1,node]
        dy = pos[2,i] - t.com[2,node]
        dz = pos[3,i] - t.com[3,node]
        d2 = dx*dx + dy*dy + dz*dz

        p = t.leafpart[node]
        if p != 0
            p == i && continue           # a particle feels no force from itself
            r2 = d2 + eps2
            f = m / (r2 * sqrt(r2))
            ax -= f*dx; ay -= f*dy; az -= f*dz
            nterms += 1
            continue
        end

        s = t.size[node]
        opened = d2 <= 0 || s*s >= theta2 * d2
        if !opened && forced_subdivision
            opened = inside_cell(t, node, pos[1,i], pos[2,i], pos[3,i])
        end
        if opened
            for o in 1:8
                c = t.child[o, node]
                c != 0 && push!(stack, c)
            end
            continue
        end

        # far enough away: replace the cell by its multipoles
        r2 = d2 + eps2; r = sqrt(r2)
        f = m / (r2 * r)
        ax -= f*dx; ay -= f*dy; az -= f*dz

        if quadrupole
            qxx = t.quad[1,node]; qxy = t.quad[2,node]; qxz = t.quad[3,node]
            qyy = t.quad[4,node]; qyz = t.quad[5,node]; qzz = t.quad[6,node]
            qdx = qxx*dx + qxy*dy + qxz*dz      # Q . d
            qdy = qxy*dx + qyy*dy + qyz*dz
            qdz = qxz*dx + qyz*dy + qzz*dz
            dQd = dx*qdx + dy*qdy + dz*qdz      # d . Q . d
            r5 = r2*r2*r
            c1 = 1 / r5
            c2 = 2.5 * dQd / (r5 * r2)
            ax += c1*qdx - c2*dx
            ay += c1*qdy - c2*dy
            az += c1*qdz - c2*dz
        end
        nterms += 1
    end
    return ax, ay, az, nterms
end
```

\note{
    **The one test that matters.** Set $\theta = 0$. Then $s^2 \ge 0 = \theta^2 d^2$ is true for every cell, so *nothing* is ever accepted and the walk descends all the way to individual particles — it must reproduce the direct $O(N^2)$ sum exactly. My test suite checks this for $N = 2000$ and gets agreement to $10^{-10}$ of the largest acceleration. If a tree code passes this, the tree structure and the walk logic are both correct, and only the multipole terms remain to be checked separately.
}

Note also the softening in the quadrupole terms. The paper applies an ad hoc substitution $r^4 \to (r^2+\varepsilon^2)^2$; I instead use $r^n \to (r^2+\varepsilon^2)^{n/2}$ throughout, which has the advantage of being exactly $-\nabla$ of a consistently softened quadrupole potential. The two agree when $\varepsilon = 0$ and differ only in how they behave at large softening, which is [one of the things I test](/Pages/Physics/papers/hernquist1987/04_results/#softening_fights_the_expansion).

## Where we are

We now have the complete method:

1. Build an octree over the particles — $O(N\log N)$, done once per step.
2. Fill in mass, centre of mass and quadrupole for every cell by a bottom-up sweep — $O(N)$.
3. For each particle, walk the tree accepting cells with $s/d < \theta$ — $O(\log N)$ each.
4. Push everything forward with leapfrog.

The next part is the payoff: does it actually behave the way the counting argument says, and how wrong are the forces?

---

**Previous:** [Part 2 — Moving the particles](/Pages/Physics/papers/hernquist1987/02_leapfrog/)\\
**Next:** [Part 4 — Results](/Pages/Physics/papers/hernquist1987/04_results/)

Hope this helps you in some way. If you like it then share with others if possible.

If you have some queries, do let me know in the comments or contact me using the informations that are given on the page [About Me](/Pages/about_me/).

~~~
<button onclick="window.history.back()">Go Back</button>
~~~
