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

function hfun_recent_blogs()
    blog_dirs = ["Pages/Physics/blogs", "Pages/Maths/blogs"]
    posts = []
    
    for dir in blog_dirs
        isdir(dir) || continue
        for file in readdir(dir)
            endswith(file, ".md") || continue
            file == "phy_blog.md" && continue
            file == "math_blog.md" && continue
            
            path = joinpath(dir, file)
            content = read(path, String)
            
            # Extract date
            date_m = match(r"(?:rss_pubdate|date)\s*=\s*Date\((\d+),\s*(\d+),\s*(\d+)\)", content)
            if date_m !== nothing
                y, m, d = parse.(Int, date_m.captures)
                date = Date(y, m, d)
            else
                date = Date(2000, 1, 1) # default
            end
            
            # Extract title
            title_m = match(r"title\s*=\s*\"([^\"]+)\"", content)
            title = title_m !== nothing ? title_m.captures[1] : replace(file, ".md" => "")
            
            # Extract category
            category = occursin("Physics", dir) ? "Physics" : "Mathematics"
            
            # Extract description
            desc_m = match(r"rss\s*=\s*\"([^\"]+)\"", content)
            desc = desc_m !== nothing ? desc_m.captures[1] : "A fascinating exploration into this topic..."
            
            url = "/" * replace(path, ".md" => "/")
            push!(posts, (date=date, title=title, category=category, url=url, desc=desc))
        end
    end
    
    # Separate by category
    physics_posts = filter(p -> p.category == "Physics", posts)
    math_posts = filter(p -> p.category == "Mathematics", posts)
    
    sort!(physics_posts, by=x->x.date, rev=true)
    sort!(math_posts, by=x->x.date, rev=true)
    
    # Pick top 2 from each to ensure representation
    final_posts = vcat(physics_posts[1:min(2, end)], math_posts[1:min(2, end)])
    sort!(final_posts, by=x->x.date, rev=true)
    
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
    <link rel="stylesheet" href="/assets/css/custom_comments.css">
    <script type="module" src="/assets/js/custom_comments.js"></script>
    """
end
