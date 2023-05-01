local vec2 = require("vector2")

local overmap = {
    tile_w = 32, tile_h = 32,
    width = 12, height = 12,
}

overmap.player = {
    pos = vec2.new(4, 8),
    last_pos = vec2.zero(),
}

local prompt_enter = {
    width = 600, height = 300,
    texture = "prompt_bg.png",
    text = {
        {"Enter occupied territory?", {0.5, 0.4}, 0.7},
        {"Yes [select]", {0.25, 0.75}, 0.6},
        {"No [escape]", {0.75, 0.75}, 0.6},
    },
}

overmap.enter_base = function(self)
    if game.has_key then
        -- win
        print("win!")
    else
        -- replay cutscenes
        print("cutscene")
    end
end

overmap.get_area = function(self, x, y)
    return game.areas[y * self.width + x + 1]
end

overmap.get_current_area = function(self)
    return self:get_area(self.player.pos.x, self.player.pos.y)
end

overmap.process_tile_events = function(self)
    local area = self:get_current_area()
    if area.terrain.type == "city" then
        if area.enemies > 0 then
            game.ui.show_prompt(75, 50, prompt_enter, 0.9)
            return
        end
    elseif area.terrain.type == "base" then
        overmap:enter_base()
    elseif area.terrain.type == "shelter" then
        print("got key")
        game.has_key = true
    end

    return true
end

overmap.enter_current_tile = function(self)
    local area = self:get_current_area()
    if area.terrain.type == "city" then
        if area ~= game.world.data then
            game.world:load_area(area)
        end

        game:pause(false)
    end
end

game.register_key_callback(function(key)
    if not game.paused then return end

    -- Handle prompt inputs
    if game.ui.prompt then
        if game.keybinds.exit[key] then
            overmap.player.pos = overmap.player.last_pos
            game.ui.hide_prompt()
        elseif game.keybinds.select[key] then
            overmap:enter_current_tile()
            game.ui.hide_prompt()
        end
        return
    end

    -- Manual enter
    if game.keybinds.select[key] then
        overmap:enter_current_tile()
        return
    end

    -- Try to move
    if overmap:get_current_area().enemies > 0 then return end

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
    local area = overmap:get_area(target.x, target.y)

    if not area.terrain.solid and area.discovered then
        overmap.player.last_pos = overmap.player.pos
        overmap.player.pos = target

        overmap:process_tile_events()
    end
end)

overmap.load = function(self)
    self.canvas = love.graphics.newCanvas(self.tile_w * self.width, self.tile_h * self.height)
end

overmap.draw_tile = function(self, x, y, texture)
    love.graphics.draw(
        game.media[texture],
        x * self.tile_w, y * self.tile_h
    )
end

overmap.draw = function(self)
    local ppos = self.player.pos
    local current_area = self:get_current_area()

    love.graphics.setCanvas(self.canvas)

    for idx = 1, self.width * self.height do
        local x, y = idx % self.width - 1, math.floor(idx / self.width)
        local area = game.areas[idx]

        if area.discovered then
            if current_area.enemies > 0 and area ~= current_area then
                love.graphics.setColor(0.6, 0.6, 0.6)
            end

            self:draw_tile(x, y, area.terrain.texture)

            if area.enemies > 0 then
                local difficulty = math.min(5, math.ceil(area.enemies / 8))
                self:draw_tile(x, y, "overmap_enemy_" .. difficulty .. ".png")
            end

            if y == ppos.y and x == ppos.x then
                self:draw_tile(x, y, "overmap_icon_mech.png")
            end

            love.graphics.setColor(1, 1, 1, 1)
        else
            self:draw_tile(x, y, "overmap_undiscovered.png")
        end
    end

    love.graphics.setCanvas()
end

return overmap
