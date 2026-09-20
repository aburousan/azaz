+++
title = "Renormalisation Group VII: Running Couplings"
hascode = true
date = Date(2026, 9, 19)
rss = "Part 7 of the renormalisation group course. The particle physics road, in simple words: counterterms, minimal subtraction, beta functions and the Callan-Symanzik equation. phi^4 finds the Wilson-Fisher point again, QED screens (checked with FORM and Wolfram) and QCD antiscreens and is asymptotically free. With an interactive running-coupling calculator."
rss_title = "Renormalisation Group VII: Running Couplings"
rss_pubdate = Date(2026, 9, 19)

tags = ["physics", "qft", "renormalization", "qed", "qcd", "beta-function", "course"]
+++

\newcommand{\dd}{\mathrm d}

~~~
<link rel="stylesheet" href="/assets/Physics/courses/RG/rg.css">
<script defer src="/assets/Physics/courses/RG/rg.js"></script>
~~~

\toc

# Renormalisation Group VII: Running Couplings

> *Part 7 of eight. previous: [The Wilson-Fisher point](/Pages/Physics/courses/RG/06_wilson_fisher/) · [Course home](/Pages/Physics/courses/RG/Main_page/) · [Glossary](/Pages/Physics/courses/RG/glossary/) · next: [Effective field theory](/Pages/Physics/courses/RG/08_eft/)*

So far we have coarse-grained: we lowered a cutoff and watched the couplings flow. Particle physicists usually do it another way. They remove the cutoff completely (using dimensional regularisation from Part 2) and they fix the theory with a measurement made at some energy $\mu$ that they choose. Then they ask how the answer depends on that choice. The result is the same kind of flow, now called the **running** of couplings with energy. This part shows that the two pictures agree and then applies the particle-physics version to QED and QCD, where the running has actually been measured.

## Two questions, one idea

Books often blur these together, so it pays to be exact. Melo's notes separate two questions:

- **Wilson's question**: keep the long-distance physics fixed. How must the *bare* couplings change as I move the *cutoff* $\Lambda$? That was Parts 5 and 6.
- **The particle physicist's question**: keep the underlying theory fixed. How does the *measured* coupling depend on the *energy* $\mu$ at which I measure it? That's this part.

\analogy{
Think of a cake. Wilson asks: if I bake at a different oven temperature, how must I change the recipe to get the same cake? The particle physicist asks: if I keep the recipe fixed and taste the cake at different moments as it cools, how does the taste change? These are different questions, but both are about how one set of numbers must shift to match another and at one loop they give the same answer.
}

## Minimal subtraction, on one page

Work in $d=4-\epsilon$ dimensions (Part 2). There the bare coupling $\lambda_0$ has mass dimension $\epsilon$, so to keep a pure-number coupling we bring in an arbitrary mass scale $\mu$ and write

$$ \lambda_0 = \mu^{\epsilon}\left(\lambda + \frac{a_1(\lambda)}{\epsilon} + \frac{a_2(\lambda)}{\epsilon^2}+\dots\right). $$

Here $\lambda$ is the **renormalised coupling at scale $\mu$**. The extra $a_i/\epsilon$ terms are called **counterterms**. They're chosen to cancel the $1/\epsilon$ infinities of the loop diagrams and do nothing else, which is why this scheme is called **minimal subtraction** (MS).

Now the key point. $\lambda_0$ belongs to the actual theory and it cannot know about $\mu$, which is a scale we made up. So $\mu\,\dd\lambda_0/\dd\mu=0$.

\analogy{
Altitude is measured from sea level, but sea level is a choice: you could measure from the ground floor of your house instead. The height of a mountain, the real thing, doesn't care which you pick. All your numbers change, but they change together, in a fixed way. $\mu$ is the chosen "sea level", $\lambda_0$ is the mountain and the rule for how $\lambda$ must change when you move $\mu$ is the beta function.
}

Here's how that turns into a formula, step by step. Define $\beta(\lambda)\equiv\mu\,\dd\lambda/\dd\mu$. Differentiate $\lambda_0$ with respect to $\mu$ using the product rule and the chain rule ($a_1$ depends on $\mu$ only through $\lambda$):

$$ 0 = \mu\frac{\dd\lambda_0}{\dd\mu} = \mu^\epsilon\left[\epsilon\Big(\lambda+\frac{a_1}{\epsilon}\Big) + \Big(1+\frac{a_1'}{\epsilon}\Big)\beta\right]+\dots, $$

where $a_1'=\dd a_1/\dd\lambda$. Divide by $\mu^\epsilon$ and look for a $\beta$ of the form $\beta=-\epsilon\lambda+b(\lambda)$. Substituting it in and sorting by powers of $\epsilon$:

- the terms with $\epsilon^1$: $\;\epsilon\lambda-\epsilon\lambda = 0$, fine;
- the terms with $\epsilon^0$: $\;a_1 + b - \lambda a_1' = 0$, so $b=\lambda a_1'-a_1$;
- the terms with $1/\epsilon$ only involve higher loops and $a_2$, so we can ignore them at one loop.

So

$$ \boxed{\;\beta(\lambda) = -\epsilon\lambda + \Big(\lambda\frac{\dd}{\dd\lambda}-1\Big)a_1(\lambda).\;} $$

(For a coupling written as $g_0=\mu^{\rho\epsilon}(g+a_1/\epsilon+\dots)$ the same steps give $\beta=-\rho\epsilon g+\rho\,(g\,a_1'-a_1)$. QED has $\rho=\tfrac12$; see exercise 7.1.) So **only the number in front of the simplest $1/\epsilon$ matters**. All of the running comes from the $1/\epsilon$ of one-loop diagrams.

## φ⁴: the bubble finds the Wilson-Fisher point again

Write $\Gamma^{(4)}$ for the full strength of the four-particle interaction: the tree-level $\lambda_0$ plus its loop corrections. (It is what you would measure in a collision of two particles into two.) At one loop it gets the bubble diagram of Part 2 in three different ways, called **channels**. The four outside legs can be paired up as (1,2) meeting (3,4), or (1,3) meeting (2,4), or (1,4) meeting (2,3) and the squared momentum flowing through the bubble in each case is called $s$, $t$ and $u$ respectively. Each comes with a symmetry factor $\tfrac12$:

$$ \Gamma^{(4)} = \lambda_0 - \frac{\lambda_0^2}{2}\big[B(s)+B(t)+B(u)\big]+\dots,\qquad B(p)=\int\frac{\dd^dk}{(2\pi)^d}\frac1{(k^2+m^2)((k+p)^2+m^2)}. $$

We computed exactly this integral, step by step, in Part 2, section 6 (Feynman parameter, completing the square, master formula, then $d\to4$):

$$ B(p) = \frac{\Gamma(2-\tfrac d2)}{(4\pi)^{d/2}}\int_0^1\dd x\,\big[m^2+x(1-x)p^2\big]^{d/2-2} = \frac{1}{16\pi^2}\left[\frac2\epsilon+\text{finite}\right]. $$

(A warning about letters: this $u$ is a momentum variable, nothing to do with the coupling $\tilde u$ of Parts 5 and 6. Both names are too standard to change.) The three channels give an infinite part $-\frac{\lambda^2}{2}\cdot3\cdot\frac{2}{16\pi^2\epsilon}=-\frac{3\lambda^2}{16\pi^2\epsilon}$. The counterterm must cancel it, so $a_1=\frac{3\lambda^2}{16\pi^2}$ and

$$ \boxed{\;\beta(\lambda) = -\epsilon\lambda + \frac{3\lambda^2}{16\pi^2}.\;} $$

Now compare with Part 6. There we integrated out shells of fast momentum modes and found a fixed point at $\tilde u^*=16\pi^2\epsilon/3$. Here, setting $\beta=0$:

$$ \lambda^* = \frac{16\pi^2}{3}\,\epsilon. $$

**The same number, from a completely different calculation.** One used a hard cutoff and zooming out. The other used dimensional regularisation and a made-up scale $\mu$, with no cutoff at all. The slope here, $\beta'(\lambda^*)=+\epsilon$, is Part 6's $-\epsilon$ read with RG time running the other way. Both were checked in Wolfram:

```mathematica
beta0[a1_, g_, rho_] := rho (g D[a1, g] - a1);             (* MS beta from the simple pole *)
Simplify[beta0[3 lam^2/(16 Pi^2), lam, 1]]                   (* 3 lam^2/(16 Pi^2) *)
I2 = Gamma[2 - d/2]/(4 Pi)^(d/2) (m^2 + x (1 - x) p^2)^(d/2 - 2);
Series[I2 /. d -> 4 - eps, {eps, 0, 0}]                      (* (1/(16 Pi^2)) (2/eps + ...) *)
beta = -eps lam + 3 lam^2/(16 Pi^2);
lam /. Last[Solve[beta == 0, lam]]                           (* 16 Pi^2 eps/3, same as Wilson *)
```

The $\tfrac32$ we counted by hand in Part 6 (72 ways to join the lines) equals the $3\times\tfrac12$ here (three channels, each with a factor of one half). Two independent calculations that had to agree and do.

## The Callan-Symanzik equation

A real, measurable correlation function can't depend on the $\mu$ we picked. Written in terms of $\lambda(\mu)$, that simple fact becomes a differential equation, the **Callan-Symanzik equation** (Peskin §12.2):

$$ \Big[\mu\frac{\partial}{\partial\mu}+\beta(\lambda)\frac{\partial}{\partial\lambda}+n\,\gamma(\lambda)\Big]G^{(n)}(p_i;\lambda,\mu)=0. $$

Here $\gamma$ is the **anomalous dimension** of the field: how much its scaling differs from what plain dimensional analysis says. For $\phi^4$, $\gamma$ first appears at two loops, which is why $\eta=\epsilon^2/54$ in Part 6. The equation just says that moving $\mu$ can be exactly undone by moving $\lambda$ (and rescaling the field).

\analogy{
It's like converting prices between currencies. A laptop's price in rupees and in dollars are different numbers, but the laptop is the same. Change the currency and you must change the number by the exchange rate to keep describing the same object. The beta function is the exchange rate between descriptions at different $\mu$.
}

## Solving the flow: running and the Landau pole

In $d=4$ the equation is $\mu\,\dd\lambda/\dd\mu=3\lambda^2/16\pi^2$. Write $L=\ln\mu$, so $\mu\,\dd/\dd\mu=\dd/\dd L$ and separate the variables:

$$ \frac{\dd\lambda}{\lambda^2} = \frac{3}{16\pi^2}\,\dd L\quad\Longrightarrow\quad -\frac1{\lambda(\mu)}+\frac1{\lambda(\mu_0)} = \frac{3}{16\pi^2}\ln\frac{\mu}{\mu_0}. $$

Solving for $\lambda(\mu)$ gives

$$ \lambda(\mu) = \frac{\lambda(\mu_0)}{1-\dfrac{3\lambda(\mu_0)}{16\pi^2}\ln\dfrac{\mu}{\mu_0}}. $$

Why bother with this? A plain one-loop calculation of a process at energy $E$ contains terms like $\lambda\ln(E/\mu)$ and at higher loops $\lambda^2\ln^2(E/\mu)$ and so on. If $E$ is far from $\mu$, those "small corrections" aren't small at all. Choosing $\mu\approx E$ and using the running coupling puts all of those logarithms into $\lambda(E)$, summed to all orders. This is called **RG improvement** and it's why modern collider predictions quote couplings "at the scale of the process".

\puja{
A *running coupling* is what happens when a couple at the Ekdalia pandal spots an aunt from the girl's para in the queue. For our single readers there's a consolation: a coupling that is exactly zero doesn't run at all. $\beta(0)=0$, so you're a fixed point, perfectly stable, all Puja long.
}

\analogy{
It's like interest on a loan. If you apply a yearly rate to fifty years in one go (simple interest), you get the wrong answer. You have to compound it: apply the rate for one year, update the balance, apply it again. The running coupling is the compounded version. It keeps updating $\lambda$ as the energy changes instead of using one fixed value across a huge range.
}

The formula has a problem. The bottom of the fraction hits zero when $\ln(\mu/\mu_0)=16\pi^2/(3\lambda(\mu_0))$. At that finite energy the coupling becomes infinite. This is called the **Landau pole** and Part 8 discusses what it means. For now, note that it's exponentially far away when the coupling is small.

## QED: the electric charge grows at short distance

In QED the one-loop running comes from **vacuum polarisation**: a photon briefly turning into an electron and a positron, which then turn back into a photon. We'll follow the five-step recipe from Part 2, section 6, with every line shown. (This is Peskin §7.5.) We now work in ordinary Minkowski spacetime, because that's where the Dirac matrices are usually written.

**Step 1: write the integral.** The photon (momentum $q$) opens into an electron loop: one electron line carries $k$ and the other $k+q$. Each vertex gives $-ie\gamma^\mu$, each electron propagator gives $\frac{i(\not k+m)}{k^2-m^2}$ and a closed loop of fermions gives an extra factor of $-1$ plus a trace over the Dirac matrices. (The $-1$ comes from the fact that swapping two fermions flips the sign of the wavefunction.) Putting these together:

$$ i\Pi^{\mu\nu}(q) = -(-ie)^2\int\frac{\dd^4k}{(2\pi)^4}\,\mathrm{Tr}\left[\gamma^\mu\frac{i(\not k+m)}{k^2-m^2}\gamma^\nu\frac{i(\not k+\not q+m)}{(k+q)^2-m^2}\right]. $$

The constants combine as $-(-ie)^2\cdot i\cdot i=-(-e^2)(-1)=-e^2$, so

$$ i\Pi^{\mu\nu}(q) = -e^2\int\frac{\dd^4k}{(2\pi)^4}\,\frac{\mathrm{Tr}\big[\gamma^\mu(\not k+m)\gamma^\nu(\not k+\not q+m)\big]}{(k^2-m^2)\big((k+q)^2-m^2\big)}. $$

**Step 1b: do the trace.** This is where FORM earns its keep:

```text
Vectors k, q;  Indices mu, nu;  Symbols m;
Local trace = g_(1,mu)*(g_(1,k)+m)*g_(1,nu)*(g_(1,k)+g_(1,q)+m);
trace4 1;  contract;
Local textbook = 4*( k(mu)*(k(nu)+q(nu)) + k(nu)*(k(mu)+q(mu))
                     - d_(mu,nu)*(k.k + k.q - m^2) );
Local difference = trace - textbook;          * FORM prints: difference = 0;
Print;  .end
```

So the trace is $4\big[k^\mu(k+q)^\nu+k^\nu(k+q)^\mu-g^{\mu\nu}(k\cdot(k+q)-m^2)\big]$.

**Step 2: Feynman parameter.** Exactly as in Part 2, with $A=(k+q)^2-m^2$ and $B=k^2-m^2$:
$$ \frac{1}{(k^2-m^2)\big((k+q)^2-m^2\big)} = \int_0^1\frac{\dd x}{\big[k^2+2x\,k\cdot q+x q^2-m^2\big]^2}. $$

**Step 3: complete the square.** $k^2+2x\,k\cdot q = (k+xq)^2-x^2q^2$, so with $\ell=k+xq$ the denominator becomes $(\ell^2-\Delta)^2$, where
$$ \Delta = m^2 - x(1-x)\,q^2. $$
(For a spacelike photon, $q^2<0$, so $\Delta>0$.)

**Step 4: rewrite the numerator in terms of $\ell$.** Substitute $k=\ell-xq$ into the trace and throw away the terms with a single $\ell$, since they integrate to zero. FORM does the bookkeeping:

```text
Vectors k, q, l;  Indices mu, nu;  Symbols m, x, t;
Local N = g_(1,mu)*(g_(1,k)+m)*g_(1,nu)*(g_(1,k)+g_(1,q)+m);
trace4 1;  .sort
id k = l - x*q;                 * shift the loop momentum
id l = t*l;  .sort              * t counts the powers of l
if ( count(t,1) == 1 ) discard; * odd powers of l integrate to zero
id t = 1;  .sort
Local Npeskin = 4*( 2*l(mu)*l(nu) - d_(mu,nu)*l.l - 2*x*(1-x)*q(mu)*q(nu)
                 + d_(mu,nu)*(m^2 + x*(1-x)*q.q) );
Local diff = N - Npeskin;  Print;  .end
* FORM prints: diff = 0;
```

Then replace $\ell^\mu\ell^\nu\to\frac1d g^{\mu\nu}\ell^2$ (the averaging rule from Part 2) to get
$$ N^{\mu\nu} = 4\Big[\big(\tfrac2d-1\big)g^{\mu\nu}\ell^2 - 2x(1-x)\,q^\mu q^\nu + g^{\mu\nu}\big(m^2+x(1-x)q^2\big)\Big]. $$

**Step 5: the two master integrals.** We need $I_0=\int\frac{\dd^d\ell}{(2\pi)^d}\frac{1}{(\ell^2-\Delta)^2}$ and $I_2=\int\frac{\dd^d\ell}{(2\pi)^d}\frac{\ell^2}{(\ell^2-\Delta)^2}$. Wick rotate ($\ell^0=i\ell^4$, so $\dd^d\ell=i\,\dd^d\ell_E$ and $\ell^2=-\ell_E^2$) and use Part 2's master formula:
$$ I_0 = \frac{i}{(4\pi)^{d/2}}\,\Gamma\big(2-\tfrac d2\big)\,\Delta^{d/2-2},\qquad I_2 = \frac{-i}{(4\pi)^{d/2}}\,\frac d2\,\Gamma\big(1-\tfrac d2\big)\,\Delta^{d/2-1}. $$

Now one small identity does something beautiful. Since $\Gamma(2-\tfrac d2)=(1-\tfrac d2)\,\Gamma(1-\tfrac d2)$ and $(\tfrac2d-1)\cdot\tfrac d2 = 1-\tfrac d2$,
$$ \Big(\frac2d-1\Big)I_2 = -\Delta\,I_0. $$
So in the $g^{\mu\nu}$ part of the numerator, the $\ell^2$ term becomes $-\Delta=-m^2+x(1-x)q^2$, which cancels the $m^2$ and leaves $2x(1-x)q^2$. Everything collapses to one clean structure:
$$ i\Pi^{\mu\nu}(q) = -8e^2\int_0^1\dd x\;x(1-x)\;I_0\;\big(q^2g^{\mu\nu}-q^\mu q^\nu\big). $$

\analogy{
The combination $q^2g^{\mu\nu}-q^\mu q^\nu$ is called "transverse". It's what gauge symmetry demands and it guarantees the photon stays massless. It isn't put in by hand: the calculation produces it, as long as we're careful to average $\ell^\mu\ell^\nu$ in $d$ dimensions. It's like balancing a cheque book at the end of a long calculation and finding that it comes out to exactly zero. That's how you know the bookkeeping was right.
}

Reading off $\Pi^{\mu\nu}=(q^2g^{\mu\nu}-q^\mu q^\nu)\,\Pi_2(q^2)$:
$$ \Pi_2(q^2) = -\frac{8e^2}{(4\pi)^{d/2}}\int_0^1\dd x\,x(1-x)\,\Gamma\big(2-\tfrac d2\big)\,\Delta^{d/2-2}, $$
which is Peskin's eq. 7.90.

**Step 6: let $d$ approach 4.** The only infinite factor is $\Gamma(\tfrac\epsilon2)\approx\tfrac2\epsilon$ and $\int_0^1x(1-x)\,\dd x=\tfrac16$, so
$$ \Pi_2\Big|_{\rm pole} = -\frac{8e^2}{16\pi^2}\cdot\frac2\epsilon\cdot\frac16 = -\frac{e^2}{6\pi^2\epsilon} = -\frac{2\alpha}{3\pi\epsilon}. $$

Every intermediate line above was checked, the Dirac algebra in FORM and the integrals in Wolfram:

```mathematica
eucl0[n_] := Gamma[n - d/2]/((4 Pi)^(d/2) Gamma[n]) D0^(d/2 - n);          (* master formula *)
eucl2[n_] := (d/2) Gamma[n - d/2 - 1]/((4 Pi)^(d/2) Gamma[n]) D0^(d/2 - n + 1);
I0 = I eucl0[2];  I2 = -I eucl2[2];                                        (* after Wick rotation *)
FullSimplify[(2/d - 1) I2 + D0 I0]                                           (* 0: the key identity *)
Dx = m^2 - x (1 - x) q2;
Cg  = -4 e^2 ((2/d - 1) I2 + (m^2 + x (1 - x) q2) I0) /. D0 -> Dx;        (* coefficient of g^{mu nu} *)
Cqq = -4 e^2 (-2 x (1 - x) I0) /. D0 -> Dx;                                (* coefficient of q^mu q^nu *)
FullSimplify[Cg + q2 Cqq]                                                    (* 0: transverse *)
```

The photon's counterterm, written $Z_3=1-\frac{e^2}{6\pi^2\epsilon}$, cancels it.

Now, in principle the electric charge could also be corrected by two other things: the electron's own self-energy and the correction to the vertex where the photon meets the electron. Gauge symmetry saves us. The **Ward identity**, which is the statement in diagrams that electric charge is conserved, forces those two corrections to cancel each other exactly. (Peskin §7.4 proves it.) So the entire running of the charge comes from the photon's $Z_3$ alone:

$$ e_0=\mu^{\epsilon/2}\,Z_3^{-1/2}\,e, $$

which is a coupling of the form used above with $\rho=\tfrac12$ and $a_1=\frac{e^3}{12\pi^2}$.

\analogy{
This cancellation is why charge is so well behaved. Every electron in the universe has exactly the same charge as every other, even though each one is dressed by a different mess of virtual particles. Gauge symmetry guarantees that the dressing changes the *photon*, which everyone shares and not the individual particle's coupling.
} The minimal-subtraction formula gives

$$ \boxed{\;\beta(e)=\frac{e^3}{12\pi^2}\qquad\Longleftrightarrow\qquad \mu\frac{\dd\alpha}{\dd\mu}=\frac{2\alpha^2}{3\pi}\;} $$

for one electron-like particle. It is **positive**: the electromagnetic coupling grows at higher energy, which means shorter distance.

\analogy{
Shirkov's own picture in the *CERN Courier* is a charge placed in an electrolyte, like salt water: at distance $r$ it has an *effective* charge $Q(r)$. Put a positive charge in water. The water molecules turn so that their negative ends face the charge and from far away they hide part of it: the charge looks smaller. That's why salt dissolves: water weakens the pull between the ions. The quantum vacuum does the same thing with virtual electron-positron pairs. Probe the charge from far away and you see it shielded. Push in closer, inside some of the shielding cloud and you see more of the real charge. So the coupling grows as you look closer. It's like a film star at a Durga Puja pandal in Kolkata: from the back of the crowd you only see the crowd around them, but push your way in and you see more and more of the star.
}

~~~
<div class="mfig" style="--w:520px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/screening.svg" alt="Screening in QED versus antiscreening in QCD">
  <p>The usual picture. It's a heuristic only; the exact statement is the sign of \(\beta\). QED's vacuum acts like water around an ion and screens a charge. QCD's gluons carry charge themselves and the overall effect is reversed.</p>
</div>
~~~

**The finite part says the same thing.** We measure $\alpha=1/137.036$ with photons of almost zero momentum, so the physical, finite quantity is the *change* from $q^2=0$: $\hat\Pi_2(q^2)=\Pi_2(q^2)-\Pi_2(0)$. The $2/\epsilon$ is the same at every $q^2$, so it cancels in the difference. Using step 6 of the recipe in Part 2 for the finite part, what's left is
$$ \hat\Pi_2 = \frac{2\alpha}{\pi}\int_0^1\dd x\,x(1-x)\,\ln\frac{m^2+x(1-x)Q^2}{m^2}, $$
where $Q^2=-q^2>0$ for a spacelike photon. Now take $Q^2\gg m^2$. Inside the logarithm the $m^2$ is negligible next to $x(1-x)Q^2$ (except in tiny corners near $x=0,1$, which barely contribute), so $\ln\frac{m^2+x(1-x)Q^2}{m^2}\approx\ln\frac{Q^2}{m^2}+\ln\big(x(1-x)\big)$. Two simple integrals remain:
$$ \int_0^1x(1-x)\,\dd x=\frac16,\qquad \int_0^1x(1-x)\ln\big(x(1-x)\big)\,\dd x=-\frac5{18}. $$
(For the second, split the log into $\ln x+\ln(1-x)$. By symmetry the two halves are equal and $\int_0^1(x-x^2)\ln x\,\dd x=-\tfrac14+\tfrac19=-\tfrac5{36}$.) Putting it together,
$$ \hat\Pi_2(Q^2)\approx\frac{2\alpha}{\pi}\left[\frac16\ln\frac{Q^2}{m^2}-\frac5{18}\right]=\frac{\alpha}{3\pi}\left[\ln\frac{Q^2}{m^2}-\frac53\right],\qquad \alpha_{\rm eff}(Q^2)=\frac{\alpha}{1-\hat\Pi_2(Q^2)}. $$

The $1/(1-\hat\Pi_2)$ is the same geometric series we summed for the propagator in Part 1: a photon can polarise the vacuum once, twice, three times in a row and $1+\hat\Pi_2+\hat\Pi_2^2+\dots=1/(1-\hat\Pi_2)$.

Differentiate with respect to $\ln Q$ and you get $2\alpha^2/3\pi$ back exactly. At $Q=m_Z$ with only the electron in the loop this gives $1/\alpha_{\rm eff}=134.65$ (the exact one-loop integral, checked two ways). The measured value is $1/\alpha(m_Z)=127.95$, because every charged particle lighter than the $Z$ (the muon, the tau and the quarks) runs in the loop too. The effect is large, it has been measured and the running is exactly as predicted.

~~~
<div class="mfig" style="--w:640px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/running_couplings.svg" alt="Running of the QED and QCD couplings">
  <p>Left: \(1/\alpha\) falls as the energy rises, from the electron loop alone (the exact one-loop integral). Right: the strong coupling \(\alpha_s\) at one loop with five quark types, starting from the measured \(\alpha_s(m_Z)=0.1180\). It falls at high energy.</p>
</div>
~~~

\note{
**A mistake in one of our sources.** In its section on the low-energy beta function, Melo's notes say the measured electron charge "is smaller at higher energies". That's backwards. The same notes correctly call the QED coupling marginally irrelevant, like $\lambda\phi^4$ and a marginally irrelevant coupling shrinks at long distances, so it *grows* at short distances. The data agree: $1/\alpha$ goes from $137.036$ at low energy to $127.95$ at $m_Z$, so $\alpha$ is larger at high energy.
}

## QCD: asymptotic freedom

The strong force is where running couplings stop being a technical detail. Here the coupling runs the *other* way from QED, which is the whole reason quarks behave as they do. For 3 colours with $n_f$ types of quark, the one-loop result is (Gross and Wilczek and Politzer, 1973; worked out in Peskin §16.5 to §16.6):

$$ \beta(g) = -\frac{g^3}{16\pi^2}\left(\frac{11}{3}N-\frac23 n_f\right)\qquad\Longleftrightarrow\qquad \mu\frac{\dd\alpha_s}{\dd\mu}=-\frac{b_0}{2\pi}\alpha_s^2,\quad b_0=11-\frac23n_f\ \ (N=3). $$

That line has six symbols in it. None of them is difficult, so here is every one.

\defn{
**$g$, the coupling.** One number saying how strongly a quark emits a gluon, exactly as $e$ says how strongly an electron emits a photon. Experiments quote the tidier combination $\alpha_s=g^2/4\pi$, built the same way as the fine structure constant $\alpha=e^2/4\pi$. At the mass of the $Z$ boson, $\alpha_s=0.118$, so the strong force really is strong: compare $\alpha=1/137$.

**$\mu$, the scale.** The energy at which you look. It is the same $\mu$ as the rest of this part, the sliding scale of minimal subtraction. A bigger $\mu$ means a shorter distance, roughly $\text{distance}\sim\hbar c/\mu$, so "high energy" always means "close up".

**$\beta(g)=\mu\,\dd g/\dd\mu$, the beta function.** The rate at which the coupling changes when you change the scale. Nothing more. A positive $\beta$ means the coupling grows as you go to higher energy, which is QED. A negative $\beta$ means it shrinks, which is QCD.

**$N$, the number of colours.** Colour is the strong charge. Where electric charge comes in one kind, strong charge comes in three, called red, green, blue. $N=3$ for the real world. The gauge group is $SU(N)=SU(3)$. The force carriers are the $N^2-1=8$ gluons.

**$n_f$, the number of flavours.** Flavour is just the quark type: up, down, strange, charm, bottom, top. Only quarks lighter than the scale you work at get to contribute, for the decoupling reason of [Part 8](/Pages/Physics/courses/RG/08_eft/): a particle heavier than the energy you have cannot be made, so it drops out. At $\mu=m_Z$ five of the six are light enough, so $n_f=5$.

**$b_0=11-\tfrac23n_f$.** The whole coefficient packed into one number, for $N=3$. It is positive for every real quark count, which is what makes the minus sign in front of it survive.
}

### Why this one is quoted instead of derived

The QED beta function in the last section came from one diagram, the electron loop, which we traced out in FORM. The QCD one needs three new ingredients that would take a course of their own: gluons carry colour charge so they couple to themselves, which adds diagrams with three and four gluon legs that have no QED counterpart; the gluon propagator needs a gauge choice; and that gauge choice drags in **ghosts**.

\defn{
**Ghosts.** When you fix a gauge in a covariant way, the gluon field is left with four polarisations instead of the two a massless particle really has. The two extra ones are not physical, so their contribution has to be cancelled. Faddeev and Popov showed that the cancellation is done automatically by adding a fake field that appears only inside loops, never as an incoming or outgoing particle, with a minus sign attached to each of its loops. That fake field is the ghost. It is bookkeeping, not a particle: nobody will ever detect one. Peskin §16.2 does the construction.
}

None of that changes the RG logic of this part. The coupling still runs, the beta function is still read off from the $1/\epsilon$ pole, so Exercise 7.1's formula $\beta=\rho(ga_1'-a_1)$ still delivers it. Only the diagram count goes up.

### Where the sign comes from

You can still see why the answer has the sign it does. The two pieces of $b_0$ pull in opposite directions.

**The quark piece, $-\tfrac23n_f$, is ordinary screening.** A quark loop does exactly what the electron loop did in QED. Virtual quark and antiquark pairs pop out of the vacuum, turn their negative end towards the charge, hiding part of it. Get closer than the cloud and you see more charge. That is why its sign matches QED's.

**The gluon piece, $+\tfrac{11}3N$, is antiscreening.** Because a gluon itself carries colour, a colour charge leaks into the cloud around it, so the cloud carries the same colour as the source rather than the opposite one. Peskin §16.7 works this out picture by picture: the induced dipole ends up pointing *towards* the original charge, amplifying it instead of hiding it. Move away from the source and you see more charge, not less. Move in close and there is less and less of it.

The two effects are inside the same number. Peskin's quantitative statement is that the antiscreening beats the gauge boson screening by a factor of 12, which is exactly what $\tfrac{11}3=\tfrac{12}3-\tfrac13$ says: a screening piece $-\tfrac13$ of the ordinary kind, plus an antiscreening piece $+\tfrac{12}3=4$ that only a self-interacting force can have.

~~~
<figure>
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/qcd_screening.svg" alt="Screening in QED versus antiscreening in QCD, with the breakdown of the one-loop coefficient">
  <p>Why QCD runs the other way. (a) In QED the vacuum dipoles turn their minus ends inward, so they hide the charge. (b) In QCD the induced dipole points inward with its plus end, so it adds to the charge. (c) The same story as numbers: the magnetic, self-interaction piece of the gluon gives $+12$, the ordinary screening piece of the gluon gives $-1$, six quark flavours give $-4$. The gluons win, so $b_0>0$ and therefore $\beta<0$.</p>
</figure>
~~~

\note{
The split into "electric" screening and "magnetic" antiscreening can be made precise. Treat the vacuum as a material with a dielectric constant $\varepsilon$ and a magnetic permeability $\mu_m$. Relativity forces $\varepsilon\mu_m=1$, so a vacuum that is *paramagnetic*, meaning $\mu_m>1$, must have $\varepsilon<1$, which is antiscreening. Gluons carry spin 1 with a large magnetic moment, so the gluon vacuum is a paramagnet. Electrons and quarks, with spin $\tfrac12$, lose that competition. Nielsen wrote this up as "Asymptotic freedom as a spin effect" (*Am. J. Phys.* **49**, 1171, 1981).
}

So $\tfrac{11}3N$ beats $\tfrac23n_f$ as long as $n_f<\tfrac{11}2N=16.5$, which the real world comfortably satisfies with six flavours. Then $b_0>0$, so **$\beta<0$** and the strong coupling *shrinks* at high energy. That is **asymptotic freedom**: quarks squeezed close together stop interacting.

\analogy{
Picture two quarks tied together by a rubber band. When they're close, the band is slack and they barely feel each other: that's the weak coupling at high energy (short distance). Pull them apart and the band pulls harder and harder: that's the strong coupling at low energy. You can never separate them, because the band would snap into a new quark pair first. It's only a cartoon, but it captures why quarks look almost free inside a proton yet are never seen alone.
}

### Solving the flow, then reading off $\Lambda_{\rm QCD}$

The $\alpha_s$ equation is easy to integrate. Write it for $1/\alpha_s$:

$$ \frac{\dd}{\dd\ln\mu}\frac{1}{\alpha_s}=-\frac1{\alpha_s^2}\frac{\dd\alpha_s}{\dd\ln\mu}=\frac{b_0}{2\pi} \qquad\Longrightarrow\qquad \frac{1}{\alpha_s(\mu)}=\frac{1}{\alpha_s(\mu_0)}+\frac{b_0}{2\pi}\ln\frac{\mu}{\mu_0}. $$

So $1/\alpha_s$ climbs as a straight line in $\ln\mu$. Run the line backwards and it must cross zero somewhere, which means $\alpha_s$ itself blows up there. Call that place $\Lambda_{\rm QCD}$ and the solution takes a form with no free constant left in it at all:

$$ \boxed{\;\alpha_s(\mu)=\frac{2\pi}{b_0\,\ln(\mu/\Lambda_{\rm QCD})}\;},\qquad \Lambda_{\rm QCD}=\mu_0\,e^{-2\pi/(b_0\alpha_s(\mu_0))}. $$

\defn{
**$\Lambda_{\rm QCD}$.** Read the second formula slowly, because something strange happened. We started with a theory whose Lagrangian contains no mass at all for the gluon, only a dimensionless number $g$. Out came a quantity measured in GeV. The scale came in through the running itself, through the $\mu$ that renormalisation forced us to introduce. This is **dimensional transmutation**: a pure number turns into an energy. Every mass in the proton, so nearly all the mass you are made of, traces back to this one number rather than to the Higgs.
}

Putting in $\alpha_s(m_Z)=0.1180$ with $n_f=5$ gives $b_0=23/3$ and $\Lambda_{\rm QCD}=0.088$ GeV at one loop. The same line then gives $\alpha_s(1\ \mathrm{TeV})=0.088$ and $\alpha_s(10\ \mathrm{GeV})=0.173$. Running down to $2$ GeV gives $0.262$. Real analyses get about $0.30$ there, because they use more loops and change $n_f$ at each quark mass, so treat the one-loop number as a sketch. The blow-up at $0.09$ GeV signals that the approximation has broken down, not that anything really becomes infinite. It does mark roughly where quarks stop being free objects, which is why the proton's size is what it is.

\otaku{
Watching the QED coupling climb towards its Landau pole is pure *Gurren Lagann*: "Pierce the heavens!" Except the heavens here are at $10^{277}$ GeV and gravity takes over long before the drill gets there.
}

## Run it yourself

~~~
<div id="rg-running" style="--w:720px"></div>
~~~

Things to try. In QCD, drag $n_f$ past 16 and watch asymptotic freedom disappear as the curve turns round. In QED with one flavour, find the Landau pole: it's around $10^{277}$ GeV, absurdly far beyond the Planck scale, so in practice nobody worries about it.

## Exercises

\prob{
**7.1.** For $g_0=\mu^{\rho\epsilon}\big(g+a_1(g)/\epsilon+\dots\big)$, impose $\mu\,\dd g_0/\dd\mu=0$ and show that $\beta(g)=-\rho\epsilon g+\rho\,(g\,a_1'-a_1)$. Check that it gives $3\lambda^2/16\pi^2$ for $\phi^4$ ($\rho=1$) and $e^3/12\pi^2$ for QED ($\rho=\tfrac12$, $a_1=e^3/12\pi^2$).
}
\soln{
$0=\mu\frac{\dd g_0}{\dd\mu}=\mu^{\rho\epsilon}\left[\rho\epsilon\Big(g+\frac{a_1}\epsilon\Big)+\Big(1+\frac{a_1'}\epsilon\Big)\beta\right]$. Try $\beta=-\rho\epsilon g+b_0$. At order $\epsilon$: $\rho\epsilon g-\rho\epsilon g=0$. At order $\epsilon^0$: $\rho a_1+b_0-\rho g a_1'=0$, so $b_0=\rho(ga_1'-a_1)$. For $\phi^4$: $a_1=3\lambda^2/16\pi^2$ and $\lambda a_1'=2a_1$, so $b_0=a_1=3\lambda^2/16\pi^2$. For QED: $ea_1'=3a_1$, so $b_0=\tfrac12\cdot2a_1=a_1=e^3/12\pi^2$. A classic mistake is forgetting the $\rho=\tfrac12$ for QED, which gives $e^3/24\pi^2$, half the right answer.
}

\prob{
**7.2.** For $\phi^4$ with $\lambda(\mu_0)=1$, how far above $\mu_0$ is the one-loop Landau pole?
}
\soln{
$\ln(\mu/\mu_0)=16\pi^2/3=52.64$, so $\mu/\mu_0=e^{52.64}\approx7.3\times10^{22}$. Even a coupling of size one only blows up more than twenty powers of ten higher. That's how gentle logarithmic running is.
}

\prob{
**7.3.** Show that $\alpha_{\rm eff}(Q^2)=\alpha/\big(1-\tfrac{\alpha}{3\pi}\ln(Q^2/m^2)\big)$ satisfies $\dd\alpha_{\rm eff}/\dd\ln Q=\frac{2\alpha^2_{\rm eff}}{3\pi}$ at this order. Then find the QED Landau pole with only the electron in the loop.
}
\soln{
$\frac{\dd}{\dd\ln Q}\frac1{\alpha_{\rm eff}}=-\frac{1}{3\pi}\cdot\frac{\dd\ln Q^2}{\dd\ln Q}=-\frac{2}{3\pi}$ and so $\frac{\dd\alpha}{\dd\ln Q}=-\alpha^2\frac{\dd(1/\alpha)}{\dd\ln Q}=\frac{2\alpha^2}{3\pi}$. The pole is where $\frac{2\alpha}{3\pi}\ln\frac{\mu}{m_e}=1$, so $\mu=m_e\,e^{3\pi/2\alpha}=m_e\,e^{645.8}\approx1.5\times10^{277}$ GeV.
}

\prob{
**7.4.** For three colours, what is $b_0$ with all six quark flavours? What's the largest $n_f$ that keeps QCD asymptotically free? What about with two colours?
}
\soln{
$b_0=11-\frac23\cdot6=7>0$, so QCD is still asymptotically free. Freedom needs $\frac{11}3N>\frac23n_f$, which means $n_f<\frac{11}2N$. For $N=3$ that's $n_f<16.5$, so at most 16 flavours. For $N=2$, $n_f<11$, so at most 10.
}

\prob{
**7.5.** *Why the "transverse" shape is the whole point.* The vacuum-polarisation calculation gave $\Pi^{\mu\nu}=(q^2g^{\mu\nu}-q^\mu q^\nu)\,\Pi(q^2)$, with a factor of $q^2$ in front. Suppose instead a loop had produced a plain constant, $\Pi^{\mu\nu}=M^2g^{\mu\nu}$. Treat the photon propagator as simply $1/q^2$ and each insertion of the loop as one extra factor (just as for the tadpole chain in Part 1). Sum the chain of insertions in both cases. What happens to the photon's mass in each? And what, in the transverse case, *does* the loop change?
}
\soln{
**Constant insertion.** Each insertion puts an $M^2$ between two propagators, so the chain is
$$ \frac1{q^2}+\frac1{q^2}M^2\frac1{q^2}+\frac1{q^2}M^2\frac1{q^2}M^2\frac1{q^2}+\dots=\frac1{q^2}\cdot\frac{1}{1-M^2/q^2}=\frac1{q^2-M^2}. $$
The pole has moved from $q^2=0$ to $q^2=M^2$: the photon would have a **mass** $M$. Light would then have a finite range, which is ruled out by experiment to an extraordinary precision.

**Transverse insertion.** Now each insertion brings $q^2\,\Pi(q^2)$ (the $q^\mu q^\nu$ part drops out when the photon couples to conserved currents). The chain is
$$ \frac1{q^2}+\frac1{q^2}\,q^2\Pi\,\frac1{q^2}+\dots=\frac1{q^2}\big(1+\Pi+\Pi^2+\dots\big)=\frac{1}{q^2\,\big(1-\Pi(q^2)\big)}. $$
The pole stays at $q^2=0$, so **the photon stays massless**. What changes is the *height* of the propagator: every exchange of a photon between two charges is multiplied by $1/(1-\Pi(q^2))$, which is the same as replacing $e^2$ by $e^2/(1-\Pi(q^2))$. That's exactly $\alpha_{\rm eff}$, the running coupling of this page. (This is Peskin eq. 7.77.)

So the factor of $q^2$ that the calculation produced, the one that looked like tidy bookkeeping, is precisely what makes the loop change the *strength* of the force rather than the *mass* of the photon. And that factor comes from gauge symmetry, which is why the FORM and Wolfram check of transversality in this section matters.
}

\coursenav{/Pages/Physics/courses/RG/06_wilson_fisher/}{Part 6: The Wilson-Fisher point}{/Pages/Physics/courses/RG/08_eft/}{Part 8: Effective field theory}

{{comments}}
