function run_intcode(program, x, y)::Int
    program[2] = x
    program[3] = y
    pointer = 1
    while pointer <= length(program)
        opcode = program[pointer]
        if opcode == 1
            pt1 = program[pointer+1]+1
            pt2 = program[pointer+2]+1
            pt3 = program[pointer+3]+1    
            program[pt3] = program[pt1] + program[pt2]
        elseif opcode == 2
            pt1 = program[pointer+1]+1
            pt2 = program[pointer+2]+1
            pt3 = program[pointer+3]+1    
            program[pt3] = program[pt1] * program[pt2]
        elseif opcode == 99
            break
        else
            throw(ErrorException("Invalid opcode"))
        end
        pointer = pointer+4
    end

    return program[1]
end

open("intcode.csv") do f
    program = parse.(Int, split(readlines(f)[1], ","))
    println(run_intcode(deepcopy(program), 12, 2))
    for i in 0:99
        for j in 0:99
            res = try 
                run_intcode(deepcopy(program), i, j)
            catch e
                -1
            end
            if res == 19690720
                println(100*i+j)
                break
            end
        end
    end
end
