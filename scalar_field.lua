local maths = require("maths")

ScalarField = {}

function ScalarField.new(N, M)
    local self = {}
    self.N = N
    self.M = M
    self.field = {}
    self.type = "scalar"
    for i = 1, N do
        self.field[i] = {}
    end

    setmetatable(self, {__index = ScalarField})
    return self
end

function ScalarField:outside(x, y)
    return x < 1 or x > self.N or y < 1 or y > self.M
end

function ScalarField:get(i, j)
    if self:outside(i, j) then
        return 0
    else
        return self.field[i][j] or 0
    end
end

function ScalarField:getInterpolated(x, y)
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

function ScalarField:set(i, j, v)
    if self:outside(i, j) then
        return
    else
        self.field[i][j] = maths.Clamp(v, 0, 1)
    end
end

function ScalarField:draw(width, height)
    local w = width / self.N
    local h = height / self.M
    for i = 1, self.N do
        for j = 1, self.M do
            local x = (i - 1) * w
            local y = (j - 1) * h
            local v = self:get(i, j)
            love.graphics.setColor(v, v, v)
            love.graphics.rectangle("fill", x, y, w, h)
        end
    end
end

return ScalarField