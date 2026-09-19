+++
title = "The Renormalisation Group: from Block Spins to Running Couplings"
hascode = true
rss = "An eight-part beginner's course on the renormalisation group, in simple words with an everyday picture for every idea: loops and cutoffs from scratch, block spins and the Ising chain, fixed points and universality, Wilson's momentum shells, the Wilson-Fisher fixed point, running couplings in QED and QCD, then effective field theory. Every formula checked in Wolfram and FORM, with live simulations in the browser."
rss_title = "The Renormalisation Group: a beginner's course"
rss_pubdate = Date(2026, 9, 19)
card = true
card_category = "Course"

tags = ["physics", "qft", "renormalization", "statistical-mechanics", "course"]
+++

# **\col{#3c568e}{The Renormalisation Group}**: A Course for People Who Know a Little QFT

Physics looks different depending on how closely you look. Up close, water is molecules bumping into each other. From a metre away it is a smooth liquid with a density and a viscosity. Nobody needs the molecules to predict how it flows. The renormalisation group (RG for short) is the mathematics of that change of view. It tells you how the numbers in a theory must change when you step back and look from further away.

That one idea explains a surprising amount:

- why a magnet and a boiling liquid share exactly the same strange numbers near their critical points,
- why the electric charge of an electron looks bigger when you probe it harder,
- why quarks are almost free inside a proton but can never escape it,
- and why we can do physics at all without knowing what happens at the smallest scales.

## First, one word: coarse-graining

The whole course keeps using one word, so here it is with a picture.

~~~
<div class="mfig" style="--w:520px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/pixel_blocking.svg" alt="An image with its resolution lowered twice by averaging 2 by 2 blocks of pixels">
  <p>Coarse-graining a picture: replace every 2×2 square of pixels by one pixel with their average shade, then do it again. Fine detail is lost, but the big shapes survive.</p>
</div>
~~~

\analogy{
**Coarse-graining** means throwing away fine detail by merging small pieces into bigger ones. It is what happens when you lower the resolution of a photo, or when you step back from a painting: the brush strokes blur together and you see the big picture.
}

For a magnet made of tiny arrows (spins) that point up or down, coarse-graining means taking a small block of neighbouring spins and replacing it with one big spin that points the way most of them point. It's a majority vote. The result is the same magnet, seen from further away.

~~~
<div class="mfig" style="--w:540px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/RG/self_similar.svg" alt="A 2D Ising magnet coarse-grained three times above, at and below the critical temperature">
  <p>The whole course in one picture. A simulated magnet (the two colours are the two spin directions) is coarse-grained three times by majority vote, moving left to right. Too hot (top row) and the blocks drift towards noise: neighbours agree 0.58 of the time, then 0.47, 0.37, 0.23. Too cold (bottom row) and they drift to one colour: 0.82, 0.87, 0.93, 0.98. At exactly the critical temperature (middle row) the number barely moves: 0.71, 0.69, 0.70, 0.70. Something that doesn't change when you zoom out is called a <b>fixed point</b> and finding fixed points is what the RG does.</p>
</div>
~~~

\note{
**How to read this figure.** Each little square is a snapshot of a simulated magnet: a grid of spins, each pointing up or down, shown as the two colours.

- **Going right** is one coarse-graining step each time. Every 2×2 block of spins is replaced by one spin pointing the way the majority of the four point. So one pixel stands for 1 spin in the first column, then 4, then 16, then 64. Moving right is stepping back from the magnet: you see it from 2, 4, then 8 times further away.
- **Each row** is one temperature, held fixed. The row is the RG flow: it shows what that magnet turns into when you keep zooming out.
- **The number under each panel** is how often neighbouring spins agree, averaged over 16 independent simulations. It's the flow written as a number instead of a picture. Hot rows fall towards 0 (no agreement, pure noise), cold rows climb towards 1 (everything agrees) and the critical row barely moves. For the exact 2D Ising model at $T_c$ this number is $1/\sqrt2=0.707$, which is what the simulation gives.

Two honest caveats. The grid is finite, so by the last column it is only 32×32 and one colour can win just by luck. And each picture is a single snapshot, so "looks the same" is a statement about the *kind* of picture, not about the exact pattern.
}

\note{
**Stuck on a word?** Every technical term in the course, from "cutoff" to "beta function", is explained in plain language, with a picture, in the [**glossary**](/Pages/Physics/courses/RG/glossary/).
}

## What you need to know first

You need calculus, a little complex analysis (what a pole is) and the idea that a field is a number at every point of space. It helps to have seen a path integral and a Feynman diagram once, but you don't need to be comfortable with them: Part 2 derives the Feynman rules from scratch, including where the propagator, the vertex, the minus signs and the symmetry factors come from. You don't need to have met a loop integral, a cutoff or the word "regularisation" before and you need no statistical mechanics beyond the Boltzmann factor $e^{-E/k_BT}$.

\note{
**How this course was checked.** Every calculation was redone by computer: Wolfram Language for the integrals (including the complex contour integrals) and FORM for the Dirac matrices in QED. Every number was then reproduced a second way, in Python, JavaScript or a Monte Carlo simulation. The main sources are [David Tong's *Statistical Field Theory*](https://davidtong.org/teaching/statistical-field-theory/) for the magnet side and most of the intuition, João Melo's [*Introduction to Renormalisation*](https://arxiv.org/abs/1909.11099) for the field theory side and Peskin & Schroeder and Ashok Das's *Field Theory: A Path Integral Approach* for the QFT tools. Where a source has a mistake, the course says so at that point.
}

## The eight parts

~~~
<div class="feature__wrapper">
  <div class="feature__item"><div class="archive__item"><div class="archive__item-body">
    <h2 class="archive__item-title">1 · Why scale matters</h2>
    <div class="archive__item-excerpt"><p>A simple quantum correction to a particle's mass comes out infinite. What that is really telling us, drawn out diagram by diagram.</p></div>
    <p><a href="/Pages/Physics/courses/RG/01_scale/" class="btn btn--primary">Read</a></p>
  </div></div></div>
  <div class="feature__item"><div class="archive__item"><div class="archive__item-body">
    <h2 class="archive__item-title">2 · Loops, infinities and cutoffs</h2>
    <div class="archive__item-excerpt"><p>The toolkit from zero: where Feynman diagrams and their rules come from, why loops blow up, the Wick rotation, what a cutoff is and what renormalisation actually does. Interactive.</p></div>
    <p><a href="/Pages/Physics/courses/RG/02_toolkit/" class="btn btn--primary">Read</a></p>
  </div></div></div>
  <div class="feature__item"><div class="archive__item"><div class="archive__item-body">
    <h2 class="archive__item-title">3 · Block spins</h2>
    <div class="archive__item-excerpt"><p>Coarse-grain a line of spins exactly, by hand, then watch the coupling change. Interactive.</p></div>
    <p><a href="/Pages/Physics/courses/RG/03_block_spins/" class="btn btn--primary">Read</a></p>
  </div></div></div>
  <div class="feature__item"><div class="archive__item"><div class="archive__item-body">
    <h2 class="archive__item-title">4 · Fixed points and universality</h2>
    <div class="archive__item-excerpt"><p>Why a magnet and a liquid behave identically at their critical points. A live magnet simulation you can coarse-grain yourself.</p></div>
    <p><a href="/Pages/Physics/courses/RG/04_fixed_points/" class="btn btn--primary">Read</a></p>
  </div></div></div>
  <div class="feature__item"><div class="archive__item"><div class="archive__item-body">
    <h2 class="archive__item-title">5 · Wilson's shells</h2>
    <div class="archive__item-excerpt"><p>The same idea for a field: remove the fastest wiggles, zoom out, repeat. Why only a few terms in a Lagrangian ever matter.</p></div>
    <p><a href="/Pages/Physics/courses/RG/05_wilson/" class="btn btn--primary">Read</a></p>
  </div></div></div>
  <div class="feature__item"><div class="archive__item"><div class="archive__item-body">
    <h2 class="archive__item-title">6 · The Wilson-Fisher point</h2>
    <div class="archive__item-excerpt"><p>A one-loop calculation that finds the fixed point behind real 3D critical points. Interactive flow.</p></div>
    <p><a href="/Pages/Physics/courses/RG/06_wilson_fisher/" class="btn btn--primary">Read</a></p>
  </div></div></div>
  <div class="feature__item"><div class="archive__item"><div class="archive__item-body">
    <h2 class="archive__item-title">7 · Running couplings</h2>
    <div class="archive__item-excerpt"><p>Why the charge of the electron grows when you look closer and why the strong force weakens. Interactive.</p></div>
    <p><a href="/Pages/Physics/courses/RG/07_running/" class="btn btn--primary">Read</a></p>
  </div></div></div>
  <div class="feature__item"><div class="archive__item"><div class="archive__item-body">
    <h2 class="archive__item-title">8 · Effective field theory</h2>
    <div class="archive__item-excerpt"><p>Why physics works at all without a final theory, what "renormalisable" really means and where to go next.</p></div>
    <p><a href="/Pages/Physics/courses/RG/08_eft/" class="btn btn--primary">Read</a></p>
  </div></div></div>
</div>
~~~

## How to use it

Read the parts in order, since each one builds on the last. Every part ends with exercises; try each one before you open its solution. Most take about ten minutes.

The interactive boxes run inside your own browser, so nothing is sent anywhere. They're kept light enough that your computer won't slow down and the magnet simulation pauses itself when you scroll away from it. When a widget sits next to a paragraph, playing with the widget is usually the quickest way to understand the paragraph.

If you only have one evening, read Parts 3 and 4. They contain the whole idea without any field theory.

\coursenav{}{}{/Pages/Physics/courses/RG/01_scale/}{Part 1: Why scale matters}

{{comments}}
