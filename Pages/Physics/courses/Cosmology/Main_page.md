+++
title = "The Expanding Universe — with Cosmic.jl"
hascode = true
rss = "A five-part tour through cosmology (Baumann, Chapters 2, 5 and 6): the homogeneous universe's geometry, kinematics, dynamics and thermal history, then how tiny perturbations grow into galaxies — with every result checked numerically against my Julia package Cosmic.jl."
rss_title = "The Expanding Universe with Cosmic.jl"
rss_pubdate = Date(2026, 7, 24)
card = true
card_category = "Course"

tags = ["physics", "cosmology", "course", "julia", "code"]
+++

\newcommand{\HH}{\mathcal H}

# **\col{#3c568e}{The Expanding Universe}** — a hands-on cosmology mini-course

~~~
<div class="mfig" style="--w:720px">
  <img class="cv-img math-diagram" loading="lazy" decoding="async" src="/assets/Physics/courses/Cosmology/expansion_a_of_t.svg" alt="Scale factor a(t) of our universe versus cosmic time, computed with Cosmic.jl">
  <p>The whole story in one curve: how the size of the universe, the scale factor \(a(t)\), has grown with cosmic time. Every number in this plot comes out of <a href="https://github.com/aburousan/Cosmic.jl">Cosmic.jl</a>. We spend this course learning to read it.</p>
</div>
~~~

This is a five-part reading of **Daniel Baumann's _Cosmology_ (2021)** — the first four parts follow Chapter 2, on the *homogeneous* universe; the fifth goes one chapter further, into how small *inhomogeneities* grow into the structure we actually see. I follow the book's structure and notation closely, but with one addition: at every stage we don't just write the equation, we **solve it on a computer and check the number**, using my own cosmology library [**Cosmic.jl**](https://github.com/aburousan/Cosmic.jl). Theory on the left, a plot from real code on the right.

The philosophy of the package is worth stating up front, because it shapes how we work. A cosmology, in Cosmic, is nothing but a **list of species** — photons, baryons, cold dark matter, neutrinos, dark energy — each of which knows only its own energy density $\rho_s(a)$ as a function of the scale factor. Everything else (the expansion rate, every distance, the thermal history) is *derived* from that list:

$$ \left(\frac{H(a)}{H_0}\right)^2 \;=\; \sum_s \frac{\rho_s(a)}{\rho_{c,0}} \;\equiv\; E(a)^2 . $$

So when we "verify with Cosmic.jl," we are really watching the Friedmann equation do its job.

\note{
**Who this is for.** Anyone with first-year GR-lite background: you've seen a metric, an index, and a differential equation. I re-derive the cosmology from scratch. The code is Julia, but you can read the plots without running a line of it.
}

## The five parts

~~~
<div class="feature__wrapper">
  <div class="feature__item">
    <div class="archive__item">
      <div class="archive__item-body">
        <h2 class="archive__item-title">1 · Geometry</h2>
        <div class="archive__item-excerpt">
          <p>Homogeneity and isotropy force the metric of the universe into a single shape: the Robertson–Walker line element. One function of time \(a(t)\), one number \(k\) for the curvature.</p>
        </div>
        <p><a href="/Pages/Physics/courses/Cosmology/Geometry/" class="btn btn--primary">Read</a></p>
      </div>
    </div>
  </div>
  <div class="feature__item">
    <div class="archive__item">
      <div class="archive__item-body">
        <h2 class="archive__item-title">2 · Kinematics</h2>
        <div class="archive__item-excerpt">
          <p>How light and free particles move through the expanding spacetime: geodesics, redshift, and the several different "distances" a cosmologist has to keep straight.</p>
        </div>
        <p><a href="/Pages/Physics/courses/Cosmology/Kinematics/" class="btn btn--primary">Read</a></p>
      </div>
    </div>
  </div>
  <div class="feature__item">
    <div class="archive__item">
      <div class="archive__item-body">
        <h2 class="archive__item-title">3 · Dynamics</h2>
        <div class="archive__item-excerpt">
          <p>What makes \(a(t)\) do what it does: perfect fluids, the Friedmann equations, and the exact solutions for a radiation-, matter- and \(\Lambda\)-dominated universe.</p>
        </div>
        <p><a href="/Pages/Physics/courses/Cosmology/Dynamics/" class="btn btn--primary">Read</a></p>
      </div>
    </div>
  </div>
  <div class="feature__item">
    <div class="archive__item">
      <div class="archive__item-body">
        <h2 class="archive__item-title">4 · Our Universe</h2>
        <div class="archive__item-excerpt">
          <p>The measured numbers: the cosmic energy budget, the age, matter–radiation equality, and a first look at the thermal history — Cosmic.jl versus Baumann's Table 2.1.</p>
        </div>
        <p><a href="/Pages/Physics/courses/Cosmology/Our_Universe/" class="btn btn--primary">Read</a></p>
      </div>
    </div>
  </div>
  <div class="feature__item">
    <div class="archive__item">
      <div class="archive__item-body">
        <h2 class="archive__item-title">5 · Perturbations</h2>
        <div class="archive__item-excerpt">
          <p>The universe isn't perfectly smooth — and that's why we exist. How tiny density ripples grow under gravity, from Newtonian dust to the full relativistic treatment, into the galaxies and the matter power spectrum we measure.</p>
        </div>
        <p><a href="/Pages/Physics/courses/Cosmology/Perturbations/" class="btn btn--primary">Read</a></p>
      </div>
    </div>
  </div>
</div>
~~~

## How to follow along

Everything below is reproducible. Install the package and open a REPL:

```julia
using Pkg
Pkg.add(url="https://github.com/aburousan/Cosmic.jl")
using Cosmic

c = cosmology()          # Planck 2018 ΛCDM
age(c)                   # ≈ 13.8 Gyr
```

Each part ends with the exact snippet that produced its figures, so you can change a parameter and watch the universe respond.

~~~
<button onclick="window.history.back()">Go Back</button>
~~~

{{comments}}
