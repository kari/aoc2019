function run_intcode(program, input)
    pointer = 1
    i = 0
    while pointer <= length(program) && i < 1000
        # println(program)
        i = i + 1
        instruction = reverse(digits(program[pointer], pad=5))
        # println(instruction)
        opcode = instruction[end] + instruction[end-1]*10
        modes = reverse(instruction[1:end-2])
        #println(join([opcode,": ",modes]))
        if opcode == 1
            pt1 = program[pointer+1]
            pt2 = program[pointer+2]
            val1 = modes[1] == 0 ? program[pt1+1] : pt1
            val2 = modes[2] == 0 ? program[pt2+1] : pt2
            pt3 = program[pointer+3]+1    
            program[pt3] = val1 + val2
            pointer = pointer + 4
        elseif opcode == 2            
            pt1 = program[pointer+1]
            pt2 = program[pointer+2]
            val1 = modes[1] == 0 ? program[pt1+1] : pt1
            val2 = modes[2] == 0 ? program[pt2+1] : pt2
            pt3 = program[pointer+3]+1
            # println(join([modes, pt1, pt2, val1, val2, val1*val2], ","))
            program[pt3] = val1 * val2
            pointer = pointer + 4
        elseif opcode == 3
            pt1 = program[pointer+1]+1
            program[pt1] = input
            pointer = pointer + 2
        elseif opcode == 4
            pt1 = program[pointer+1]+1
            println(program[pt1])
            pointer = pointer + 2
        elseif opcode == 99
            break
        else
            throw(ErrorException("Invalid opcode: " * string(opcode)))
        end
        
    end
end

open("diagnostic.csv") do f
    program = parse.(Int, split(readlines(f)[1], ","))
    # program = parse.(Int, split("3,0,4,0,99", ","))
    # program = parse.(Int, split("1002,4,3,4,33", ","))

    run_intcode(deepcopy(program), 1)
end
