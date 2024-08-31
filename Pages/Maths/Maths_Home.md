+++
title = "Mathematics Blog"
hascode = true
date = Date(2019, 3, 22)
rss = "A short description of the page which would serve as **blurb** in a `RSS` feed; you can use basic markdown here but the whole description string must be a single line (not a multiline string). Like this one for instance. Keep in mind that styling is minimal in RSS so for instance don't expect maths or fancy styling to work; images should be ok though: ![](https://upload.wikimedia.org/wikipedia/en/3/32/Rick_and_Morty_opening_credits.jpeg)"

tags = ["syntax", "code", "mathematics", "math"]
+++


# What is Mathematics?
**Mathematics** is the *fragment* of our Imagination, which let us understand both the **physical** and **abstract** realities using **Logic**, **Numbers** and **Geometry**.

In **Galilio's** words,
> The universe cannot be read until we have learnt the language and become familiar with the characters in which it is written. It is written in MATHEMATICAL LANGUAGE...

Because of this without maths we cannot learn physics and vice-versa.\\
To learn mathematics, we need only one thing...
* ~~~
<span style="color:purple;font-weight:700">
    An Open Mind which is capable of Imagination
</span>
~~~
That's all we need. But for learning, It always helps to see examples and applications. As a result we will use a bit of coding (Mostly **Python** or **Julia**).

We will sometimes use codes for solving problems.
As an example, consider the birthday problem (see [detailed discussion](https://www.cheenta.com/a-probability-birthday-with-coding/))

```julia:./birthday_tre.jl
arr = [2,6,2,10]
arr.==2
sum(arr.==2)
begin
  function prob(n::Int)
    favour = 0
    for ex_num=1:n
      months = rand(1:12,20)
      nums = [sum(months.==i) for i=1:12]
      if sum(nums.==3)==4 && sum(nums.==2)==4
        favour += 1
      end
    end
    probability = favour/n
  end
end
println("The output, probability is = ",prob(10_000_000))
```
The output is:
\output{./birthday_tre.jl}
~~~
<img src="/assets/cat-gray.gif" alt="Code bro code" width="400">
<div class="caption">Coding...Maths...Coding</div>
~~~

~~~
<div class="feature__wrapper">
  <div class="feature__item">
    <div class="archive__item">
      <div class="archive__item-teaser">
        <img src="/assets/Maths/blogs.jpeg" alt="customizable" />
      </div>
      <div class="archive__item-body">
        <h2 class="archive__item-title">Read Blogs</h2>
        <div class="archive__item-excerpt">
          <p>Read standalone blogs</p>
        </div>
        <p><a href="/Pages/Maths/blogs/math_blog" class="btn btn--primary">Visit</a></p>
      </div>
    </div>
  </div>
  <div class="feature__item">
    <div class="archive__item">
      <div class="archive__item-teaser">
        <img src="/assets/Maths/papers.jpg" alt="fully responsive" />
      </div>
      <div class="archive__item-body">
        <h2 class="archive__item-title">Papers</h2>
        <div class="archive__item-excerpt">
          <p>Recreating different scientific articles and analysing them.</p>
        </div>
        <p><a href="/Pages/Maths/papers/math_papers" class="btn btn--primary">Visit</a></p>
      </div>
    </div>
  </div>
  <div class="feature__item">
    <div class="archive__item">
      <div class="archive__item-teaser">
        <img src="/assets/Maths/course.jpg" alt="100% free" />
      </div>
      <div class="archive__item-body">
        <h2 class="archive__item-title">Courses</h2>
        <div class="archive__item-excerpt">
          <p>Courses and Books</p>
        </div>
        <p><a href="/Pages/Maths/courses/math_co" class="btn btn--primary">Visit</a></p>
      </div>
    </div>
  </div>
</div>
~~~

~~~
<button onclick="window.history.back()">Go Back</button>
~~~