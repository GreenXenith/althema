local vec2 = require("vector2")

local object = {}

object.new_object = function()
    return setmetatable({
        children = {},
        pos = vec2.zero(),
        size = vec2.new(1, 1),
        rotation = 0,
        velocity = vec2.zero(),
    }, {__index = object})
end

object.update = function(self, dtime)
    if self.velocity then
        if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
            self.pos = self.pos + self.velocity * dtime
        end
    end

    if self.children then
        for child, params in pairs(self.children) do
            local offset = params.position
            if params.relative_position then
                local length = vec2.length(offset)
                local angle = vec2.angle(vec2.zero(), offset)
                offset = vec2.new(math.cos(angle + self.rotation), math.sin(angle + self.rotation)) * length
            end
            child.pos = self.pos + offset

            local rotation = params.rotation
            if params.relative_rotation then
                rotation = rotation + self.rotation
            end
            child.rotation = rotation
        end
    end
end

object.attach = function(self, other, position, rotation, relative_position, relative_rotation)
    other.children[self] = {
        position = position or vec2.zero(),
        rotation = rotation or 0,
        relative_position = (relative_position == nil and true) or relative_position,
        relative_rotation = (relative_rotation == nil and true) or relative_rotation,
    }

    self.parent = other
end

return object
