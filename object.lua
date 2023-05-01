local vec2 = require("vector2")

local object = {
    pos = vec2.zero(),
    rotation = 0,
    size = vec2.new(1, 1),
    velocity = vec2.zero(),
}
object.__index = object

object.new = function(self, o)
    o = o or {}
    o.children = {}
    return setmetatable(o, self)
end

object.set_collider = function(self, size)
    self.collider = game.world:new_collider(self, size)
end

object.update = function(self, dtime)
    if self.velocity then
        if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
            if self.collider then
                local travel = self.velocity * dtime

                self.pos.x = self.pos.x + travel.x
                for collider2 in pairs(game.world.colliders) do
                    if collider2 ~= self.collider then
                        if self.collider:intersection(collider2) then
                            self.pos.x = self.pos.x - travel.x
                        end
                    end
                end

                self.pos.y = self.pos.y + travel.y
                for collider2 in pairs(game.world.colliders) do
                    if collider2 ~= self.collider then
                        if self.collider:intersection(collider2) then
                            self.pos.y = self.pos.y - travel.y
                        end
                    end
                end
            else
                self.pos = self.pos + self.velocity * dtime
            end
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

object.remove = function(self)
    if self.collider then game.world:remove_collider(self.collider) end
    for child in pairs(self.children) do
        game.world:remove_object(child)
    end
end

return object
