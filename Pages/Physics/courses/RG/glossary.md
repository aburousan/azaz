+++
title = "Renormalisation Group: Glossary"
hascode = true
date = Date(2026, 9, 19)
rss = "A plain-language glossary for the renormalisation group course: every technical word explained in one or two simple sentences, with an everyday picture and a pointer to where the course explains it properly."
rss_title = "Renormalisation Group: Glossary"
rss_pubdate = Date(2026, 9, 19)

tags = ["physics", "renormalization", "course"]
+++

\newcommand{\dd}{\mathrm d}

\toc

# Glossary: every word in plain language

> *[Course home](/Pages/Physics/courses/RG/Main_page/)*

This page explains every technical word in the course the way the course home page explains "coarse-graining": what it means in plain words, a picture to hold on to and where the course explains it properly. If you meet a word you don't know, look here first.

## The big ideas

**Coarse-graining.** Throwing away fine detail by merging small pieces into bigger ones. *Picture:* lowering the resolution of a photo, averaging each 2×2 block of pixels into one. [Course home](/Pages/Physics/courses/RG/Main_page/), [Part 3](/Pages/Physics/courses/RG/03_block_spins/).

**Scale.** The size (or energy) at which you look at something. Small distance means high energy and large distance means low energy. *Picture:* the zoom level on a map.

**Renormalisation group (RG).** The rules that tell you how the numbers in a theory must change when you change the scale, so that everything you can measure stays the same. *Picture:* the rulebook for redrawing a map at a different zoom level. [Part 1](/Pages/Physics/courses/RG/01_scale/).

**RG flow.** The path the numbers of a theory follow as you keep zooming out. *Picture:* a boat drifting on a river; the current is the RG. [Parts 3 and 4](/Pages/Physics/courses/RG/03_block_spins/).

**RG map, RG step.** One round of coarse-graining: the rule $K\to K'$ that takes the old numbers to the new ones. [Part 3](/Pages/Physics/courses/RG/03_block_spins/).

**Fixed point.** A theory the RG leaves unchanged. It looks the same at every scale. *Picture:* a photo of TV static, or a fern, which look the same when you zoom out. [Part 3](/Pages/Physics/courses/RG/03_block_spins/).

**Relevant, irrelevant, marginal.** How a small change away from a fixed point behaves when you zoom out. **Relevant** changes grow, **irrelevant** ones fade away and **marginal** ones stay the same to first order. *Picture:* a ball on a mountain pass. Push it across the ridge and it rolls off (relevant). Push it along the ridge and it rolls back (irrelevant). [Part 4](/Pages/Physics/courses/RG/04_fixed_points/).

**Critical surface.** All the theories that flow *into* a particular fixed point. *Picture:* a river basin; rain falling anywhere in it ends up in the same sea. [Part 4](/Pages/Physics/courses/RG/04_fixed_points/).

**Universality.** Very different systems behave in exactly the same way near their critical points, because they flow to the same fixed point. **Universality class:** the group of systems sharing a fixed point. [Part 4](/Pages/Physics/courses/RG/04_fixed_points/).

**Effective field theory (EFT).** A theory built only for a limited range of scales, keeping just the terms that matter there. *Picture:* the multipole expansion: far from a lump of charge, a point charge plus small corrections is all you need. [Part 8](/Pages/Physics/courses/RG/08_eft/).

**Decoupling.** Very heavy particles have almost no effect at low energy, beyond shifting a few numbers. *Picture:* a baker needs yeast and heat, not quarks. [Part 8](/Pages/Physics/courses/RG/08_eft/).

## Magnets and phase transitions

**Spin.** A tiny magnet on each site of a lattice, pointing up ($+1$) or down ($-1$). [Part 3](/Pages/Physics/courses/RG/03_block_spins/).

**Ising model.** The simplest model of a magnet: spins on a lattice that prefer to agree with their neighbours. [Part 3](/Pages/Physics/courses/RG/03_block_spins/).

**Coupling $K=J/k_BT$.** In the Ising model, how strongly neighbours want to agree compared with how hot it is. Large $K$ is cold, small $K$ is hot.

**Partition function $Z$.** The sum of the probability weights of every possible arrangement. Everything else can be calculated from it. *Picture:* a complete catalogue of every state, each tagged with how likely it is.

**Boltzmann weight.** The factor $e^{-E/k_BT}$ that says how likely an arrangement with energy $E$ is at temperature $T$. Low-energy arrangements are more likely and heat makes the others more likely too.

**Phase transition.** A sudden change in behaviour as you tune something like temperature, such as water boiling or a magnet losing its magnetism.

**Critical point, critical temperature $T_c$.** The special temperature at a smooth (second-order) phase transition, where fluctuations happen at every size at once. *Picture:* critical opalescence, a clear fluid turning milky. [Part 4](/Pages/Physics/courses/RG/04_fixed_points/).

**Magnetisation, order parameter.** The average direction of the spins. It's zero when disordered and nonzero when ordered. For a fluid, the order parameter is the density difference from the critical density.

**Susceptibility $\chi$.** How much magnetisation appears when you apply a small magnetic field, $\chi=\partial m/\partial h$. It diverges at a critical point, where a tiny field produces a big response. [Part 4](/Pages/Physics/courses/RG/04_fixed_points/).

**Correlation length $\xi$.** How far away one spin still "knows" about another. *Picture:* the typical size of the islands in the magnet pictures. At $T_c$ it becomes infinite. [Part 3](/Pages/Physics/courses/RG/03_block_spins/).

**Critical exponents ($\nu,\alpha,\beta,\gamma,\delta,\eta$).** The powers in the laws that describe how quantities behave near $T_c$, such as $\xi\propto|T-T_c|^{-\nu}$. [Part 4](/Pages/Physics/courses/RG/04_fixed_points/).

**Block spin, majority rule.** Replacing a block of spins by one spin that points the way most of them point. *Picture:* an election where each village sends one representative. [Part 3](/Pages/Physics/courses/RG/03_block_spins/).

**Decimation.** Coarse-graining by summing over every second spin and keeping the rest. *Picture:* removing every other person from a game of telephone. [Part 3](/Pages/Physics/courses/RG/03_block_spins/).

**Mean field.** An approximation where each spin feels only the *average* of its neighbours and ignores their jiggling. It works best when each spin has many neighbours. [Part 5](/Pages/Physics/courses/RG/05_wilson/).

**Monte Carlo, Wolff cluster algorithm.** Simulating a magnet by sampling arrangements at random with the right weights. Near $T_c$ flipping one spin at a time becomes hopelessly slow (**critical slowing down**), so the Wolff method flips a whole correlated cluster at once. [Parts 3 and 4](/Pages/Physics/courses/RG/04_fixed_points/).

**Finite-size scaling.** Measuring exponents by running the model in boxes of different sizes $L$. At $T_c$ nothing else sets a scale, so every quantity becomes a power of $L$ whose exponent is the one you want. [Part 4](/Pages/Physics/courses/RG/04_fixed_points/).

**Binder cumulant.** The dimensionless ratio $U=1-\langle m^4\rangle/3\langle m^2\rangle^2$. It is a shape rather than a size, so at $T_c$ it cannot depend on the box size, which makes curves for different $L$ cross exactly at $T_c$. It runs from $0$ in the hot phase to $\tfrac23$ in the cold one. [Part 4](/Pages/Physics/courses/RG/04_fixed_points/).

**Duality (Kramers-Wannier).** An exact mirror that swaps the hot and cold versions of the 2D Ising model. It pins down $T_c$ exactly. [Part 4](/Pages/Physics/courses/RG/04_fixed_points/).

## Fields and quantum field theory

**Field.** A function of spacetime: hand it a point, it hands you back a value. Written $\phi(x)$. When the value is a single number the field is called **scalar**, which is the only kind this course needs. In the magnet chapters the field is a function of space alone, a snapshot at one instant, which Part 2's Wick rotation shows is the same mathematics. *Picture:* the temperature in a room, or the height of a rubber sheet at each point. [Parts 1 and 5](/Pages/Physics/courses/RG/01_scale/).

**Action $S$, Lagrangian.** The formula that defines a theory. Adding up the Lagrangian over all of space and time gives the action. In statistical physics the same object plays the role of the energy.

**Path integral.** A sum over every possible shape of the field, each weighted by $e^{-S}$. *Picture:* one ordinary integral for every little box of space, all done together. [Part 5](/Pages/Physics/courses/RG/05_wilson/).

**Mode, momentum, wavelength.** Any field can be written as a sum of waves and each wave is a **mode**. Its **momentum** $k$ says how fast it wiggles in space and its wavelength is about $1/k$. **Fast modes** have large $k$ (short, fine detail) and **slow modes** have small $k$ (long, smooth features).

**Momentum space.** Describing the field by its waves (modes) instead of its values at each point. *Picture:* an audio equaliser showing bass and treble instead of the sound wave itself.

**Propagator.** How easily a disturbance (a particle) travels from one place to another. Its pole tells you the particle's mass. [Part 1](/Pages/Physics/courses/RG/01_scale/).

**Pole.** A place where a formula blows up, like $1/(x-a)$ at $x=a$.

**Feynman diagram.** A picture of one way particles can interact. Lines are particles travelling, dots (**vertices**) are places where they interact. Each diagram stands for one term in a calculation.

**Tree diagram.** A diagram with no closed loops. It describes classical physics.

**Loop, virtual particle.** A closed loop in a diagram is a particle that briefly appears and disappears, never observed. Its momentum isn't fixed, so you integrate over all of it. *Picture:* money passed around a circle of friends. [Part 2](/Pages/Physics/courses/RG/02_toolkit/).

**Tadpole, bubble.** The two simplest one-loop diagrams in $\phi^4$ theory, named for their shapes. The tadpole corrects the mass; the bubble corrects the coupling. [Parts 1, 2 and 6](/Pages/Physics/courses/RG/01_scale/).

**Symmetry factor.** A number that fixes over-counting when a diagram can be made in several equivalent ways, like the $\tfrac12$ in the tadpole. [Part 1](/Pages/Physics/courses/RG/01_scale/).

**Wick's theorem.** For a free (Gaussian) field, the average of a product of fields is the sum over all ways of pairing them up, each pair giving a propagator. An odd number of fields averages to zero. *Picture:* pairing dancers, where everyone needs exactly one partner. [Parts 2 and 5](/Pages/Physics/courses/RG/05_wilson/).

**Contraction, pairing.** Taking two fields out of a list and replacing that pair by a propagator. A pairing is one complete way of doing it with nobody left over. [Part 5](/Pages/Physics/courses/RG/05_wilson/).

**Connected and disconnected.** A diagram is disconnected if it falls into pieces with no line between them. Those pieces cancel against the denominator of the average, so only connected diagrams matter. [Part 2](/Pages/Physics/courses/RG/02_toolkit/).

**Vertex function $\Gamma^{(4)}$.** The full strength of the four-particle interaction: the coupling written in the Lagrangian plus all its loop corrections. It's what a collision experiment actually measures. [Part 7](/Pages/Physics/courses/RG/07_running/).

**Channels (s, t, u).** The three ways four legs of a diagram can pair up, together with the squared momentum flowing through the internal line in each case. With 1 and 2 incoming while 3 and 4 go out: $s=(p_1+p_2)^2$ is the two incoming particles merging, $t=(p_1-p_3)^2$ is the momentum handed over when 1 becomes 3, $u=(p_1-p_4)^2$ the same with 4. They satisfy $s+t+u=\sum_i m_i^2$. Careful: this $u$ is a momentum, not the coupling $\tilde u$ of Parts 5 and 6. [Part 7](/Pages/Physics/courses/RG/07_running/).

**Coupling constant.** A number that sets how strongly things interact, like $\lambda$ in $\phi^4$ theory or the electric charge $e$ in QED.

**Dressed particle.** A particle together with the cloud of virtual particles around it. What you measure is always the dressed one. *Picture:* walking through a crowd makes you move as if you were heavier. [Part 1](/Pages/Physics/courses/RG/01_scale/).

## Infinities and how to handle them

**Divergence.** A calculation that comes out infinite. **Quadratic** divergences grow like $\Lambda^2$, **logarithmic** ones like $\ln\Lambda$. [Part 2](/Pages/Physics/courses/RG/02_toolkit/).

**Ultraviolet (UV) and infrared (IR).** UV means short distances and high energies; IR means long distances and low energies. The names come from the light spectrum.

**Cutoff $\Lambda$.** The largest momentum we allow, which is the same as the smallest distance we trust. *Picture:* the pixel size of the map. [Parts 1 and 2](/Pages/Physics/courses/RG/02_toolkit/).

**Regularisation.** Temporarily changing a theory at very short distances so that calculations are finite, controlled by one adjustable number (the **regulator**). *Picture:* measuring a coastline with a ruler of a chosen length. [Part 2](/Pages/Physics/courses/RG/02_toolkit/).

**Pauli-Villars.** A way to regularise by subtracting the same diagram with an imaginary very heavy particle. [Part 2](/Pages/Physics/courses/RG/02_toolkit/).

**Dimensional regularisation.** A way to regularise by doing the integral in $d$ dimensions, where it's finite, then letting $d$ approach 4. Infinities appear as $1/\epsilon$ with $\epsilon=4-d$. [Part 2](/Pages/Physics/courses/RG/02_toolkit/).

**Euclidean space, Wick rotation.** Replacing real time $t$ by imaginary time, which turns quantum formulas into statistical-physics formulas and makes integrals easier. *Picture:* swinging a rubber band round two nails without catching them. [Part 2](/Pages/Physics/courses/RG/02_toolkit/).

**Feynman parameters.** A trick that squeezes several denominators into one, so an integral becomes symmetric. *Picture:* considering every mixture of two paints. [Part 2](/Pages/Physics/courses/RG/02_toolkit/).

**Master formula.** The one integral, $\int\frac{\dd^d\ell}{(2\pi)^d}\frac1{(\ell^2+\Delta)^n}$, that every one-loop calculation reduces to. [Part 2](/Pages/Physics/courses/RG/02_toolkit/).

**Superficial degree of divergence $D$.** A quick count of how badly a diagram diverges: powers of momentum on top minus powers on the bottom. [Part 2](/Pages/Physics/courses/RG/02_toolkit/).

**Bare parameter.** A number written in the Lagrangian, like $m_0$ or $\lambda_0$. It's never measured directly. *Picture:* the mass of a ball that can never be taken out of the water. [Part 2](/Pages/Physics/courses/RG/02_toolkit/).

**Physical (renormalised) parameter.** The value you actually measure, like the position of the propagator's pole.

**Renormalisation.** Rewriting predictions in terms of measured parameters instead of bare ones. When you do, the regulator drops out. [Part 2](/Pages/Physics/courses/RG/02_toolkit/).

**Counterterm.** An extra piece added to a bare parameter to cancel an infinity. [Part 7](/Pages/Physics/courses/RG/07_running/).

**Minimal subtraction (MS).** Choosing counterterms that cancel only the $1/\epsilon$ infinities and nothing else. [Part 7](/Pages/Physics/courses/RG/07_running/).

**Renormalisable.** A theory where only finitely many kinds of quantity diverge, so finitely many counterterms suffice. [Parts 2 and 8](/Pages/Physics/courses/RG/08_eft/).

## Scaling

**Dimensional analysis, mass dimension.** Working out how quantities scale with units. With $\hbar=c=1$ everything is a power of mass; for example $[\phi]=1$ in four dimensions. [Part 1](/Pages/Physics/courses/RG/01_scale/).

**Scaling dimension.** How a quantity changes when you zoom out. Near the free fixed point it equals the mass dimension. [Part 5](/Pages/Physics/courses/RG/05_wilson/).

**Anomalous dimension.** The extra scaling a field gets from interactions, beyond plain dimensional analysis. [Part 7](/Pages/Physics/courses/RG/07_running/).

**Power counting.** Using mass dimensions to decide which couplings are relevant, marginal or irrelevant. [Part 5](/Pages/Physics/courses/RG/05_wilson/).

**Gaussian fixed point.** The free theory, with no interactions. The RG leaves it unchanged. [Part 5](/Pages/Physics/courses/RG/05_wilson/).

**Upper critical dimension.** The dimension (four, for magnets like Ising) above which mean-field theory gives the right exponents. [Part 5](/Pages/Physics/courses/RG/05_wilson/).

**Wilson-Fisher fixed point.** The interacting fixed point that controls real critical points below four dimensions. [Part 6](/Pages/Physics/courses/RG/06_wilson_fisher/).

**ε expansion.** Working in $d=4-\epsilon$ dimensions, where the fixed point is at small coupling and expanding in $\epsilon$. *Picture:* using $\sqrt{1+x}\approx1+x/2$ even at $x=1$. [Part 6](/Pages/Physics/courses/RG/06_wilson_fisher/).

**Cumulant expansion.** The formula $\ln\langle e^{-X}\rangle=-\langle X\rangle+\tfrac12(\langle X^2\rangle-\langle X\rangle^2)-\dots$ used to average out the fast modes. [Part 6](/Pages/Physics/courses/RG/06_wilson_fisher/).

**Functional RG, Wetterich equation.** An exact equation for how the whole action changes as the scale $k$ is lowered, rather than how two or three couplings change. It is one loop in shape, with the full propagator inside. [Part 6](/Pages/Physics/courses/RG/06_wilson_fisher/).

**Regulator $R_k$.** A mass-like term added by hand to the modes slower than $k$, which freezes them so only modes near $k$ contribute. It switches off at the end. *Picture:* a weight tied to the long waves. [Part 6](/Pages/Physics/courses/RG/06_wilson_fisher/).

**Local potential approximation (LPA).** Solving the functional RG while keeping the kinetic term fixed, so only the potential flows. It gives $\nu=0.6496$ in three dimensions against the true $0.6300$, with $\eta=0$ by construction. [Part 6](/Pages/Physics/courses/RG/06_wilson_fisher/).

**Derivative expansion.** The systematic sequence beyond the LPA, keeping more terms with derivatives in them. At order $\partial^6$ it matches the best known 3D Ising exponents to five digits. [Part 6](/Pages/Physics/courses/RG/06_wilson_fisher/).

**Correction-to-scaling exponent $\omega$.** The largest irrelevant eigenvalue at a fixed point. It sets how fast the corrections to a scaling law die away as you approach $T_c$, through $\xi\sim t^{-\nu}(1+a\,t^{\nu\omega})$. Bigger $\omega$ means cleaner scaling sooner. [Parts 4 and 6](/Pages/Physics/courses/RG/06_wilson_fisher/).

**Conformal bootstrap.** A method that pins down critical exponents from symmetry plus consistency alone, with no perturbation theory. It currently gives the most accurate 3D Ising numbers, such as $\nu=0.629971(4)$. [Part 6](/Pages/Physics/courses/RG/06_wilson_fisher/).

## Running couplings

**Beta function $\beta$.** How fast a coupling changes as you change the scale: $\beta=\mu\,\dd g/\dd\mu$. Positive means it grows with energy. *Picture:* the exchange rate between descriptions at different scales. [Part 7](/Pages/Physics/courses/RG/07_running/).

**Running coupling.** A coupling whose value depends on the energy at which you measure it, such as $\alpha$ going from $1/137$ to $1/128$. [Part 7](/Pages/Physics/courses/RG/07_running/).

**Callan-Symanzik equation.** The equation that says physics can't depend on the arbitrary scale $\mu$. [Part 7](/Pages/Physics/courses/RG/07_running/).

**Landau pole.** An energy where a one-loop running coupling blows up. It signals that the theory must change before then. [Parts 6 and 7](/Pages/Physics/courses/RG/07_running/).

**Vacuum polarisation.** A photon briefly turning into a charged pair and back. It makes the vacuum behave like a dielectric. [Part 7](/Pages/Physics/courses/RG/07_running/).

**Screening.** A charge looking smaller from far away because the surrounding medium partly hides it. *Picture:* water molecules turning around an ion. [Part 7](/Pages/Physics/courses/RG/07_running/).

**Asymptotic freedom.** A coupling that shrinks at high energy, like the strong force. *Picture:* quarks on a rubber band that is slack up close. [Part 7](/Pages/Physics/courses/RG/07_running/).

**Colour, flavour.** Colour is the strong charge, which comes in three kinds instead of the one kind electric charge has. Flavour is the quark type: up, down, strange, charm, bottom, top. The one-loop QCD coefficient counts both, as $N=3$ colours against $n_f$ flavours. [Part 7](/Pages/Physics/courses/RG/07_running/).

**Gluon.** The carrier of the strong force, the photon's counterpart. Unlike the photon it carries colour charge itself, so gluons pull on each other. That one difference is what flips the sign of the beta function. [Part 7](/Pages/Physics/courses/RG/07_running/).

**Ghost.** A fake field added when a gauge is fixed, which cancels the unphysical polarisations of the gluon. It appears only inside loops, never as a real particle. [Part 7](/Pages/Physics/courses/RG/07_running/).

**Antiscreening.** The opposite of screening: the cloud around a colour charge carries the *same* colour, so the charge looks bigger from further away. It is why QCD is asymptotically free. *Picture:* a rumour that grows as it spreads instead of fading. [Part 7](/Pages/Physics/courses/RG/07_running/).

**$\Lambda_{\rm QCD}$, dimensional transmutation.** The energy at which the one-loop strong coupling blows up, about $0.09$ GeV at one loop. It is a mass that appears out of a theory whose Lagrangian had no mass in it, produced by the running alone. That trade of a dimensionless number for an energy is dimensional transmutation. [Part 7](/Pages/Physics/courses/RG/07_running/).

**Triviality.** When the only way a theory can work at all energies is to have no interactions at all, as is believed for $\phi^4$ in four dimensions. [Part 8](/Pages/Physics/courses/RG/08_eft/).

**Asymptotic safety.** A theory whose short-distance end is an interacting fixed point. [Part 8](/Pages/Physics/courses/RG/08_eft/).

**Naturalness, hierarchy problem.** The puzzle that a light Higgs boson needs its bare mass tuned to about thirty digits. *Picture:* a pencil balanced on its tip. [Parts 1, 2 and 8](/Pages/Physics/courses/RG/08_eft/).

\coursenav{}{}{/Pages/Physics/courses/RG/01_scale/}{Part 1: Why scale matters}

{{comments}}
