wires = open("wires.csv") do f
    split.(readlines(f), ",")
end

function shortest_distance(wires)
    paths = []

    for w in wires
        coord = (0, 0)
        path = []
        for p in w
            d = p[1]
            if d == 'U'
                dir = (0, 1)
            elseif d == 'R'
                dir = (1, 0)
            elseif d == 'D'
                dir = (0, -1)
            elseif d == 'L'
                dir = (-1, 0)
            else
                throw(ErrorException("Invalid direction: " * d))
            end
            len = parse(Int, p[2:end])
            for i = 1:len
                coord = coord .+ (dir)
                push!(path, coord)
            end
        end
        push!(paths, path)
    end
    
    return minimum(sum.((x -> abs.(x)).(intersect(paths[1], paths[2]))))
end

println(shortest_distance(wires))