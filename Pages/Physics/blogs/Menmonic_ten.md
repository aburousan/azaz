+++
title = "Mnemonic for Riemann Curvature Tensor"
hascode = true
rss = "Riemann Curvature Tensor is one of the most important thing in General Relativity. But how do we remember that?, well let's see here."
rss_title = "Mnemonic for Riemann Curvature Tensor"
rss_pubdate = Date(2024, 7, 19)

tags = ["physics", "General Relativity", "Tensor", "Curvature", "Differential Geometry"]
+++

\toc

# Mnemonic for Riemann Curvature Tensor
In differential geometry, the **\col{purple}{Riemann Curvature Tensor}** is the most common way used to express the curvature of Riemannian manifolds. It assigns a tensor to each point of a Riemannian manifold (i.e., it is a tensor field). It is a local invariant of Riemannian metrics which measures the failure of the second covariant derivatives to commute.

But what is this **\col{red}{Riemann Curvature Tensor}**?, Well here I will not go into too much detail but let's see a bit of it.
## Introduction
It all starts with a very simple question, **\col{blue}{How can we tell if a space is curved or flat?}**

Well, It seems very simple right?, just by looking at the surface.
~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/Physics/blogs/Menmonic_ten/cur_st.jpeg">
    <p>
    <i></i>.
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
The right one is a sphere which is curved and the left one is a plane which is flat. But have you noticed a very important point?, **\col{red}{we are seeing the $2D$ surfaces from a $3D$ space}**, i.e., these $2D$ surfaces are embeded into $3D$ spaces.

So, to use this method, if we have a $n-D$ surface, then we need to use $(n+1) -D$ space. But most time we don't have a luxory of doing this nor we have a image of the surface in higher dimension.

As an example, earth is spherical but we live on it. So, we only have maps but no picture of the surface(until we have spacecrafts).
~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/Physics/blogs/Menmonic_ten/cur_st2.jpeg">
    <p>
    <i></i>.
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
As shown, we have some map with some coordinates on the surface. Somehow we have to use these **coordinates** with **\col{blue}{Christoffel Symbols}** or **\col{blue}{metric}** to measure curvature.

This exact thing is done by **Riemann Curvature Tensor**. The whole idea is based upon the idea of **\col{red}{Parallel Transport}** of vectors.

\note{Understanding **parallel transport** is very simple. Start with a person(here \col{green}{catto}) on a sphere with a sphere or a solid arrow board. Then, the person starts to move along any closed curve on the surface keeping the sphere as straight as possible. This is called **\col{blue}{Parallel Transport}**.
~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/Physics/blogs/Menmonic_ten/parallelt.jpeg">
    <p>
    <i></i>
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
If **\col{red}{after reaching the initial point, i.e., completing the loop, the vector points in the different direction}**(as shown in the figure above, for both catto and vector) , then we say the **\col{red}{surface/space is curved}**.}
To define  **\col{blue}{Riemann Curvature Tensor}**, we need to define two vector fields let's say $\vec{U}$ and $\vec{V}$ with the assumption that $[\vec{U}, \vec{V}]=0$. Using this two vectors we form a parallelogram as shown.
~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/Physics/blogs/Menmonic_ten/para2.jpeg">
    <p>
    <i></i>
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
\note{$[\vec{U}, \vec{V}]=0$ represent the fact that the two vectors can be used to form closed loops. If $[\vec{U},\vec{V}]\neq 0$, then we can't form closed parallelogram.
}
Let's consider a general case where each point of the parallelogram are represented by $(0,0), (r,0), (r,s)$ and $(0,s)$. Then, we take another vector $\vec{W}$ at one of the corners and parallel transport it along the parallelogram. 
~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/Physics/blogs/Menmonic_ten/para1.jpeg">
    <p>
    <i></i>
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
Now, we consider $4$ linear maps $\hat{A}, \hat{B}, \hat{C}$ and $\hat{D}$ such that,
1. $\hat{A}$ takes in $\vec{W}$ and maps it to parallel transport of $\vec{W}$ at $(r,0)$.
2. $\hat{B}$ takes in transported $\vec{W}$ from $(r,0)$ and maps it to parallel transport of $\vec{W}$ at $(r,s)$.
3. $\hat{C}$ takes in transported $\vec{W}$ from $(r,s)$ and maps it to parallel transport of $\vec{W}$ at $(0,s)$.
4. Finally, $\hat{D}$ takes it back to it's initial position.

If the space is curved, we know after the parallel transport the vector will be different. The change in the vector can be written as $\vec{W} - \hat{D}\hat{C}\hat{B}\hat{A}\vec{W}$.

From, here we define the **Riemann Curvature Tensor($R$)** as,
$$
R(\vec{U},\vec{V})\vec{W} = \lim_{r,s\to 0} \frac{\vec{W} - \hat{D}\hat{C}\hat{B}\hat{A}\vec{W}}{rs}
$$
A little simplification gives us,
$$
R(\vec{U},\vec{V})\vec{W} = \nabla_{\vec{U}}\nabla_{\vec{V}}\vec{W} - \nabla_{\vec{V}}\nabla_{\vec{U}}\vec{W} - \nabla_{[\vec{U},\vec{V}]}\vec{W}
$$
where $\nabla$ represent **\col{blue}{covariant derivative}**.

In component form, the formula of this tensor becomes,
$$
R^{\alpha}_{\beta \mu \nu} = \partial_\mu \Gamma^{\alpha}_{\nu \beta} - \partial_\nu \Gamma^{\alpha}_{\mu \beta} + \Gamma^{\alpha}_{\mu \lambda}\Gamma^{\lambda}_{\nu \beta} - \Gamma^{\alpha}_{\nu \lambda}\Gamma^{\lambda}_{\mu \beta}
$$
This is very big and really very hard to remember. Our main goal is to find a way to remember this (I hate this but it really helps).
## Mnemonic for the Tensor
To start this, let's represent $\partial_{\fbox{}}$ as $P$ and for the Christoffel Symbols $\Gamma^{\fbox{}}_{\fbox{}\fbox{}}$ as $C$. Here $\fbox{}$ is like a placeholder for $\alpha$, $\beta$, $\mu$ and $\nu$. So, we can write the pattern as,
$$
R^{\alpha}_{\beta \mu \nu} = + P\cdot C - P \cdot C + C \cdot C - C \cdot C
$$
So, first point to remember: **Write two $PC$ and $CC$ with alternating signs, starting with $+$.**
So, we have,

$$
R^{\alpha}_{\beta \mu \nu} = + \partial_{\fbox{}}\Gamma^{\fbox{}}_{\fbox{}\fbox{}} - \partial_{\fbox{}}\Gamma^{\fbox{}}_{\fbox{}\fbox{}} + \Gamma^{\fbox{}}_{\fbox{}\fbox{}} \Gamma^{\fbox{}}_{\fbox{}\fbox{}} - \Gamma^{\fbox{}}_{\fbox{}\fbox{}} \Gamma^{\fbox{}}_{\fbox{}\fbox{}}
$$
Now, for $\alpha$ put that in the correct places. This is obvious.
$$
R^{\alpha}_{\beta \mu \nu} = + \partial_{\fbox{}}\Gamma^{\alpha}_{\fbox{}\fbox{}} - \partial_{\fbox{}}\Gamma^{\alpha}_{\fbox{}\fbox{}} + \Gamma^{\alpha}_{\fbox{}\fbox{}} \Gamma^{\fbox{}}_{\fbox{}\fbox{}} - \Gamma^{\alpha}_{\fbox{}\fbox{}} \Gamma^{\fbox{}}_{\fbox{}\fbox{}}
$$
After this, for the $CC$ terms, put same **index** in the cross placeholders as shown (in red colour),
$$
R^{\alpha}_{\beta \mu \nu} = + \partial_{\fbox{}}\Gamma^{\alpha}_{\fbox{}\fbox{}} - \partial_{\fbox{}}\Gamma^{\alpha}_{\fbox{}\fbox{}} + \Gamma^{\alpha}_{\fbox{}\textcolor{lime}{\lambda}} \Gamma^{\textcolor{lime}{\lambda}}_{\fbox{}\fbox{}} - \Gamma^{\alpha}_{\fbox{}\textcolor{lime}{\lambda}} \Gamma^{\textcolor{lime}{\lambda}}_{\fbox{}\fbox{}}
$$
The next step is to take our $3$ index $\beta$, $\mu$ and $\nu$ & push the **middle**($m$) one down as shown.
~~~
<div class="row">
  <div class="container">
    <img class="center" src="/assets/Physics/blogs/Menmonic_ten/riem1.svg">
    <p>
    <i></i>.
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
<!-- \begin{tikzcd}{riem1}
\beta \mu \nu \arrow[r, "down"] & \beta & & \nu\\
 &  & \mu & 
\end{tikzcd} -->
Now, for the **positive**($+$) terms, we start from $\mu$ and go \col{blue}{anticlockwise} direction & for the **negative**($-$) terms, we start from $\nu$ and go \col{blue}{clockwise} term, as we do for \col{blue}{angle} measurment.

The picture below should show what I mean.
~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/Physics/blogs/Menmonic_ten/cyclicp.jpeg">
    <p>
    <i></i>.
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
As it is clear for $+$ means fill the 3 boxes with $\textcolor{red}{\mu\nu\beta}$ and $-$ means fill the boxes with $\textcolor{blue}{\nu\mu\beta}$.
This gives us, 
$$
R^{\alpha}_{\beta \mu \nu} = \partial_{\textcolor{red}{\mu}} \Gamma^{\alpha}_{\textcolor{red}{\nu} \textcolor{red}{\beta}} - \partial_{\textcolor{blue}{\nu}} \Gamma^{\alpha}_{\textcolor{blue}{\mu} \textcolor{blue}{\beta}} + \Gamma^{\alpha}_{\textcolor{red}{\mu} \textcolor{lime}{\lambda}}\Gamma^{\textcolor{lime}{\lambda}}_{\textcolor{red}{\nu} \textcolor{red}{\beta}} - \Gamma^{\alpha}_{\textcolor{blue}{\nu} \textcolor{lime}{\lambda}}\Gamma^{\textcolor{lime}{\lambda}}_{\textcolor{blue}{\mu} \textcolor{blue}{\beta}}
$$
Reproducing our result.

---

Hope this helps you in some way. If you like it then share with others if possible.

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
    this.page.url = https://rousan.netlify.app/pages/physics/blogs/menmonic_ten/;  // Replace PAGE_URL with your page's canonical URL variable
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