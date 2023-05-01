local vec2 = require("vector2")
local object = require("object")
local particle = require("particle")

local bullet = object:new({
    size = vec2.new(0.75, 0.75),
    texture = "bullet.png",
})
bullet.__index = bullet

bullet.new = function(self, def, pos, rotation, velocity)
    local o = setmetatable(object:new(), self)

    for key, value in pairs(def or {}) do self[key] = value end
    o.pos = pos
    o.rotation = rotation
    o.velocity = velocity
    o._ttl = 2

    return o
end

bullet.update = function(self, dtime)
    self._ttl = self._ttl - dtime
    if self._ttl <= 0 then return game.world:remove_object(self) end

    local old_pos = self.pos
    object.update(self, dtime)

    for collider in pairs(game.world.colliders) do
        local nx, _, f = collider.shape:rayCast(
            old_pos.x, old_pos.y,
            self.pos.x, self.pos.y, 1,
            collider.parent.pos.x, collider.parent.pos.y, 0
        )

        if nx then
            if collider.parent.on_hit then
                local hit_pos = vec2.new(
                    old_pos.x + (self.pos.x - old_pos.x) * f,
                    old_pos.y + (self.pos.y - old_pos.y) * f
                )

                collider.parent:on_hit({
                    hit_pos = hit_pos,
                    source = "bullet",
                    damage = self.damage,
                })
            end

            return game.world:remove_object(self)
        end
    end
end

local weapon = object:new()
weapon.__index = weapon

weapon.new = function(self, def)
    local o = setmetatable(object:new(), self)

    for key, value in pairs(def) do o[key] = value end
    o._timer = 0
    o._rof = 60 / (def.firerate or 0)
    o._firing = false

    return o
end

weapon.fire = function(self)
    self:spawn_projectile()
end

weapon.firing = function(self, firing)
    self._firing = firing
end

weapon.spawn_projectile = function(self)
    local velocity = vec2.normalize(vec2.new(math.cos(self.rotation), math.sin(self.rotation))) *
        self.bullet_speed + self.parent.velocity

    game.world:add_object(bullet:new(self.bullet, self.pos, self.rotation, velocity))
end

weapon.update = function(self, dtime)
    self._timer = self._timer + dtime
    while self._timer >= self._rof do
        if self._firing then
            self:fire()
        end
        self._timer = self._timer - self._rof
    end
end

return weapon
