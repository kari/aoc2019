image = open("password.sif") do f
    reshape([parse(Int, s) for s in readlines(f)[1]], 25, 6, :)
end

# image = reshape([parse(Int, s) for s in "0222112222120000"], 2, 2, :)

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

function visible_pixel(pixels::Array{Int,1})::Int
    for p in pixels
        # println(p)
        if p == 0 || p == 1
            return p
        end        
    end
    return -1
end

function parse_image(image::Array{Int,3})::Array{Int,2}
    res = zeros(Int, size(image, 1), size(image, 2))
    for x in 1:size(image, 1), y in 1:size(image,2)
        # println(image[x, y, :])
        res[x, y] = visible_pixel(image[x, y, :])
    end
    for row in 1:size(res, 2)
        println(replace(join(res[:,row]), "0" => " "))
    end
    return res
end

println(checksum(image))
parse_image(image)