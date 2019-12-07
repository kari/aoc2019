using Combinatorics

function run_intcode(program::Array{Int,1}, phase::Int, input::Channel, output::Channel)
    pointer = 1
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
            val1 = modes[1] == 0 ? program[pt1+1] : pt1
            val2 = modes[2] == 0 ? program[pt2+1] : pt2
            program[pt3+1] = val1 + val2
            pointer = pointer + 4
        elseif opcode == 2 # multiply
            pt1 = program[pointer+1]
            pt2 = program[pointer+2]
            pt3 = program[pointer+3]
            val1 = modes[1] == 0 ? program[pt1+1] : pt1
            val2 = modes[2] == 0 ? program[pt2+1] : pt2
            # println(join([modes, pt1, pt2, val1, val2, val1*val2], ","))
            program[pt3+1] = val1 * val2
            pointer = pointer + 4
        elseif opcode == 3 # store input
            pt1 = program[pointer+1]
            if phase >= 0
                program[pt1+1] = phase
                phase = -1
            else
                program[pt1+1] = take!(input)
            end
            pointer = pointer + 2
        elseif opcode == 4 # output
            pt1 = program[pointer+1]
            val1 = modes[1] == 0 ? program[pt1+1] : pt1            
            pointer = pointer + 2
            put!(output, val1)
        elseif opcode == 5 # jump if true
            pt1 = program[pointer+1]
            pt2 = program[pointer+2]
            val1 = modes[1] == 0 ? program[pt1+1] : pt1
            val2 = modes[2] == 0 ? program[pt2+1] : pt2
            if val1 != 0
                pointer = val2 + 1
            else
                pointer = pointer + 3
            end
        elseif opcode == 6 # jump if false
            pt1 = program[pointer+1]
            pt2 = program[pointer+2]
            val1 = modes[1] == 0 ? program[pt1+1] : pt1
            val2 = modes[2] == 0 ? program[pt2+1] : pt2
            if val1 == 0
                pointer = val2 + 1
            else
                pointer = pointer + 3
            end
        elseif opcode == 7 # less than
            pt1 = program[pointer+1]
            pt2 = program[pointer+2]
            pt3 = program[pointer+3]
            val1 = modes[1] == 0 ? program[pt1+1] : pt1
            val2 = modes[2] == 0 ? program[pt2+1] : pt2
            program[pt3+1] = val1 < val2 ? 1 : 0
            pointer = pointer + 4
        elseif opcode == 8 # equal
            pt1 = program[pointer+1]
            pt2 = program[pointer+2]
            pt3 = program[pointer+3]
            val1 = modes[1] == 0 ? program[pt1+1] : pt1
            val2 = modes[2] == 0 ? program[pt2+1] : pt2
            program[pt3+1] = val1 == val2 ? 1 : 0
            pointer = pointer + 4
        elseif opcode == 99
            break
        else
            throw(ErrorException("Invalid opcode: " * string(opcode)))
        end
    end
end

function find_max_signal(program::Array{Int,1}, phases::Array{Int,1})::Int
    max = 0
    settings = []
    for phase in permutations(phases)
        a_in = Channel(1)
        b_in = Channel(1)
        c_in = Channel(1)
        d_in = Channel(1)
        e_in = Channel(1)
        e_out = Channel(1)
        @async run_intcode(deepcopy(program), phase[1], a_in, b_in)
        @async run_intcode(deepcopy(program), phase[2], b_in, c_in)
        @async run_intcode(deepcopy(program), phase[3], c_in, d_in)
        @async run_intcode(deepcopy(program), phase[4], d_in, e_in)
        @async run_intcode(deepcopy(program), phase[5], e_in, e_out)
        put!(a_in, 0)
        thrusters = take!(e_out)
        if thrusters > max
            max = thrusters
            settings = phase
        end
    end
    println(settings)
    println(max)
    return max
end

# function feedback_loop(in, out)
    
# end

program = open("thrusters.csv") do f
    parse.(Int, split(readlines(f)[1], ","))
end
# program = [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]
# phases = [4,3,2,1,0]
# program = [3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0]
# phases = [0,1,2,3,4]
# program = [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]
# phases = [1,0,4,3,2]
find_max_signal(program, [0,1,2,3,4])
