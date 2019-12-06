orbits = open("orbitmap.txt") do f
    split.(readlines(f), ")")
end

mutable struct Node
    name::String
    parent::Union{Node, Nothing}
    children::Array{Node,1}
end
Base.show(io::IO, z::Node) = print(io, z.name)

objects = Node[]

function find_or_create(name::AbstractString, arr::Array{Node,1})::Node
    i = findfirst(x -> x.name == name, arr)
    if i == nothing
        n = Node(name, nothing, [])
        push!(objects, n)
        return n
    else
        return objects[i]
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

for o in orbits
    parent_name, child_name = o
    parent = find_or_create(parent_name, objects)
    child = find_or_create(child_name, objects)
    push!(parent.children, child)
    child.parent = parent
end

orbit_count = 0
for o in objects
    global orbit_count
    if o.name == "COM"
        continue
    end
    orbit_count = orbit_count + length(climb(o))
end
println(orbit_count)

you = find_or_create("YOU", objects)
santa = find_or_create("SAN", objects)
root = intersect(climb(you), climb(santa))[1]
# println(root)
# println(climb_to(you, root))
# println(climb_to(santa, root))
println(length(climb_to(you, root)) + length(climb_to(santa, root)) - 2)