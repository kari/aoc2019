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

function process_output(in::Channel, out::Channel)::Int
    score = 0
    screen = zeros(100, 100)
    player, x,y,tile = [0,0,0,0]
  
    while true
        try
            x = take!(in)
            y = take!(in)
            tile = take!(in)
        catch e
            if isa(e, InvalidStateException)
                break
            else
                rethrow
            end
        end
        println("(", x,", ",y,"): ",tile)
        if x == -1 && y == 0
            score = tile
        else
            screen[x+1, y+1] = tile
        end
        if tile == 3
            player = x
        end
        if tile == 4
            if player == x
                put!(out, 0)
            elseif player < x
                put!(out, 1)
            else
                put!(out, -1)
            end
        end
    end
    return sum(x -> x == 2, screen)
end

program = open("arcade.csv") do f
    parse.(Int, split(readlines(f)[1], ","))
end

in = Channel(1)
out = Channel(2)

program[1] = 2
@async run_intcode(deepcopy(program), in, out)
println(process_output(out, in))
