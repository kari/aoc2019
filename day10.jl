using LinearAlgebra

map = open("asteroids.txt") do f
    readlines(f)
end

asteroids = []

for (y, i) in enumerate(map)
    for (x, j) in enumerate(i)
        if map[y][x] == '#'
            push!(asteroids, [x,y])
        end
    end
end
# println(asteroids)

struct Station
    coordinates
    asteroids::Int
end

candidate = Station(nothing, 0)
for a in asteroids
    global candidate
    angles = Set()
    others = filter(x -> x != a, asteroids)
    for o in others
        v = o - a
        x = [1, 0]
        # angle = acos(dot(x,v)/(norm(x)*norm(v)))
        angle = atan(v[1],v[2]) - atan(1,0)
        len = norm(v)
        # println(o," ",v," ",round(rad2deg(angle), digits=2)," ",round(len, digits=2))
        push!(angles, angle)
    end
    if length(angles) > candidate.asteroids
        candidate = Station(a, length(angles))
    end
    # println(sort(collect(Float64, angles)))
    # println(a, " unique angles: ", length(angles))
end
println(candidate)


