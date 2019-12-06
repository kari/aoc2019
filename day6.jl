orbits = open("orbitmap.txt") do f
    split.(readlines(f), ")")
end

mutable struct Node
    name::String
    parent::Union{Node, Nothing}
    children::Array{Node,1}
end

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

function climb(node, i = 0)
    if node.parent == nothing
        return i
    else
        climb(node.parent, i + 1)
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
    orbit_count = orbit_count + climb(o)
end
println(orbit_count)

#root = find_or_create("COM", objects)
#println(root)
#println(objects)