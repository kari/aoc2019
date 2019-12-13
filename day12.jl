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

positions = [ # puzzle input
    [-16, 15, -9],
    [-14, 5, 4],
    [2, 0, 6],
    [-3, 18, 9],
]
# positions = [ # example 1
#     [-1, 0, 2],
#     [2, -10, -7],
#     [4, -8, 8],
#     [3, 5, -1],
# ]
positions = [ # example 2
    [-8, -10, 0],
    [5, 5, 10],
    [2, -7, 3],
    [9, -8, -3],
]

moons = create_moons(positions)
for i in 1:1000
    simulate(moons)
    # println(moons)
end
println("Total energy: ", sum(energy.(moons)))

function filter_history(x)
    println(x)
end

function find_periods(moons)
    history = [deepcopy(moons)]
    counter = 0
    periods = [0,0,0]
    
    while true
        counter = counter + 1
        simulate(moons)
        for axis in 1:3
            if periods[axis] == 0
                pos = map(moon -> moon.pos[axis], moons)
                v = map(moon -> moon.v[axis], moons)
                res = filter(x -> map(m -> m.pos[axis], x) == pos && map(m -> m.v[axis], x) == v, history)
                if length(res) > 0
                    # println("pos,v = ", pos,",",v," = ",res[end][i].pos[axis],",",res[end][i].v[axis])
                    prev = findlast(x -> x == res[end], history)
                    println(counter, ": period found for axis ",axis, ": ", counter,"-",(prev-1),"=", counter-(prev-1))
                    periods[axis] = counter-(prev-1)
                end
            end
        end
        if length(filter(x -> x != 0, periods)) == 3
            break
        end
        push!(history, deepcopy(moons))
    end

    return lcm(periods)
end

moons = create_moons(positions)
@time println(find_periods(moons))