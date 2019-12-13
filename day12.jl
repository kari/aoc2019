using Combinatorics

mutable struct Moon
    pos::Vector{Int}
    v::Vector{Int}
end
Moon(pos) = Moon(pos, zeros(Int, 3))
Base.show(io::IO, m::Moon) = print("pos=<x = ",m.pos[1],", y= ",m.pos[2],", z= ",m.pos[3],">, vel=<x= ",m.v[1],", y= ",m.v[2],", z= ",m.v[3],">\n")
# Base.:(==)(a::Moon, b::Moon) = a.pos == b.pos && a.v == b.v
Base.:(==)(a::Moon, b::Moon) = hash(a) == hash(b)
Base.hash(m::Moon, h::UInt64) = hash((m.pos, m.v), h)

function energy(m::Moon)::Int
    return sum(abs.(m.pos)) * sum(abs.(m.v))
end

function create_moons(positions::Array{Vector{Int}})::Vector{Moon}
    moons = Moon[]
    for i in 1:length(positions)
        push!(moons, Moon(positions[i]))
    end
    return moons
end

function create_moons(positions::Array{})
    moons = Moon[]
    for i in 1:size(positions,1)
        push!(moons, Moon(positions[i,:]))
    end
    return moons
end

function simulate(moons::Vector{Moon})
    for pair in combinations(moons, 2)
        a, b = pair
        a.v = a.v + (a.pos .< b.pos) - (a.pos .> b.pos)
        b.v = b.v + (b.pos .< a.pos) - (b.pos .> a.pos)
    end
    for moon in moons
        moon.pos = moon.pos + moon.v
    end
end

function simulate(moons::Vector{Moon}, n::Int)
    for i = 1:n
        simulate(moons)
    end
end


function simulate(pos::Array{}, v::Array{})
    for pair in combinations(1:4, 2)
        a, b = pair
        v[a,:] = v[a,:] + (pos[a,:] .< pos[b,:]) - (pos[a,:] .> pos[b,:])
        v[b,:] = v[b,:] + (pos[b,:] .< pos[a,:]) - (pos[b,:] .> pos[a,:])
    end
    return pos+v, v
end

function simulate(pos::Array{}, v::Array{}, n::Int)
    for i in 1:n
        pos, v = simulate(pos, v)
    end
    return pos, v
end

function calculate_energy(positions::Array{Int,2}, n::Int)
    moons = create_moons(positions)
    # println(positions)
    simulate(moons, n)
    # println(moons)
    println("Total energy: ", sum(energy.(moons)))
end

# example 1
positions1 = [-1 0 2; 2 -10 -7; 4 -8 8; 3 5 -1]
# example 2
positions2 = [-8 -10 0; 5 5 10; 2 -7 3; 9 -8 -3]
# puzzle input
positions = [-16 15 -9; -14 5 4; 2 0 6; -3 18 9]

# velocities = zeros(Int,4,3)

calculate_energy(positions1, 10)
calculate_energy(positions2, 100)
calculate_energy(positions, 1000)
# function filter_history(x)
#     println(x)
# end

function find_periods(positions::Array{Int,2})
    # moons = create_moons(positions)
    velocities = zeros(Int,4,3)
    counter = 0
    history = Array{UInt64}(undef, 3, 1000000)
    #history[counter+1] = hash.(eachcol(vcat(positions, velocities)))
    history[:, counter+1] = hash.(eachcol(vcat(positions, velocities)))
    periods = [0,0,0]

    while true
        counter = counter + 1
        positions, velocities = simulate(positions, velocities)
        entry = hash.(eachcol(vcat(positions, velocities)))
        for axis in 1:3
            if periods[axis] == 0
                res = findfirst(x -> x == entry[axis], history[axis,1:counter])
                if res != nothing 
                    println(counter, ": period found for axis ",axis, ": ", counter,"-",(res-1),"=", counter-(res-1))
                    periods[axis] = counter-(res-1)
                end
            end
        end
        if sum(periods .> 0) == 3
            break
        end
        if counter % 5000 == 0
            println(counter)
        end
        # history = hcat(history, entry)
        history[:,counter+1] = entry
    end

    return lcm(periods)
end

@time println(find_periods(positions1))
@time println(find_periods(positions2))
@time println(find_periods(positions))