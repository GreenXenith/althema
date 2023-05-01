local vec2 = require("vector2")

local terrain_tiles = {
    {
        texture = "overmap_void.png",
    },
    {
        texture = "overmap_river.png",
    },
    {
        world_tile = 1,
        texture = "overmap_tile_terrain.png",
    },
}

local overmap_icons = {
    mech = {
        texture = "overmap_icon_mech.png",
    },
    enemy = {
        texture = "overmap_tile_enemy.png",
    }
}

local overmap = {
    tile_w = 32, tile_h = 32,
    width = 10, height = 10,
    tiles = {
        terrain = {},
        enemy = {},
        visible = {},
    },
}

overmap.get_tile = function(self, x, y)
    local idx = y * self.width + x + 1
    return {
        terrain = self.tiles.terrain[idx],
        enemy = self.tiles.enemy[idx],
        visible = self.tiles.visible[idx] == 1,
    }
end

overmap.tiles.terrain = {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 3, 3, 3, 3, 3, 3, 3, 3, 1,
    1, 3, 3, 3, 3, 3, 3, 3, 3, 1,
    1, 3, 3, 3, 3, 3, 3, 3, 3, 1,
    1, 3, 3, 3, 3, 3, 3, 3, 3, 1,
    1, 3, 3, 3, 3, 3, 3, 3, 3, 1,
    1, 2, 2, 2, 3, 2, 2, 2, 2, 1,
    1, 1, 3, 3, 3, 3, 3, 3, 3, 1,
    1, 1, 1, 3, 3, 3, 3, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
}

overmap.tiles.enemy = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    0, 1, 1, 0, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
}

overmap.player = {
    pos = vec2.new(5, 7),
    last_pos = vec2.zero(),
}

game.register_key_callback(function(key)
    if not game.paused then return end

    if game.ui.dialog then
        if game.keybinds.exit[key] then
            overmap.player.pos = overmap.player.last_pos
            game.ui.hide_dialog()
        end

        return
    end

    local move = vec2.zero()
    if game.keybinds.up[key] then
        move.y = -1
    end
    if game.keybinds.down[key] then
        move.y = 1
    end
    if game.keybinds.left[key] then
        move.x = -1
    end
    if game.keybinds.right[key] then
        move.x = 1
    end

    local target = move + overmap.player.pos
    local tile = overmap:get_tile(target.x, target.y)

    if tile.terrain > 2 then
        overmap.player.last_pos = overmap.player.pos
        overmap.player.pos = target

        overmap:process_current_tile()
    end
end)


local dialog_enter = {
    width = 600, height = 300,
    texture = "dialog_bg.png",
    text = {"Enter occupied territory?", {0.5, 0.3}, 0.5},
    buttons = {
        {"btn_yes", "Yes", {150, 75}, {0.175, 0.6}, "button_bg.png"},
        {"btn_no", "No", {150, 75}, {0.575, 0.6}, "button_bg.png"},
    },
}

overmap.process_current_tile = function(self)
    local ppos = self.player.pos
    local tile = self:get_tile(ppos.x, ppos.y)

    if tile.enemy > 0 then
        game.ui.show_dialog(dialog_enter)
    elseif game.ui.dialog then
        game.ui.hide_dialog()
    end
end

overmap.enter_current_tile = function(self)
    local tile = terrain_tiles[self:get_tile(self.player.pos.x, self.player.pos.y).terrain]
    game.world:enter_tile(tile.world_tile)
    game:pause(false)
end

function love.mousepressed(x, y, button)
    if game.ui.dialog then
        if button == 1 then
            for name, rect in pairs(game.ui.dialog.buttons) do
                if x >= rect[1] and x <= rect[3] and y >= rect[2] and y <= rect[4] then
                    if name == "btn_no" then
                        overmap.player.pos = overmap.player.last_pos
                    elseif name == "btn_yes" then
                        overmap:enter_current_tile()
                    end

                    game.ui.hide_dialog()
                end
            end
        end
    end
end

overmap.load = function(self)
    self.canvas = love.graphics.newCanvas(self.tile_w * self.width, self.tile_h * self.height)
end

overmap.draw_tile = function(self, x, y, tiledef)
    love.graphics.draw(
        game.media[tiledef.texture],
        x * self.tile_w, y * self.tile_h
    )
end

overmap.draw = function(self)
    local ppos = self.player.pos

    love.graphics.setCanvas(self.canvas)

    for idx = 1, self.width * self.height do
        local x, y = idx % self.width - 1, math.floor(idx / self.width)

        self:draw_tile(x, y, terrain_tiles[self.tiles.terrain[idx]])

        if self.tiles.enemy[idx] > 0 then
            self:draw_tile(x, y, overmap_icons.enemy)
        end

        if y == ppos.y and x == ppos.x then
            self:draw_tile(x, y, overmap_icons.mech)
        end
    end

    love.graphics.setCanvas()
end

return overmap
