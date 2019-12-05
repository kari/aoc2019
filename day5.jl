function run_intcode(program, input)
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
            program[pt1+1] = input
            pointer = pointer + 2
        elseif opcode == 4 # output
            pt1 = program[pointer+1]
            val1 = modes[1] == 0 ? program[pt1+1] : pt1            
            pointer = pointer + 2
            println(val1)
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

open("diagnostic.csv") do f
    program = parse.(Int, split(readlines(f)[1], ","))
    run_intcode(deepcopy(program), 1)
    run_intcode(deepcopy(program), 5)
end
