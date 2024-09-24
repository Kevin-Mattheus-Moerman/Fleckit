# Call required packages

using XML
# using GeometryBasics # For point and mesh format
# using LinearAlgebra # For things like dot and cross products
# using DataStructures # For unique_dict
# using Statistics # For: mean etc.
# using GLMakie # For slidercontrol
# using Rotations 
# using Interpolations # E.g. for resampling curves
# using BSplineKit # E.g. for resampling curves
# using QuadGK: quadgk # For numerical integration
# using Distances
# using DelaunayTriangulation # For triangular meshing
# using StaticArrays
# using TetGen # For tetrahedral meshing in tetgenmesh


"""
    comododir()

# Description 

This function simply returns the string for the Fleckit path. This is helpful for instance to load items, such as images, from the `assets`` folder. 
"""
function fleckitdir()
    joinpath(@__DIR__, "..")
end

function svg_initialize(w,h; fill=nothing)
    # Define document level
    doc = XML.Document()

    # Define declaration: <?xml version="1.0" encoding="UTF-8"?>
    declarationNode = XML.Declaration(version = "1.0", encoding = "UTF-8")
    push!(doc, declarationNode)

    # Define svg node: <svg>
    svg_node = XML.Element("svg"; width=string(w)*"mm", height=string(h)*"mm", viewBox = "0 0 "*string(w)*" "*string(h))
    push!(doc, svg_node)

    # Add comment: <!--Created using Julia-->
    comment_node = XML.Comment("Created using Fleckit in Julia")
    push!(svg_node, comment_node)
    
    # Add background rectangle and color
    if ~isnothing(fill)
        aen(svg_node,"rect"; x=0.0, y=0.0, width=w, height=h, fill=fill)
    end

    return doc,svg_node
end

function aen(main_node::Node,sub_node_name::String, args...; kwargs...)
    if isnothing(args)
        sub_node = XML.Element(sub_node_name; kwargs...)    
    else
        sub_node = XML.Element(sub_node_name, args...; kwargs...)    
    end
    push!(main_node, sub_node)
    return sub_node
end

function addpolyline(svg_node,P; fill="black")

    # Format coordinate/point string
    points_string = ""
    for p in P
        points_string *= string(p[1])*", "*string(p[2])*" "
    end

    # Add polyline to svg
    aen(svg_node,"polyline"; points = points_string[1:end-1], fill=fill)

end

function svg_write(fileName, doc)
    XML.write(fileName, doc)
end


function serp(a,b,t; func=:perlin)
    if func == :smoothstep
        q = 3.0*t^3 - 2.0*t^3 # Smoothstep
    elseif func == :cosine
        q = 0.5 .- 0.5.*cos.(t*pi) # Cosine
    elseif func == :linear
        q = t # Linear 
    elseif func == :perlin
        # Fade function q = 6t⁵-15t⁴+10t³    
        q = t^3 * (t * (6.0 * t - 15.0) + 10.0) # Perlin fade function
    end
    return (1.0-q)*a + q*b
end
