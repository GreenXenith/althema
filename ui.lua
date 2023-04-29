local ui = {
    dialog = nil,
}

local function draw_button(x, y, def)
    local tex = game.media[def[5]]
    local sx, sy = def[3][1] / tex:getWidth(), def[3][2] / tex:getHeight()
    love.graphics.draw(
        tex, x, y,
        0, sx, sy
    )

    local text = love.graphics.newText(ui.font, def[2])
    love.graphics.draw(
        text, x + (def[3][1] - text:getWidth()) * 0.5, y + (def[3][2] - text:getHeight()) * 0.5,
        0, 1, 1
    )

    return {x, y, x + tex:getWidth() * sx, y + tex:getHeight() * sy}
end

ui.show_dialog = function(def)
    ui.dialog = {
        canvas = love.graphics.newCanvas(def.width, def.height),
        def = def,
        buttons = {},
    }

    love.graphics.setCanvas(ui.dialog.canvas)

    local texture = game.media[def.texture]
    love.graphics.draw(texture, 0, 0, 0, def.width / texture:getWidth(), def.height / texture:getHeight())

    local text = love.graphics.newText(ui.font, def.text[1])
    local ts = def.text[3] or 1
    love.graphics.draw(
        text,
        (def.width - text:getWidth() * ts) * def.text[2][1], (def.height - text:getHeight() * ts) * def.text[2][2],
        0, ts, ts
    )

    for _, btn in pairs(def.buttons) do
        ui.dialog.buttons[btn[1]] = draw_button(btn[4][1] * def.width, btn[4][2] * def.height, btn)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas()
end

ui.draw_dialog = function()
    if ui.dialog then
        love.graphics.draw(ui.dialog.canvas, 0, 0)
    end
end

ui.hide_dialog = function()
    if ui.dialog then
        ui.dialog.canvas:release()
        ui.dialog = nil
    end
end

return function(config)
    ui.font = config.font
    return ui
end
