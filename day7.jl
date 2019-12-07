using Combinatorics

function run_intcode(program::Array{Int,1}, phase::Int, input::Channel, output::Channel)
    pointer = 1
    ret = nothing
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
            ret = val1
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
            return ret
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
        e = 0
        @sync begin
            @async run_intcode(deepcopy(program), phase[1], a_in, b_in)
            @async run_intcode(deepcopy(program), phase[2], b_in, c_in)
            @async run_intcode(deepcopy(program), phase[3], c_in, d_in)
            @async run_intcode(deepcopy(program), phase[4], d_in, e_in)
            @async e = run_intcode(deepcopy(program), phase[5], e_in, a_in)
            put!(a_in, 0)
        end
        if e > max
            max = e
            settings = phase
        end
    end
    println(settings)
    println(max)
    return max
end

program = open("thrusters.csv") do f
    parse.(Int, split(readlines(f)[1], ","))
end
# program = [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]
# phases = [4,3,2,1,0]
# program = [3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0]
# phases = [0,1,2,3,4]
# program = [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]
# phases = [1,0,4,3,2]
# find_max_signal(program, [0,1,2,3,4])
# program = [3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26, 27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]
# program = [3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54, -5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4, 53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10]
find_max_signal(program, [5,6,7,8,9])
