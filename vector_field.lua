local vec = require("vector")
local maths = require("maths")

VectorField = {}

function VectorField.new(N, M)
    local self = {}
    self.N = N
    self.M = M
    self.field = {}
    self.type = "vector"

    for i = 1, N do
        self.field[i] = {}
    end

    setmetatable(self, {__index = VectorField})
    return self
end

function VectorField:outside(x, y)
    return x < 1 or x > self.N or y < 1 or y > self.M
end

function VectorField:get(i, j)
    if self:outside(i, j) then
        return vec.new(0, 0)
    else
        return self.field[i][j] or vec.new(0, 0)
    end
end
    
function VectorField:set(i, j, v)
    if self:outside(i, j) then
        return
    else
        self.field[i][j] = v
    end
end

function VectorField:getInterpolated(x, y)
    --Calculate relative to (1.5, 1.5)
    x = x - 1.5
    y = y - 1.5

    local i = math.floor(x) + 1
    local j = math.floor(y) + 1
    local tl = self:get(i, j)
    local tr = self:get(i + 1, j)
    local bl = self:get(i, j + 1)
    local br = self:get(i + 1, j + 1)
    local t = maths.Lerp(tl, tr, x - math.floor(x))
    local b = maths.Lerp(bl, br, x - math.floor(x))
    return maths.Lerp(t, b, y - math.floor(y))
end

function VectorField:DrawVector(v, x, y, w, h)
    local x1 = x + v.x * w
    local y1 = y + v.y * h
    love.graphics.setColor(0,  1,  0)
    love.graphics.line(x, y, x1, y1)
end

function VectorField:draw(width, height)
    local w = width / self.N
    local h = height / self.M
    for i = 1, self.N do
        for j = 1, self.M do
            local v = self:get(i, j)
            local x = (i - 1) * w + w / 2
            local y = (j - 1) * h + h / 2
            self:DrawVector(v, x, y, w, h)
        end
    end
end

return VectorField