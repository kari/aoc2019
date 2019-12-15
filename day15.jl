using Serialization

function deref(pointer::Int, program::Array{Int,1}, mode::Int, base::Int)::Int
    if mode == 0
        return program[pointer+1]
    elseif mode == 1
        return pointer
    elseif mode == 2
        return program[pointer+base+1]
    else
        throw(ErrorException("Invalid mode: " * mode))
    end
end

function write_pointer(pointer::Int, mode::Int, base::Int)::Int
    if mode == 0
        return pointer+1
    elseif mode == 2
        return pointer+base+1
    else
        throw(ErrorException("Invalid mode for writing: " * mode))
    end
end

function run_intcode(program::Vector{Int}, input::Channel, output::Channel)::Int
    program = vcat(program, zeros(Int, 1000))
    pointer = 1
    ret = nothing
    base = 0
    while pointer <= length(program)
        # println(program)
        instruction = reverse(digits(program[pointer], pad=5))
        # println(instruction)
        opcode = instruction[end] + instruction[end-1]*10
        modes = reverse(instruction[1:end-2])
        # println(join([opcode,": ",modes]))
        if opcode == 1 # add
            pt1 = program[pointer+1]
            pt2 = program[pointer+2]
            pt3 = program[pointer+3]
            val1 = deref(pt1, program, modes[1], base)
            val2 = deref(pt2, program, modes[2], base)
            program[write_pointer(pt3, modes[3], base)] = val1 + val2
            pointer = pointer + 4
        elseif opcode == 2 # multiply
            pt1 = program[pointer+1]
            pt2 = program[pointer+2]
            pt3 = program[pointer+3]
            val1 = deref(pt1, program, modes[1], base)
            val2 = deref(pt2, program, modes[2], base)
            program[write_pointer(pt3, modes[3], base)] = val1 * val2
            pointer = pointer + 4
        elseif opcode == 3 # store input
            pt1 = program[pointer+1]
            program[write_pointer(pt1, modes[1], base)] = take!(input)
            pointer = pointer + 2
        elseif opcode == 4 # output
            pt1 = program[pointer+1]
            val1 = deref(pt1, program, modes[1], base)
            pointer = pointer + 2
            ret = val1
            put!(output, val1)
        elseif opcode == 5 # jump if true
            pt1 = program[pointer+1]
            pt2 = program[pointer+2]
            val1 = deref(pt1, program, modes[1], base)
            val2 = deref(pt2, program, modes[2], base)
            if val1 != 0
                pointer = val2 + 1
            else
                pointer = pointer + 3
            end
        elseif opcode == 6 # jump if false
            pt1 = program[pointer+1]
            pt2 = program[pointer+2]
            val1 = deref(pt1, program, modes[1], base)
            val2 = deref(pt2, program, modes[2], base)
            if val1 == 0
                pointer = val2 + 1
            else
                pointer = pointer + 3
            end
        elseif opcode == 7 # less than
            pt1 = program[pointer+1]
            pt2 = program[pointer+2]
            pt3 = program[pointer+3]
            val1 = deref(pt1, program, modes[1], base)
            val2 = deref(pt2, program, modes[2], base)
            program[write_pointer(pt3, modes[3], base)] = val1 < val2 ? 1 : 0
            pointer = pointer + 4
        elseif opcode == 8 # equal
            pt1 = program[pointer+1]
            pt2 = program[pointer+2]
            pt3 = program[pointer+3]
            val1 = deref(pt1, program, modes[1], base)
            val2 = deref(pt2, program, modes[2], base)
            program[write_pointer(pt3, modes[3], base)] = val1 == val2 ? 1 : 0
            pointer = pointer + 4
        elseif opcode == 9 # modify base
            pt1 = program[pointer+1]
            val1 = deref(pt1, program, modes[1], base)
            base = base + val1
            pointer = pointer + 2
        elseif opcode == 99
            close(output)
            return ret
        else
            throw(ErrorException("Invalid opcode: " * string(opcode)))
        end
    end
end

function draw_map(map::Array{Int, 2}, min::Vector{Int}, max::Vector{Int})
    map = string.(map)
    for row in eachrow(map[min[2]-1:max[2]+1,:])
        println(replace(replace(replace(replace(replace(replace(join(row[min[1]-1:max[1]+1]), "0" => " "), "1" => "."), "2" => "#"), "4" => "S"), "3" => "F"), "7" => "O"))
    end
end

function draw_map(map::Array{Int, 2}, robot::Vector{Int}, target::Vector{Int}, min::Vector{Int}, max::Vector{Int})
    map = string.(map)
    map[robot[2], robot[1]] = "^"
    map[target[2], target[1]] = "*"
    for row in eachrow(map[min[2]-1:max[2]+1,:])
        println(replace(replace(replace(replace(replace(join(row[min[1]-1:max[1]+1]), "0" => " "), "1" => "."), "2" => "#"), "4" => "S"), "3" => "F"))
    end
end

function draw_map(map::Array{Int, 2})
    min = findfirst(x -> x != 0, map)
    max = findlast(x -> x != 0, map)
    draw_map(map, [min[2], min[1]], [max[2], max[1]])
end

function draw_map(map::Array{Int, 2}, robot::Vector{Int}, direction::Int, queue::Vector{Vector{Int}})
    map = deepcopy(map)
    for q in queue
        map[q[2], q[1]] = 5 # queue
    end
    map[queue[1][2], queue[1][1]] = 6 # next objective
    map = string.(map)
    map[robot[2], robot[1]] = if direction == 0
        "^"
    elseif direction == 90
        "<"
    elseif direction == 180
        "v"
    elseif direction == 270
        ">"
    end
    for row in eachrow(map[robot[2]-2:robot[2]+2,:])
        println(replace(replace(replace(replace(replace(replace(replace(join(row[robot[1]-3:robot[1]+3]), "0" => " "), "1" => "."), "2" => "#"), "4" => "S"), "5" => "?"), "6" => "*"), "3" => "F"))
    end
end

function update_bounding_box(point, min, max)
    if point[1] < min[1]
        min[1] = point[1]
    end
    if point[1] > max[1]
        max[1] = point[1]
    end
    if point[2] < min[2]
        min[2] = point[2]
    end
    if point[2] > max[2]
        max[2] = point[2]
    end

    return min, max
end

function route(start::Vector{Int}, target::Vector{Int}, arr)
    i = 0
    arr = map(x -> x == 0 || x == 2 ? -99 : -1, arr) # Only consider visited points walkable
    # arr = map(x -> x == 2 ? -99 : -1, arr) # Consider unvisited points walkable, -1 => walkable
    
    # 1. init
    arr[start[2], start[1]] = i 
    arr[target[2], target[1]] = -1 # NOTE: target has to be reachable
    
    # 2. wave expansion
    target_reached = false
    while !target_reached # && i < 10 
        # println("Wave expansion #", i)
        res = findall(x -> x == i, arr)
        if length(res) == 0
            throw(ErrorException("Could not find path to "*string(target)*" from "*string(start)))
        end
        for p in res
            # println(p)
            neighbors = [
                [p[1]-1, p[2]],
                [p[1]+1, p[2]],
                [p[1], p[2]+1],
                [p[1], p[2]-1],
            ]
            for n in neighbors
                # println(n," ",arr[n[1], n[2]])
                if arr[n[1], n[2]] == -1
                    # println(n," ",arr[n[2], n[1]])
                    arr[n[1], n[2]] = i + 1
                    if n == reverse(target)
                        # println("Target found at ", n, " on iteration #",i)
                        target_reached = true
                        break
                    end
                end
            end
        end
        i = i + 1
    end

    # 3. backtrace
    path = []
    p = reverse(target)
    while p != reverse(start)
        neighbors = [
            [p[1]-1, p[2]],
            [p[1]+1, p[2]],
            [p[1], p[2]+1],
            [p[1], p[2]-1],
        ]
        for n in neighbors
            if arr[n[1],n[2]] == arr[p[1],p[2]] - 1
                # println(n)
                push!(path, n)
                p = n
                break
            end
        end
    end

    return path
end

# https://en.wikipedia.org/wiki/Lee_algorithm
function find_path_to(target::Vector, start::Vector, arr)::Int
    global cache
    # 0 = unvisited
    # 1 = visited
    # 2 = wall
    # 3 = finish
    # 4 = start
    distance = sqrt((start[1]-target[1])^2 + (start[2]-target[2])^2)
    # println("Start: ", start)
    # println("Target: ", target)
    # println("Distance: ", round(distance, digits=1))

    if arr[target[2], target[1]] == 2
        throw(ErrorException("Target is a wall"))
    end

    min = deepcopy(start)
    max = deepcopy(start)
    min, max = update_bounding_box(target, min, max)

    if distance > 1 && haskey(cache, target)
        # println("Possible cached paths")
        for path in cache[target]
            res = findlast(x -> x == reverse(start), path)
            if res != nothing
                # println("Cache hit!")
                target = reverse(path[res-1])
                break
            end
        end
    end

    if target == [start[1]-1, start[2]]
        # println("shortcircuit to left")
        return 90
    elseif target == [start[1]+1, start[2]]
        # println("shortcircuit to right")
        return 270
    elseif target == [start[1], start[2]+1]
        # println("shortcircuit to down")
        return 180
    elseif target == [start[1], start[2]-1]
        # println("shortcircuit to up")
        return 0
    end

    path = route(start, target, arr)

    # println("Write cache from ", start, " to ", target)
    if !haskey(cache, target)
        cache[target] = [path]
    else
        push!(cache[target], path)
    end

    res = reverse(path[end-1])

    if  res == [start[1]-1, start[2]]
        # println("to reach target go left")
        return 90
    elseif res == [start[1]+1, start[2]]
        # println("to reach target go right")
        return 270
    elseif res == [start[1], start[2]+1]
        # println("to reach target go down")
        return 180
    elseif res == [start[1], start[2]-1]
        # println("to reach target go up")
        return 0
    else
        throw(ErrorException("Node not next to start"))
    end

    throw(ErrorException("You shoudln't be here"))
end

function process_output(in::Channel, out::Channel)
    room = zeros(Int, 1000, 1000) # unvisited
    room[500, 500] = 4 # start
    robot = [500, 500]
    max = [500, 500] # drawing boundaries
    min = [500, 500]
    direction = 0 # up
    queue = [
        [robot[1]-1, robot[2]],
        [robot[1]+1, robot[2]],
        [robot[1], robot[2]+1],
        [robot[1], robot[2]-1],
        ]
    counter = 0
    status = -1
    # println(counter, ": robot at ",robot,":")
    # draw_map(room, robot, direction, queue)
    # println("Queue: ", length(queue))
    while true
        counter = counter + 1

        target = deepcopy(robot)
        if direction == 0
            put!(out, 1) # north/up
            target[2] = target[2] - 1
        elseif direction == 90
            put!(out, 3) # west/left
            target[1] = target[1] - 1
        elseif direction == 180
            put!(out, 2) # south/down
            target[2] = target[2] + 1
        elseif direction == 270
            put!(out, 4) # east/right
            target[1] = target[1] + 1
        else
            throw(ErrorException("invalid direction: "*direction ))
        end

        min, max = update_bounding_box(target, min, max)

        try
            status = take!(in)
        catch e
            if isa(e, InvalidStateException)
                break
            else
                rethrow
            end
        end

        if status == 0
            if room[target[2], target[1]] == 0 
                room[target[2], target[1]] = 2 # wall
            end
        elseif status == 1
            robot = target
            if room[target[2], target[1]] == 0 
                room[target[2], target[1]] = 1 # visited
            end
        elseif status == 2
            robot = target
            room[target[2], target[1]] = 3 # oxygen
            # break # FIXME: we use robot to exhaust the map, not to find target
        else
            throw(ErrorException("invalid status: "*direction ))
        end

        neighbors = [
            [robot[1]-1, robot[2]],
            [robot[1]+1, robot[2]],
            [robot[1], robot[2]+1],
            [robot[1], robot[2]-1],
        ]
    
        # println("Queue (", length(queue), "): ", queue)
        # println("Neighbors: ", neighbors)
        queue = filter(x -> room[x[2], x[1]] == 0, queue)
        neighbors = filter(x -> room[x[2], x[1]] == 0, neighbors)
        append!(queue, neighbors)
        if length(queue) == 0
            break # map exhausted
        end
        prepend!(queue, filter(x -> sqrt((x[1]-robot[1])^2 + (x[2]-robot[2])^2) == 1, queue))
        unique!(queue)
        # sort!(queue, by = x -> sqrt((x[1]-robot[1])^2 + (x[2]-robot[2])^2))

        if counter % 200 == 0
            println(counter, ": robot at ",robot,":")
            #    draw_map(room, robot, direction, queue)
            # draw_map(room, robot, queue[1], min, max)
            # println("Queue: ", length(queue))
            #    println(queue)
        end

       direction = find_path_to(queue[1], robot, room)

    end
    # println("Mapped in ", counter) # 2444
    return room
end

function fill(arr, start)
    min = findfirst(x -> x != 0, arr)
    max = findlast(x -> x != 0, arr)

    i = 0
    arr = map(x -> x == 2 ? -99 : x == 0 ? -98 : -1, arr) # block walls
    
    # 1. init
    arr[start[2], start[1]] = i 
    
    # 2. wave expansion
    while true
        # println("Wave expansion #", i)
        res = findall(x -> x == i, arr)
        if length(res) == 0
            break
        end
        for p in res
            # println(p)
            neighbors = [
                [p[1]-1, p[2]],
                [p[1]+1, p[2]],
                [p[1], p[2]+1],
                [p[1], p[2]-1],
            ]
            for n in neighbors
                # println(n," ",arr[n[1], n[2]])
                if arr[n[1], n[2]] == -1
                    # println(n," ",arr[n[2], n[1]])
                    arr[n[1], n[2]] = i + 1
                end
            end
        end
        i = i + 1
    end
    
    arr = map(x -> x >= 0 ? 7 : x, arr) # oxygen
    arr = map(x -> x == -1 ? 1 : x, arr) # visited (empty of oxygen)    
    arr = map(x -> x == -99 ? 2 : x, arr) # walls back
    arr = map(x -> x == -98 ? 0 : x, arr) # emptiness back
#    draw_map(arr, [min[2],min[1]], [max[2],max[1]])
   draw_map(arr)


    return i-1
end

cache = Dict()

function map_room()
    program = open("droid.csv") do f
        parse.(Int, split(readlines(f)[1], ","))
    end

    in = Channel(1)
    out = Channel(2)

    @async run_intcode(deepcopy(program), in, out)

    room = process_output(out, in)
    serialize("room.jls", room)

    return room
end 

room =  if isfile("room.jls")
            deserialize("room.jls")
        else
            map_room()
        end
draw_map(room)
target = findfirst(x -> x == 3, room)
steps = length(route([500,500], [target[2], target[1]], room))
println("Shortest path to oxygen in ", steps, " steps")
steps = fill(room, [target[2], target[1]])
println("It takes oxygen ", steps, " minutes to fill the space")
