+++
title = "Code blocks"
hascode = true
date = Date(2019, 3, 22)
rss = "A short description of the page which would serve as **blurb** in a `RSS` feed; you can use basic markdown here but the whole description string must be a single line (not a multiline string). Like this one for instance. Keep in mind that styling is minimal in RSS so for instance don't expect maths or fancy styling to work; images should be ok though: ![](https://upload.wikimedia.org/wikipedia/en/3/32/Rick_and_Morty_opening_credits.jpeg)"

tags = ["syntax", "code"]
+++
@def hasjsx = false


# Working with code blocks

\toc

## Live evaluation of code blocks

If you would like to show code as well as what the code outputs, you only need to specify where the script corresponding to the code block will be saved.

Indeed, what happens is that the code block gets saved as a script which then gets executed.
This also allows for that block to not be re-executed every time you change something _else_ on the page.

Here's a simple example (change values in `a` to see the results being live updated):

```julia:./exdot.jl
using LinearAlgebra
a = [1, 2, 3, 3, 4, 5, 2, 2]
@show dot(a, a)
println(dot(a, a))
```

You can now show what this would look like:

\output{./exdot.jl}

**Notes**:
* you don't have to specify the `.jl` (see below),
* you do need to explicitly use print statements or `@show` for things to show, so just leaving a variable at the end like you would in the REPL will show nothing,
* only Julia code blocks are supported at the moment, there may be a support for scripting languages like `R` or `python` in the future,
* the way you specify the path is important; see [the docs](https://tlienart.github.io/franklindocs/code/index.html#more_on_paths) for more info. If you don't care about how things are structured in your `/assets/` folder, just use `./scriptname.jl`. If you want things to be grouped, use `./group/scriptname.jl`. For more involved uses, see the docs.

Lastly, it's important to realise that if you don't change the content of the code, then that code will only be executed _once_ even if you make multiple changes to the text around it.

Here's another example,

```julia:./code/ex2
for i ∈ 1:5, j ∈ 1:5
    print(" ", rpad("*"^i,5), lpad("*"^(6-i),5), j==5 ? "\n" : " "^4)
end
```

which gives the (utterly useless):

\output{./code/ex2}

note the absence of `.jl`, it's inferred.

You can also hide lines (that will be executed nonetheless):

```julia:./code/ex3
using Random
Random.seed!(1) # hide
@show randn(2)
```

\output{./code/ex3}


## Including scripts

Another approach is to include the content of a script that has already been executed.
This can be an alternative to the description above if you'd like to only run the code once because it's particularly slow or because it's not Julia code.
For this you can use the `\input` command specifying which language it should be tagged as:


\input{julia}{/_assets/scripts/script1.jl} <!--_-->


these scripts can be run in such a way that their output is also saved to file, see `scripts/generate_results.jl` for instance, and you can then also input the results:

\output{/_assets/scripts/script1.jl} <!--_-->

which is convenient if you're presenting code.

**Note**: paths specification matters, see [the docs](https://tlienart.github.io/franklindocs/code/index.html#more_on_paths) for details.

Using this approach with the `generate_results.jl` file also makes sure that all the code on your website works and that all results match the code which makes maintenance easier.



```?
real
```



```julia:ex2
using PlotlyJS
p=plot(
     scatter(x=1:10, y=rand(10), mode="markers"),
     Layout(title="Responsive Plots")
     )
savejson(p, joinpath(@OUTPUT, "plotlyex.json"))  # savejson is an alternative to savefig # hide
# PlotlyBase.json (also exported by PlotlyJS) often gives a smaller json compared to PlotlyJS.savefig # hide
```

\fig{plotlyex}



```julia:table
#hideall
names = (:Taimur, :Catherine, :Maria, :Arvind, :Jose, :Minjie)
numbers = (1525, 5134, 4214, 9019, 8918, 5757)
println("Name | Number")
println(":--- | :---")
println.("$name | $number" for (name, number) in zip(names, numbers))
```
\textoutput{table}


\begin{center}
ewfukhrwjkfbvjkhabvkrfb
\end{center}


<!-- \pycode{py1}{
  import numpy as np
  np.random.seed(2)
  x = np.random.randn(5)
  r = np.linalg.norm(x) / len(x)
  np.round(r, 2)
} -->


\collaps{An additional example: **Press here to expand**}{In the content part you can have latex: $x^2$,

lists
* Item 1
* Item 2

And all other stuff processed by Franklin!}

---------------------------------------------------------




\begin{tikzcd}{tcd1}
\draw[blue, very thick] (0,0) rectangle (3,2);
\draw[orange, ultra thick] (4,0) -- (6,0) -- (5.7,2) -- cycle;
\end{tikzcd}


~~~
<script type="text/javascript" charset="UTF-8"
 src="https://cdn.jsdelivr.net/npm/jsxgraph/distrib/jsxgraphcore.js"></script>
<link rel="stylesheet"
 type="text/css" href="https://cdn.jsdelivr.net/npm/jsxgraph/distrib/jsxgraph.css" />
<script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
<div id="board" class="jxgbox" style="width:400px; height:400px;"></div>
<script>
    JXG.Options.text.useMathJax = true;
    var board = JXG.JSXGraph.initBoard(
        "board",
        {
            boundingbox: [-8, 2.5, 8, -2.5],
            axis: true
        }
    );
    /* The slider neesd the following input parameters:
    [[x1, y1], [x2, y2], [min, start, max]]
    [x1, y1]: first point of the ruler
    [x2, y2]: last point of the ruler
    min: minimum value of the slider
    start: initial value of the slider
    max: maximum value of the slider
    */
    var a = board.create("slider", [[1, 2], [5, 2], [-10, -3, 0]], { name: "start" });
    var b = board.create("slider", [[1, 1.2], [5, 1.2], [0, 2*Math.PI, 10]], { name: "end" });
    var s = board.create("slider", [[1, -2], [5, -2], [1, 10, 100]], { name: "n" ,snapWidth:1});
    var f = function(x){ return Math.sin(x); };
    var plot = board.create('functiongraph',[f,function(){return a.Value();}, function(){return b.Value();}]);
    var os = board.create('riemannsum',[f,
    function(){ return s.Value();}, function(){ return "left";},
    function(){return a.Value();},
    function(){return b.Value();}],
    {fillColor:'#ffff00', fillOpacity:0.8});
    board.create('text',[-6,-1.5,function(){ return 'Sum='+(JXG.Math.Numerics.riemannsum(f,s.Value(),'left',a.Value(),b.Value())).toFixed(4); }]);
</script>
~~~

jknvfjfnj
<!-- ~~~
<script type="text/javascript" charset="UTF-8"
 src="https://cdn.jsdelivr.net/npm/jsxgraph/distrib/jsxgraphcore.js"></script>
<link rel="stylesheet"
 type="text/css" href="https://cdn.jsdelivr.net/npm/jsxgraph/distrib/jsxgraph.css" />
<script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
<div id="board" class="jxgbox" style="width:400px; height:400px;"></div>
<script>
    JXG.Options.text.useMathJax = true;
    var board = JXG.JSXGraph.initBoard(
        "board",
        {
            boundingbox: [-8, 2.5, 8, -2.5],
            axis: true
        }
    );
    const maxIterations = 100;
    const escapeRadius = 2;
    function iterate(c) {
    let z = {x: 0, y: 0};
    let iterations = 0;
    while (z.x * z.x + z.y * z.y < escapeRadius * escapeRadius && iterations < maxIterations) {
        let temp = z.x * z.x - z.y * z.y + c.x;
        z.y = 2 * z.x * z.y + c.y;
        z.x = temp;
        iterations++;
    }
    return iterations;
    }

    function plotMandelbrot() {
    const points = [];
    for (let i = -2; i <= 2; i += 0.01) {
        for (let j = -2; j <= 2; j += 0.01) {
        const c = {x: i, y: j};
        const iterations = iterate(c);
        if (iterations === maxIterations) {
            points.push([i, j]);
        }
        }
    }
    return points;
    }

    const mandelbrotPoints = plotMandelbrot();
    mandelbrotPoints.forEach(point => {
        board.create('point', point, {size: 1, color: 'black'});
    });
</script>
~~~ -->



<!-- <script>
    JXG.Options.text.useMathJax = true;
    var board = JXG.JSXGraph.initBoard(
        "board",
        {
            boundingbox: [-15, 15, 15, -15],
            axis: true
        }
    );
  var p = board.create('point',[-3,1]);
</script> -->