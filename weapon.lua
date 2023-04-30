local vec2 = require("vector2")
local object = require("object")

local weapon = setmetatable({}, {__index = object})

weapon.new_weapon = function(def)
    local w = setmetatable(object.new_object(), {__index = weapon})
    for key, value in pairs(def) do w[key] = value end
    w._timer = 0
    w._rof = 60 / (def.firerate or 0)
    w._firing = false
    return w
end

weapon.firing = function(self, firing)
    self._firing = firing
end

weapon.spawn_projectile = function(self)
    local bullet = object.new_object()
    bullet.texture = "bullet.png"
    bullet.size = vec2.new(0.75, 0.75)
    bullet.rotation = self.rotation
    bullet.pos = self.pos

    bullet.velocity = vec2.normalize(vec2.new(math.cos(self.rotation), math.sin(self.rotation))) *
        self.bullet_speed + self.parent.velocity

    game.world:add_object(bullet)
end

weapon.update = function(self, dtime)
    self._timer = self._timer + dtime
    while self._timer >= self._rof do
        if self._firing then
            self:spawn_projectile()
        end
        self._timer = self._timer - self._rof
    end
end

return weapon
