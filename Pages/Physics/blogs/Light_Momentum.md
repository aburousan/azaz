+++
title = "What exactly is Light Momentum?"
hascode = true
rss = "IN this blog, we will understand What exactly is Light Momentum? and from where exactly it is coming?"
rss_title = "What exactly is Light Momentum?"
rss_pubdate = Date(2024, 3, 10)

tags = ["physics", "Electromagnetic Wave", "Light", "Magnetic Field", "Electric Field"]
+++

<!-- [![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Faburousan.github.io%2Fazazaya%2FPages%2FPhysics%2FLight_Momentum%2F&count_bg=%23B461C2&title_bg=%2357521A&icon=atom.svg&icon_color=%23E7E7E7&title=visits&edge_flat=false)](https://hits.seeyoufarm.com) -->

\toc

\newcommand{\col}[2]{~~~<span style="color:~~~#1~~~">~~~!#2~~~</span>~~~}

# What exactly is Light Momentum?
We all of heard many times **Light has Momentum**!\\
But the thing is most of us really don't understand why is so or how is responsible for this momentum?

Today in this blog, we will exactly try to understand it from the basic physics. So, just take a cup of tea and get ready.
> The ultimate test of your knowledge is your capacity to convey it to another. -- Richard Feynmann

## Introduction
While studying many topics we have used that fact that, the momentum of light is given by,
$$
p = \frac{E}{c}
\label{light_mom}
$$
In this eqn-\eqref{light_mom}, $E$ represent the **energy of light** and $c$ is the **speed of light**.

Normally, the proof is given by using **Einstein Mass-Energy Equivalence** formula. The proof is as follows:
@@colbox-blue
Proof:
$$
E^2 = (mc^2)^2 + (pc)^2
\label{Mass-Ener_f}
$$
Now, as **light doesn't have any mass**, we put $m=0$, which gives us our expression for the momentum $p$.

After posting this many people are saying using the $4-vector$ method , i.e., $p^{\mu}p_{\mu}$ we can easily find momentum of photon. I guess they have not read the blog. As that method is equivalent to what i just discussed here in this box because 
$$
p^{\mu}p_{\mu} = m^2c^2 = \Big(\frac{E}{c}\Big)^2 - \vec{p}\cdot \vec{p}
$$
@@
The problem with this proof is that fact **\col{green}{It doesn't teach us what is physically happening}** nor it tells us how the hell **\col{green}{something which doesn't have any mass can have momentum?}**

@@im-50
![](/assets/Physics/blogs/Light_Momentum/em_field_light.jpg)
@@
**Spolier: Magnetic-Field Component is responsible for Light Momentum**


Before exactly learning where is momentum is coming, let's first see if this momentum even exist. In science, we always need **experimental evidence** to be sure if something really is there.
> No matter how beautiful or elegant your theory is if there is no evidence then it's wrong.

So, let's first see the observations. But again before that we have to know what is **Momentum**?, is it $mass \times velocity$ or something else?

## What is Momentum?
Normally, we say **Momentum** is a measurement of mass in motion: how much mass is in how much motion. It is usually given the symbol $\vec{p}$ and it is given by $\vec{p} = m\vec{v}$. But this is not correct in general. 

In many streams of physics, like **Analytical Mechanics** or **Special Theory of Relativity**, we have some different expression for momentum. Those expressions boils down to this one in some special case, i.e., $\vec{p} = m\vec{v}$ is not true in general. Then, what exactly is **momentum**?

**\col{red}{Momentum is a property of any object which tells us it's ability to push or apply force to some other object.}**

This means *even if some object don't have any mass, but if it can push something we can conclude that it has some momentum* (just remember $\vec{F} = \frac{d \vec{p}}{dt}$). Maybe we will explore this point in much more detail in some future blog.


## Evidence of Light's Momentum
Keeping the point of the previous section in our mind, let's see few evidences for light momentum.\\
Normally when we are sitting in your room while the light is on or maybe sitting outside, you don't feel any push. Then can we say **light don't have any mometum?**, well no!


@@colbox-red

**Misinformation Alert!!**\\

After posting this, Many people specially [Dr. Chentan Waghela](linkedin.com/in/dr-chetan-waghela-6682384a), [Terry Bollinger](https://www.linkedin.com/in/terry-bollinger-8a976) pointed out this is clearly a misinformation as the plastic can just fall due to the thermal effect of air and heating, which is 100% correct. 

I had added that as it looks visually great. I shouldn't have done that.... Sorry about that. I decided not to remove this part so people can see and understand the mistake.


Maybe it is very small. We have to perform some experiment which can even detect very small momentum. You can actually perform one such experiment in your home with a very strong flash light or a laser(see the video below).
@@im-50
![Wrong Video](/assets/Physics/blogs/Light_Momentum/pressure_of_light.gif)
@@

As shown in the video if we took a very light plastic and hit it with a laser, the plasic falls due to the **pressure**, i.e., **force of the light**, which implies *light can push* and hence it has *momentum*.


@@


An actual visuals to see the pressure of light can be seen in the video below.

~~~
<iframe width="460" height="280" src="https://www.youtube.com/embed/Sq7GaO8iqu8?si=4GbyLG1kWGv-WRPv&amp;start=87" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
~~~

Compton effect is actually a very nice proof of *light having momentum* but we will not discuss that here.

Another nice observation is the tail of **Hale Bopp** comet. Normally, when a comes goes around it's orbit we expect that it's tail should be tangent to the orbit. But observation showed us it is not the case (see the figure below).
~~~
<div class="row">
  <div class="container">
    <img class="center" src="/assets/Physics/blogs/Light_Momentum/Hale_Bopp.jpeg" height="400">
    <p>
    
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
There, The tail is pushed due to the pressure/force of radiation coming from the sun.\\
There are many more experiments to notice that **light has momentum**. If you guys are curious about some experiment to calculate it just go through this [paper](https://onlinelibrary.wiley.com/doi/full/10.1002/andp.201800111).

## Origin of Momentum of Light
We know **\col{violet}{Light is a Electro-Magnetic wave.}** The electric and magnetic field oscillate perpendicular to each other and propagate in the perpendicular direction as shown below.
~~~
<div class="row">
  <div class="container">
    <img class="center" src="/assets/Physics/blogs/Light_Momentum/EM_Wave_prop.gif" height="300">
    <p>
    The blue one is electric field and red one is magnetic field.
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
Now, let's consider an electron lying on the y-axis. As the **E** field is oscillating in the **z-direction**, the electron will also oscilate also in the z-direction.

As shown in the figure, when the **E-field** points downwards, the electron being an negative charged particle will get pushed upward.
~~~
<div class="row">
  <div class="container">
    <img class="center" src="/assets/Physics/blogs/Light_Momentum/E_wave_pushe.png" height="300">
    <p>
    
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
In the next moment when the wave goes up at the same location, the electron feels a force downward as shown below.
~~~
<div class="row">
  <div class="container">
    <img class="center" src="/assets/Physics/blogs/Light_Momentum/E_wave_pushe1.png" height="300">
    <p>
    
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
Hence, the net push is $0$. Hence, the **\col{red}{average momentum}** transfered by the **Electric Field** of **Light** on the **electron** is $0$.

What happens for the case of **Magnetic Field**?\\
In this case again let's take an electron at some point. The magnetic field is pointing in the $-\hat{x}$ direction and due to the electric field the electron will have a velocity in the $+\hat{z}$ direction.

Using the **Lorentz Force equation**,
$$
\vec{F}_m = q(\vec{v}\times \vec{B})
$$
where $q$ is the charge of the particle, $\vec{v}$ is the velocity and $\vec{B}$ is the magnetic field, we see that the magnetic field will push the electron in the \col{red}{$+\hat{y}$ direction} with a value of $evB$ (Note: electron has negative charge).
~~~
<div class="row">
  <div class="container">
    <img class="center" src="/assets/Physics/blogs/Light_Momentum/B_wave_push1.png" height="300">
    <p>
    
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
After a while when the magnetic field is now pointing in the $+\hat{x}$ direction, the velocity of the electron will be along the $-\hat{z}$ direction. Here applying the **Lorentz Force** formula again, will show us that the electron will be pushed in the \col{red}{$+\hat{y}$ direction} once again.
~~~
<div class="row">
  <div class="container">
    <img class="center" src="/assets/Physics/blogs/Light_Momentum/B_wave_push2.png" height="300">
    <p>
    
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
Hence, there is a \col{green}{Net non-zero push}, i.e., **\col{green}{There is a net momentum transfer}**.

This shows us that **\col{red}{Light's momentum is actually provided by the Magnetic Field.}** So, It is the magnetic field who gives **light it's momentum**. But if it's true we should be able to derive the eqn-\eqref{light_mom}. Let's try to derive that.

@@colbox-blue
**Proof:**
The magnetic force on the electron on both case is,
$$
\vec{F}_m = evB \hat{y} \to F_m = evB
\label{F_m_exp}
$$
Now, we know that $B$ and $E$ follow the relation,
$$
\frac{E}{B} = c
\label{E_B_rel}
$$
Using eqn-\eqref{E_B_rel} in eqn-\eqref{F_m_exp} we get,
$$
F_m = \frac{evE}{c} = \frac{vF_e}{c}
$$
where $F_e = eE$ is the electric force on the electron.

Note: This tells us that as $v< c$, **Electric Force** will always be **greater** than **Magnetic force**.

Now, we know the **Energy Tranfer per sec**($E_{enr}/ sec$) or **Power**($P_{ow}$) is given by,
$$
P_{ow} = \frac{E_{enr}}{sec} = Fv
$$
where $F$ is any force and $v$ is the velocity of the object of interest.\\
Using this, we have
$$
F_m = \frac{E_{enr}}{c \ \ 1sec}
$$
As we know **Force** is rate of change of momentum. Hence, for **unit time**, we have,
$$
p = \frac{E_{enr}}{c}
$$
where $p$ is the momentum transfer done by magnetic field.
@@

Isn't it beautiful?, how we now understand the real physics behind the whole process.

We know understand **it is the magnetic field** who is giving the momentum, well **electric field** is also somewhat responsible for this as it gives the initial push giving some velocity to the electrons.

There are few points we should note:
1. Although the magnetic field is applying the push, the energy stored due in the process is due to electric field. This is the case as magnetic field don't do any work.
2. The momentum is in the direction to light propagaration. If you consider a proton in place of electron even then it is the case.
---------------------------------------------------

I tried my best to explain this, although I am not sure how much you guys have understood but I hope, atleast you have found of insight on this topic.

If you have some queries, do let me know in the comments or contact me using my using the informations that are given on the page [About Me](/Pages/about_me/).

~~~
<button onclick="window.history.back()">Go Back</button>
~~~

~~~
<script src="https://utteranc.es/client.js"
        repo="aburousan/blog_comments"
        issue-term="pathname"
        theme="github-light"
        crossorigin="anonymous"
        async>
</script>
~~~