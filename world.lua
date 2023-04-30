local world = {
    seed = math.random() * 2 ^ 32,
    width = 64, height = 64,
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

world.add_object = function(self, o)
    table.insert(self.objects, o)
    o:load()

    return o
end

world.load = function(self)
    self:add_object(self.player)
end

world.update = function(self, dtime)
    for _, object in ipairs(self.objects) do
        object:update(dtime)
    end

    game.camera.pos = self.objects[1].pos
end

world.draw = function(self)
    for idx = 1, self.width * self.height do
        local x, y = (idx - 1) % self.width, math.floor((idx - 1) / self.width)

        local texture = world_tiles[self.tiles[1][idx] or 1]
        game.camera:draw(game.media[texture], x, y)
    end

    local cx, cy = game.camera:get_local_cursor()
    game.camera:draw(game.media["crosshair.png"], cx, cy)

    -- Draw objects
    for _, object in ipairs(self.objects) do
        if object.texture then
            game.camera:draw(
                game.media[object.texture], object.pos.x, object.pos.y,
                object.size.x, object.size.y, object.rotation
            )
        end
    end
end

return world
