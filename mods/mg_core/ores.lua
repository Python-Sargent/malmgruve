--mg_core.ores = {}

mg_core.ores.registered_ores = {}
mg_core.ores.registered_raw = {}

mg_core.ores.levels = {
    [0] = {node="mg_core:soil", name="soil"},
    [1] = {node="mg_core:limestone", name="limestone"},
    [2] = {node="mg_core:granite", name="granite"},
    [3] = {node="mg_core:quartz", name="quartz"},
    [4] = {node="mg_core:peridotite", name="peridotite"}
}

mg_core.ores.register_ore = function(def, override)
    local name = "mg_core:" .. mg_core.ores.levels[def.level].name .. "_with_" .. def.name
    local raw = "mg_core:raw_" .. def.name

    if def.type == "metal" then
        local refined = "mg_core:" .. def.name
        local sheet = "mg_core:" .. def.name .. "_sheet"

        local refined_def = {
            description = "Refined " .. string.upper(string.sub(def.name, 1, 1)) .. string.sub(def.name, 2),
            inventory_image = "mg_" .. def.name .. ".png",
        }
    
        local sheet_def = {
            description = string.upper(string.sub(def.name, 1, 1)) .. string.sub(def.name, 2) .. " Sheet",
            inventory_image = "mg_" .. def.name .. "_sheet.png",
        }

        core.register_craftitem(refined, refined_def)
        core.register_craftitem(sheet, sheet_def)
    elseif def.type == "gem" then
        local refined = "mg_core:" .. def.name

        local refined_def = {
            description = "Refined " .. string.upper(string.sub(def.name, 1, 1)) .. string.sub(def.name, 2),
            inventory_image = "mg_" .. def.name .. ".png",
        }

        core.register_craftitem(refined, refined_def)
    end

    local ore_def = {
        description = string.upper(string.sub(def.name, 1, 1)) .. string.sub(def.name, 2) .. " Ore",
        tiles = {"mg_" .. mg_core.ores.levels[def.level].name .. ".png^mg_ore_" .. def.name .. ".png"},
        groups = {ground = 1, layer=def.level, ore=1},
        drop = raw
    }

    local rawdef = {
        description = "Raw " .. string.upper(string.sub(def.name, 1, 1)) .. string.sub(def.name, 2),
        inventory_image = "mg_raw_" .. def.name .. ".png",
    }

    for k, v in pairs(override) do
		ore_def[k] = v
	end

    local ore_type = { level=def.level, name=name, type=def.type, ore=true }
    local raw_ore_type = { level=def.level, name=def.name, type=def.type, ore=false }

    mg_core.ores.registered_ores[name], mg_core.ores.registered_ores[raw] = ore_type, raw_ore_type
    mg_core.ores.registered_raw[raw] = raw_ore_type

    core.register_node(name, ore_def)
    core.register_craftitem(raw, rawdef)
end

mg_core.ores.get_ores = function(y, rock)
    local ores = {}
    for _,v in pairs(mg_core.ores.registered_ores) do
        if mg_core.ores.levels[v.level].node == rock then
            table.insert(ores, v.name)
        end
    end
    return ores
end

--[[mg_core.ores.register_ore({
    name="chalk",
    level=0,
}, {})]]

-- Level 1: Surface

mg_core.ores.register_ore({
    name="aluminum",
    level=1,
    type="metal",
}, {})

mg_core.ores.register_ore({
    name="iron",
    level=1,
    type="metal",
}, {})

mg_core.ores.register_ore({
    name="azurite",
    level=1,
    type="metal",
}, {})

mg_core.ores.register_ore({
    name="manganese",
    level=1,
    type="metal",
}, {})

mg_core.ores.register_ore({
    name="halite",
    level=1,
    type="crystaline",
}, {})

mg_core.ores.register_ore({
    name="coal",
    level=1,
    type="strata",
}, {})

-- Level 2: Subsurface

mg_core.ores.register_ore({
    name="lead",
    level=2,
    type="metal",
}, {})

mg_core.ores.register_ore({
    name="copper",
    level=2,
    type="metal",
}, {})

mg_core.ores.register_ore({
    name="cinnabar",
    level=2,
    type="metal",
}, {})

mg_core.ores.register_ore({
    name="uranium",
    level=2,
    type="metal",
}, {light_source=5})

mg_core.ores.register_ore({
    name="argentite",
    level=2,
    type="metal",
}, {})

mg_core.ores.register_ore({
    name="bornite",
    level=2,
    type="metal",
}, {})

-- Level 3: Crust

mg_core.ores.register_ore({
    name="molybdenite",
    level=3,
    type="crystaline",
}, {})

mg_core.ores.register_ore({
    name="tungsten",
    level=3,
    type="metal",
}, {})

mg_core.ores.register_ore({
    name="nickel",
    level=3,
    type="metal",
}, {})

mg_core.ores.register_ore({
    name="cobalt",
    level=3,
    type="metal",
}, {})

mg_core.ores.register_ore({
    name="gold",
    level=3,
    type="metal",
}, {})

-- Level 4: Mantle

mg_core.ores.register_ore({
    name="chromium",
    level=4,
    type="metal",
}, {})

mg_core.ores.register_ore({
    name="platinum",
    level=4,
    type="metal",
}, {})

mg_core.ores.register_ore({
    name="graphite",
    level=4,
    type="strata",
}, {})

-- Gemstones

mg_core.ores.register_ore({
    name="opal",
    level=1,
    type="gem",
}, {})

mg_core.ores.register_ore({
    name="emerald",
    level=1,
    type="gem",
}, {})

mg_core.ores.register_ore({
    name="topaz",
    level=2,
    type="gem",
}, {})

mg_core.ores.register_ore({
    name="tourmaline",
    level=2,
    type="gem",
}, {})

mg_core.ores.register_ore({
    name="ruby",
    level=3,
    type="gem",
}, {})

mg_core.ores.register_ore({
    name="sapphire",
    level=3,
    type="gem",
}, {})

mg_core.ores.register_ore({
    name="diamond",
    level=4,
    type="gem",
}, {})

mg_core.ores.register_ore({
    name="olivine",
    level=4,
    type="gem",
}, {})