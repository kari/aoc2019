using Combinatorics
# <x=-16, y=15, z=-9>
# <x=-14, y=5, z=4>
# <x=2, y=0, z=6>
# <x=-3, y=18, z=9>

mutable struct Moon
    pos::Vector{Int}
    v::Vector{Int}
end
Moon(pos) = Moon(pos, zeros(Int, 3))
Base.show(io::IO, m::Moon) = print("pos=<x = ",m.pos[1],", y= ",m.pos[2],", z= ",m.pos[3],">, vel=<x= ",m.v[1],", y= ",m.v[2],", z= ",m.v[3],">\n")

function energy(m::Moon)::Int
    return sum(abs.(m.pos)) * sum(abs.(m.v))
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


moons = Moon[]
for i in 1:length(positions)
    push!(moons, Moon(positions[i]))
end

for i in 1:1000
    for pair in combinations(moons, 2)
        a, b = pair
        a.v = a.v + (a.pos .< b.pos) - (a.pos .> b.pos)
        b.v = b.v + (b.pos .< a.pos) - (b.pos .> a.pos)
    end
    for moon in moons
        moon.pos = moon.pos + moon.v
    end
    # println(moons)
end
println(sum(energy.(moons)))