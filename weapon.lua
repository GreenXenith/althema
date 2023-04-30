local vec2 = require("vector2")
local object = require("object")
local particle = require("particle")

local weapon = object:new()
weapon.__index = weapon


weapon.new = function(self, def)
    local o = setmetatable(object:new(), self)

    for key, value in pairs(def) do self[key] = value end
    o._timer = 0
    o._rof = 60 / (def.firerate or 0)
    o._firing = false

    return o
end

weapon.firing = function(self, firing)
    self._firing = firing
end

weapon.spawn_projectile = function(self)
    local velocity = vec2.normalize(vec2.new(math.cos(self.rotation), math.sin(self.rotation))) *
        self.bullet_speed + self.parent.velocity

    particle:new("bullet.png", self.pos, vec2.new(0.75, 0.75), self.rotation, velocity, 0.5)
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
