
local soil = core.get_content_id("mg_core:soil")
local limestone = core.get_content_id("mg_core:limestone")
local granite = core.get_content_id("mg_core:granite")
local quartz = core.get_content_id("mg_core:quartz")
local peridotite = core.get_content_id("mg_core:peridotite")

local levels = {
    {0, soil},
    {-100, limestone},
    {-250, granite},
    {-500, quartz},
    {-1000, peridotite}
}

local function getLevel(y, lvls)
    local cid = core.get_content_id("air")
    --local bestKey = -2000

    for i, entry in ipairs(lvls) do
        local key = entry[1]
        local value = entry[2]

        if key >= y and y >= levels[i+1][1] then
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

    for y = minp.y, maxp.y do
        for z = minp.z, maxp.z do
            local vi = area:index(minp.x, y, z)
            for x = minp.x, maxp.x do
                data[vi] = getLevel(y, levels)
                vi = vi + 1
            end
        end
    end

    vm:set_data(data)
end)