local ScalarField = require("scalar_field")
local VectorField = require("vector_field")
local vec = require("vector")
local maths = require("maths")

function love.load()
    SIZE = 35
    pField = ScalarField.new(SIZE, SIZE)
    vField = VectorField.new(SIZE, SIZE)

    diffusionFactor = 0
end

local mX0, mY0 = -1, -1
function love.update(dt)
    if love.mouse.isDown(1) then
        local mX, mY = love.mouse.getPosition()
        if mX0 == -1 and mY0 == -1 then
            mX0, mY0 = mX, mY
            return
        end
        local dx, dy = mX - mX0, mY - mY0
        mX0, mY0 = mX, mY
        local i, j = GetCell()
        pField:set(i, j, 1)
        vField:set(i, j, (vec.new(dx, dy)):normalized() * 10)
    else
        mX0, mY0 = -1, -1
    end

    --Density
    Diffuse(dt, pField)
    Advect(dt, pField)

    --velocity
    Diffuse(dt, vField)
    Project()
    Advect(dt, vField)
    Project()

    for i=1, SIZE do
        for j=1, SIZE do
            pField:set(i, j, pField:get(i, j) - 0.05 * dt)
        end
    end
end

function Diffuse(dt, state)
    local a = dt * diffusionFactor * pField.N * pField.M
    local iterations = 10
    
    if state.type == "scalar" then
        pField = maths.GaussSeidel(pField, iterations, a, 1 + 4 * a)
    elseif state.type == "vector" then
        vField = maths.GaussSeidel(vField, iterations, a, 1 + 4 * a)
    end
end

function Advect(dt, state)
    local result = nil
    local object = nil

    if state.type == "vector" then
        result = VectorField.new(vField.N, vField.M)
        object = vField
    elseif state.type == "scalar" then
        result = ScalarField.new(pField.N, pField.M)
        object = pField
    end

    for i = 1, object.N do
        for j = 1, object.M do
            local velocity = vField:get(i, j)
            --+0.5 because we are considering the center of the cell
            local was = vec.new(i + 0.5, j + 0.5) - dt * velocity
    
            result:set(i, j, object:getInterpolated(was.x, was.y))
        end
    end

    if state.type == "vector" then
        vField = result
    elseif state.type == "scalar" then
        pField = result
    end
end

function Project()
    local h = 1.0 / vField.N
    local div = ScalarField.new(vField.N, vField.M)
    local p = ScalarField.new(vField.N, vField.M)

    for i = 1, vField.N do
        for j = 1, vField.M do
            local top = vField:get(i, j - 1)
            local bottom = vField:get(i, j + 1)
            local left = vField:get(i - 1, j)
            local right = vField:get(i + 1, j)

            div:set(i, j, -0.5 * h * ((bottom.y - top.y) + (right.x - left.x)))
        end
    end

    p = maths.GaussSeidel(div, 10, 1, 4)

    for i = 1, vField.N do
        for j = 1, vField.M do
            local velocity = vField:get(i, j)
            velocity.x = velocity.x - 0.5 * (p:get(i + 1, j) - p:get(i - 1, j)) / h
            velocity.y = velocity.y - 0.5 * (p:get(i, j + 1) - p:get(i, j - 1)) / h
            vField:set(i, j, velocity)
        end
    end
end

function GetCell()
    local x, y = love.mouse.getPosition()
    local w, h = love.graphics.getDimensions()
    local cw, ch = w / pField.N, h / pField.M
    local i, j = math.floor(x / cw) + 1, math.floor(y / ch) + 1
    return i, j
end

function love.draw()
    local w, h = love.graphics.getDimensions()
    pField:draw(w, h)
end