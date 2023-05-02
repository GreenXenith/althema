local vec2 = require("vector2")

game = {
    media = {},
    paused = false,
    width = 1280, height = 720,
    DEVMODE = false,
}

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

local function keybind(...)
    local binds = {...}
    for _, key in ipairs(binds) do
        binds[key] = true
    end
    return binds
end

game.keybinds = {
    up = keybind("up", "w"),
    down = keybind("down", "s"),
    left = keybind("left", "a"),
    right = keybind("right", "d"),
    select = keybind("space", "return"),
    menu = keybind("m", "q", "i", "e"),
    exit = keybind("escape"),
}

game.key_callbacks = {}

game.register_key_callback = function(callback)
    table.insert(game.key_callbacks, callback)
end

-- Load modules
game.ui = require("ui")({
    font = love.graphics.newFont("media/fonts/Unlock-Regular.ttf", 50)
})

game.menu = require("menu")
game.camera = require("camera")
game.world = require("world")

game.areas = require("areas")

game.pause = function(self, pause)
    self.paused = pause
    -- if pause then
    --     game.menu:load()
    -- end
end

-- Main functions
function love.keypressed(key)
    for _, callback in ipairs(game.key_callbacks) do callback(key) end
end

function love.load()
    math.randomseed(os.time())

    love.window.setTitle("Althema")

    love.window.setMode(game.width, game.height)
    -- love.window.maximize()
    love.graphics.setDefaultFilter("nearest")

    -- Preload media
    load_textures("media/textures")

    -- Begin on menu
    game.menu:load()
    game.menu:show_slide("slide1.png")
    game:pause(true)

    if game.DEVMODE then
        -- game.menu.overmap.player.pos = vec2.new(4, 4)
        -- game.menu.overmap:enter_current_tile()
    end
end

function love.update(dtime)
    if not game.paused then
        game.world:update(dtime)
    else
        game.menu:update(dtime)
    end

    game.ui.update_status(dtime)
end

function love.draw()
    love.graphics.clear(0, 0, 0)

    if not game.paused then
        game.world:draw()
    else
        game.menu:draw()
    end
end
