include("form.jl")
using .FormWrapper
include("art_carousel.jl")

function hfun_bar(vname)
  val = Meta.parse(vname[1])
  return round(sqrt(val), digits=2)
end

function hfun_m1fill(vname)
  var = vname[1]
  return pagevar("index", var)
end

function lx_baz(com, _)
  # keep this first line
  brace_content = Franklin.content(com.braces[1]) # input string
  # do whatever you want here
  return uppercase(brace_content)
end

using Dates

# Where the "Recently Published" cards come from. Ordinary blog posts are picked
# up automatically from the two blog folders. Longer things that live outside
# them, a paper recreation or a course, opt in with `card = true` in their
# front matter, so a multi-part series shows up once as its landing page instead
# of once per part.
const CARD_BLOG_DIRS = [("Pages/Physics/blogs", "Physics"),
                        ("Pages/Maths/blogs", "Mathematics")]
const CARD_FEATURE_ROOTS = ["Pages/Physics/papers", "Pages/Physics/courses",
                            "Pages/Maths/papers", "Pages/Maths/courses"]
const CARD_SKIP = ["phy_blog.md", "math_blog.md"]

# Front matter is read line by line rather than with a loose search, so that
# `rss_title` cannot be mistaken for `title`.
function _card_field(txt, key)
    m = match(Regex("^" * key * "\\s*=\\s*\"([^\"]+)\"", "m"), txt)
    m === nothing ? nothing : String(m.captures[1])
end

function _card_date(txt)
    m = match(r"^(?:rss_pubdate|date)\s*=\s*Date\(\s*(\d+),\s*(\d+),\s*(\d+)\s*\)"m, txt)
    m === nothing ? Date(2000, 1, 1) : Date(parse.(Int, m.captures)...)
end

# Franklin serves `foo/index.md` at `foo/`, everything else at its own name.
function _card_url(path)
    basename(path) == "index.md" && return "/" * dirname(path) * "/"
    return "/" * replace(path, ".md" => "/")
end

function _card(path, category, txt = read(path, String))
    (date = _card_date(txt),
     title = something(_card_field(txt, "title"), replace(basename(path), ".md" => "")),
     category = category,
     url = _card_url(path),
     desc = something(_card_field(txt, "rss"),
                      "A fascinating exploration into this topic..."))
end

"Blog posts, newest first, split by category."
function _card_blogs()
    posts = []
    for (dir, category) in CARD_BLOG_DIRS
        isdir(dir) || continue
        for file in readdir(dir)
            (endswith(file, ".md") && !(file in CARD_SKIP)) || continue
            push!(posts, _card(joinpath(dir, file), category))
        end
    end
    return posts
end

"Series and courses that have asked to be featured, newest first."
function _card_featured()
    out = []
    for root in CARD_FEATURE_ROOTS
        isdir(root) || continue
        default = occursin("papers", root) ? "Series" : "Course"
        for (dir, _, files) in walkdir(root), file in files
            endswith(file, ".md") || continue
            path = joinpath(dir, file)
            txt = read(path, String)
            occursin(r"^card\s*=\s*true"m, txt) || continue
            push!(out, _card(path, something(_card_field(txt, "card_category"), default), txt))
        end
    end
    sort!(out, by = x -> x.date, rev = true)
    return out
end

function hfun_recent_blogs()
    posts = _card_blogs()
    newest(cat, n) = first(sort(filter(p -> p.category == cat, posts),
                                by = x -> x.date, rev = true),
                           n)

    final_posts = vcat(newest("Physics", 2), newest("Mathematics", 2),
                       first(_card_featured(), 2))
    sort!(final_posts, by = x -> x.date, rev = true)

    io = IOBuffer()
    write(io, "<div class=\"recent-blogs-container fade-up-element\">")
    write(io, "<h2 class=\"recent-blogs-header\">Recently Published</h2>")
    write(io, "<div class=\"recent-blogs-grid\">")

    for p in final_posts
        date_str = Dates.format(p.date, "u d, yyyy")
        tag_class = lowercase(p.category)
        write(io, """
        <a href="$(p.url)" class="blog-card">
            <div class="blog-card-category $(tag_class)">$(p.category)</div>
            <h3 class="blog-card-title">$(p.title)</h3>
            <p class="blog-card-desc">$(p.desc)</p>
            <div class="blog-card-meta">$(date_str)</div>
        </a>
        """)
    end
    write(io, "</div></div>")

    return String(take!(io))
end

function hfun_comments()
    return """
    <div id="custom-comments-container"></div>
    <link rel="stylesheet" href="/assets/css/custom_comments.css?v=2">
    <script type="module" src="/assets/js/custom_comments.js?v=5"></script>
    """
end
