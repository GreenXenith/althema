local vec2 = require("vector2")

local camera = {
    pos = vec2.new(1, 1),
    size = 40,
    canvas = love.graphics.newCanvas(),
}

camera.draw = function(self, drawable, x, y, w, h, r, ox, oy, kx, ky)
    local ww, wh = love.window.getMode()
    local meter_size = math.max(ww / self.size, wh / self.size)
    local sx, sy = meter_size / drawable:getWidth() * (w or 1), meter_size / drawable:getHeight() * (h or 1)
    -- local cx, cy = math.max(ww / 2 / meter_size, self.pos.x), math.max(wh / 2 / meter_size, self.pos.y)
    local cx, cy = self.pos.x, self.pos.y
    local wx, wy = (x - cx) * meter_size + ww / 2, (y - cy) * meter_size + wh / 2

    love.graphics.draw(
        drawable, wx, wy, r or 0, sx, sy,
        drawable:getWidth() / 2 + (ox or 0), drawable:getHeight() / 2 + (oy or 0), kx, ky
    )
end

camera.get_local_cursor = function(self)
    local cx, cy = love.mouse.getPosition()
    local ww, wh = love.window.getMode()
    local meter_size = math.max(ww / self.size, wh / self.size)

    return (cx - ww / 2) / meter_size + self.pos.x, (cy - wh / 2) / meter_size + self.pos.y
end

return camera
