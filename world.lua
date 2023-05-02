local vec2 = require("vector2")
local enemy = require("enemy")
local collider = require("collider")
local player = require("player")

local world = {
    tile_w = 32, tile_h = 32,
    player = player,
}

world.load_area = function(self, area) -- tile id
    self.objects = {}
    self.colliders = {}

    self.data = area
    self.data.enemies = self.data.enemies or self.data.max_enemies

    self:load()
end

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

game.register_key_callback(function(key)
    if not game.paused and (game.keybinds.exit[key] or game.keybinds.menu[key]) then
        return game:pause(true)
    end
end)

world.remove_enemy = function(self)
    game.world.data.enemies = game.world.data.enemies - 1

    if self.data.enemies == 0 then
        self:clear()
    end
end

world.clear = function(self)
    local area = self.data
    local w = game.menu.overmap.width
    game.areas[area.index - (w + 1)].discovered = true
    game.areas[area.index -  w     ].discovered = true
    game.areas[area.index - (w - 1)].discovered = true
    game.areas[area.index -  1     ].discovered = true
    game.areas[area.index +  1     ].discovered = true
    game.areas[area.index + (w - 1)].discovered = true
    game.areas[area.index +  w     ].discovered = true
    game.areas[area.index + (w + 1)].discovered = true

    game.ui.set_status("Area clear! (ESC)", 5)
end

game.advance_enemies = function()
    for idx, area in ipairs(game.areas) do
        if area.max_enemies > 0 then
            if area.enemies < area.max_enemies then
                area.enemies = math.min(area.max_enemies, area.enemies + math.random(2, 4))
            else
                if area.enemies > 20 then
                    local adjacent_unoccupied = {}
                    for _, offset in ipairs({-game.menu.overmap.width, -1, 1, game.menu.overmap.width}) do
                        local area2 = game.areas[idx + offset]
                        if not area2.terrain.type == "city" and area2.enemies == 0 then
                            table.insert(adjacent_unoccupied, area2)
                        end
                    end

                    if #adjacent_unoccupied > 0 then
                        local adjacent = adjacent_unoccupied[math.random(1, #adjacent_unoccupied)]
                        if adjacent.max_enemies == 0 then
                            adjacent.max_enemies = 22
                        end
                        adjacent.enemies = math.random(4, 8)
                    end
                end
            end
        end
    end
end

world.load = function(self)
    math.randomseed(os.time())
    love.physics.setMeter(1)

    -- Set up tiles
    local tiles = self.data.tiles
    for _, layer in ipairs(tiles) do
        if layer.physical then
            for idx = 1, tiles.width * tiles.height do
                if layer[idx] and layer[idx] > 0 then
                    local x, y = (idx - 1) % tiles.width, math.floor((idx - 1) / tiles.width)
                    world:new_collider({pos = vec2.new(x, y), name = "wall"}, vec2.new(1, 1))
                end
            end
        end
    end

    -- Populate objects
    self:add_object(self.player)

    for _ = 1, self.data.enemies do
        enemy:spawn(vec2.new(math.random(16, tiles.width - 5), math.random(16, tiles.height - 5)), enemy.types.medium)
    end
end

world.update = function(self, dtime)
    for object in pairs(self.objects) do
        object:update(dtime)
    end

    game.camera.pos = self.player.pos
end

world.draw = function(self)
    local w, h = love.window.getMode()

    -- Draw world tiles
    local tiles = self.data.tiles
    for _, layer in ipairs(tiles) do
        for idx = 1, tiles.width * tiles.height do
            local x, y = (idx - 1) % tiles.width, math.floor((idx - 1) / tiles.width)

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

    game.world.player:draw_hp(32, 32, 5)
    game.ui.draw_status(w / 2, h * 0.85, 0.75)
end

return world
