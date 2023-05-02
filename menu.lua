local menu = {
    padding = 50,
    main_width = 0.6,

    state = "overmap",
    dmg_str = "DMG: %d%% / %d%%",
    slide = nil,
}

menu.overmap = require("overmap")

menu.show_slide = function(self, texture)
    self.slide = game.media[texture]
end

menu.hide_slide = function(self)
    self.slide = nil
end

menu.load = function(self)
    self.overmap:load()

    local ww, wh = love.window.getMode()
    menu.main_area = love.graphics.newCanvas(ww * self.main_width, wh - self.padding * 2)
    menu.status_area = love.graphics.newCanvas(ww - ww * self.main_width - self.padding * 3, wh - self.padding * 2)

    menu.damage_text = love.graphics.newText(game.ui.font, "")
end

menu.update = function() end

menu.draw = function(self)
    if self.state == "overmap" then
        local overmap = self.overmap
        overmap:draw()

        self.main_area:renderTo(function()
            love.graphics.clear()
            local w, h = self.main_area:getDimensions()

            if self.slide then
                local sw, sh = self.slide:getDimensions()
                local scale = math.min(w / sw, h / sh)
                love.graphics.draw(self.slide, 0, 0, 0, scale, scale)
            else
                local scale = w / overmap.width / overmap.tile_w
                local offset = (-overmap.player.pos - 0.5) * 32 * scale

                love.graphics.draw(
                    overmap.canvas,
                    offset.x + w / 2, offset.y + h / 2,
                    0, scale, scale
                )

                game.ui.draw_prompt()
                game.ui.draw_status(w / 2, h - 30, 0.5)

                love.graphics.setColor(0, 1, 1)
                love.graphics.setLineWidth(2)
                love.graphics.rectangle("line", 0, 0, self.main_area:getWidth(), self.main_area:getHeight())
                love.graphics.setColor(1, 1, 1)
            end
        end)

        self.status_area:renderTo(function()
            love.graphics.clear()

            local w = self.status_area:getDimensions()
            local scale = w * 0.75 / 32
            game.world.player:draw_hp(w * 0.125, w * 0.125, scale)

            self.damage_text:set(self.dmg_str:format(
                100 - game.world.player.hp.upper,
                100 - game.world.player.hp.lower
            ))
            love.graphics.draw(self.damage_text, w * 0.125, scale * 32 + w * 0.25, 0, 0.65, 0.65)

            love.graphics.setColor(0, 1, 1)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", 0, 0, self.status_area:getWidth(), self.status_area:getHeight())
            love.graphics.setColor(1, 1, 1)
        end)

    end

    love.graphics.draw(self.main_area, self.padding, self.padding)
    love.graphics.draw(self.status_area, self.main_area:getWidth() + self.padding * 2, self.padding)
end

return menu
