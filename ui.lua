local ui = {
    prompt = nil,
    status = nil,
}

ui.set_status = function(str, time)
    if ui.status then
        ui.status.text:set(str)
        ui.status._timer = time
    end
end

ui.update_status = function(dtime)
    if ui.status and ui.status._timer > 0 then
        ui.status._timer = math.max(0, ui.status._timer - dtime)
    end
end

ui.draw_status = function(x, y, scale)
    if ui.status._timer > 0 then
        love.graphics.draw(ui.status.text, x - ui.status.text:getWidth() * scale / 2, y - ui.status.text:getHeight() * scale / 2, 0, scale)
    end
end

ui.show_prompt = function(x, y, def, scale)
    ui.prompt = {
        canvas = love.graphics.newCanvas(def.width, def.height),
        def = def,
        pos = {x = x, y = y},
        scale = scale or 1,
        buttons = {},
    }

    love.graphics.setCanvas(ui.prompt.canvas)

    local texture = game.media[def.texture]
    love.graphics.draw(texture, 0, 0, 0, def.width / texture:getWidth(), def.height / texture:getHeight())

    for _, ptext in ipairs(def.text) do
        local text = love.graphics.newText(ui.font, ptext[1]) -- This is probably a memory leak
        local ts = ptext[3] or 1
        love.graphics.draw(
            text,
            (def.width - text:getWidth() * ts) * ptext[2][1], (def.height - text:getHeight() * ts) * ptext[2][2],
            0, ts, ts
        )
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas()
end

ui.draw_prompt = function()
    if ui.prompt then
        love.graphics.draw(ui.prompt.canvas, ui.prompt.pos.x, ui.prompt.pos.y)
    end
end

ui.hide_prompt = function()
    if ui.prompt then
        ui.prompt.canvas:release()
        ui.prompt = nil
    end
end

return function(config)
    ui.font = config.font
    ui.status = {
        text = love.graphics.newText(config.font, ""),
        _timer = 0,
    }
    return ui
end
