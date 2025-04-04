<!--
Add here global page variables to use throughout your website.
-->
+++
author = "Kazi Abu Rousan"
mintoclevel = 2

# uncomment and adjust the following line if the expected base URL of your website is something like [www.thebase.com/yourproject/]
# please do read the docs on deployment to avoid common issues: https://franklinjl.org/workflow/deploy/#deploying_your_website
# prepath = "yourproject"

# Add here files or directories that should be ignored by Franklin, otherwise
# these files might be copied and, if markdown, processed by Franklin which
# you might not want. Indicate directories by ending the name with a `/`.
# Base files such as LICENSE.md and README.md are ignored by default.
ignore = ["node_modules/"]

# RSS (the website_{title, descr, url} must be defined to get RSS)
generate_rss = true
website_title = "Azazaya"
website_descr = "Personal Website of Kazi Abu Rousan"
website_url   = "https://rousan.netlify.app/"
+++

@def prepath = "azazaya"
<!--
Add here global latex commands to use throughout your pages.
-->
\newcommand{\R}{\mathbb R}
\newcommand{\scal}[1]{\langle #1 \rangle}


<!--
For Interactive Plotly
-->

@def hasplotly = true


\newcommand{\pycode}[2]{
```julia:!#1
#hideall
using PyCall
lines = replace("""!#2""", r"(^|\n)([^\n]+)\n?$" => s"\1res = \2")
py"""
$$lines
"""
println(py"res")
```
```python
#2
```
\codeoutput{!#1}
}



\newcommand{\rcode}[2]{
```julia:!#1
#hideall
using RCall
R"""
!#2
"""
```
```R
#2
```
\codeoutput{!#1}
}



\newcommand{\collaps}[2]{
~~~<button type="button" class="collapsible">~~~ #1 ~~~</button><div class="collapsiblecontent">~~~ #2 ~~~</div>~~~
}


\newcommand{\html}[1]{~~~#1~~~}

\newenvironment{center}{
  \html{<div style="text-align:center">}
}{
  \html{</div>}
}


\newcommand{\emdash}{&#8212;}

\newcommand{\fieldset}[3]{
  ~~~
  <fieldset class="#1"><legend class="#1-legend">#2</legend>
  ~~~
  #3
  ~~~
  </fieldset>
  ~~~
}

\newcommand{\cmdiff}[1]{
  \fieldset{cm-diff}{&ne; CommonMark}{
    #1
  }
}

<!--
  Tip
-->
\newcommand{\tip}[1]{
  \fieldset{tip}{🚀 Tip}{
    #1
  }
}

<!--
 Todo
-->
\newcommand{\todo}[1]{
  \fieldset{todo}{🚧 To Do}{
    #1
  }
}

\newcommand{\exam}[1]{
  \fieldset{todo}{🚧 Example}{
    #1
  }
}

\newcommand{\prob}[1]{
  \fieldset{todo}{🤔 Problem}{
    #1
  }
}
<!--
 Note
-->
\newcommand{\note}[1]{
  \fieldset{note}{📝 Note}{
    #1
  }
}

\newcommand{\poem}[1]{
  \fieldset{poem}{🪶 Poem}{
    #1
  }
}

\newcommand{\defn}[1]{
  \fieldset{defn}{🧠 Defn}{
    #1
  }
}

\newcommand{\showmd}[1]{~~~<div class="trim">~~~\fieldset{md-input}{markdown}{`````plaintext#1`````}~~~</div>~~~
  ~~~<div class="trim">~~~\fieldset{md-result}{result}{~~~~~~#1~~~~~~}~~~</div>~~~}

\newcommand{\col}[2]{~~~<span style="color:~~~#1~~~">~~~!#2~~~</span>~~~}