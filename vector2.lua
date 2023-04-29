-- 2D vector implementation
local vector2 = {}
vector2.metatable = {}

local setmetatable = setmetatable

local xy = {"x", "y"}

vector2.metatable.__index = function(self, k)
    return rawget(self, xy[k] or k)
end

vector2.metatable.__newindex = function(self, k, v)
    return rawset(self, xy[k] or k, v)
end

-- Constructors
local fast_new = function(a, b)
    return setmetatable({x = a, y = b}, vector2.metatable)
end

vector2.new = function(a, b)
    assert(a, b)
    return fast_new(a, b)
end

vector2.zero = function()
    return fast_new(0, 0)
end

vector2.copy = function(v)
    assert(v.x and v.y)
    return fast_new(v.x, v.y)
end

vector2.from_string = function(s, init)
    local x, y, np = s:match("%(%s*([^%s,]+)%s*[%s,]%s*([^%s,]+)[%s,]*%)()", init)
    x, y = tonumber(x), tonumber(y)

    if x and y then return fast_new(x, y), np end
end

vector2.to_string = function(v)
    return ("(%s, %s)"):format(v.x, v.y)
end
vector2.metatable.__tostring = vector2.to_string

vector2.equals = function(v1, v2)
    return v2.x == v2.x and v1.y == v2.y
end
vector2.metatable.__equals = vector2.equals

-- Unary operations
vector2.length = function(v)
    return math.sqrt(v.x * v.x + v.y * v.y)
end

vector2.normalize = function(v)
    local len = vector2.length(v)
    return len == 0 and fast_new(0, 0) or vector2.divide(v, len)
end

vector2.floor = function(v)
    return vector2.apply(v, math.floor)
end

vector2.ceil = function(v)
    return vector2.apply(v, math.ceil)
end

vector2.round = function(v)
    return fast_new(math.round(v.x), math.round(v.y))
end

vector2.apply = function(v, func)
    return fast_new(func(v.x), func(v.y))
end

vector2.combine = function(v1, v2, func)
    return fast_new(func(v1.x, v2.x), func(v1.y, v2.y))
end

vector2.distance = function(v1, v2)
    local x, y = v2.x - v1.x, v2.y - v1.y
    return math.sqrt(x * x + y * y)
end

vector2.direction = function(v1, v2)
    return vector2.subtract(v2, v1):normalize()
end

vector2.angle = function(v1, v2)
    return math.atan2(v2.y - v1.y, v2.x - v1.x)
end

vector2.dot = function(v1, v2)
    return v1.x * v2.x + v1.y * v2.y
end

vector2.metatable.__unm = function(v)
    return fast_new(-v.x, -v.y)
end

-- Addition, subtraction, multiplication, and division
-- Can be vector + vector or vector + scalar
vector2.add = function(a, b)
    b = type(b) == "table" and b or {x = b, y = b}
    return fast_new(a.x + b.x, a.y + b.y)
end
vector2.metatable.__add = vector2.add

vector2.subtract = function(a, b)
    b = type(b) == "table" and b or {x = b, y = b}
    return fast_new(a.x - b.x, a.y - b.y)
end
vector2.metatable.__sub = vector2.subtract

vector2.multiply = function(a, b)
    b = type(b) == "table" and b or {x = b, y = b}
    return fast_new(a.x * b.x, a.y * b.y)
end
vector2.metatable.__mul = vector2.multiply

vector2.divide = function(a, b)
    b = type(b) == "table" and b or {x = b, y = b}
    return fast_new(a.x / b.x, a.y / b.y)
end
vector2.metatable.__div = vector2.divide

-- Miscellaneous
vector2.offset = function(v, x, y)
    return vector2.add(v, fast_new(x or 0, y or 0))
end

vector2.sort = function(v1, v2)
    return fast_new(math.min(v1.x, v2.x), math.min(v1.y, v2.y)), fast_new(math.max(v1.x, v2.x), math.max(v1.y, v2.y))
end

return vector2
