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
    o.ttl = 2

    return o
end

bullet.update = function(self, dtime)
    self.ttl = self.ttl - dtime
    if self.ttl <= 0 then return game.world:remove_object(self) end

    local old_pos = self.pos
    object.update(self, dtime)

    for o in pairs(game.world.objects) do
        if o.collider then
            local nx = o.collider:rayCast(old_pos.x, old_pos.y, self.pos.x, self.pos.y, 1, o.pos.x, o.pos.y, 0)
            if nx then
                return game.world:remove_object(self)
            end
        end
    end
end

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

    game.world:add_object(bullet:new(nil, self.pos, self.rotation, velocity))
    -- local max_time = 1
    -- local max_pos = self.pos + velocity * max_time
    -- local time = max_time

    -- for o in pairs(game.world.objects) do
    --     if o.collider then
    --         local nx, _, f = o.collider:rayCast(self.pos.x, self.pos.y, max_pos.x, max_pos.y, 1, o.pos.x, o.pos.y, 0)
    --         if nx then
    --             local travel = vec2.new((max_pos.x - self.pos.x) * f, (max_pos.y - self.pos.y) * f)
    --             time = math.min(time, vec2.length(travel) / self.bullet_speed)
    --         end
    --     end
    -- end

    -- particle:new("bullet.png", self.pos, vec2.new(0.75, 0.75), self.rotation, velocity, time)
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
