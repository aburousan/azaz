+++
title = "Renormalisation Group III: Block Spins"
hascode = true
date = Date(2026, 9, 19)
rss = "Part 3 of the renormalisation group course. Kadanoff's block-spin idea done exactly on a line of spins, explained as a game of telephone: the recursion tanh K' = tanh^2 K, fixed points and a correlation length that never changes when you measure it properly. With an interactive widget."
rss_title = "Renormalisation Group III: Block Spins"
rss_pubdate = Date(2026, 9, 19)

tags = ["physics", "statistical-mechanics", "renormalization", "ising", "course"]
+++

\newcommand{\dd}{\mathrm d}

~~~
<link rel="stylesheet" href="/assets/Physics/courses/RG/rg.css">
<script defer src="/assets/Physics/courses/RG/rg.js"></script>
~~~

\toc

# Renormalisation Group III: Block Spins

> *Part 3 of eight. previous: [Loops, infinities and cutoffs](/Pages/Physics/courses/RG/02_toolkit/) · [Course home](/Pages/Physics/courses/RG/Main_page/) · [Glossary](/Pages/Physics/courses/RG/glossary/) · next: [Fixed points and universality](/Pages/Physics/courses/RG/04_fixed_points/)*

Part 1 said the numbers in a theory depend on the resolution you describe it at. This part makes that concrete with a system so simple you can coarse-grain it exactly on paper. No field theory is needed at all.

## The Ising model

Put a tiny magnet, a **spin**, on each site of a lattice. Each spin points either up ($s_i=+1$) or down ($s_i=-1$). Neighbouring spins prefer to point the same way, so the energy is

$$ E = -J\sum_{\langle ij\rangle} s_i s_j , $$

summed over neighbouring pairs, with $J>0$. At temperature $T$, a configuration appears with probability proportional to $e^{-E/k_BT}$. Only the combination $K\equiv J/k_BT$ ever matters, so we call $K$ the **coupling**. Large $K$ means cold, so the spins line up. Small $K$ means hot, so they point every which way.

\puja{
Every spin in the Ising model has a coupling $K$ to its neighbours. That's already more coupling than some readers will manage this Puja, doing pandal hopping alone with only a plate of phuchka for company.
}

\analogy{
Tong describes this as a story with rival characters. The coupling $J$ wants every spin to agree with its neighbours, which is order. Temperature wants to mess everything up, because there are vastly more messy arrangements than tidy ones, which is chaos (entropy). Which side wins depends on $K$ and at a critical point they're perfectly balanced.
}

Everything we might want to know follows from the **partition function**, the sum of the weights of all configurations:

$$ Z(K) = \sum_{\{s\}} \exp\Big(K\sum_{\langle ij\rangle}s_is_j\Big). $$

If you know QFT, this is a path integral. The "field" is the set of spins, the "action" is $-K\sum s_is_j$ and summing over all configurations is integrating over all field histories. So coarse-graining this model is the lattice version of integrating out short-distance modes.

## Kadanoff's idea: vote in blocks

In 1966 Leo Kadanoff noticed something simple. Near the critical point, spins agree with each other over long distances, so a small block of neighbours mostly points the same way. So replace each block by one "block spin" that points the way the majority of its members point. The result is a lattice with fewer spins and a bigger spacing and it *looks like another Ising model*, only with a different coupling $K'$.

~~~
<div class="mfig" style="--w:560px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/blocking_cartoon.svg" alt="Majority-rule blocking of a 9 by 9 spin lattice">
  <p>Majority-rule blocking. Each 3×3 block (dashed) is replaced by one spin that points the way most of its members point. Do it again and you have one spin. Each round loses detail. The question is what happens to the coupling between the spins that are left.</p>
</div>
~~~

\analogy{
It's like an election run in stages. Each para in Kolkata picks one person for the ward, each ward sends one to the municipal corporation and so on up to the state. At every level the representatives interact with each other, a bit like the original villagers did, but you'd expect the "strength" of the connections between them to be different at each level.
}

Blocking turns the model into itself with a new coupling. That gives a function $K' = R(K)$, the **RG map**. Applying it again and again tells us how the system looks from further and further away. In two and three dimensions majority voting can only be done approximately. In one dimension a closely related trick can be done **exactly**, so that's where we start.

## Coarse-graining a line of spins, exactly

Take an endless line of spins with coupling $K$ between neighbours. Instead of voting, use **decimation**: sum over every second spin and keep the rest. Look at one removed spin $s_2$, sitting between two survivors $s_1$ and $s_3$. It appears in exactly two bonds, so summing over its two values gives

$$ \sum_{s_2=\pm1} e^{K s_2 (s_1+s_3)} = 2\cosh\big(K(s_1+s_3)\big). $$

~~~
<div class="mfig" style="--w:560px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/decimation_1d.svg" alt="Decimation of the 1D Ising chain">
  <p>Sum over every even spin. What's left is a line of odd spins, twice as far apart, joined by a new coupling \(K'\).</p>
</div>
~~~

We want this to look like an ordinary bond between $s_1$ and $s_3$, of the form $f\,e^{K's_1s_3}$, for some new coupling $K'$ and some constant $f$. There are only two cases to check:

$$ s_1=s_3:\quad 2\cosh 2K = f\,e^{K'}, \qquad\qquad s_1=-s_3:\quad 2 = f\,e^{-K'}. $$

That's two equations for two unknowns. Dividing one by the other gives $e^{2K'}=\cosh 2K$ and multiplying them gives $f^2=4\cosh 2K$:

$$ \boxed{\;K' = \tfrac12\ln\cosh 2K \quad\Longleftrightarrow\quad \tanh K' = \tanh^2 K, \qquad f(K) = 2\sqrt{\cosh 2K}.\;} $$

The two forms of $K'$ agree because $\tanh K' = (e^{2K'}-1)/(e^{2K'}+1) = (\cosh2K-1)/(\cosh2K+1) = \sinh^2K/\cosh^2K$.

### What $\tanh K' = \tanh^2 K$ means

That second form has a lovely meaning. In a line of spins, the number $\tanh K$ measures how reliably each spin copies its neighbour. (Exactly: the average of $s_1s_2$ is $\tanh K$.)

\analogy{
Think of gossip travelling along a Kolkata lane, passed from one adda to the next, like a game of telephone. Say each person copies their neighbour correctly with a "reliability" $t=\tanh K$. Now remove every second person. The message between two survivors has to pass through two whispers instead of one, so its reliability becomes $t\times t=t^2$. That is exactly $\tanh K'=\tanh^2K$. Coarse-graining the chain is literally skipping every other person in the game of telephone.
}

Nothing was approximated here. The partition function of $N$ spins at coupling $K$ is a known factor times the partition function of $N/2$ spins at coupling $K'$:

$$ Z_N(K) = f(K)^{N/2}\, Z_{N/2}(K'). $$

That's one complete, exact RG step. Here's the check in Wolfram Language, which runs as printed:

```mathematica
dec[s1_, s3_] := Exp[K (s1 + s3)] + Exp[-K (s1 + s3)];      (* sum over s2 *)
sol = Solve[{dec[1, 1] == f Exp[Kp], dec[1, -1] == f Exp[-Kp]}, {f, Kp}];
Kp1 = Kp /. First[sol];
FullSimplify[Kp1 - Log[Cosh[2 K]]/2, K > 0]           (* -> 0 *)
FullSimplify[Tanh[Log[Cosh[2 K]]/2] - Tanh[K]^2, K > 0] (* -> 0 *)
FullSimplify[f /. First[sol], K > 0]                   (* -> 2 Sqrt[Cosh[2K]] *)
```

## Following the flow

Now repeat: $K\to K'\to K''\to\cdots$. Since $0\le\tanh K<1$, squaring always makes it smaller, so **$K$ goes down at every step**. The two ends behave very differently:

- **Small $K$ (hot).** Use the series $\tanh K = K-\tfrac13K^3+\dots$, so $\tanh^2K = K^2-\tfrac23K^4+\dots$. For a small number $y$, $\operatorname{artanh}y = y+\tfrac13y^3+\dots$ and $y^3=K^6$ is far smaller than $K^4$, so to this order $K' = \operatorname{artanh}(\tanh^2K) = K^2 - \tfrac23K^4+\dots$. Squaring a small number makes it much smaller, so $K$ shrinks to zero very fast.
- **Large $K$ (cold).** Use the other form, $K'=\tfrac12\ln\cosh2K$. For large $K$, $\cosh2K=\tfrac12(e^{2K}+e^{-2K})\approx\tfrac12e^{2K}$, so $K'\approx\tfrac12\big(2K-\ln2\big)=K-\tfrac12\ln2$. So $K$ creeps down slowly, by $\tfrac12\ln2\approx0.347$ per step.

(Both expansions were checked in Wolfram with `Series[ArcTanh[Tanh[K]^2], {K, 0, 6}]`, which gives $K^2-\tfrac23K^4+\tfrac{32}{45}K^6$.)

~~~
<div class="mfig" style="--w:600px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/flow_1d.svg" alt="The RG map of the 1D Ising chain, cobwebbed and the flow on the coupling line">
  <p>Left: the map \(K'=R(K)\) (blue) lies below the diagonal everywhere, so applying it again and again (red staircase) always walks down to \(K=0\). Right: the same thing drawn as arrows on the line of couplings. There are two <b>fixed points</b>, \(K^*=0\) and \(K^*=\infty\) and every starting point flows to the first one.</p>
</div>
~~~

\defn{
A **fixed point** of the RG is a value of the coupling that the map doesn't change: $R(K^*)=K^*$. A system sitting exactly at a fixed point looks the same at every scale.
}

\analogy{
A fixed point is like a photo of a perfectly blank wall, or of static on an old TV. Zoom out and it looks exactly the same. Most photos change when you zoom out. The special ones that don't are the fixed points.
}

The chain's two fixed points are the two ends of the temperature scale. At $K^*=0$ (infinitely hot), every spin is random, so every scale looks like noise. At $K^*=\infty$ (absolute zero), every spin agrees, so every scale looks uniform. The flow tells us that **any** chain at a nonzero temperature, seen from far enough away, looks like the infinitely hot one: disordered.

In the game of telephone, however reliable each person is, a long enough line always scrambles the message. That's the RG's way of saying the one-dimensional Ising model never becomes a magnet, which Ising proved the hard way in 1925.

## The correlation length and a small miracle

How far does order reach along the chain? Here's a neat way to find out. Instead of the spins, use the **bonds**: define $\tau_i = s_is_{i+1}$, which is $+1$ if two neighbours agree and $-1$ if they disagree. The energy is $-J\sum\tau_i$, so each bond is independent of the others, with probability proportional to $e^{K\tau_i}$. The average of one bond is therefore

$$ \langle\tau\rangle = \frac{e^{K}\cdot(+1)+e^{-K}\cdot(-1)}{e^{K}+e^{-K}} = \tanh K. $$

Now $s_0s_r = (s_0s_1)(s_1s_2)\cdots(s_{r-1}s_r) = \tau_0\tau_1\cdots\tau_{r-1}$, because each middle spin appears twice and $s_i^2=1$. Since the bonds are independent, the average of the product is the product of the averages:

$$ \langle s_0s_r\rangle = (\tanh K)^r. $$

That's the reliability multiplied $r$ times, just as in telephone. (Das derives the same result in §15.1 with the transfer matrix, if you'd like a second route.) A power like that decays as $e^{-r/\xi}$, which defines the **correlation length** in units of the lattice spacing:

$$ \xi(K) = -\frac{1}{\ln\tanh K}. $$

After one decimation the spacing between spins has doubled. A distance that used to be $2r$ steps is now only $r$ steps. So if coarse-graining keeps the physics fixed, the correlation length counted in the *new* steps must be half the old one: $\xi(K')=\xi(K)/2$. Check it: $\ln\tanh K' = \ln\tanh^2 K = 2\ln\tanh K$, so $\xi(K')=\xi(K)/2$ **exactly**.

\analogy{
A road that's 10 km long is 10,000 m long. The number changed because the unit changed, but the road didn't. Coarse-graining changes the unit of length (the lattice spacing doubles), so the correlation length *in those units* halves, but the actual distance over which spins agree doesn't change at all.
}

This is the most important equation in the course, in its simplest form. Coarse-graining throws away detail but keeps the physics, so after a step of scale factor $b$:

$$ \xi(K') = \xi(K)/b. $$

Now apply it at a fixed point, where $K'=K$. Then $\xi=\xi/b$, which only works if $\xi=0$ or $\xi=\infty$. **A fixed point has either no correlations at all or infinitely long ones.** The interesting fixed points, the ones behind phase transitions, are the infinite kind. The chain doesn't have one at any finite $K$. In two dimensions it does and that's the next part.

## Try it

The widget takes a real sample of a chain at coupling $K$. Each click keeps every second spin. The spins that survive are an exact sample of a chain at the new coupling $K'$, twice as spread out. The table tracks the coupling and both versions of the correlation length.

~~~
<div id="rg-decimate" style="--w:760px"></div>
~~~

\otaku{
Applying the RG map again and again is basically a *JoJo* stand rush: "ORA ORA ORA ORA!" Each punch is one decimation. The difference is that the chain doesn't fly off a wall at the end. It just calmly settles at $K^*=0$.
}

Start at $K=3$ and click a few times. At first $K$ hardly moves (the slow, large-$K$ end) and then it drops off a cliff. The last column, the correlation length in the original units, never changes.

## Exercises

\prob{
**3.1.** At low temperature write $w=e^{-2K}$ (so $w$ is small). Show that one decimation gives $w'\approx2w$. What does that tell you about how $\xi$ depends on $K$ when it's cold? Check it against the exact formula.
}
\soln{
From $K'\approx K-\tfrac12\ln2$ we get $e^{-2K'}=2e^{-2K}$, so $w'=2w$: doubling the length scale doubles $w$. Since $\xi$ halves when the scale doubles, $\xi\propto1/w=e^{2K}$. The exact formula agrees: $\tanh K\approx1-2e^{-2K}$, so $\ln\tanh K\approx-2e^{-2K}$ and $\xi\approx\tfrac12e^{2K}$. At $K=3$, the exact value is $201.714$ and $\tfrac12e^{6}=201.714$. The correlation length grows exponentially as the chain gets colder, never with a power law. That's another sign there's no ordinary critical point in one dimension.
}

\prob{
**3.2.** *Thermodynamics from the flow.* Let $g(K)=\lim_{N\to\infty}\frac1N\ln Z_N(K)$, the log of the partition function per spin. (It is minus the free energy per spin, measured in units of $k_BT$: $g=-f/k_BT$.) Use $Z_N(K)=f(K)^{N/2}Z_{N/2}(K')$ to show
$$ g(K) = \tfrac12\ln f(K) + \tfrac12 g(K'). $$
Repeat it forever, using $g(0)=\ln2$ (at $K=0$ each spin is free, so it contributes a factor 2). Check numerically that you get the exact answer, $g(K)=\ln(2\cosh K)$.
}
\soln{
Take logs and divide by $N$: $\frac1N\ln Z_N = \frac12\ln f + \frac12\cdot\frac{1}{N/2}\ln Z_{N/2}(K')$. Repeating gives
$g(K)=\sum_{n\ge0}2^{-(n+1)}\ln f(K_n)+\lim_n 2^{-n}g(K_n)$ and since $K_n\to0$ the last term vanishes. Summing 60 terms numerically gives $g=0.737487950486$ at $K=0.3$, $1.126928011043$ at $K=1$ and $2.506715348489$ at $K=2.5$. These match $\ln(2\cosh K)$ to all twelve digits. So the constants $f$ we kept at each step add up to the complete thermodynamics.
}

\prob{
**3.3.** Add a magnetic field, $E=-J\sum s_is_{i+1}-H\sum s_i$ and write $h=H/k_BT$. Decimate again. Now you need three constants $(f,K',h')$ and there are three separate cases, $(s_1,s_3)=(+,+),(-,-),(+,-)$. Show that
$$ e^{4K'} = \frac{\cosh(2K+h)\cosh(2K-h)}{\cosh^2 h}, \qquad e^{2h'} = e^{2h}\,\frac{\cosh(2K+h)}{\cosh(2K-h)}. $$
(This one is longer.) Where are the fixed points now?
}
\soln{
Give half of each survivor's field to each of its two bonds, so each new bond carries $e^{Ks_1s_3+\frac h2(s_1+s_3)}$. Summing over $s_2$ gives $e^{\frac h2(s_1+s_3)}\,2\cosh(K(s_1+s_3)+h)$. Matching $f\,e^{K's_1s_3+\frac{h'}2(s_1+s_3)}$ case by case:
$(+,+)$: $f e^{K'+h'} = 2e^{h}\cosh(2K+h)$; $(-,-)$: $f e^{K'-h'} = 2e^{-h}\cosh(2K-h)$; $(+,-)$: $f e^{-K'} = 2\cosh h$.
Dividing the first two gives $e^{2h'}$. Multiplying the first two and dividing by the square of the third gives $e^{4K'}$. At $h=0$ this goes back to $e^{2K'}=\cosh2K$, as it should. (These formulas were checked numerically against the direct sum over $s_2$, to machine precision.) The fixed points are the whole line $K^*=0$, for any $h$, since independent spins in a field look the same at every scale, plus the point $K^*=\infty,\ h^*=0$. Near the cold end the field grows under the flow ($h'\approx2h$), so it is **relevant**, a word Part 4 explains.
}

\coursenav{/Pages/Physics/courses/RG/02_toolkit/}{Part 2: Loops, infinities and cutoffs}{/Pages/Physics/courses/RG/04_fixed_points/}{Part 4: Fixed points and universality}

{{comments}}
