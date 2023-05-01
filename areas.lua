local maps = {
    {
        {},
        {1, 1, 1, 1},
        {
            0, 0, 3, 3, 3, 3, 3, 3, 3,
            physical = true,
        },
    },
}

-- TEMPORARY ground tiles
for i = 1, 32 * 32 do maps[1][1][i] = 2 end

local terrain = {
    void = {
        texture = "overmap_void.png",
        solid = true,
    },
    river = {
        texture = "overmap_river.png",
        solid = true,
    },
    city = {
        texture = "overmap_tile_terrain.png",
    },
}

-- TEMPORARY premade map
local map_terrain = {{
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 3, 3, 3, 3, 3, 3, 3, 3, 1,
    1, 3, 3, 3, 3, 3, 3, 3, 3, 1,
    1, 3, 3, 3, 3, 3, 3, 3, 3, 1,
    1, 3, 3, 3, 3, 3, 3, 3, 3, 1,
    1, 3, 3, 3, 3, 3, 3, 3, 3, 1,
    1, 2, 2, 2, 3, 2, 2, 2, 2, 1,
    1, 1, 3, 3, 3, 3, 3, 3, 3, 1,
    1, 1, 1, 3, 3, 3, 3, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
}, {terrain.void, terrain.river, terrain.city}}

local map_occupied = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    0, 1, 1, 0, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
}

local map_discovered = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 1, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
}

local areas = {}

for idx = 1, 10 * 10 do
    math.randomseed(os.clock())
    local enemies = map_occupied[idx] * math.random(1, 20)

    areas[idx] = {
        terrain = map_terrain[2][map_terrain[1][idx]],
        discovered = map_discovered[idx] == 1,
        tiles = maps[1],
        max_enemies = enemies,
        enemies = enemies,
        index = idx,
    }
end

return areas
