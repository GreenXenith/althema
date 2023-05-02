local maps = {
    {
        width = 64, height = 64,
        {},
        {physical = true},
    },
}

for _, map in ipairs(maps) do
    for i = 1, map.width * map.height do maps[1][1][i] = 2 end -- Ground tiles

    -- Road
    local wmid, hmid = map.width / 2, map.height / 2
    local rw = 16
    for x = wmid - rw / 2, wmid + rw / 2 do for y = 1, map.height do maps[1][1][(y - 1) * map.width + x] = 1 end end
    for y = hmid - rw / 2, hmid + rw / 2 do for x = 1, map.height do maps[1][1][(y - 1) * map.width + x] = 1 end end

    for i = 1, map.width * map.height do maps[1][2][i] = 3 end -- Walls
    for x = 2, map.width - 1 do for y = 2, map.height - 1 do maps[1][2][(y - 1) * map.width + x] = 0 end end
end

local terrain = {
    {
        texture = "overmap_void.png",
        solid = true,
        type = "void",
    },
    {
        texture = "overmap_river.png",
        solid = true,
        type = "river",
    },
    {
        texture = "overmap_plain.png",
        type = "city",
    },
    {
        texture = "overmap_base.png",
        type = "base",
    },
    {
        texture = "overmap_shelter.png",
        type = "shelter",
    },
    {
        texture = "overmap_bridge.png",
        type = "bridge",
    },
    {
        texture = "overmap_rocky.png",
        type = "rocky",
        solid = true,
    },
    {
        texture = "overmap_farm.png",
        type = "farm",
    },
    {
        texture = "overmap_dirt.png",
        type = "dirt",
    },
}

-- TEMPORARY premade map
local map_terrain = {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 1,
    1, 7, 3, 3, 3, 3, 3, 3, 5, 3, 7, 1,
    1, 7, 3, 3, 3, 3, 3, 3, 3, 3, 7, 1,
    1, 7, 3, 7, 3, 3, 3, 7, 3, 3, 7, 1,
    1, 7, 3, 3, 3, 3, 3, 3, 3, 3, 7, 1,
    1, 7, 3, 3, 3, 3, 3, 3, 3, 3, 7, 1,
    1, 2, 2, 2, 6, 2, 2, 2, 2, 2, 2, 1,
    1, 7, 7, 8, 9, 8, 8, 8, 8, 7, 7, 1,
    1, 7, 7, 8, 4, 8, 8, 7, 7, 7, 7, 1,
    1, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
}

local map_occupied = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0,
    0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0,
    0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
}

local map_discovered = {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
}

local areas = {}

for idx = 1, 12 * 12 do
    math.randomseed(os.clock())
    local enemies = map_occupied[idx] * math.random(1, 40)

    areas[idx] = {
        terrain = terrain[map_terrain[idx]],
        discovered = map_discovered[idx] == 1,
        tiles = maps[1],
        max_enemies = enemies,
        enemies = enemies,
        index = idx,
    }
end

return areas
