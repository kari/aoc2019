using Combinatorics

mutable struct Moon
    pos::Vector{Int}
    v::Vector{Int}
end
Moon(pos) = Moon(pos, zeros(Int, 3))
Base.show(io::IO, m::Moon) = print("pos=<x = ",m.pos[1],", y= ",m.pos[2],", z= ",m.pos[3],">, vel=<x= ",m.v[1],", y= ",m.v[2],", z= ",m.v[3],">\n")
Base.:(==)(a::Moon, b::Moon) = a.pos == b.pos && a.v == b.v

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

function simulate(moons::Array{Moon})
    for pair in combinations(moons, 2)
        a, b = pair
        a.v = a.v + (a.pos .< b.pos) - (a.pos .> b.pos)
        b.v = b.v + (b.pos .< a.pos) - (b.pos .> a.pos)
    end
    for moon in moons
        moon.pos = moon.pos + moon.v
    end
end

positions = [
    [-16, 15, -9],
    [-14, 5, 4],
    [2, 0, 6],
    [-3, 18, 9],
]
# positions = [
#     [-1, 0, 2],
#     [2, -10, -7],
#     [4, -8, 8],
#     [3, 5, -1],
# ]
# positions = [
#     [-8, -10, 0],
#     [5, 5, 10],
#     [2, -7, 3],
#     [9, -8, -3],
# ]

moons = create_moons(positions)
for i in 1:1000
    simulate(moons)
    # println(moons)
end
println("Total energy: ", sum(energy.(moons)))

state = create_moons(positions)
history = [deepcopy(state)]
counter = 0
while true
    # println(history)
    global counter
    counter = counter + 1
    simulate(state)
    # if counter >= 2770
    #     println("After ", counter, " steps:")
    #     println(state)
    # end
    if state in history
        println(counter)
        break
    end
    
    push!(history, deepcopy(state))
    
end
