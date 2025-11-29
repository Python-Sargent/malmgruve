
-- Rock Types

local air = core.get_content_id("air")
local sand = core.get_content_id("mg_core:sand")
local silt = core.get_content_id("mg_core:silt")
local soil = core.get_content_id("mg_core:soil")
local limestone = core.get_content_id("mg_core:limestone")
local granite = core.get_content_id("mg_core:granite")
local quartz = core.get_content_id("mg_core:quartz")
local peridotite = core.get_content_id("mg_core:peridotite")

local bush = core.get_content_id("mg_core:bush")
local tall_bush = core.get_content_id("mg_core:tall_bush")

local levels = {
    {0, sand},
    {-4, soil},
    {-10, limestone},
    {-250, granite},
    {-500, quartz},
    {-1000, peridotite},
    {-32000, peridotite},
}

-- Ores

local aluminum = core.get_content_id("mg_core:limestone_with_aluminum")
local iron = core.get_content_id("mg_core:limestone_with_iron")
local azurite = core.get_content_id("mg_core:limestone_with_azurite")
local manganese = core.get_content_id("mg_core:limestone_with_manganese")
local halite = core.get_content_id("mg_core:limestone_with_halite")
local coal = core.get_content_id("mg_core:limestone_with_coal")

local lead = core.get_content_id("mg_core:granite_with_lead")
local copper = core.get_content_id("mg_core:granite_with_copper")
local cinnabar = core.get_content_id("mg_core:granite_with_cinnabar")
local argentite = core.get_content_id("mg_core:granite_with_argentite")
local bornite = core.get_content_id("mg_core:granite_with_bornite")

local molybdenite = core.get_content_id("mg_core:quartz_with_molybdenite")
local tungsten = core.get_content_id("mg_core:quartz_with_tungsten")
local nickel = core.get_content_id("mg_core:quartz_with_nickel")
local cobalt = core.get_content_id("mg_core:quartz_with_cobalt")
local gold = core.get_content_id("mg_core:quartz_with_gold")

local chromium = core.get_content_id("mg_core:peridotite_with_chromium")
local uranium = core.get_content_id("mg_core:peridotite_with_uranium")
local platinum = core.get_content_id("mg_core:peridotite_with_platinum")
local graphite = core.get_content_id("mg_core:peridotite_with_graphite")

local opal = core.get_content_id("mg_core:limestone_with_opal")
local emerald = core.get_content_id("mg_core:limestone_with_emerald")

local topaz = core.get_content_id("mg_core:granite_with_topaz")
local tourmaline = core.get_content_id("mg_core:granite_with_tourmaline")

local ruby = core.get_content_id("mg_core:quartz_with_ruby")
local sapphire = core.get_content_id("mg_core:quartz_with_sapphire")

local diamond = core.get_content_id("mg_core:peridotite_with_diamond")
local olivine = core.get_content_id("mg_core:peridotite_with_olivine")

local ores = {
    --{0, limestone},
    {-20, aluminum},
    {-80, iron},
    {-100, azurite},
    {-120, opal},
    {-140, manganese},
    {-160, halite},
    {-170, coal},
    {-190, emerald},

    {-250, lead},
    {-270, copper},
    {-310, cinnabar},
    {-350, topaz},
    {-370, argentite},
    {-430, bornite},
    {-460, tourmaline},

    {-500, molybdenite},
    {-590, tungsten},
    {-600, nickel},
    {-650, ruby},
    {-700, cobalt},
    {-810, gold},
    {-900, sapphire},

    {-1000, chromium},
    {-1100, uranium},
    {-1200, platinum},
    {-1300, diamond},
    {-1400, graphite},
    {-1500, olivine},
    {-32000, olivine}
}

local function getLevel(y, lvls)
    local cid = air
    --local bestKey = -2000

    for i, entry in ipairs(lvls) do
        local key = entry[1]
        local value = entry[2]

        if key >= y and lvls[i+1] ~= nil and y >= lvls[i+1][1] then
            --bestKey = key
            cid = value
        end
    end

    return cid
end

core.register_on_generated(function(vm, minp, maxp, seed)
    local emin, emax = vm:get_emerged_area()
    local area = VoxelArea(emin, emax)
    local data = vm:get_data()
    local size = {x=math.abs(maxp.x-minp.x), y=math.abs(maxp.y-minp.y), z=math.abs(maxp.z-minp.z)}
    local noise_map = core.get_value_noise({
        offset = 0,
        scale = 1,
        spread = {x = 10, y = 10, z = 0},
        seed = 1,
        octaves = 1,
        persist = 0.5,
        lacunarity = 2.0,
    }) -- z is ommitted for 2D noise

    local noise_map_2 = core.get_value_noise({
        offset = 0,
        scale = 5,
        spread = {x = 20, y = 20, z = 0},
        seed = 1,
        octaves = 5,
        persist = 0.5,
        lacunarity = 2.0,
    }) -- z is ommitted for 2D noise

    local feature_map = core.get_value_noise({
        offset = 0,
        scale = 0.6,
        spread = {x = 2, y = 2, z = 0},
        seed = 1,
        octaves = 2,
        persist = 0.4,
        lacunarity = 2.0,
    }) -- z is ommitted for 2D noise

    local m_pos = {z=minp.x,y=minp.y,x=minp.z}

    local ore_map = core.get_value_noise_map({
        offset = 0,
        scale = 0.8,
        spread = {x = 3, y = 3, z = 3},
        seed = 1,
        octaves = 1,
        persist = 0.5,
        lacunarity = 2,
        flags = {
            eased = true,
            absvalue = false,
            defaults = false
        }
    }, {x=80, y=80, z=80})
    local ore_noise_m = ore_map:get_3d_map(m_pos)

    local cave_map = core.get_value_noise_map({
        offset = 0,
        scale = 0.5,
        spread = {x=20, y=10, z=20},
        seed = 1,
        octaves = 3,
        persist = 0.63,
        lacunarity = 2.0,
    }, {x=80, y=80, z=80})
    local cave_noise_m = cave_map:get_3d_map(m_pos)

    local ly = 0
    for y = minp.y, maxp.y do
        ly = ly + 1
        local lz = 0
        for z = minp.z, maxp.z do
            lz = lz + 1
            local vi = area:index(minp.x, y, z)
            local lx = 0
            for x = minp.x, maxp.x do
                lx = lx + 1
                local rand = noise_map:get_2d(vector.new(z, x, 0))/2 + noise_map_2:get_2d(vector.new(z, x, 0))
                local rock = getLevel(y + rand*2, levels)
                if rock == air then
                    local below = getLevel(y + rand*2 - 1, levels)
                    if below == sand then
                        local r = feature_map:get_2d(vector.new(z, x, 0))
                        if r > 0.75 then
                            rock = tall_bush
                        elseif r > 0.5 then
                            rock = bush
                        end
                    end
                    if y + rand*2 < -5 then
                        rock = silt
                    end
                else
                    local ore_noise = ore_noise_m[lx][ly][lz]
                    local ore = getLevel(y + rand*2, ores)
                    if ore_noise ~= nil and ore_noise > 0.6 and ore ~= air then
                        rock = ore
                    end
                end

                local cn = cave_noise_m[lx][ly][lz]
                if rock ~= sand and rock ~= soil and cn*cn > 0.15 and y + rand*2 < -20 then -- and cn*cn < 0.5
                    rock = air
                end

                data[vi] = rock
                vi = vi + 1
            end
        end
    end

    vm:set_data(data)
end)