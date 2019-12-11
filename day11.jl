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

function draw_map(map, robot, direction, min=nothing, max=nothing)
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
    if min === nothing || max === nothing 
        for row in eachrow(map[robot[2]-2:robot[2]+2,:])
            println(replace(replace(join(row[robot[1]-3:robot[1]+3]), "0" => "."), "1" => "#"))
        end
    else
        for row in eachrow(map[min[2]-1:max[2]+1,:])
            println(replace(replace(join(row[min[1]-1:max[1]+1]), "0" => " "), "1" => "#"))
        end
    end
end

function process_output(in::Channel, out::Channel)
    hull = zeros(Int, 1000, 1000)
    hull[500, 500] = 1
    robot = [500, 500]
    max = [500, 500]
    min = [500, 500]
    paint = turn = 0
    direction = 0 # up
    painted_coords = []
    counter = 0
    while true
        if counter > 10 
            # throw(ErrorException)
        end
        counter = counter + 1
        put!(out, hull[robot[2], robot[1]])
        try
            paint = take!(in)
            turn = take!(in)
        catch e
            if isa(e, InvalidStateException)
                break
            else
                rethrow
            end
        end

        # println(counter, ": robot at ",robot," (", direction ,"): ",hull[robot[2], robot[1]]," -> ", paint)
        hull[robot[2], robot[1]] = paint
        push!(painted_coords, deepcopy(robot))
        
        if turn == 0 
            direction = direction + 90
        elseif turn == 1
            direction = direction - 90
        else
            throw(ErrorException("Invalid turn: " * turn))
        end
        if direction >= 360
            direction = direction - 360
        elseif direction < 0 
            direction = direction + 360
        end
        if direction == 0 # up
            robot[2] = robot[2] - 1
        elseif direction == 90 # left
            robot[1] = robot[1] - 1
        elseif direction == 180 # down
            robot[2] = robot[2] + 1
        elseif direction == 270 # right
            robot[1] = robot[1] + 1
        else
            throw(ErrorException("Invalid direction: " * direction))
        end

        if robot[1] < min[1]
            min[1] = robot[1]
        end
        if robot[1] > max[1]
            max[1] = robot[1]
        end
        if robot[2] < min[2]
            min[2] = robot[2]
        end
        if robot[2] > max[2]
            max[2] = robot[2]
        end             
        # println("Turned ",turn == 0 ? "left" : "right", " (", turn, ") to face ",direction, ". Visited ", length(painted_coords), " points (", length(unique(painted_coords)), " unique)")
        # println(painted_coords)
        # draw_map(hull, robot, direction)
    end
    draw_map(hull, robot, direction, min, max)
    println("Visited ", length(painted_coords), " points (", length(unique(painted_coords)), " unique)")
    return length(unique(painted_coords))
end

program = open("paintrobot.csv") do f
    parse.(Int, split(readlines(f)[1], ","))
end

in = Channel(1)
out = Channel(2)

@async run_intcode(deepcopy(program), in, out)
println(process_output(out, in))