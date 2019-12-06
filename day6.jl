mutable struct Node
    name::String
    parent::Union{Node, Nothing}
    children::Array{Node,1}
end
Base.show(io::IO, z::Node) = print(io, z.name)

function find_or_create(name::AbstractString, arr::Array{Node,1})::Node
    i = findfirst(x -> x.name == name, arr)
    if i == nothing
        n = Node(name, nothing, [])
        push!(arr, n)
        return n
    else
        return arr[i]
    end
end

function climb(node::Node, arr = Node[])::Array{Node,1}
    if node.parent == nothing
        return arr
    else
        climb(node.parent, push!(arr, node.parent))
    end
end

function climb_to(node::Node, target::Node, arr = Node[])::Array{Node,1}
    if node.name == target.name
        return arr
    elseif node.parent == nothing
        throw(ErrorException("target node not found"))
    else
        climb_to(node.parent, target, push!(arr, node.parent))
    end
end

function build_orbitmap()::Array{Node,1}
    data = open("orbitmap.txt") do f
        split.(readlines(f), ")")
    end
    objects = Node[]    
    for o in data
        parent_name, child_name = o
        parent = find_or_create(parent_name, objects)
        child = find_or_create(child_name, objects)
        push!(parent.children, child)
        child.parent = parent
    end

    return objects        
end

function orbit_count(objects::Array{Node,1})::Int
    orbit_count = 0
    for o in objects
        orbit_count = orbit_count + length(climb(o))
    end

    return orbit_count    
end

function orbit_distance(from::Node, to::Node)::Int
    root = intersect(climb(from), climb(to))[1]

    return length(climb_to(you, root)) + length(climb_to(santa, root)) - 2
end

orbitmap = build_orbitmap()

println(orbit_count(orbitmap))

you = find_or_create("YOU", orbitmap)
santa = find_or_create("SAN", orbitmap)
println(orbit_distance(you, santa))
