game = {
    media = {},
}

game.ui = require("ui")({
    font = love.graphics.newFont("media/fonts/Unlock-Regular.ttf", 50)
})

game.camera = require("camera")

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

game.world = require("world")
local overmap = require("overmap")

-- game.keybinds = {
--     up = {up = true, w = true},
--     down = {down = true, s = true},
--     left = {left = true, a = true},
--     right = {right = true, d = true},
--     select = {space = true, enter = true},
--     map = {m = true, q = true},
--     inventory = {i = true, e = true},
--     exit = {escape = true},
-- }

game.keybinds = {
    up = {"up", "w"},
    down = {"down", "s"},
    left = {"left", "a"},
    right = {"right", "d"},
    select = {"space", "enter"},
    map = {"m", "q"},
    inventory = {"i", "e"},
    exit = {"escape"},
}

function love.keypressed(key)
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

game.show_overmap = function()
    local ww, wh = love.window.getMode()
    local scale = ww / overmap.width / overmap.tile_w

    love.graphics.draw(
        overmap.canvas,
        (-overmap.player.pos.x - 0.5) * 32 * scale + ww / 2, (-overmap.player.pos.y - 0.5) * 32 * scale + wh / 2,
        0, scale, scale
    )
end

function love.load()
    love.window.setTitle("Althema")

    love.window.setMode(1920, 1080, {resizable = true})
    love.window.maximize()
    love.graphics.setDefaultFilter("nearest")

    -- Preload media
    load_textures("media/textures")

    game.world:load()
    overmap:load()

    game.state = "world"
end

local states = {
    overmap = {
        update = function() end,
        draw = function()
            overmap:draw()
            game.show_overmap()
        end,
    },
    world = {
        update = function(dtime) game.world:update(dtime) end,
        draw = function() game.world:draw() end
    }
}

function love.update(dtime)
    states[game.state].update(dtime)
end

function love.draw()
    love.graphics.clear()

    states[game.state].draw()

    game.ui.draw_dialog()
end
