using Combinatorics

function run_intcode(program, input)
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
            program[pt1+1] = popfirst!(input)
            pointer = pointer + 2
        elseif opcode == 4 # output
            pt1 = program[pointer+1]
            val1 = modes[1] == 0 ? program[pt1+1] : pt1            
            pointer = pointer + 2
            # println(val1)
            ret = val1
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

program = open("thrusters.csv") do f
    parse.(Int, split(readlines(f)[1], ","))
end
# program = [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]
# phases = [4,3,2,1,0]
# program = [3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0]
# phases = [0,1,2,3,4]
# program = [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]
# phases = [1,0,4,3,2]
max = 0
settings = []
for phases in permutations([0,1,2,3,4])
    global max, settings
    a_out = run_intcode(deepcopy(program), [phases[1], 0])
    b_out = run_intcode(deepcopy(program), [phases[2], a_out])
    c_out = run_intcode(deepcopy(program), [phases[3], b_out])
    d_out = run_intcode(deepcopy(program), [phases[4], c_out])
    e_out = run_intcode(deepcopy(program), [phases[5], d_out])
    if e_out > max
        max = e_out
        settings = phases
    end
end
println(settings)
println(max)
