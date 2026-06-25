+++
title = "About Me"
hascode = false
rss = "Kazi Abu Rousan — PhD student in Cosmology at NISER. Research in early-universe cosmology, recombination and CMB spectral distortions, with scientific computing in Julia and Python."
rss_title = "About / CV"
rss_pubdate = Date(2019, 5, 1)

tags = ["physics", "code", "Kazi Abu Rousan"]
+++

~~~
<style>
  .cv-header {
    display: flex; gap: 2rem; align-items: center; flex-wrap: wrap;
    margin: 1.5rem 0 2.5rem;
  }
  .cv-header img.cv-photo {
    width: 215px; height: auto; border-radius: 16px;
    box-shadow: 0 12px 30px rgba(0,0,0,0.14);
    border: 4px solid var(--pastel-bg, #fdfbf7);
    flex-shrink: 0;
  }
  .cv-id { flex: 1; min-width: 250px; }
  .cv-id h1 { margin: 0 0 .25rem; font-size: 2.9rem; line-height: 1; }
  .cv-role {
    font-family: 'Lora', Georgia, serif; font-style: italic;
    color: var(--pastel-link, #2f6d78); font-size: 1.15rem; margin-bottom: .5rem;
  }
  .cv-tagline { color: var(--pastel-text, #444); margin-bottom: 1rem; font-size: .98rem; }
  .cv-links { display: flex; flex-wrap: wrap; gap: .5rem; }
  .cv-links a {
    display: inline-flex; align-items: center; gap: .4rem;
    padding: .35rem .85rem; border: 1px solid #e2d9c7; border-radius: 30px;
    font-size: .85rem; font-weight: 600; text-decoration: none !important;
    color: var(--pastel-link, #2f6d78); transition: all .2s ease;
  }
  .cv-links a:hover {
    background: var(--pastel-link, #2f6d78); color: #fff !important;
    transform: translateY(-2px);
  }
  .cv-links a i { color: var(--ornament-gold, #9c7a3c); }
  .cv-links a:hover i { color: #fff; }

  /* proficiency / score bars */
  .bar-row { display: flex; align-items: center; gap: .9rem; margin: .45rem 0; }
  .bar-row .blabel { width: 168px; font-weight: 600; font-size: .9rem; flex-shrink: 0; }
  .bar-row .track {
    flex: 1; height: 11px; background: #ece3d3; border-radius: 6px; overflow: hidden;
  }
  .bar-row .fill {
    height: 100%; border-radius: 6px;
    background: linear-gradient(90deg, var(--pastel-link, #2f6d78), var(--ornament-gold, #b8923f));
  }
  .bar-row .bval { width: 64px; text-align: right; font-size: .8rem; color: #8a8170; flex-shrink: 0; }

  .edu-item { margin: 0 0 1.2rem; }
  .edu-item .ehead { font-weight: 700; font-size: 1.02rem; }
  .edu-item .esub { color: #6b6358; font-size: .9rem; margin: .15rem 0 .35rem; font-style: italic; }

  .cv-skills { display: flex; flex-wrap: wrap; gap: .5rem; margin: .4rem 0 1rem; }
  .cv-skills span {
    background: #f1ebde; color: #7a5a2a; padding: .32rem .7rem;
    border-radius: 6px; font-size: .85rem; font-weight: 600;
  }
  .franklin-content h2 {
    border-bottom: 1px solid #e7ded0; padding-bottom: .3rem;
    margin-top: 1.9rem; margin-bottom: .8rem;
  }
  /* The theme locks content to a narrow 705px centred column, which leaves
     huge empty margins on a wide screen. Use the available width as a clean,
     left-aligned document instead. */
  @media (min-width: 940px) {
    .franklin-content {
      width: auto !important; max-width: 880px;
      padding-left: 1.5rem !important; padding-right: 1.5rem !important;
      margin-left: auto !important; margin-right: auto !important;
    }
  }
  /* Tighten the loose vertical rhythm (figures + broken lists left big gaps) */
  .franklin-content ul { margin-top: .35rem; margin-bottom: .35rem; }
  .edu-item { margin-bottom: .85rem !important; }
  .franklin-content .cv-img { margin: .5rem auto 1rem !important; }

  /* Clean CV lists — no bullet/arrow marks, just a thin accent rule */
  .franklin-content ul { list-style: none; padding-left: 0; margin-left: 0; }
  .franklin-content ul li {
    margin: 0 0 .7rem; padding-left: .9rem;
    border-left: 2px solid #e2d9c7; list-style: none;
  }
  .franklin-content ul li::marker { content: ""; }
  .franklin-content ul ul { margin-top: .5rem; }

  /* Embedded videos: centred, comfortable size, responsive */
  .franklin-content iframe {
    display: block; margin: 1rem auto 1.4rem;
    width: 100%; max-width: 480px; aspect-ratio: 16 / 9; height: auto;
    border-radius: 8px;
  }

  /* dark mode */
  html.dark-mode .franklin-content ul li { border-left-color: #3a3326; }
  html.dark-mode .cv-header img.cv-photo { border-color: #1e1a13; }
  html.dark-mode .cv-links a { border-color: #3a3326; color: #d8b46a; }
  html.dark-mode .cv-links a i { color: #d8b46a; }
  html.dark-mode .cv-links a:hover { background: #d8b46a; color: #14110d !important; }
  html.dark-mode .cv-links a:hover i { color: #14110d; }
  html.dark-mode .bar-row .track { background: #2a2419; }
  html.dark-mode .bar-row .bval { color: #a99f8a; }
  html.dark-mode .edu-item .esub { color: #a99f8a; }
  html.dark-mode .cv-skills span { background: #2a2419; color: #e0c489; }
  html.dark-mode .franklin-content h2 { border-bottom-color: #322c22; }
</style>

<div class="cv-header">
  <img class="cv-photo" src="/assets/me.webp" alt="Kazi Abu Rousan">
  <div class="cv-id">
    <h1>Kazi Abu Rousan</h1>
    <div class="cv-role">PhD Student in Cosmology &middot; NISER</div>
    <div class="cv-tagline">Early-Universe Cosmology &middot; Mathematical Physics &middot; Scientific Computing &middot; Science Outreach</div>
    <div class="cv-links">
      <a href="https://www.linkedin.com/in/kazi-abu-rousan-819848198/" rel="noopener"><i class="fab fa-linkedin"></i> LinkedIn</a>
      <a href="https://github.com/aburousan" rel="noopener"><i class="fab fa-github"></i> GitHub</a>
      <a href="https://www.researchgate.net/profile/Kazi-Abu-Rousan" rel="noopener"><i class="fab fa-researchgate"></i> ResearchGate</a>
      <a href="https://medium.com/@kaziaburousan" rel="noopener"><i class="fab fa-medium"></i> Medium</a>
    </div>
  </div>
</div>
~~~

## Profile

I'm **Kazi Abu Rousan**, a PhD student in **Cosmology** at [NISER](https://www.niser.ac.in/), with a Master's degree in Physics (High-Energy Physics) from the [Indian Association for the Cultivation of Science (IACS)](https://www.iacs.res.in/). I work on the physics of the **early universe**, build small scientific tools in Julia, Python and R, and care a lot about teaching and science communication — I create expository articles, videos, and animations, and have mentored students for the Physics and Mathematics Olympiads.

## Research Interests

My current research is on **primordial gravitational waves** and **inflation**, the study of **galactic dust and its cross-correlation with the Cosmic Infrared Background (CIB)**, and **modified theories of gravity** — I'm currently writing a paper in this area with collaborators in theoretical physics. More broadly, I'm interested in **early-universe cosmology** and **cosmological perturbation theory** (the long-term goal of my Julia package *Cosmic.jl*), along with **non-commutative quantum mechanics** and time crystals, and **computational and numerical methods** for physics.

## Education

~~~
<div class="edu-item">
  <div class="ehead">M.Sc. in Physics (High-Energy Physics) — Indian Association for the Cultivation of Science (IACS), Jadavpur, Kolkata</div>
  <div class="esub">MS Project: Study of Recombination and spectral distortion of the CMB</div>
</div>

<div class="edu-item">
  <div class="ehead">B.Sc. in Physics — Sripatsingh College, Jiaganj (University of Kalyani)</div>
  <div class="esub">B.Sc. Dissertation: Introduction to Anyons and a Generalized Distribution Function</div>
</div>

<div class="edu-item">
  <div class="ehead">Higher Secondary — Nawab Bahadur's Institution, Murshidabad</div>
</div>
~~~

## Experience

* **NISER, Bhubaneswar — PhD** *(ongoing)* — School of Physical Sciences (Cosmology).
* **NISER, Bhubaneswar — Junior Research Fellow** *(completed)* — School of Earth and Planetary Sciences; worked on a project in collaboration with the Max Planck Society.
* **Cheenta Ganit Kendra, Kolkata — Mentor** *(former)* — Physics teacher for the Physics Olympiad, and content creator on Cheenta's YouTube channel.
* **Chegg, Kolkata — Advanced Physics Expert**.
* **S. N. Bose National Centre for Basic Sciences — Summer Project Student** — *Can the time-crystal nature arise naturally from Non-Commutative Quantum Mechanics?* (under Prof. Archan S. Majumdar).
* **Introduction to Astronomy Research — Summer School (2023)** — Mentor for the course on using NumPy, SciPy and Astropy for data analysis.

## Publications & Selected Work

* [**Method of Images and its Relation to Optical Images**](https://link.springer.com/article/10.1007/s12045-022-1398-y) — *Resonance* (Springer). DOI: [10.1007/s12045-022-1398-y](https://doi.org/10.1007/s12045-022-1398-y). How optical lens formulas mirror the electrostatic method of images.
~~~
<img src="https://www.researchgate.net/profile/Kazi-Abu-Rousan/publication/361545877/figure/fig7/AS:1171982066429952@1656433707070/Here-you-see-the-fields-from-qred-to-qblue-The-field-is-symmetry-about-the-grounded_W640.jpg" class="cv-img" loading="lazy" decoding="async" style="max-width: 340px;">
~~~

* [**Diffraction patterns from different orientations of rectangular apertures**](https://www.researchgate.net/publication/356142815_Diffraction_patterns_by_different_orientation_of_rectangular_Apertures_Intuitive_understanding_of_Optical_Transformations) — *submitted to Resonance*. Based on a TIFR problem; how diffraction patterns change with aperture configuration, simulated in Python.
~~~
<img src="https://www.researchgate.net/profile/Kazi-Abu-Rousan/publication/356142815/figure/fig2/AS:1098551824265217@1638926573534/Diffraction-pattern-of-the-aperture-in-Fig-2.ppm" class="cv-img" loading="lazy" decoding="async" style="max-width: 340px;">
~~~

* **A new formula for $\pi$** — discovered while [extending the Gauss circle problem to a triangular grid](https://www.researchgate.net/publication/370161335_Extension_of_Gauss_circle_problem_Lattices_for_a_Triangular_grid); published in *MSAST 2022*, Kolkata.
~~~
<img src="https://www.researchgate.net/profile/Kazi-Abu-Rousan/publication/370161335/figure/fig3/AS:11431281152663383@1682100177142/A-circle-of-Radius-7-has-18-lattice-points-on-it_Q320.jpg" class="cv-img" loading="lazy" decoding="async" style="max-width: 340px;">
~~~

* [**Introduction to Anyons and a Generalized Distribution Function**](https://www.researchgate.net/publication/352641643_Introduction_to_Anyons_and_generalized_distribution_function) — my B.Sc. project: a generalized distribution function for **anyons** that recovers the Bose–Einstein and Fermi–Dirac distributions as special cases.

* [**Time Crystal as a consequence of Non-Commutative Quantum Mechanics for a 2D Harmonic Oscillator**](https://www.researchgate.net/publication/372221313_Time_Crystal_as_a_consequence_of_NonCommutative_Quantum_Mechanics_for_2D_Harmonic_Oscillator) — 2023 summer project at the S. N. Bose National Centre for Basic Sciences.
~~~
<img src="https://www.researchgate.net/profile/Kazi-Abu-Rousan/publication/372221313/figure/fig1/AS:11431281173427597@1688888680920/Physical-Realisation-of-Time-Crystal_W640.jpg" class="cv-img" loading="lazy" decoding="async" style="max-width: 340px;">
~~~

* [**Basic Recombination and Formation of Neutral Hydrogen in the Early Universe**](https://www.researchgate.net/publication/376889659_Basic_Recombination_and_Formation_of_Neutral_Hydrogen_in_Early_Universe) — the mechanism of recombination, including a discussion of **Peebles' equation**.

* [**Power Logarithmic Inequality**](http://www.ssmrmh.ro/2021/02/12/power-logarithmic-inequality/) — *Romanian Mathematical Magazine*.

## Software & Tools

* [**Cosmic.jl**](https://github.com/aburousan/cosmic.jl) — a Julia package I'm developing for basic cosmology computations, aimed eventually at cosmological perturbations.
* [**astronomR**](https://github.com/samrit2442/astronomR) — an R package for astronomy and astrophysics, developed with **Samrit Pramanik**.
* **Radiometric Calibration of the DAWN VIR dataset** — I built a [web app](https://virdawnradiometrical.streamlit.app/) for the calibration: upload `.lbl`, `.qub`, and house-keeping data, then download the calibrated `.npy` file.
~~~
<img src="/assets/radio_cal_1.webp" class="cv-img" loading="lazy" decoding="async" style="max-width: 340px;">
~~~
* **Mathematics & physics animations** with [manim](https://www.manim.community/) — see the [playlist](https://youtube.com/playlist?list=PLTDTcDkWcXuzwI6M1bGzNh6dDPCB9qZiu&si=I8vaX6GaIaK5jVei).
~~~
<iframe width="220" height="124" loading="lazy" src="https://www.youtube.com/embed/videoseries?si=PXwPtqGFReU-ZJct&amp;list=PLTDTcDkWcXuzwI6M1bGzNh6dDPCB9qZiu" title="manim animations" frameborder="0" allow="accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
~~~

## Teaching & Outreach

* **Olympiad mentoring** — previously mentored students in Mathematics and Physics for the Olympiads at Cheenta Ganit Kendra.
* **Mentor, Introduction to Astronomy Research — Summer School (2023)**: authored the notes and assignments on Matplotlib, NumPy, SciPy and Astropy ([materials](https://github.com/howardisaacson/Intro-to-Astro2023/tree/main/Week2_packages_plotting), [course](https://sites.google.com/view/intro-2-astro/2023-course)).
~~~
<iframe width="220" height="124" loading="lazy" src="https://www.youtube.com/embed/0wXsGut5kYY" title="Intro2Astro: Numpy, Scipy & Astropy" frameborder="0" allow="accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
~~~
* **Instructor (Python)** for *Approaching Computational Thinking with R + Python*, organised by [Cosmic Charade](https://cosmic-charade.netlify.app/).
* **Upcoming book** on [Number Theory](https://drive.google.com/file/d/1dD4zTXiz76PVD15ZdT4v-SawX2OkMIc8/view?usp=drive_link) — the first chapter is linked.
* **Expository articles on Medium:** [What is the Fourier Series? And its Beauty](https://medium.com/swlh/what-is-fourier-series-and-its-beauty-ce2410012329) (with a [video](https://youtu.be/0y8UsIFcvPs)), and [Trapezoidal Rule: a method of numerical integration](https://www.cantorsparadise.com/trapezoidal-rule-a-method-of-numerical-integration-5772838657b3).
* **Digital art** — see some of it [here](/Pages/art/).

## Skills

~~~
<div>
  <div class="bar-row"><span class="blabel">Python</span><div class="track"><div class="fill" style="width:95%"></div></div><span class="bval">Expert</span></div>
  <div class="bar-row"><span class="blabel">Julia</span><div class="track"><div class="fill" style="width:90%"></div></div><span class="bval">Expert</span></div>
  <div class="bar-row"><span class="blabel">LaTeX</span><div class="track"><div class="fill" style="width:95%"></div></div><span class="bval">Expert</span></div>
  <div class="bar-row"><span class="blabel">Mathematica</span><div class="track"><div class="fill" style="width:82%"></div></div><span class="bval">Advanced</span></div>
  <div class="bar-row"><span class="blabel">R</span><div class="track"><div class="fill" style="width:75%"></div></div><span class="bval">Proficient</span></div>
  <div class="bar-row"><span class="blabel">C++</span><div class="track"><div class="fill" style="width:70%"></div></div><span class="bval">Proficient</span></div>
  <div class="bar-row"><span class="blabel">Qiskit (Quantum)</span><div class="track"><div class="fill" style="width:72%"></div></div><span class="bval">Proficient</span></div>
  <div class="bar-row"><span class="blabel">Arduino &amp; ESP32</span><div class="track"><div class="fill" style="width:66%"></div></div><span class="bval">Working</span></div>
</div>
~~~

## Beyond Research

And of course, my cat — Mr. **Gino**!

~~~
<img src="/assets/gino.webp" alt="Gino the cat" class="cv-img" loading="lazy" decoding="async" style="max-width: 320px;">
~~~

~~~
<button onclick="window.history.back()">Go Back</button>
~~~
