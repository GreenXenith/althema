local vec2 = require("vector2")
local object = require("object")
local weapon = require("weapon")

local player = object:new()

player.pos = vec2.new(5, 5)
player.size = vec2.new(2, 2)
player.z_index = 0
player.texture = "player.png"

player.speed = 10
player.hp = 10000
player.weapons = {}
player.active = true
player.alignment = "humans"

player.move = function(self)
    local direction = vec2.zero()

    if love.keyboard.isDown(game.keybinds.left) then
        direction.x = direction.x - 1
    end

    if love.keyboard.isDown(game.keybinds.right) then
        direction.x = direction.x + 1
    end

    if love.keyboard.isDown(game.keybinds.up) then
        direction.y = direction.y - 1
    end

    if love.keyboard.isDown(game.keybinds.down) then
        direction.y = direction.y + 1
    end

    self.direction = vec2.normalize(direction)
end

player.shoot = function(self)
    for _, firearm in ipairs(self.weapons) do
        firearm:firing(love.mouse.isDown(1))
    end
end

local weapons = {
    standard = {
        texture = "gun.png",
        size = vec2.new(1.5, 1.5),
        firerate = 1500, -- rounds per minute
        bullet_speed = 100,
        damage = 10,
    }
}

player.load = function(self)
    local bl = game.world:add_object(weapon:new(weapons.standard), 1)
    bl:attach(self, vec2.new(-0.1, -0.75), 0, true, true)

    local ml = game.world:add_object(weapon:new(weapons.standard), 2)
    ml:attach(self, vec2.new(0.5, -0.6), 0, true, true)

    local tl = game.world:add_object(weapon:new(weapons.standard), 3)
    tl:attach(self, vec2.new(0.1, -0.3), 0, true, true)

    local br = game.world:add_object(weapon:new(weapons.standard), 1)
    br:attach(self, vec2.new(-0.1, 0.75), 0, true, true)

    local mr = game.world:add_object(weapon:new(weapons.standard), 2)
    mr:attach(self, vec2.new(0.5, 0.6), 0, true, true)

    local tr = game.world:add_object(weapon:new(weapons.standard), 3)
    tr:attach(self, vec2.new(0.1, 0.3), 0, true, true)

    player.weapons = {bl, ml, tl, br, mr, tr}
end

player.update = function(self, dtime)
    self:shoot()

    self:move()
    self.velocity = self.direction * self.speed

    self.rotation = vec2.angle(self.pos, vec2.new(game.camera:get_local_cursor()))

    object.update(self, dtime)
end

return player
