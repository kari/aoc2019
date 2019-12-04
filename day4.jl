function password_enumerator(s, e)::Int
    valid = 0
    for i = s:e
        if length(unique(digits(i))) <= 5 && sum(reverse(digits(i))[2:end] .>= reverse(digits(i))[1:end-1]) == 5
            for j in unique(digits(i))
                if sum(x->x==j, digits(i)) == 2
                    # println(i)
                    valid = valid + 1
                    break
                end
            end
        end
    end
    return valid
end

println(password_enumerator(236491,713787))