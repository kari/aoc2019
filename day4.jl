function password_enumerator(s, e)::Int
    valid = []
    for i = s:e
        if length(unique(digits(i))) <= 5 && sum(reverse(digits(i))[2:end] .>= reverse(digits(i))[1:end-1]) == 5
            println(i)
            push!(valid, i)
        end
    end
    return length(valid)
end

println(password_enumerator(236491,713787))