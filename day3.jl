wires = open("wires.csv") do f
    split.(readlines(f), ",")
end

function parse_paths(wires)
    paths = []

    for w in wires
        coord = (0, 0)
        path = []
        for p in w
            dir = if p[1] == 'U'
                (0, 1)
            elseif p[1] == 'R'
                (1, 0)
            elseif p[1] == 'D'
                (0, -1)
            elseif p[1] == 'L'
                (-1, 0)
            else
                throw(ErrorException("Invalid direction: " * p[1]))
            end
            for i = 1:(parse(Int, p[2:end]))
                coord = coord .+ dir
                push!(path, coord)
            end
        end
        push!(paths, path)
    end

    return paths
end

function shortest_distance(wires)::Int
    paths = parse_paths(wires)
    
    return minimum(sum.((x -> abs.(x)).(intersect(paths[1], paths[2]))))
end

function shortest_delay(wires)::Int
    paths = parse_paths(wires)
    intersections = intersect(paths[1], paths[2])
    
    delays = []
    for i in intersections
        s1 = findfirst(x -> x==i, paths[1])
        s2 = findfirst(x -> x==i, paths[2])
        push!(delays, s1+s2)
    end
    
    return minimum(delays)
end

println(shortest_distance(wires))
println(shortest_delay(wires))