local object = require("object")
local vec2 = require("vector2")

local enemy = object:new()
enemy.__index = enemy

enemy.types = {
    medium = {
        texture = "enemy.png",
        size = vec2.new(2, 2),
        active = true,
        alignment = "robots",
        speed = 2,
        hp = 1000,
        sense_range = 5,
        hostility = 3,
        aggression = 2, -- -2: flee, -1: flee and shoot, 0: wait, 1: shoot, 2: pursue and shoot
    }
}

enemy.spawn = function(self, pos, def)
    local o = setmetatable(object:new(), self)

    for key, value in pairs(def) do self[key] = value end
    o.pos = pos
    o.brain = {
        angle = 0,
        want_to_move = 0,
        chance_per_second = 0.5,
        home = pos,
        destination = nil,
        target = nil,
        follow = nil,
    }

    o:set_collider(o.size * 0.75)

    game.world:add_object(o)
end

enemy.on_hit = function(self, info)
    if info.damage then
        self.hp = self.hp - info.damage
    end

    if self.hp <= 0 then
        game.world:remove_object(self)
    end
end

enemy.move_to = function(self, pos)
    self.rotation = vec2.angle(self.pos, pos)
    self.velocity = vec2.direction(self.pos, pos) * self.speed
end

enemy.sense_objects = function(self)
    local targets = {}

    for o in pairs(game.world.objects) do
        if o.active then
            if vec2.distance(o.pos, self.pos) <= self.sense_range then
                table.insert(targets, o)
            end
        end
    end

    return targets
end

enemy.find_targets = function(self)
    for _, o in ipairs(self:sense_objects()) do
        if o.alignment ~= self.alignment then
            if self.hostility >= 3 then -- Kill anything that moves
                self.brain.target = o
                return
            end
        end
    end

    -- for _, o in ipairs(self:see_targets()) do

    -- end
end

enemy.do_logic = function(self, dtime)
    local brain = self.brain
    math.randomseed(os.clock())

    self:find_targets()

    if brain.target then
        if self.aggression > 0 then
            brain.destination = brain.target.pos
        end
    end

    if brain.follow then

    end

    if not brain.destination then
        brain.want_to_move = brain.want_to_move + dtime

        if math.random() * brain.want_to_move * brain.chance_per_second >= 1 then
            brain.want_to_move = 0
            local offset = vec2.new((math.random() - 0.5) * 10, (math.random() - 0.5) * 10)
            brain.destination = brain.home + offset
        end
    end

    if brain.destination then
        if vec2.distance(self.pos, brain.destination) < 0.1 then
            brain.destination = nil
            self.velocity = vec2.zero()
        else
            self:move_to(brain.destination)
        end
    end
end

enemy.update = function(self, dtime)
    self:do_logic(dtime)

    object.update(self, dtime)
end

return enemy
