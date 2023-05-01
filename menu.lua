local menu = {
    padding = 50,
    main_width = 0.666,
    status_height = 0.5,

    state = "overmap",
}

menu.overmap = require("overmap")

menu.load = function(self)
    self.overmap:load()

    local ww, wh = love.window.getMode()
    menu.main_area = love.graphics.newCanvas(ww * self.main_width, wh - self.padding * 2)
end

menu.update = function(self)

end

menu.draw = function(self)
    if self.state == "overmap" then
        local overmap = self.overmap
        overmap:draw()

        self.main_area:renderTo(function()
            love.graphics.clear()
            local w, h = self.main_area:getDimensions()
            local scale = w / overmap.width / overmap.tile_w
            local offset = (-overmap.player.pos - 0.5) * 32 * scale

            love.graphics.draw(
                overmap.canvas,
                offset.x + w / 2, offset.y + h / 2,
                0, scale, scale
            )

            love.graphics.setColor(0, 255, 255)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", 0, 0, self.main_area:getWidth(), self.main_area:getHeight())
            love.graphics.setColor(255, 255, 255)
        end)

    end

    love.graphics.draw(self.main_area, self.padding, self.padding)
end

return menu
