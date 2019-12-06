function fuel(mass)::Int
    fuelreq = round(mass/3, RoundDown) - 2
    if fuelreq <= 0
        return 0
    end
    return fuelreq + fuel(fuelreq)
end

masses = open("mass.csv") do f
    parse.(Int, readlines(f))
end
println(sum(round.(masses/3, RoundDown) .- 2))
println(sum(fuel.(masses)))

