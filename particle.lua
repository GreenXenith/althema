local object = require("object")

local particle = object:new()
particle.__index = particle

particle.new = function(self, texture, pos, size, rotation, velocity, time)
    local o = setmetatable(object:new(), self)

    o.texture = texture
    o.pos = pos
    o.velocity = velocity
    if size then o.size = size end
    if rotation then o.rotation = rotation end

    o._timer = time

    game.world:add_object(o)
end

particle.update = function(self, dtime)
    self._timer = self._timer - dtime
    if self._timer <= 0 then
        game.world:remove_object(self)
    end

    object.update(self, dtime)
end

return particle
