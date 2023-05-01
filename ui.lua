local ui = {
    prompt = nil,
}

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
    return ui
end
