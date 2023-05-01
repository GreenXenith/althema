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
        texture = "overmap_tile_terrain.png",
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
}

-- TEMPORARY premade map
local map_terrain = {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 3, 3, 3, 3, 3, 3, 3, 3, 1,
    1, 3, 3, 3, 3, 3, 3, 5, 3, 1,
    1, 3, 3, 3, 3, 3, 3, 3, 3, 1,
    1, 3, 3, 3, 3, 3, 3, 3, 3, 1,
    1, 3, 3, 3, 3, 3, 3, 3, 3, 1,
    1, 2, 2, 2, 6, 2, 2, 2, 2, 1,
    1, 1, 3, 3, 3, 3, 3, 3, 3, 1,
    1, 1, 1, 3, 4, 3, 3, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
}

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
