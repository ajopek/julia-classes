function symmetricswap(array)
    size = length(array)
    for i = 1:convert(Int32, floor(size/2))
        endi = size + 1 - i
        tmp = array[endi]
        array[endi] = array[i]
        array[i] = tmp
    end
    return array
end

symmetricswap([1 3 2 4 5 6 7])
