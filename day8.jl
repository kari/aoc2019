image = open("password.sif") do f
    reshape([parse(Int, s) for s in readlines(f)[1]], 25, 6, :)
end

function checksum(image::Array{Int,3})::Int
    min = size(image, 1)*size(image, 2)
    prod = 0
    for i in 1:size(image, 3)
        zeros = sum(x -> x == 0, image[:,:,i])
        ones = sum(x -> x == 1, image[:,:,i])
        twos = sum(x -> x == 2, image[:,:,i])
        if zeros < min
            min = zeros
            prod = ones * twos
        end
    end

    return prod
end

println(checksum(image))