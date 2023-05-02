local collider = {}
collider.__index = collider

collider.new = function(self, parent, size)
    local o = setmetatable({
        shape = love.physics.newRectangleShape(size.x, size.y),
        parent = parent,
    }, self)

    return o
end

collider.AABB = function(self)
    -- minx, miny, maxx, maxy
    return {self.shape:computeAABB(self.parent.pos.x, self.parent.pos.y, 0)}
end

collider.intersection = function(self, collider2)
    local box1, box2 = self:AABB(), collider2:AABB()
    return box1[1] <= box2[3] and box1[3] >= box2[1] and box1[2] <= box2[4] and box1[4] >= box2[2]
end

return collider
