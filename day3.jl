wires = open("wires.csv") do f
    split.(readlines(f), ",")
end

function shortest_distance(wires)
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
    
    return minimum(sum.((x -> abs.(x)).(intersect(paths[1], paths[2]))))
end

println(shortest_distance(wires))