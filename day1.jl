function fuel(mass)::Int
    fuelreq = round(mass/3, RoundDown) - 2
    if fuelreq <= 0
        return 0
    end
    return fuelreq + fuel(fuelreq)
end

open("mass.csv") do f
    masses = parse.(Int, readlines(f))
    println(sum(round.(masses/3, RoundDown) .- 2))
    println(sum(fuel.(masses)))
end

