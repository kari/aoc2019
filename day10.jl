function parse_map(fn::String)::Vector{Asteroid}
    map = open(fn) do f
        readlines(f)
    end
    
    asteroids = []

    for (y, i) in enumerate(map)
        for (x, j) in enumerate(i)
            if map[y][x] == '#'
                push!(asteroids, Asteroid([x,y]))
            end
        end
    end

    return asteroids
end

struct Station
    coordinates::Vector{Int}
    asteroids::Int
end

mutable struct Asteroid
    coordinates::Vector{Int}
    distance::Union{Float64, Nothing}
    angle::Union{Float64, Nothing}
end
Asteroid(c) = Asteroid(c, nothing, nothing)

Base.show(io::IO, s::Station) = print(io, "Station at (",s.coordinates[1],",",s.coordinates[2],") with ",s.asteroids," asteroids visible")
Base.show(io::IO, s::Asteroid) = print(io, "Asteroid at (",s.coordinates[1],",",s.coordinates[2],"), angle ",round(rad2deg(s.angle), digits=2),", distance ",round(s.distance, digits=2))

function find_best_station(asteroids::Vector{Asteroid})::Station
    candidate = Station([0,0], 0)

    for a in asteroids
        angles = Set()
        others = filter(x -> x != a, asteroids)

        for o in others
            v = o.coordinates - a.coordinates
            angle = atan(v[1],v[2]) - atan(1,0)
            len = sqrt(v[1]^2+v[2]^2)
            # println(Asteroid(o, len, angle))
            push!(angles, angle)
        end

        if length(angles) > candidate.asteroids
            candidate = Station(a.coordinates, length(angles))
        end
        # println(sort(collect(Float64, angles)))
        # println(candidate)
    end

    return candidate
end

function nuke(asteroids::Vector{Asteroid}, station::Station)
    laser_direction = pi/2 # -> 0deg, ccw
    others = filter(x -> x.coordinates != station.coordinates, asteroids)
    for o in others
        v = o.coordinates - station.coordinates
        # angle = acos(dot(x,v)/(norm(x)*norm(v)))
        o.angle = atan(v[1],v[2]) - atan(1,0)
        if o.angle < 0
            o.angle = o.angle + 2*pi
        end
        o.distance = sqrt(v[1]^2+v[2]^2)
        # a = Asteroid(o.coordinates, len, angle)
        # println(o)
    end
    counter = 0
    # laser_direction = 0
    println("Targets: ", length(others))
    while length(others) > 0 # && counter < 100
        # println("laser direction ", round(laser_direction, digits=2))
        targets = sort(filter(x -> x.angle == laser_direction, others), by = x -> x.distance)
        # println("Targets: ", targets)
        if length(targets) > 0 
            target = targets[1]
            filter!(x -> x != target, others)
            counter = counter + 1
            println("Target ",counter,": ", target)
            # println(length(others)," targets left")
            if length(others) == 0
                break
            end
        else
            println("No target?!")
        end
        angles = sort(filter(x -> x < laser_direction, map(x -> x.angle, others)), rev = true)
        if length(angles) == 0
            laser_direction = laser_direction + 2*pi
            angles = sort(filter(x -> x < laser_direction, map(x -> x.angle, others)), rev = true)
        end
        # println(angles)
        laser_direction = angles[1]
        # break
    end
end

asteroids = parse_map("asteroids.txt")
station = find_best_station(asteroids)
println(station)
nuke(asteroids, station)