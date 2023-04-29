game = {
    media = {},
    font = love.graphics.newFont("media/fonts/Unlock-Regular.ttf", 50),
    state = "overworld",
}

local vec2 = require("vector2")

local function load_textures(path)
    for _, name in pairs(love.filesystem.getDirectoryItems(path)) do
        local file = path .. "/" .. name
        local info = love.filesystem.getInfo(file)

        if info then
            if info.type == "file" and name:sub(-4) == ".png" then
                game.media[name] = love.graphics.newImage(file)
            elseif info.type == "directory" then
                load_textures(file)
            end
        end
    end
end

local terrain_tiles = {
    {
        texture = "overmap_void.png",
    },
    {
        texture = "overmap_river.png",
    },
    {
        texture = "overmap_tile_terrain.png",
    },
}

local overworld_icons = {
    mech = {
        texture = "overmap_icon_mech.png",
    },
    enemy = {
        texture = "overmap_tile_enemy.png",
    }
}

local tile_w, tile_h = 32, 32

local overworld = {
    width = 10, height = 10,
    tiles = {
        terrain = {},
        enemy = {},
        visible = {},
    },
}

overworld.get_tile = function(self, x, y)
    local idx = y * self.width + x + 1
    return {
        terrain = self.tiles.terrain[idx],
        enemy = self.tiles.enemy[idx],
        visible = self.tiles.visible[idx] == 1,
    }
end

overworld.tiles.terrain = {
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

overworld.tiles.enemy = {
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

overworld.player = {
    pos = vec2.new(5, 7),
    last_pos = vec2.zero(),
}

local function draw_tile(x, y, tiledef)
    love.graphics.draw(
        game.media[tiledef.texture],
        x * tile_w, y * tile_h
    )
end

local function draw_map()
    local ww, wh = love.window.getMode()
    local scale = ww / overworld.width / tile_w
    local ppos = overworld.player.pos

    love.graphics.setCanvas(overworld.canvas)

    for y = 0, overworld.height - 1 do
        for x = 0, overworld.width - 1 do
            local idx = y * overworld.width + x + 1

            draw_tile(x, y, terrain_tiles[overworld.tiles.terrain[idx]])

            if overworld.tiles.enemy[idx] > 0 then
                draw_tile(x, y, overworld_icons.enemy)
            end

            if y == ppos.y and x == ppos.x then
                draw_tile(x, y, overworld_icons.mech)
            end
        end
    end

    love.graphics.setCanvas()

    love.graphics.draw(
        overworld.canvas,
        (-ppos.x - 0.5) * 32 * scale + ww / 2, (-ppos.y - 0.5) * 32 * scale + wh / 2,
        0, scale, scale
    )
end

game.dialog = nil

local function draw_button(x, y, def)
    local tex = game.media[def[5]]
    local sx, sy = def[3][1] / tex:getWidth(), def[3][2] / tex:getHeight()
    love.graphics.draw(
        tex, x, y,
        0, sx, sy
    )

    local text = love.graphics.newText(game.font, def[2])
    love.graphics.draw(
        text, x + (def[3][1] - text:getWidth()) * 0.5, y + (def[3][2] - text:getHeight()) * 0.5,
        0, 1, 1
    )

    return {x, y, x + tex:getWidth() * sx, y + tex:getHeight() * sy}
end

local function show_dialog(def)
    game.dialog = {
        canvas = love.graphics.newCanvas(def.width, def.height),
        def = def,
        buttons = {},
    }

    love.graphics.setCanvas(game.dialog.canvas)

    local texture = game.media[def.texture]
    love.graphics.draw(texture, 0, 0, 0, def.width / texture:getWidth(), def.height / texture:getHeight())

    local text = love.graphics.newText(game.font, def.text[1])
    local ts = def.text[3] or 1
    love.graphics.draw(
        text,
        (def.width - text:getWidth() * ts) * def.text[2][1], (def.height - text:getHeight() * ts) * def.text[2][2],
        0, ts, ts
    )

    for _, btn in pairs(def.buttons) do
        game.dialog.buttons[btn[1]] = draw_button(btn[4][1] * def.width, btn[4][2] * def.height, btn)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas()
end

local dialog_enter = {
    width = 600, height = 300,
    texture = "dialog_bg.png",
    text = {"Enter occupied territory?", {0.5, 0.3}, 0.5},
    buttons = {
        {"btn_yes", "Yes", {150, 75}, {0.175, 0.6}, "button_bg.png"},
        {"btn_no", "No", {150, 75}, {0.575, 0.6}, "button_bg.png"},
    },
}

local function draw_dialog()
    if game.dialog then
        love.graphics.draw(game.dialog.canvas, 0, 0)
    end
end

local function hide_dialog()
    if game.dialog then
        game.dialog.canvas:release()
        game.dialog = nil
    end
end

overworld.process_current_tile = function(self)
    local ppos = self.player.pos
    local tile = self:get_tile(ppos.x, ppos.y)

    if tile.enemy > 0 then
        show_dialog(dialog_enter)
    elseif game.dialog then
        hide_dialog()
    end
end

local world = require("state_world")

overworld.enter_current_tile = function(self)
    -- local tile = self:get_tile(self.player.pos.x, self.player.pos.y)
    game.state = "world"
end

function love.mousepressed(x, y, button)
    if game.dialog then
        if button == 1 then
            for name, rect in pairs(game.dialog.buttons) do
                if x >= rect[1] and x <= rect[3] and y >= rect[2] and y <= rect[4] then
                    if name == "btn_no" then
                        overworld.player.pos = overworld.player.last_pos
                    elseif name == "btn_yes" then
                        overworld:enter_current_tile()
                    end

                    hide_dialog()
                end
            end
        end
    end
end

local keybinds = {
    up = {up = true, w = true},
    down = {down = true, s = true},
    left = {left = true, a = true},
    right = {right = true, d = true},
    select = {space = true, enter = true},
    map = {m = true, q = true},
    inventory = {i = true, e = true},
    exit = {escape = true},
}

function love.keypressed(key)
    if game.dialog then
        if keybinds.exit[key] then
            overworld.player.pos = overworld.player.last_pos
            hide_dialog()
        end

        return
    end

    local move = vec2.zero()
    if keybinds.up[key] then
        move.y = -1
    end
    if keybinds.down[key] then
        move.y = 1
    end
    if keybinds.left[key] then
        move.x = -1
    end
    if keybinds.right[key] then
        move.x = 1
    end

    local target = move + overworld.player.pos
    local tile = overworld:get_tile(target.x, target.y)

    if tile.terrain > 2 then
        overworld.player.last_pos = overworld.player.pos
        overworld.player.pos = target

        overworld:process_current_tile()
    end
end

function love.load()
    love.window.setMode(1920, 1080, {resizable = true})
    love.window.maximize()
    love.graphics.setDefaultFilter("nearest")

    -- Preload media
    load_textures("media/textures")

    overworld.canvas = love.graphics.newCanvas(tile_w * overworld.width, tile_h * overworld.height)
end

local states = {
    overworld = function()
        draw_map()
    end,
    world = function()
        world.draw()
    end
}

function love.draw()
    love.graphics.clear()

    states[game.state]()

    draw_dialog()
end
