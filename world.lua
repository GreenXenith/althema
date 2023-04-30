local vec2 = require("vector2")
local enemy = require("enemy")

local world = {
    seed = math.random() * 2 ^ 32,
    width = 32, height = 32,
    tile_w = 32, tile_h = 32,

    objects = {},

    player = require("player"),

    tiles = {
        {},
        {},
    },
}

local world_tiles = {
    [0] = "asphalt.png",
    "concrete.png",
}

world.add_object = function(self, o, z_index)
    self.objects[o] = o
    o.z_index = z_index or o.z_index
    if o.load then o:load() end

    return o
end

world.remove_object = function(self, o)
    local object = self.objects[o]
    if object then
        if object.remove then object:remove() end

        self.objects[o] = nil
        return true
    end
end

world.load = function(self)
    love.physics.setMeter(1)

    self:add_object(self.player)

    enemy:spawn(vec2.new(10, 10), enemy.types.medium)
end

world.update = function(self, dtime)
    for object in pairs(self.objects) do
        object:update(dtime)
    end

    game.camera.pos = self.player.pos
end

world.draw = function(self)
    for idx = 1, self.width * self.height do
        local x, y = (idx - 1) % self.width, math.floor((idx - 1) / self.width)

        local texture = world_tiles[self.tiles[1][idx] or 1]
        game.camera:draw(game.media[texture], x, y)
    end

    -- Draw objects
    local layers = {}
    local min_z, max_z = 0, 0
    for object in pairs(self.objects) do
        if object.texture then
            local z = object.z_index or 0
            layers[z] = layers[z] or {}
            min_z, max_z = math.min(min_z, z), math.max(z, max_z)

            table.insert(layers[z], object)
        end
    end

    for z = min_z, max_z do
        if layers[z] then
            for _, object in ipairs(layers[z]) do
                if type(object.texture) == "table" then -- animated

                else
                    game.camera:draw(
                        game.media[object.texture], object.pos.x, object.pos.y,
                        object.size.x, object.size.y, object.rotation
                    )
                end
            end
        end
    end

    local cx, cy = game.camera:get_local_cursor()
    game.camera:draw(game.media["crosshair.png"], cx, cy)
end

return world
