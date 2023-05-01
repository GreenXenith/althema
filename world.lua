local vec2 = require("vector2")
local enemy = require("enemy")
local collider = require("collider")

local world = {
    seed = math.random() * 2 ^ 32,
    width = 32, height = 32,
    tile_w = 32, tile_h = 32,

    objects = {},
    colliders = {},

    player = require("player"),

    tiles = {
        {},
        {1, 1, 1, 1},
        {
            0, 0, 3, 3, 3, 3, 3, 3, 3,
            physical = true,
        },
    },
}

for i = 1, world.width * world.height do world.tiles[1][i] = 2 end

local world_tiles = {
    "asphalt.png",
    "concrete.png",
    "wall.png",
}

world.new_collider = function(self, parent, size)
    assert(parent)
    local c = collider:new(parent, size)

    self.colliders[c] = c
    return c
end

world.remove_collider = function(self, c)
    self.colliders[c] = nil
end

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

    -- Set up tiles
    for _, layer in ipairs(self.tiles) do
        if layer.physical then
            for idx = 1, self.width * self.height do
                if layer[idx] and layer[idx] > 0 then
                    local x, y = (idx - 1) % self.width, math.floor((idx - 1) / self.width)
                    world:new_collider({pos = vec2.new(x, y), name = "wall"}, vec2.new(1, 1))
                end
            end
        end
    end

    -- Populate objects
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
    -- Draw world tiles
    for _, layer in ipairs(self.tiles) do
        for idx = 1, self.width * self.height do
            local x, y = (idx - 1) % self.width, math.floor((idx - 1) / self.width)

            local tile_idx = layer[idx] or 0
            if tile_idx > 0 then
                game.camera:draw(game.media[world_tiles[tile_idx]], x, y)
            end
        end
    end

    -- Draw objects
    local layers = {}
    local min_z, max_z = 0, 0
    -- Sort z layers first
    for object in pairs(self.objects) do
        if object.texture then
            local z = object.z_index or 0
            layers[z] = layers[z] or {}
            min_z, max_z = math.min(min_z, z), math.max(z, max_z)

            table.insert(layers[z], object)
        end
    end

    -- Render layers in order
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
