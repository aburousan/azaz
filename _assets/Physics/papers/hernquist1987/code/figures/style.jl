# Shared styling for every figure on the page.
#
# The site has a light and a dark theme, so nothing here commits to a
# background colour: the paper and plot areas are transparent and the text and
# gridlines are neutral greys that stay readable either way.

using JSON3

const OUT = normpath(joinpath(@__DIR__, "..", "..", "..",
                              "_assets", "Physics", "papers", "hernquist1987"))
mkpath(OUT)

const DATA = normpath(joinpath(@__DIR__, "..", "data"))

const C = (blue   = "#4C8DF6", orange = "#F0913E", green  = "#3FBF8F",
           red    = "#E5646E", purple = "#A78BFA", teal   = "#2FB4C4",
           yellow = "#E3B93E", pink   = "#EE7BB0", grey   = "#9AA0A6")

const SEQ = [C.blue, C.orange, C.green, C.red, C.purple, C.teal, C.yellow,
             C.pink]

const FONT = "#8A8F98"
const GRID = "rgba(138,143,152,0.22)"
const ZERO = "rgba(138,143,152,0.45)"

load(name) = JSON3.read(read(joinpath(DATA, name * ".json"), String))

axis(title; kw...) = merge(Dict{String,Any}(
    "title" => Dict("text" => title, "font" => Dict("size" => 13, "color" => FONT)),
    "gridcolor" => GRID, "zerolinecolor" => ZERO, "linecolor" => GRID,
    "tickfont" => Dict("size" => 11, "color" => FONT),
    "showline" => true, "mirror" => false, "ticks" => "outside",
    "tickcolor" => GRID),
    Dict{String,Any}(String(k) => v for (k, v) in kw))

function layout(; title = nothing, xaxis = axis(""), yaxis = axis(""),
                 legend = true, height = 460, kw...)
    l = Dict{String,Any}(
        "paper_bgcolor" => "rgba(0,0,0,0)",
        "plot_bgcolor" => "rgba(0,0,0,0)",
        "font" => Dict("family" => "system-ui, -apple-system, sans-serif",
                       "size" => 12, "color" => FONT),
        "xaxis" => xaxis, "yaxis" => yaxis,
        "margin" => Dict("l" => 62, "r" => 24, "t" => title === nothing ? 24 : 52,
                         "b" => 56),
        "height" => height,
        "hovermode" => "closest",
        "showlegend" => legend,
        "legend" => Dict("font" => Dict("size" => 11, "color" => FONT),
                         "bgcolor" => "rgba(0,0,0,0)",
                         "bordercolor" => GRID, "borderwidth" => 1))
    title === nothing || (l["title"] = Dict(
        "text" => title, "x" => 0.02, "xanchor" => "left",
        "font" => Dict("size" => 14, "color" => FONT)))
    for (k, v) in kw
        l[String(k)] = v
    end
    return l
end

line(x, y, name; color = C.blue, width = 2.2, dash = nothing, kw...) = merge(
    Dict{String,Any}("type" => "scatter", "mode" => "lines", "x" => x, "y" => y,
                     "name" => name,
                     "line" => merge(Dict{String,Any}("color" => color,
                                                      "width" => width),
                                     dash === nothing ? Dict{String,Any}() :
                                     Dict{String,Any}("dash" => dash))),
    Dict{String,Any}(String(k) => v for (k, v) in kw))

markers(x, y, name; color = C.blue, size = 6, kw...) = merge(
    Dict{String,Any}("type" => "scatter", "mode" => "markers", "x" => x, "y" => y,
                     "name" => name,
                     "marker" => Dict("color" => color, "size" => size)),
    Dict{String,Any}(String(k) => v for (k, v) in kw))

"Write a plotly figure. `fig` needs at least the keys data and layout."
function write_fig(name::AbstractString, data, lay; frames = nothing,
                   config = Dict{String,Any}())
    fig = Dict{String,Any}("data" => data, "layout" => lay, "config" => config)
    frames === nothing || (fig["frames"] = frames)
    path = joinpath(OUT, name * ".json")
    open(path, "w") do io
        JSON3.write(io, fig)
    end
    println("  ", rpad(name, 28), round(filesize(path) / 1024, digits = 1), " kB")
    return path
end

"Play/pause buttons and a slider stepping through named frames."
function animation_controls(names; label = "t = ", duration = 350,
                            transition = 0)
    steps = [Dict("label" => n, "method" => "animate",
                  "args" => [[n], Dict("mode" => "immediate",
                                       "frame" => Dict("duration" => duration,
                                                       "redraw" => true),
                                       "transition" => Dict("duration" => transition))])
             for n in names]
    slider = Dict("active" => 0, "pad" => Dict("t" => 40, "b" => 10),
                  "x" => 0.06, "len" => 0.94,
                  "currentvalue" => Dict("prefix" => label, "xanchor" => "right",
                                         "font" => Dict("size" => 13, "color" => FONT)),
                  "font" => Dict("size" => 10, "color" => FONT),
                  "steps" => steps)
    menu = Dict("type" => "buttons", "showactive" => false,
                "x" => 0.0, "y" => -0.02, "xanchor" => "right", "yanchor" => "top",
                "pad" => Dict("t" => 50, "r" => 12),
                "font" => Dict("size" => 11, "color" => FONT),
                "bgcolor" => "rgba(0,0,0,0)", "bordercolor" => GRID,
                "buttons" => [
                    Dict("label" => "▶", "method" => "animate",
                         "args" => [nothing, Dict("mode" => "immediate",
                                                  "fromcurrent" => true,
                                                  "frame" => Dict("duration" => duration,
                                                                  "redraw" => true),
                                                  "transition" => Dict("duration" => transition))]),
                    Dict("label" => "❚❚", "method" => "animate",
                         "args" => [[nothing], Dict("mode" => "immediate",
                                                    "frame" => Dict("duration" => 0,
                                                                    "redraw" => false),
                                                    "transition" => Dict("duration" => 0))])])
    return [slider], [menu]
end
