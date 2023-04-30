local object = require("object")
local vec2 = require("vector2")

local enemy = object:new()
enemy.__index = enemy

enemy.types = {
    medium = {
        texture = "enemy.png",
        size = vec2.new(2, 2),
    }
}

enemy.spawn = function(self, pos, def)
    local o = setmetatable(object:new(), self)

    for key, value in pairs(def) do self[key] = value end
    o.pos = pos
    o.hp = 10
    o.speed = 2
    o.brain = {
        angle = 0,
        want_to_move = 0,
        chance_per_second = 0.5,
        home = pos,
        target = nil,
        follow = nil,
    }

    game.world:add_object(o)
end

enemy.move_to = function(self, pos)
    self.velocity = vec2.direction(self.pos, pos) * self.speed
end

enemy.do_logic = function(self, dtime)
    local brain = self.brain
    math.randomseed(os.clock())


    if brain.follow then

    end

    if not brain.target then
        brain.want_to_move = brain.want_to_move + dtime

        if math.random() * brain.want_to_move * brain.chance_per_second >= 1 then
            brain.want_to_move = 0
            local offset = vec2.new((math.random() - 0.5) * 10, (math.random() - 0.5) * 10)
            brain.target = brain.home + offset
        end
    end

    if brain.target then
        if vec2.distance(self.pos, brain.target) < 0.1 then
            brain.target = nil
            self.velocity = vec2.zero()
        else
            self:move_to(brain.target)
        end
    end
end

enemy.update = function(self, dtime)
    self:do_logic(dtime)

    object.update(self, dtime)
end

return enemy
