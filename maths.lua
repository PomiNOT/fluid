function Lerp(a, b, t)
    return a + (b - a) * t
end

function Clamp(x, min, max)
    return math.max(min, math.min(max, x))
end

function GaussSeidel(field, iterations, alpha, beta)
    local result = nil
    
    if field.type == "scalar" then
        result = ScalarField.new(field.N, field.M)
    elseif field.type == "vector" then
        result = VectorField.new(field.N, field.M)
    end

    for k = 1, iterations do
        for i = 1, field.N do
            for j = 1, field.M do
                local p = 
                    (field:get(i, j) +
                    alpha * 
                        (result:get(i - 1, j) +
                        result:get(i + 1, j) +
                        result:get(i, j - 1) +
                        result:get(i, j + 1)
                    )) / beta
                result:set(i, j, p)
            end
        end
    end

    return result
end

return {
    Lerp = Lerp,
    Clamp = Clamp,
    GaussSeidel = GaussSeidel
}