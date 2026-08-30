+++
title = "Tree Codes 3: The Tree and the Multipole Expansion"
hascode = true
date = Date(2026, 8, 4)
rss = "Part 3 of recreating Hernquist (1987): building an octree, the opening criterion and the multipole expansion derived term by term from the Legendre generating function."

tags = ["Julia", "physics", "papers", "N-body", "multipole", "Barnes-Hut", "algorithms"]
+++

\toc

# 3. The tree and the multipole expansion

Part 3 of my recreation of [Hernquist (1987)](/Pages/Physics/papers/hernquist1987/). This is the long one, and the one that actually contains the physics of the method. Everything so far was setup.

The question: **how do I compute the force on $N$ particles without doing $N^2$ work?**

## The idea, in one picture

Suppose I want the force on one particular star, and there is a globular cluster of ten thousand stars sitting a long way away. Do I need all ten thousand terms?

Obviously not. From far enough away the cluster is just a lump of mass $M$ at a particular place. One term instead of ten thousand.

The question is: **how far is far enough?** The answer has to be relative, because a cluster of size $s$ seen from distance $d$ looks compact if $s \ll d$. So the natural thing to compare is the ratio $s/d$, which is exactly the paper's eq. (1.1):

$$
\frac{s}{d} < \theta
$$

\defn{
    **Opening angle $\theta$**: the tolerance parameter of the method. A cell of size $s$ whose centre of mass is at distance $d$ from the particle is treated as a single lump if $s/d < \theta$; otherwise it is "opened" and we look at its subcells instead. Small $\theta$ = fussy = accurate = slow. Large $\theta$ = relaxed = approximate = fast. $\theta = 0$ means never approximate anything, which recovers the direct sum exactly.
}

Notice that $s/d$ is roughly the angle the cell subtends on the sky. So $\theta$ is literally "how big is a clump allowed to look before I stop treating it as a point".

So, a picture. A cell of width $s$ sitting at distance $d$ covers an angle of roughly $s/d$ on your sky. The test asks whether that angle is small enough to ignore what is inside it.

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

One phrase in that picture needs unpacking, since it refers to something built in the next section. Every cube of space in this method gets cut into **8 equal smaller cubes**, in the same way a Rubik's cube is eight little cubes stacked two by two by two. Those eight are called the cube's **children**. "Look at the 8 children" therefore means: this clump is too close and too wide to be trusted as a single blob, so throw the blob away, take the eight smaller cubes it is made of, and ask the same question of each one separately. Some of those will be far enough to accept; the ones that are not get chopped into eight again. In two dimensions the pictures below use 4 children instead of 8, for the obvious reason that a square splits into four.

\defn{
    So $\theta$ is really a rule about **eyesight**. Small $\theta$ is sharp eyes: you insist on resolving individuals until they are very far away, which is accurate and slow. Large $\theta$ is squinting, i.e. you lump things together aggressively, which is fast and crude.
}

Notice the criterion is an *angle*, not a distance. A clump twice as wide may be treated as one lump only if it is also twice as far away. That is exactly how vision works, and it is why the right thing to test is $s/d$ rather than $s$ or $d$ on its own.

To turn this into an algorithm I need two things: a way to organise the particles into nested clumps of every size (**the tree**), and a way to describe a clump by more than just its total mass (**the multipole expansion**). Let me do the tree first, because it is the easy half.

## Building the tree

The Barnes-Hut recipe is a recursive subdivision of space:

1. Put a cube around all the particles. This is the **root**.
2. If a cell has more than one particle in it, cut it into 8 equal sub-cubes (in 3D, hence **octree**) and hand each particle to whichever sub-cube contains it.
3. Repeat until every cell has at most one particle.

The result is a hierarchy of cells: one enormous cell containing everything, eight cells of half the size, sixty-four of a quarter and so on down to individual particles. Cells in dense regions get subdivided many times; cells in empty regions stop early.

In 2D that looks like this (a **quadtree**, four children per cell instead of eight, same logic and easier to look at). 500 particles drawn from the Plummer sphere:

\fig{/assets/Physics/papers/hernquist1987/quadtree_cells}

Dots are the particles, boxes are the cells the tree made. Notice nobody told it where the crowd is: it worked that out on its own.

The subdivision is deep and fine in the dense middle, shallow out in the sparse halo. This is what makes tree codes so much more flexible than grid methods, which have to commit to a resolution in advance.

\note{
    Empty cells are never stored. So the number of nodes stays proportional to $N$, not to the volume. For my $N = 32768$ Plummer model the tree has $48515$ nodes and is 14 levels deep; the uniform sphere with the same $N$ has $49061$ nodes but only 11 levels, because it has no dense core to keep subdividing.
}

That picture is the finished tree though, and it hides the thing that confused me at first, which is that the tree is not designed, it is grown. So here is the same construction with the particles going in one at a time:

\fig{/assets/Physics/papers/hernquist1987/anim_treebuild}

Red is the particle being inserted right now, blue are the ones already placed. Watch what happens when a red dot lands in a box that is already occupied: the box immediately splits into four, and *both* particles fall into their own quarters. Sometimes they land in the same quarter again and it has to split again, which is why one insertion can suddenly add several levels. The title tracks the count, and by the end 120 particles have produced 212 cells and 8 levels. Nobody chose that depth, it is just where the splitting stopped.

The Julia is a straightforward insert-one-particle-at-a-time loop. The one subtlety is the splitting you just watched: when a particle arrives at a cell that already holds one, the sitting particle has to be pushed down a level first:

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

Building the tree costs $O(N\log N)$, and in practice it is a small fraction of the total time. Hernquist quotes under 10%, and I find the same.

## Walking the tree

With the tree built, computing the force on particle $i$ is a walk from the root:

* If the cell is **empty**, skip it.
* If the cell holds a **single particle**, add the ordinary pairwise force (and skip it if it is particle $i$ itself).
* Otherwise compute $s/d$. If $s/d < \theta$, **accept** the cell: add one term for the whole thing and do not look inside. If not, **open** it and put its eight children on the stack.

That walk, made visible. This is the same 500-particle quadtree, and the star marks the particle we are computing the force on. Orange boxes are cells that got swallowed whole; red dots are particles that had to be summed one by one. **Drag the slider to change $\theta$**:

\fig{/assets/Physics/papers/hernquist1987/treewalk_theta}

Move the slider to change $\theta$ and watch the count above the plot. Small $\theta$ means many small boxes and a lot of work; large $\theta$ means a few big boxes and very little work.

At $\theta = 0.2$ the walk is fussy: 161 terms, descending nearly to individual particles even quite far away. At $\theta = 1.5$ it is down to 15 terms, with one enormous box covering the whole far side of the cluster.

Also notice the *spatial pattern*. Nearby particles are always handled individually, and the cells used get bigger the further away they are. The method automatically spends its effort where the force is largest and the geometry matters most.

## The multipole expansion

Now the real content. When we "accept" a cell, what exactly do we replace it with?

The crude answer is: a point mass at its centre of mass. That is the **monopole** approximation, and it is what the original Barnes-Hut paper used. We can do better, and doing better is most of what Hernquist's paper is about. This is the part sir wanted us to actually understand, so nothing below is skipped.

### The setup

Take one cell. Put the origin at its **centre of mass**. The cell contains particles of mass $m_k$ at positions $\vec s_k$, which are small, of order the cell size $s$. We want the potential at a field point $\vec d$ which is far away ($d \gg s$). Let $\gamma_k$ be the angle between $\vec d$ and $\vec s_k$.

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

Now comes the moment where the whole thing becomes beautiful. That square root is *exactly* the generating function of the **Legendre polynomials**:

$$
\frac{1}{\sqrt{1-2xt+t^2}} = \sum_{n=0}^{\infty}P_n(x)\,t^n, \qquad |t|<1
$$

The first few terms come out by hand in four lines, and doing that made the structure concrete for me. Write the thing under the root as $1 + A$ with

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
    This is why Legendre polynomials turn up everywhere in electrostatics and gravity. They are not imposed on the problem. They *are* the expansion of $1/r$, and every multipole expansion you have seen is this one identity in disguise.
}

Note also the convergence condition $|t| < 1$, i.e. $s < d$. The series simply **does not converge** if the field point is too close. That is not a technicality to wave away, and it is worth being careful about *which* distance has to be small, because the answer is not the one I assumed for a long time. The condition is that $|\vec s_\alpha|/d < 1$ for **every particle $\alpha$ in the cell**, not for some typical size of the cell. I come back to this below, in [the section on what the opening test actually tests](#the_test_does_not_test_what_you_think_it_tests), and it turns out to change the safe range of $\theta$ by a factor of nearly two.

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

the total mass of the cell. This gives $-GM/d$, i.e. the cell treated as a point. Nothing about the shape of the cell survives here.

**$n=1$, the dipole.** Write $\hat n = \vec d/d$ for the direction to the field point. Then $s_k\cos\gamma_k = \hat n\cdot\vec s_k$, so

$$
\sum_k m_k s_k\cos\gamma_k = \hat n\cdot\sum_k m_k\vec s_k
$$

And now the payoff for a decision made way back at the start. We put the origin **at the centre of mass**, which is defined by precisely $\sum_k m_k\vec s_k = 0$.

$$
\boxed{\text{The dipole term vanishes identically.}}
$$

\note{
    This is the single most important structural fact about the whole method, and it is easy to skate past. Because we expand about the centre of mass, the first correction to "treat it as a point" is not of order $s/d$ but of order $(s/d)^2$. We get an entire order of accuracy for **free**, just by choosing the expansion centre sensibly. If we had expanded about the geometric centre of the cell instead, there would be a dipole term and the method would be far worse.
}

**$n=2$, the quadrupole.** The first term that actually survives, so I am going slowly here. Again using $s_k\cos\gamma_k = \hat n\cdot\vec s_k$:

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

Before pushing on, stop and ask what we have just built. The algebra hides a very simple picture.

**The multipole expansion is a way of describing a lump of matter by progressively finer features**, in the same way you might describe a person from further and further away:

| term | what it measures | what you would say |
| --- | --- | --- |
| $n=0$, monopole | total mass $M$ | "there is something there, and this is how heavy it is" |
| $n=1$, dipole | where the mass sits | "and it is over *there*, not where you said" |
| $n=2$, quadrupole | is it a cigar or a pancake? | "and it is squashed this way" |
| $n=3$, octupole | is it lopsided? | "and it is fatter at one end than the other" |

Each term is a finer detail than the last, and each matters less the further away you stand. That is precisely what the factors of $(s/d)^n$ are saying: **detail costs distance.** From far enough away, everything is a point.

You have met this ladder before, probably several times without it being labelled:

* **The Earth's gravity field.** The Earth bulges at the equator, and that bulge is exactly a quadrupole. Satellite people call its coefficient $J_2$, and every GPS orbit accounts for it.
* **Tides.** The Moon pulls harder on the near side of the Earth than the far side. Subtract the average and what is left *is* the quadrupole field.
* **The CMB.** Decomposing the microwave sky into $\ell = 0, 1, 2, \dots$ is this same Legendre expansion on a sphere. $\ell=1$ is the dipole from our own motion.
* **Nuclear physics.** Deformed nuclei are catalogued by their electric quadrupole moment: same tensor, different force.

\note{
    It is the same mathematics every time, because it is really a statement about $1/r$ and the Laplacian rather than about gravity specifically.
}

### Why the error is second order, intuitively

The $(s/d)^2$ law is easier to believe as a picture than as a derivation.

Treating a cell as a point mass at its centre gets the *average* distance right but nothing else. Now ask what you got wrong. Particles on the near side of the cell are closer than you assumed, so they pull **more** than your point-mass estimate; particles on the far side are further, so they pull **less**.

To first order in the cell size those two errors are equal and opposite, so they **cancel**, because the centre of mass sits exactly at the balance point. That is the dipole vanishing, seen from the other side.

What does *not* cancel is that $1/r$ is **curved**. The extra pull you gain by moving a bit closer is bigger than the pull you lose by moving the same bit further away. So the near side wins by a little, and that residue, the *curvature* of $1/r$ rather than its slope, is the quadrupole.

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

Physically, $\mathbf{Q}$ measures **how far from spherical the cell is**. The cleanest way to see it: if the particles in a cell are distributed with perfect spherical symmetry, then by symmetry $\sum_k m_k s_{k,i}s_{k,j} = \tfrac{1}{3}\delta_{ij}\sum_k m_k s_k^2$, and substituting gives $Q_{ij} = 0$ exactly.

\note{
    So for a spherical clump the monopole approximation is not an approximation at all, it is **exact**. That is Newton's shell theorem, falling out of the multipole expansion as the statement $\mathbf{Q}=0$. The quadrupole is precisely the leading correction for the fact that a real cubical cell full of particles is *lumpy and not round*.
}

### The result

Putting the surviving terms together, and using $\hat n\cdot\mathbf{Q}\cdot\hat n = \vec d\cdot\mathbf{Q}\cdot\vec d / d^2$:

$$
\boxed{\;\varphi(\vec d) = -\frac{GM}{d} - \frac{1}{2}\frac{G}{d^5}\,\vec d\cdot\mathbf{Q}\cdot\vec d\;}
$$

which is the paper's eq. (2.2). The acceleration follows by $\vec a = -\nabla\varphi$. I did that gradient in index notation, since it is exactly the sort of thing I get wrong by a factor of two.

We need $\partial_k$ of $S/d^5$, where $S \equiv d_iQ_{ij}d_j$. Two ingredients. First, the derivative of the distance itself:

$$
d = \sqrt{d_ld_l} \;\Longrightarrow\; \partial_k d = \frac{d_k}{d} \;\Longrightarrow\; \partial_k\left(d^{-5}\right) = -5d^{-6}\cdot\frac{d_k}{d} = -\frac{5d_k}{d^7}
$$

Second, the derivative of the quadratic form. Using $\partial_k d_i = \delta_{ki}$ and the symmetry $Q_{ij}=Q_{ji}$:

$$
\partial_k S = \partial_k\left(d_iQ_{ij}d_j\right) = \delta_{ki}Q_{ij}d_j + d_iQ_{ij}\delta_{kj} = Q_{kj}d_j + d_iQ_{ik} = 2Q_{kj}d_j
$$

The two terms are equal *because* $\mathbf{Q}$ is symmetric, which is where the factor of 2 comes from. Now the product rule:

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

which is the paper's eq. (2.4). I did not want to take on trust that this is minus the gradient of the potential above, so:

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

* **monopole only**: we drop the $n=2$ term, so the error is $\mathcal{O}\!\left((s/d)^2\right)$
* **through quadrupole**: we drop the $n=3$ term, so the error is $\mathcal{O}\!\left((s/d)^3\right)$

That is a *prediction*, so let me test it. I took a cloud of 200 particles packed into a cube of side $s$, computed the acceleration it produces at distance $d$ exactly, and compared against both approximations, averaging over 400 directions:

\fig{/assets/Physics/papers/hernquist1987/multipole_error}

Going left means the clump is further away, going down means the answer is more correct. Blue treats the clump as a single point, orange also adds its shape. Orange sits below blue everywhere and the gap keeps widening to the left, so adding the shape always helps and helps more the further you are. The slopes come out 2 and 3, which is what we derived above, so the maths and the computer agree.

So the plot is really a measurement of two numbers, the two slopes. The orange line is steeper than the blue one, meaning its error dies away faster as you back off, and the gap between the lines is how much the quadrupole buys you at that distance. At the far left, where $s/d = 0.02$, that gap is a factor of about a hundred.

Fitting slopes on the small-$s/d$ end gives **2.00** for the monopole and **3.03** for the quadrupole. Those are the $2$ and $3$ derived above, and nothing was fitted to make them come out. I was pleased with this one. It is a clean case of theory predicting a number and the computer producing it.

## The test does not test what you think it tests

I used to finish the section above with a sentence like this: *the expansion parameter is $s/d$, the series converges only for $s/d<1$, so keep $\theta$ below about 1.* It sounds fine. It is wrong, and the way it is wrong is worth a section of its own, because it is the single most instructive mistake I made in this whole project.

Go back to the convergence condition. The Legendre series converges when $|t|<1$ with $t = |\vec s_\alpha|/d$, and that has to hold for **every particle $\alpha$ in the cell**, not for some average or typical size. So the quantity that decides convergence is

$$
b_{\max} \;=\; \max_\alpha\left|\vec s_\alpha\right|
$$

the distance from the expansion centre, which is the cell's centre of mass, out to its own furthest particle. The series converges when $b_{\max}/d < 1$.

**But the opening test never looks at $b_{\max}$.** It looks at $s$, the width of the cube, which is a completely different number. Nothing in $s/d<\theta$ says anything directly about where the particles inside the cell actually are.

\defn{
    Two lengths, easy to confuse, and the whole of this section is about the gap between them. $s$ is the **width of the cube**, a piece of bookkeeping the tree chose when it cut space. $b_{\max}$ is the **radius of the particles about their own centre of mass**, a fact about the matter. The test uses the first. Convergence depends on the second.
}

### How far apart can they be?

Take the friendly case first. If the centre of mass sits at the geometric centre of the cube, the furthest point of the cube is a corner, at half the body diagonal:

$$
b_{\max} = \frac{\sqrt3}{2}\,s \approx 0.866\,s
$$

Now the unfriendly case. Nothing pins the centre of mass to the middle. Put nearly all the mass in one corner, so the centre of mass sits essentially *at* that corner, and leave one straggler particle in the opposite corner. Now $b_{\max}$ is the **full body diagonal**:

$$
b_{\max} = \sqrt3\,s \approx 1.73\,s
$$

So the test $s/d<\theta$ buys us only

$$
\frac{b_{\max}}{d} \;<\; \sqrt3\,\theta
$$

and if we want the guarantee $b_{\max}/d<1$ to follow from the test, we need

$$
\boxed{\;\theta \;\le\; \frac{1}{\sqrt3} \;\approx\; 0.577\;}
$$

Here is the whole argument in one picture. Cut a plane through the cube along a face diagonal, so that the body diagonal lies inside the plane and is drawn at its true length. The section is a rectangle with sides $s$ and $\sqrt2\,s$, so its own diagonal is $\sqrt{1+2}\,s = \sqrt3\,s$: the worst possible $b_{\max}$. The dashed circle of that radius is where the series stops converging. The three stars sit at $d = s/\theta$, which is the *closest* the test will let a field point come, for three values of $\theta$:

~~~
<div style="max-width:620px;margin:1.5rem auto">
<svg viewBox="0 0 620 330" xmlns="http://www.w3.org/2000/svg" style="width:100%;height:auto">
  <circle cx="200" cy="180" r="103.9" fill="none" stroke="#8A8F98" stroke-width="1.1" stroke-dasharray="5 4"/>
  <rect x="200" y="120" width="84.9" height="60" fill="#4C8DF6" fill-opacity="0.07" stroke="#4C8DF6" stroke-width="1.6"/>
  <line x1="200" y1="180" x2="284.9" y2="120" stroke="#E5646E" stroke-width="2"/>
  <circle cx="284.9" cy="120" r="4.5" fill="#E5646E"/>
  <path d="M193,180 L207,180 M200,173 L200,187" stroke="#E5646E" stroke-width="2"/>
  <line x1="200" y1="180" x2="350.7" y2="267.0" stroke="#8A8F98" stroke-width="0.9"/>
  <path d="M329.9,248.0 L332.0,252.8 L336.9,252.8 L333.1,256.4 L334.4,261.4 L329.9,258.4 L325.4,261.4 L326.7,256.4 L322.9,252.8 L327.8,252.8 Z" fill="#4C8DF6"/>
  <path d="M290.0,225.0 L292.1,229.8 L297.0,229.8 L293.2,233.4 L294.5,238.4 L290.0,235.4 L285.5,238.4 L286.8,233.4 L283.0,229.8 L287.9,229.8 Z" fill="#E5646E"/>
  <path d="M252.0,203.0 L254.1,207.8 L259.0,207.8 L255.2,211.4 L256.5,216.4 L252.0,213.4 L247.5,216.4 L248.8,211.4 L245.0,207.8 L249.9,207.8 Z" fill="#3FBF8F"/>
  <text x="242" y="198" fill="#8A8F98" font-size="13" text-anchor="middle">&#8730;2 s</text>
  <text x="295" y="150" fill="#8A8F98" font-size="13">s</text>
  <text x="229" y="155" fill="#E5646E" font-size="13">&#8730;3 s</text>
  <text x="188" y="200" fill="#E5646E" font-size="12" text-anchor="end">centre of mass</text>
  <text x="344" y="260" fill="#4C8DF6" font-size="13">&#952; = 0.4, safe</text>
  <text x="304" y="237" fill="#E5646E" font-size="13">&#952; = 1/&#8730;3, exactly on the edge</text>
  <text x="266" y="215" fill="#3FBF8F" font-size="13">&#952; = 1, inside: no guarantee</text>
  <text x="90" y="78" fill="#8A8F98" font-size="12" text-anchor="end">the series converges only outside this circle</text>
  <text x="310" y="316" fill="#8A8F98" font-size="12" text-anchor="middle">a plane section through the cell, cut along a face diagonal, so the body diagonal is drawn at true length</text>
</svg>
</div>
~~~

The middle star lands exactly on the circle, and that is the entire content of $\theta \le 1/\sqrt3$. For anything larger, the acceptance test is willing to put the field point **inside** the radius of convergence.

\note{
    Read that again, because it is a strong statement. At the common working choices $\theta = 0.7$ or $\theta = 1$, **including the $\theta = 1$ that Hernquist uses for his production runs**, the opening test does not guarantee that the series being truncated even converges. Salmon and Warren (1994) arrive at the same $1/\sqrt3$ from the other direction, by deliberately building cells on which the method falls over.
}

### So why does it work anyway?

Because the worst case is a caricature, and I can measure how far real cells are from it. I took the $N = 32768$ tree, walked it with 200 target particles, and recorded $b_{\max}$ for every cell that was actually accepted.

The typical accepted cell has $b_{\max}/s = 0.67$ at $\theta=0.5$ and $0.74$ at $\theta=1$. The whole distribution piles up just **below** $\sqrt3/2 = 0.866$, which is exactly what you would get from a cell with its centre of mass near the middle and a particle out near a corner: the friendly case. In the entire measurement, across every cell accepted by 200 different particles, **not one cell reached $b_{\max}/s = 1.25$**, never mind the worst case of $1.73$.

The expansion parameter itself tells the same story more directly. Plotting $b_{\max}/d$ over the accepted cells:

* the worst-case bound $\sqrt3\,\theta$ reaches 1 at $\theta = 0.577$, as it must, by construction;
* the **largest** $b_{\max}/d$ the tree actually produces anywhere climbs far more slowly, and only reaches 1 near $\theta \approx 0.83$;
* the **ordinary** cell is nowhere near trouble at all. Its $b_{\max}/d$ is still only $0.38$ at $\theta = 1$.

\tip{
    So $\theta \le 1/\sqrt3$ is a true statement about the worst cell that geometry permits, and for a real cluster it is conservative by about $40\%$. It is still a threshold, and $\theta=1$ is still on the wrong side of it. The number to actually remember is the measured one, $\theta \approx 0.83$, because that is where the first genuinely divergent cell appears in this tree.
}

And $0.83$ earns its keep. In [part 6](/Pages/Physics/papers/hernquist1987/06_beyond/#making_a_tree_code_misbehave_on_purpose) I build a deliberately awkward configuration, a big cluster with a small compact satellite sliding across cell boundaries, and ask when particles start getting badly wrong forces. Nothing at all goes wrong up to $\theta = 0.7$. The first bad particles appear near $\theta = 0.9$, just above the measured crossing, and by $\theta = 1.3$ the worst particle is wrong by $242\%$.

\note{
    Losing a guarantee is not the same as failing immediately, and that gap is where all the practical confusion lives. Between $\theta = 0.577$ and $\theta \approx 0.83$ the formal protection is gone but every cell in my tree still happens to be fine. Between $0.83$ and $0.9$ divergent cells exist but no particle is badly hurt by one. Past that, they are. **The danger is never the average cell. It is the unusual one**, and an average error cannot see it, which is the whole subject of [part 4](/Pages/Physics/papers/hernquist1987/04_results/#what_the_average_error_is_hiding).
}

## What each term is actually seeing

Before leaving the expansion, it is worth asking what the terms *mean* operationally, because that tells you when each one is needed and when it is wasted. The cleanest way I found is an experiment you can do in twenty lines.

Build three cells that the monopole **cannot possibly tell apart**: same total mass, same centre of mass, same cell. Then look at how wrong each approximation is.

~~~
<div style="max-width:620px;margin:1.5rem auto">
<svg viewBox="0 0 620 215" xmlns="http://www.w3.org/2000/svg" style="width:100%;height:auto">
  <!-- round -->
  <rect x="15.0" y="20.0" width="150.0" height="150.0" fill="#4C8DF6" fill-opacity="0.05" stroke="#4C8DF6" stroke-width="1.1"/>
  <circle cx="71.7" cy="122.9" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="86.1" cy="65.0" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="69.7" cy="84.4" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="98.0" cy="72.1" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="98.9" cy="89.2" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="69.9" cy="118.7" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="108.3" cy="72.4" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="74.3" cy="96.7" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="85.2" cy="90.2" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="54.3" cy="98.1" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="77.9" cy="61.8" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="60.5" cy="80.3" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="119.1" cy="72.4" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="72.0" cy="129.4" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="90.8" cy="126.5" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="91.6" cy="113.8" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="125.8" cy="88.1" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="104.5" cy="97.9" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="110.3" cy="105.9" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="56.2" cy="93.2" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="95.8" cy="95.2" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="93.4" cy="74.0" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="85.6" cy="102.0" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="121.9" cy="115.8" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="84.9" cy="91.7" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="105.4" cy="90.3" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="92.7" cy="116.7" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="59.3" cy="80.9" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="112.8" cy="112.7" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="123.1" cy="91.7" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <!-- elongated -->
  <rect x="215.0" y="20.0" width="150.0" height="150.0" fill="#4C8DF6" fill-opacity="0.05" stroke="#4C8DF6" stroke-width="1.1"/>
  <circle cx="291.5" cy="87.3" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="247.6" cy="100.3" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="251.4" cy="100.7" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="316.7" cy="99.8" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="231.2" cy="101.0" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="260.4" cy="95.6" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="288.5" cy="85.4" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="276.0" cy="98.2" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="258.3" cy="86.2" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="273.1" cy="104.8" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="304.0" cy="97.9" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="252.5" cy="91.8" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="263.5" cy="92.4" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="233.6" cy="98.2" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="270.9" cy="97.5" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="317.0" cy="103.6" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="324.0" cy="96.2" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="260.6" cy="85.9" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="259.7" cy="85.5" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="325.3" cy="90.9" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="347.5" cy="90.0" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="331.1" cy="94.3" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="302.5" cy="90.8" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="301.6" cy="100.7" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="325.3" cy="101.2" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="320.4" cy="95.3" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="275.6" cy="87.7" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="348.6" cy="101.4" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="298.1" cy="87.6" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="343.3" cy="101.7" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <!-- lopsided -->
  <rect x="415.0" y="20.0" width="150.0" height="150.0" fill="#4C8DF6" fill-opacity="0.05" stroke="#4C8DF6" stroke-width="1.1"/>
  <circle cx="504.7" cy="91.1" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="474.7" cy="95.3" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="513.6" cy="119.5" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="488.9" cy="81.7" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="513.9" cy="91.2" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="519.3" cy="94.2" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="504.8" cy="96.9" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="511.4" cy="92.7" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="525.6" cy="118.1" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="483.9" cy="120.1" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="541.0" cy="80.0" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="500.8" cy="77.6" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="493.8" cy="114.7" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="465.9" cy="85.6" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="515.0" cy="64.0" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="501.6" cy="114.0" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="474.3" cy="71.4" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="522.6" cy="89.3" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="537.6" cy="98.8" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="526.9" cy="94.9" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="503.2" cy="88.5" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="525.2" cy="97.5" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="483.6" cy="75.1" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="478.3" cy="101.1" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="422.9" cy="100.6" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="442.7" cy="91.3" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="433.3" cy="100.9" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="432.0" cy="96.2" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="422.2" cy="99.2" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <circle cx="436.3" cy="108.6" r="2.6" fill="#3A3F45" fill-opacity="0.85"/>
  <path d="M84,95 L96,95 M90,89 L90,101" stroke="#E5646E" stroke-width="2"/>
  <text x="90" y="192" fill="#8A8F98" font-size="13" text-anchor="middle">(a) round</text>
  <path d="M284,95 L296,95 M290,89 L290,101" stroke="#E5646E" stroke-width="2"/>
  <text x="290" y="192" fill="#8A8F98" font-size="13" text-anchor="middle">(b) a bar</text>
  <path d="M484,95 L496,95 M490,89 L490,101" stroke="#E5646E" stroke-width="2"/>
  <text x="490" y="192" fill="#8A8F98" font-size="13" text-anchor="middle">(c) lopsided</text>
  <text x="310" y="212" fill="#8A8F98" font-size="12" text-anchor="middle">same total mass, same centre of mass (the red cross): the monopole cannot tell them apart</text>
</svg>
</div>
~~~

* **(a) round.** A roughly spherical cloud. By Newton's shell theorem this should pull almost exactly like a point mass, so there is nearly nothing for the higher terms to do.
* **(b) a bar.** Stretched along one axis. This is a pure quadrupole shape: it is symmetric under $\vec s \to -\vec s$, so its third moment vanishes.
* **(c) lopsided.** A heavy clump on one side and a light one on the other, placed so that the centre of mass is still dead centre. This is the shape a quadrupole **cannot** describe.

The measured force error at $s/d = 0.5$, averaged over 240 directions:

| cell | monopole | + quadrupole | + octupole | $\lVert\mathbf{Q}\rVert$ |
| --- | --- | --- | --- | --- |
| (a) round | $0.34\%$ | $0.043\%$ | $0.0063\%$ | $0.026$ |
| (b) bar | $2.43\%$ | $0.087\%$ | $0.074\%$ | $0.124$ |
| (c) lopsided | $2.26\%$ | $0.268\%$ | $0.092\%$ | $0.121$ |

Read the bottom two rows together, because that is where the lesson is.

The bar and the lopsided cell have **almost the same quadrupole**, $0.124$ against $0.121$, and almost the same monopole error, $2.4\%$ against $2.3\%$. Yet the quadrupole fixes the bar by a factor of **28** and the lopsided cell by a factor of only **8**. Adding the octupole then does nothing more for the bar (a factor $1.2$) and another factor of **3** for the lopsided one.

\note{
    The reason is parity, and it is a one-line argument. $Q_{ij} \propto s_is_j$ is **even** under $\vec s \to -\vec s$. So a quadrupole physically cannot tell a heavy clump on the right from a heavy clump on the left: swap them and every $Q_{ij}$ is unchanged. Only an **odd** term can see lopsidedness, the dipole is the first odd term and we deliberately killed it by expanding about the centre of mass, so the octupole is the first odd term that survives. That is the entire job of the $n=3$ term.
}

This is the same ladder as in electrostatics, and it has the same structure everywhere it appears: each term describes a finer feature of the shape than the one before, and **each term is blind to whatever first appears at the next order**. The monopole cannot see position, the dipole cannot see elongation, the quadrupole cannot see lopsidedness. Since every new term costs memory and arithmetic, where to stop is a question of economics and not of principle, and [part 6](/Pages/Physics/papers/hernquist1987/06_beyond/#but_is_it_worth_it) answers it with a cost-accuracy frontier.

## Building $\mathbf{Q}$ for every cell, cheaply

There is a practical problem left. Every cell in the tree needs its own $\mathbf{Q}$, and computing each one directly from its particles would cost $O(N\log N)$ per level. Wasteful.

The fix is a **parallel-axis theorem** for the quadrupole. A parent cell's $\mathbf{Q}$ can be assembled from its children's, and the paper gives it as eq. (2.5):

$$
\mathbf{Q} = \sum_{l}\mathbf{Q}_l + \sum_{l}m_l\left(3\vec R_l\vec R_l - R_l^2\mathbf{1}\right)
$$

where $l$ runs over the subcells, $m_l$ is the subcell's mass and $\vec R_l$ is the offset of subcell $l$'s centre of mass from the parent's.

Deriving it is worth the five minutes, because the cancellation that makes it work is the same one that killed the dipole. Take a particle $k$ in subcell $l$. Its position relative to the *parent's* centre of mass is

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
\underbrace{\mathbf{Q}_l}_{\text{its own internal shape}} \;+\; \underbrace{m_l\left(3R_{l,i}R_{l,j} - R_l^2\delta_{ij}\right)}_{\text{subcell treated as a point mass}}
$$

Now sum this over the subcells $l$. The two pieces can be collected separately, which gives

$$
\mathbf{Q} = \sum_{l=1}^{n_{\text{subcell}}}\mathbf{Q}_l + \sum_{l=1}^{n_{\text{subcell}}}m_l\left(3\vec R_l\vec R_l - R_l^2\mathbf{1}\right)
$$

and that is the paper's eq. (2.5), character for character.

\note{
    The two lines look different only because of notation. $3\vec R_l\vec R_l$ is the **outer product** of $\vec R_l$ with itself, whose $ij$ component is $R_{l,i}R_{l,j}$, and $\mathbf 1$ is the identity matrix, whose $ij$ component is $\delta_{ij}$. Written out component by component the paper's line and mine are the same nine numbers.
}

\note{
    Notice this is the *same* cancellation that killed the dipole: the linear moment $\sum m\vec y$ vanishes when measured from a centre of mass. It does double duty, once to buy an extra order of accuracy and once here to make the recursion clean. If the tree stored geometric cell centres instead, neither would work.
}

It is also exactly the parallel-axis theorem you met for moments of inertia in mechanics, $I = I_{\text{cm}} + Md^2$: a "shape about its own centre" piece plus a "point mass displaced" piece. Same algebra, same reason.

The shift is not optional, and it took me a moment to see why. Every cell needs its moments **about its own centre of mass**, because that is what made the dipole vanish. But a parent's centre of mass is not any of its children's, so a child's stored numbers are simply the wrong numbers for the parent and have to be translated first. The alternative is to recompute each cell's moments from its own particles, which costs $O(n)$ for a cell of $n$ particles and $O(N\log N)$ over the whole tree, as expensive as the force calculation it was meant to accelerate. With the shifting rule a parent is built from its eight children in constant time, so the whole tree's moments are filled in with a single bottom-up sweep costing $O(N)$ in total:

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
    This recursion is the easiest place in the whole code to make a silent mistake, because a wrong $\mathbf{Q}$ still produces plausible-looking forces. My test suite checks it by building the tree and then comparing the **root** node's quadrupole against a brute-force sum over all $N$ particles. The root never sees a particle directly, since it only ever adds up its eight children, so if the recursion is wrong at any level the root will be wrong. It agrees to $10^{-10}$, and the trace comes out zero to the same precision.
}

## Why this gives $N\log N$

Stand on a rooftop and look at a city. The houses on your own street you see one by one; a few streets away you see blocks; further out, neighbourhoods; on the horizon, one smudge. Now count how many *things* you are looking at in each of those bands. It is roughly the same number in each, because things further away are bigger but subtend the same angle.

\note{
    A tree walk is exactly this. Each level of the tree is one band of distance, and each contributes about the same number of terms. Making the city ten times bigger does not multiply your work by ten, it just adds a couple more bands on the horizon. That is the whole reason the method is $N\log N$ instead of $N^2$.
}

Now the counting argument. It came out less obvious than I expected, so I am doing it slowly.

Fix one particle and walk down the tree level by level. At level $\ell$, cells have size

$$
s_\ell = \frac{L}{2^\ell}
$$

where $L$ is the size of the root cell. A cell at that level is **accepted** when $s_\ell/d < \theta$, i.e. when its distance satisfies $d > s_\ell/\theta$, and it is **opened** otherwise. So the cells actually used at level $\ell$ are those which are accepted while their parent was not. Parents live at level $\ell-1$ with size $2s_\ell$, and were opened when $d < 2s_\ell/\theta$. The cells contributing terms at level $\ell$ therefore sit in the spherical shell

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

**The $s_\ell$ has cancelled completely.** Every level of the tree contributes the same number of terms, controlled only by $\theta$. Which is the crux: doubling the resolution adds one more level, and one more level costs a constant.

The tree has $\sim\log_8 N$ levels, so

$$
n_{\text{terms}} \sim \frac{28\pi}{3\theta^3}\log_8 N = C(\theta)\log N \quad\Longrightarrow\quad \text{total cost} \sim N\log N
$$

\tip{
    The estimate also predicts the *strength* of the $\theta$ dependence: $n_\text{terms}\propto\theta^{-3}$. Testing that at $N=32768$, going from $\theta=1$ to $\theta=0.5$ should cost a factor $2^3 = 8$, and I measure $1049/219 = 4.8$. So the scaling **with $N$** is right and the scaling **with $\theta$** is not. For a long time I wrote that off as "real cells are not uniformly distributed, so what do you expect". That was lazy: the discrepancy is a factor of nearly two and it has a clean explanation with no free parameters in it. [The next section](#a_better_count) does it properly.
}

That is the entire promise of the method, and it makes a sharp prediction I can test: **doubling $N$ should add a constant amount to $n_{\text{terms}}$, not double it.** My measurement, at $\theta = 1$:

| $N$ | $\langle n_\text{terms}\rangle$ | change |
| --- | --- | --- |
| 1024 | 124.0 | |
| 2048 | 150.8 | +26.8 |
| 4096 | 171.5 | +20.7 |
| 8192 | 191.5 | +20.0 |
| 16384 | 205.3 | +13.8 |
| 32768 | 217.6 | +12.3 |

Compare with the direct sum, where the same column would read 1023, 2047, 4095, 8191, 16383, 32767. Thirty-two times more particles cost me 1.75 times more work per particle. That is the whole game.

## A better count

So the shell argument gets the growth with $N$ right and the dependence on $\theta$ badly wrong. That bothered me for a long time and I want to fix it properly, because a factor of two in the cost of a simulation is not a rounding error, and because "real cells are not uniform, so what do you expect" is not an explanation, it is an excuse.

Go back and look at what the shell count quietly assumed. **The cluster is infinite, and every cell is full.** Neither is true, and each failure bites at a different end of the range.

* **A cell has to be inside the cluster.** The accepted cells of width $s$ live in a shell at distances $s/\theta$ to $2s/\theta$. For small $\theta$, and for the big cells near the top of the tree, that shell is pushed out beyond the edge of the cluster, where there is nothing to count. The volume is there; the matter is not. **This kills the largest cells.**
* **A cell has to contain particles.** Down at the bottom of the tree, cells are much smaller than the mean spacing between particles, so most of them are empty, and an empty cell contributes nothing and costs nothing. **This kills the smallest cells.**

The crude count includes both populations at full strength. That is why it overestimates, and why it overestimates worst at small $\theta$, where the shells are furthest out.

### Putting both cut-offs in

Write $W(d)$ for the **average volume of the system lying within a distance $d$ of one of its own particles**. This is the quantity that knows about the edge: for small $d$ it is just $\tfrac43\pi d^3$, and once $d$ is bigger than the system it saturates at the system's whole volume. Then the shell around a target particle contains

$$
\frac{W(2s/\theta) - W(s/\theta)}{s^3}
$$

cells rather than $28\pi/3\theta^3$ of them, and of those, the fraction that actually hold anything is

$$
1 - e^{-\rho s^3}
$$

with $\rho$ the number density: the Poisson probability that a box of volume $s^3$ is not empty. Summing over the levels, with $s_\ell = L/2^\ell$,

$$
\boxed{\;\left\langle n\right\rangle = \sum_\ell \frac{W(2s_\ell/\theta) - W(s_\ell/\theta)}{s_\ell^3}\left(1 - e^{-\rho s_\ell^3}\right)\;}
$$

\note{
    **Nothing in that formula is fitted.** There is no free parameter anywhere in it. $W$ is geometry, $\rho$ is the density of the model I am simulating, and the sum runs over the levels the tree actually has. That matters, because a two-parameter fit to a curve is not an explanation of anything.
}

For a uniform ball of radius $R$ the overlap volume is known in closed form, and I got it out of a computer algebra system rather than trusting an integral I did by hand:

$$
W(d) = \frac{\pi d^3\left(d^3 - 18dR^2 + 32R^3\right)}{24R^3}\quad (0<d<2R),
\qquad
W(d) = \frac{4\pi}{3}R^3 \quad (d\ge 2R)
$$

Two limits check it. For $d\ll R$ the bracket is dominated by $32R^3$ and $W\to \tfrac43\pi d^3$, which is a whole ball, as it should be when the sphere of radius $d$ is entirely inside the system. At $d=2R$ the bracket gives $4R^3$ and $W\to\tfrac43\pi R^3$, the whole system, as it must be once you can reach everything from anywhere.

For a centrally concentrated model like Plummer, $\rho$ varies from place to place, so the occupancy factor has to stay **inside** the integral instead of coming out as a constant, and the answer has to be averaged over where the target particle sits. That one is done numerically.

### Does it work?

Here is the whole comparison at $N = 32768$ for the truncated Plummer sphere. The last column is the crude shell count for reference:

| $\theta$ | measured $\langle n\rangle$ | this model | ratio | crude count |
| --- | --- | --- | --- | --- |
| $0.15$ | $11160$ | $11073$ | $0.99$ | $43439$ |
| $0.18$ | $8434$ | $8324$ | $0.99$ | $24848$ |
| $0.20$ | $7235$ | $7112$ | $0.98$ | $18801$ |
| $0.24$ | $5190$ | $5035$ | $0.97$ | $10753$ |
| $0.29$ | $3560$ | $3379$ | $0.95$ | $6150$ |
| $0.35$ | $2360$ | $2177$ | $0.92$ | $3521$ |
| $0.42$ | $1557$ | $1388$ | $0.89$ | $2015$ |
| $0.50$ | $1035$ | $877$ | $0.85$ | $1152$ |
| $0.61$ | $677$ | $537$ | $0.79$ | $659$ |
| $0.73$ | $427$ | $326$ | $0.76$ | $377$ |
| $0.88$ | $279$ | $200$ | $0.71$ | $216$ |
| $1.06$ | $198$ | $122$ | $0.62$ | $124$ |

Summarised honestly, with **means and worst cases**, because a mean on its own always flatters:

| | mean error | worst |
| --- | --- | --- |
| Plummer, $\theta\le0.5$ | $5.1\%$ | $12.8\%$ |
| Plummer, $0.15\le\theta\le1$ | $12.1\%$ | $32.9\%$ |
| uniform sphere, $\theta\le0.5$ | $11.0\%$ | $15.7\%$ |
| uniform sphere, $0.15\le\theta\le1$ | $17.2\%$ | $25.9\%$ |

And it catches most of the curvature the crude rule misses. Fitting a power law to each over $0.15\le\theta\le1$:

| | effective exponent |
| --- | --- |
| measured | $\theta^{-2.14}$ |
| this model | $\theta^{-2.34}$ |
| crude shell count | $\theta^{-3.00}$ |

### What that buys you in practice

The point of having a model is to stop being surprised, so here are the statements it lets me make, all of them measured on the real tree at the exact $\theta$ values quoted:

* Take the $\theta^{-3}$ law, anchor it to the **measured** count at $\theta=1$, and carry it down to $\theta = 0.15$. It predicts $64800$ terms per particle. The truth is $11160$. It overpredicts the work by a factor of $\mathbf{5.8}$.
* Going from $\theta = 0.50$ to $\theta = 0.20$, a strict $\theta^{-3}$ law demands a factor of $15.6$ more work. The measured factor is $\mathbf{6.8}$.
* **Halving $\theta$ costs four to five times more work, not eight.** Measured across the range, the halving factor runs from $3.4$ (going $0.30\to0.15$) to $5.0$ (going $0.80\to0.40$), with $4.8$ for $1.0\to0.5$.

\tip{
    That last one is the practically useful number, and it is good news. Everybody's mental model is "halving $\theta$ costs eight times more", which makes accuracy sound unaffordable. It is really four to five times, because by then a good part of the tree has simply run out of useful cells to give you.
}

This is not just my machine being odd, either. Khandai and Bagla, tuning a TreePM code, report about $500\%$ more CPU time for exactly that change of $\theta$ at $N\approx10^4$, which is a factor of six and sits right on top of my $6.8$.

### Where it fails, and why

The model gives up near $\theta \approx 1$, where the ratio falls to $0.62$, and the reason is structural rather than fixable. At $\theta = 1$ the acceptance shell runs from $d = s$ to $d = 2s$, so it is **thinner than one cell is wide**. Counting cells by dividing a volume by $s^3$ stops meaning anything when the region is not several cells thick, and no amount of care with $W(d)$ will repair that. It is a continuum argument being asked a discrete question.

\note{
    Which is a good general warning about this style of estimate. The counting model works precisely where the crude one fails, at small $\theta$ where there are many thin shells full of many small cells, and it fails precisely where the crude one accidentally works, at large $\theta$ where the shells are one cell thick and the two errors happen to cancel. Neither is a substitute for measuring.
}

### The growth with $N$ is the easy half

None of this trouble touches the scaling with $N$, and it is worth seeing why. **Changing $N$ at fixed $\theta$ does not move either cut-off.** The cluster is the same size, so the edge is where it was; adding particles only fills in cells that were previously empty, which is what "one more level of tree" means. So the crude constant-per-level argument should survive, and it does.

One doubling of $N$ adds a third of a level to an octree, so the prediction is

$$
\Delta\langle n\rangle = \frac{1}{3}\cdot\frac{28\pi}{3\theta^3} = \frac{28\pi}{9\theta^3}
$$

extra terms per doubling. Measured all the way to $N = 2^{20}$, which is thirty-two times the largest run in the paper:

| $\theta$ | predicted $28\pi/9\theta^3$ | measured, mean over five doublings |
| --- | --- | --- |
| $1.0$ | $9.8$ | $11.2$ |
| $0.7$ | $28.5$ | $32.6$ |
| $0.5$ | $78.2$ | $93.0$ |

Good to about $15\%$, from an argument that consists of dividing the volume of a shell by the volume of a cube. [Part 6](/Pages/Physics/papers/hernquist1987/06_beyond/#a_million_particles) has the run.

## What one particle actually sees

The average hides a lot of structure. Below is the full distribution of $n_\text{terms}$ across all 32768 particles, for the Plummer model and for a uniform sphere with the same $N$. This is the paper's Fig. 5:

\fig{/assets/Physics/papers/hernquist1987/nterms_hist}

Left to right is how many terms one particle had to add up, and the height is how many of the 32768 particles needed that many. The peak is narrow, so almost everybody does a similar amount of work, and the tail on the left is the halo particles who get off cheap.

Two things stand out, and both are physics rather than numerics.

The uniform sphere gives a **tight, symmetric** distribution centred on 122. Every particle sits in a similar neighbourhood, so every particle does a similar amount of work.

The Plummer model is centred higher (218) and has a long **tail towards smaller values**. The reason becomes obvious when you plot $n_\text{terms}$ against radius:

\fig{/assets/Physics/papers/hernquist1987/nterms_radius}

Distance from the centre goes right, work done goes up, one dot per particle. Particles in the crowded middle do the most work and particles in the empty halo do the least, which is exactly where the effort should go.

The reason is the geometry overhead. A halo particle has a shallow tree above it and the whole cluster sitting far away, so a handful of big cells covers everything. A core particle has many levels of subdivision right next to it, and every one of those levels has to be opened.

My numbers here are $217.6$ and $122.2$; the paper reports $221$ and $121$. Given that this is a completely independent implementation from a written description, I am happy with that.

## One trap: a particle pulling on itself

There is a subtle bug the paper warns about in section II. It is invisible unless you go looking for it.

Consider a particle sitting near the **edge** of a large cell that it is itself inside. The cell's centre of mass could be at the far edge, so $d$ is large-ish and $s/d < \theta$ might be satisfied. For $\theta \gtrsim 1$ this really can happen. The walk then accepts the cell as a single lump, but the particle's own mass is part of that lump. **The particle exerts a force on itself.**

The fix is a geometric check: if the particle lies inside the cell, always open it, regardless of $s/d$.

```julia
opened = d2 <= 0 || s * s >= theta2 * d2
if !opened && forced_subdivision
    opened = inside_cell(t, node, pos[1, i], pos[2, i], pos[3, i])
end
```

I have this on by default. The paper investigates it and finds the effect negligible for $\theta \lesssim 1.2$, which matches what I see, but it costs almost nothing to be correct.

## The walk, in full

Putting it all together, here is the complete force calculation for one particle, the piece of code that dominates the entire runtime:

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
    **The one test that matters.** Set $\theta = 0$. Then $s^2 \ge 0 = \theta^2 d^2$ is true for every cell, so *nothing* is ever accepted and the walk descends all the way to individual particles. It must reproduce the direct $O(N^2)$ sum exactly. My test suite checks this for $N = 2000$ and gets agreement to $10^{-10}$ of the largest acceleration. If a tree code passes this, the tree structure and the walk logic are both correct, leaving only the multipole terms to be checked separately.
}

## What softening does to the expansion

Now a correction to something I had wrong for a long time, and which turned out to be much more interesting than the thing I thought I was right about.

Look at the softening in the quadrupole branch of that code. Every $r^n$ has become $(r^2+\varepsilon^2)^{n/2}$. Hernquist calls this an *ad hoc* softening of the quadrupole terms, and I used to write that my version was better because it is "exactly $-\nabla$ of a consistently softened quadrupole potential".

Half of that is true. Write $\tilde r = \sqrt{d^2+\varepsilon^2}$ and notice that $\partial_k \tilde r = d_k/\tilde r$, which is the same form as $\partial_k d = d_k/d$. So the whole gradient calculation from earlier goes through unchanged with $d\to\tilde r$ in the denominators, and the substituted acceleration really is exactly minus the gradient of the substituted potential. It is a consistent pair.

What it is **not** is the multipole expansion of the softened force law. And those are different things.

### Doing it properly

The softened kernel is

$$
K(\vec x) = \frac{1}{\sqrt{|\vec x|^2+\varepsilon^2}}
$$

and the multipole expansion of a cell is just the Taylor series of $K$ in the source position. So the dipole still dies, for exactly the reason it always dies, $\sum_\alpha m_\alpha\vec s_\alpha = 0$. The quadrupole term needs the second derivative, and that is a short calculation:

$$
\partial_i K = -\frac{x_i}{(x^2+\varepsilon^2)^{3/2}},
\qquad
\partial_i\partial_j K = \frac{3x_ix_j - \delta_{ij}\left(x^2+\varepsilon^2\right)}{\left(x^2+\varepsilon^2\right)^{5/2}}
$$

Contracting with the **raw** second moment $M^{(2)}_{ij} = \sum_\alpha m_\alpha s_is_j$ gives the exact softened quadrupole term:

$$
\boxed{\;\varphi_2^{\,\varepsilon}
= -\frac{G}{2}\,
\frac{3M^{(2)}_{ij}d_id_j - \left(d^2+\varepsilon^2\right)\operatorname{tr}\mathbf{M}^{(2)}}
{\left(d^2+\varepsilon^2\right)^{5/2}}\;}
$$

Now compare it with the substituted version. The substituted one is built from the traceless $\mathbf Q$, so writing $Q_{ij} = 3M^{(2)}_{ij}-\delta_{ij}\operatorname{tr}\mathbf M^{(2)}$ and contracting,

$$
\vec d\cdot\mathbf{Q}\cdot\vec d = 3M^{(2)}_{ij}d_id_j - d^2\operatorname{tr}\mathbf{M}^{(2)}
$$

The two expressions are **identical except that one carries $d^2$ where the other carries $d^2+\varepsilon^2$**, and only in the trace piece. Subtracting, the entire difference is one term:

$$
\varphi_2^{\,\varepsilon} - \varphi_2^{\,\text{substituted}}
= \frac{G\,\varepsilon^2\operatorname{tr}\mathbf{M}^{(2)}}{2\left(d^2+\varepsilon^2\right)^{5/2}}
$$

### Why the trace suddenly matters

The reason that term exists at all is a nice piece of physics rather than an algebraic accident, and it connects straight back to [part 1](/Pages/Physics/papers/hernquist1987/01_setup/#the_plummer_model).

For the Newtonian kernel, $\nabla^2(1/r) = 0$ everywhere away from the origin. The kernel is **harmonic**. That is precisely why the trace of the second moment drops out of the potential: adding any multiple of $\delta_{ij}$ to $M^{(2)}_{ij}$ changes nothing, so only the five traceless combinations can ever appear, and $\mathbf Q$ is built to be traceless for that reason.

The softened kernel is not harmonic. Take its Laplacian:

$$
\nabla^2 K = -\frac{3\varepsilon^2}{\left(d^2+\varepsilon^2\right)^{5/2}}
$$

\note{
    Stare at the right-hand side for a moment. It is $-4\pi\rho_\varepsilon$, where
    $$
    \rho_\varepsilon(d) = \frac{3}{4\pi}\frac{\varepsilon^2}{\left(d^2+\varepsilon^2\right)^{5/2}}
    $$
    is a **unit-mass Plummer sphere of scale length $\varepsilon$**. So $\Phi = -GmK$ satisfies Poisson's equation exactly, with a Plummer sphere as its source. This is the same observation from part 1, that a softened point mass *is* a Plummer sphere, coming back with a job to do: it is the reason the trace survives.
}

Once the kernel has a source sitting on top of the field point, the trace no longer drops out, and **all six components of $\mathbf{M}^{(2)}$ are needed, not the five that survive in $\mathbf{Q}$**. That has a concrete consequence for the code. The traceless $\mathbf{Q}$ has thrown the trace away by construction, so you cannot rebuild the exact softened term from a stored $\mathbf{Q}$, no matter how many numbers you kept. The tree has to carry the **raw** second moment $\mathbf{M}^{(2)}$ separately, which mine does, alongside the raw third moment it needs for the octupole shift anyway. It is one more instance of the rule that runs through the whole implementation: keep the books in raw moments, and take traces at the last possible moment.

### How much does it actually matter?

Very little at sensible settings, which is why the historical prescription has survived. Compare the missing term to the monopole:

$$
\frac{\left|\varphi_2^{\,\varepsilon}-\varphi_2^{\,\text{substituted}}\right|}{\left|\varphi_0\right|}
= \frac{\varepsilon^2\left\langle s^2\right\rangle}{2\left(d^2+\varepsilon^2\right)^2}
$$

It dies as $(\varepsilon/d)^2$, so it can only become visible for a cell accepted at a distance comparable to the softening length, and a cell that close is almost always opened instead. I measured the ratio across two decades in $\varepsilon/d$ at fixed $s/d=0.25$ and it sits flat at $0.436$ of that scale, with a fitted slope of $1.94$ against the predicted $2$.

But "very little" is not "nothing", and the sign is in our favour. I implemented the exact term as well and evolved the same softened cluster both ways, $N=4096$, $\theta=1$, $\varepsilon=0.031$, 1000 steps:

| quadrupole prescription | $\Delta E/E$ after 1000 steps |
| --- | --- |
| historical substitution (what the paper does, and what I do by default) | $0.685\%$ |
| exact softened quadrupole (the extra trace term restored) | $0.496\%$ |
| Hernquist's quoted value for the comparable run | $0.68\%$ |
| **no softening at all**, $\varepsilon = 0$ | $\mathbf{620\%}$ |

\tip{
    Three things fall out of that table. My default agrees with the paper to better than a percent, which is the check that mattered. Restoring the exact term is a real $28\%$ improvement in energy conservation for no extra memory, since the raw moments were being carried anyway. And the last row is the one to keep in mind: whatever we are arguing about here is a $30\%$ effect sitting on top of a **factor of a thousand** that softening itself is buying.
}

\prob{
    Show that replacing $d$ by $\sqrt{d^2+\varepsilon^2}$ in the *potential* and then differentiating gives the same thing as replacing it in the *acceleration* directly, but that neither equals the Taylor expansion of the softened kernel. Then work out at what $d/\varepsilon$ the missing trace term reaches one per cent of the monopole, and check whether the opening test would ever accept a cell at that distance.
}

## Where we are

We now have the complete method:

1. Build an octree over the particles, $O(N\log N)$, done once per step.
2. Fill in mass, centre of mass and quadrupole for every cell by a bottom-up sweep, $O(N)$.
3. For each particle, walk the tree accepting cells with $s/d < \theta$, $O(\log N)$ each.
4. Push everything forward with leapfrog.

The next part is the payoff: does it actually behave the way the counting argument says, and how wrong are the forces?

---

**Previous:** [Part 2, moving the particles](/Pages/Physics/papers/hernquist1987/02_leapfrog/)\\
**Next:** [Part 4, results](/Pages/Physics/papers/hernquist1987/04_results/)

Hope this helps you in some way. If you like it then share with others if possible.

If you have some queries, do let me know in the comments or contact me using the informations that are given on the page [About Me](/Pages/about_me/).

~~~
<button onclick="window.history.back()">Go Back</button>
~~~
