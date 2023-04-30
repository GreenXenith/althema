local object = require("object")

local particle = setmetatable({}, {__index = object})

particle.spawn = function(texture, pos, size, rotation, velocity, time)
    local p = setmetatable(object.new_object(), {__index = particle})
    p.texture = texture
    p.pos = pos or p.pos
    p.velocity = velocity or p.velocity
    p.size = size or p.size
    p.rotation = rotation or p.rotation
    p._timer = time

    game.world:add_object(p)
end

particle.update = function(self, dtime)

    self._timer = self._timer - dtime
    if self._timer <= 0 then
        game.world:remove_object(self)
    end
    getmetatable(particle).__index.update(self, dtime)
end

return particle
