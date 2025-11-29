mg_factory.manufactory = {}

mg_factory.manufactory.machines = {}

mg_factory.manufactory.generator_formspec = function(pos)
    --local switch = "mg_factory_activate.png"
    --if mg_factory.manufactory.machines[core.get_node(pos).name].is_active == true then
    --    switch = "mg_factory_deactivate.png"
    --end
    local inv = "nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z
    local meta = core.get_meta(pos)
    local power = meta:get_int("power")
    local capacity = meta:get_int("capacity") or 0
    if power == 0 and capacity == 0 then -- fake it so we don't get nan%
        capacity = 1
    end
    local ratio = power/capacity
    local formspec = "size[8,8.5]"..
    "image[0.3,2;9,1;mg_factory_guibar_bg.png]" ..
    "image[0.32,2;" .. 8.96*ratio .. ",1;mg_factory_guibar_fg.png]" ..
    "label[0.5,2.2;" .. ratio*100 .. "%]" ..
    "list["..inv..";fuel;0.5,0;4,1;]"..
    "list["..inv..";inp;5.5,0;2,1;]"..
    "list[current_player;main;0,4.25;8,1;]"..
    "list[current_player;main;0,5.5;8,3;8]" ..
    "listring[" .. inv ..";inp]"..
    "listring[current_player;main]" ..
    "listring[" .. inv ..";fuel]"..
    "listring[current_player;main]"
    return formspec
end

mg_factory.manufactory.press_formspec = function(pos)
    local inv = "nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z
    local formspec = "size[8,8.5]"..
    "list[" .. inv ..";src;1.5,1.5;1,1;]"..
    "image[3,1.5;1,1;mg_press.png]" ..
    "list[" .. inv ..";dst;4.5,1;2,2;]"..
    "list[current_player;main;0,4.25;8,1;]"..
    "list[current_player;main;0,5.5;8,3;8]" ..
    "listring[" .. inv ..";dst]"..
    "listring[current_player;main]" ..
    "listring[" .. inv ..";src]"..
    "listring[current_player;main]"
    return formspec
end

mg_factory.manufactory.refinery_formspec = function(pos)
    local inv = "nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z
    local formspec = "size[8,8.5]"..
    "list[" .. inv ..";src;1.5,1.5;1,1;]"..
    "image[3,1.5;1,1;mg_refinery.png]" ..
    "list[" .. inv ..";dst;4.5,1;2,2;]"..
    "list[current_player;main;0,4.25;8,1;]"..
    "list[current_player;main;0,5.5;8,3;8]" ..
    "listring[" .. inv ..";dst]"..
    "listring[current_player;main]" ..
    "listring[" .. inv ..";src]"..
    "listring[current_player;main]"
    return formspec
end

mg_factory.manufactory.manufacturer_formspec = function(pos)
    local m_recipes = {}
    for k,v in pairs(mg_factory.recipes) do
        if v.machine == "manufacturing" then
            table.insert(m_recipes, v)
        end
    end
    local manufactures = ""
    for i,v in ipairs(m_recipes) do
        manufactures = manufactures .. "item_image_button["..i..",0;1,1;"..v.result..";"..v.result..";]"
    end
    local inv = "nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z
    local formspec = "size[8,8.5]"..
    manufactures ..
    "field[0,0;0,0;pos;;"..core.pos_to_string(pos).."]" ..
    "list[" .. inv ..";src;1,2;2,2;]"..
    "image[3.5,2.5;1,1;mg_factory.png]" ..
    "list[" .. inv ..";dst;5,2;2,2;]"..
    "list[current_player;main;0,4.25;8,1;]"..
    "list[current_player;main;0,5.5;8,3;8]" ..
    "listring[" .. inv ..";dst]"..
    "listring[current_player;main]" ..
    "listring[" .. inv ..";src]"..
    "listring[current_player;main]"
    return formspec
end

mg_factory.manufactory.miner_formspec = function(pos)
    local inv = "nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z
    local formspec = "size[8,8.5]"..
    "field[0,0;0,0;pos;;"..core.pos_to_string(pos).."]" ..
    "list[" .. inv ..";msi;2,1;4,2;]"..
    "button[2,3.25;4,1;activate;Start]" ..
    "list[current_player;main;0,4.25;8,1;]"..
    "list[current_player;main;0,5.5;8,3;8]" ..
    "listring[current_player;main]" ..
    "listring[" .. inv ..";msi]"
    return formspec
end

mg_factory.manufactory.register_machine = function(name, def, overrides)
    local function can_dig(pos, player)
        local inv = core.get_meta(pos):get_inventory()
        local is_empty = true
        if def.inventories ~= nil then
            for _, i in pairs(def.inventories) do
                if not inv:is_empty(i.name) then
                    is_empty = false
                end
            end
        end
        return is_empty
    end
    
    local function allow_metadata_inventory_put(pos, listname, index, stack, player)
        --local meta = core.get_meta(pos)
        --local inv = meta:get_inventory()
        if listname == "dst" then return 0 end
        return stack:get_count()
    end
    
    local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
        if to_list == "dst" then return 0 end
        --local timer = core.get_node_timer(pos)
        --if not timer:is_started() then
            return count
        --end
        --return 0
    end
    
    local function allow_metadata_inventory_take(pos, listname, index, stack, player)
        --local timer = core.get_node_timer(pos)
        --if not timer:is_started() then
            return stack:get_count()
        --end
        --return 0
    end

    local ndef = {
        description = def.description,
        drawtype = "mesh",
        mesh = def.mesh,
        tiles = def.tiles,
        use_texture_alpha=def.use_texture_alpha or "clip",
        backface_culling=(not def.use_texture_alpha == "blend") or true,
        paramtype2 = "facedir",
        groups = {diggable=1, machine=def.machine.num},
        sounds=mg_core.node_sounds(),
        on_construct = function(pos)
            local meta = core.get_meta(pos)
            --meta:set_string("formspec", def.formspec(pos))
            local power = {default = 0, max = 0}
            if def.power then
                power.default = def.power.default or 0
                power.max = def.power.max or 0
            end
            meta:set_int("power", power.default or 0)
            meta:set_int("capacity", power.max or 0)
            local inv = meta:get_inventory()
            if def.inventories ~= nil then
                for _, i in pairs(def.inventories) do
                    inv:set_size(i.name, i.size)
                end
            end
        end,
        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            core.show_formspec(clicker:get_player_name(), name, def.formspec(pos))
        end,
        can_dig = can_dig,
        allow_metadata_inventory_move = allow_metadata_inventory_move,
        allow_metadata_inventory_put = allow_metadata_inventory_put,
        allow_metadata_inventory_take = allow_metadata_inventory_take,
        on_metadata_inventory_put = def.on_inventory_put or function() end,
        on_metadata_inventory_move = def.on_inventory_move or function() end,
        on_receive_fields = def.on_receive_fields or function() end,
        on_timer = def.on_timer or function() end
    }

    for k, v in pairs(overrides) do
		ndef[k] = v
	end

    core.register_node("mg_factory:" .. name, ndef)

    mg_factory.manufactory.machines["mg_factory:" .. name] = {is_active = def.machine.active, name = def.name, num = def.machine.num}
end

local function generate(pos, amount)
    local meta = core.get_meta(pos)
    local power = meta:get_int("power")
    local capacity = meta:get_int("capacity")
    meta:set_int("power", math.min(power + amount, capacity))
    return meta
end

local get_nearby_machines = function(pos)
    local machines = {}
    local positions = {
        vector.new(pos.x+1, pos.y, pos.z),
        vector.new(pos.x-1, pos.y, pos.z),
        vector.new(pos.x, pos.y+1, pos.z),
        vector.new(pos.x, pos.y-1, pos.z),
        vector.new(pos.x, pos.y, pos.z+1),
        vector.new(pos.x, pos.y, pos.z-1),
    }

    for _, npos in pairs(positions) do
        local node = core.get_node(npos)
        if mg_factory.manufactory.machines[node.name] then
            table.insert(machines, npos)
        end
    end

    return machines
end


--[[
mg_factory.manufactory.register_machine("manufactory", {
    description = "Manufactory Controller",
    mesh = "mg_manufactory_controller.obj",
    tiles = {"mg_machine_mechanical_frame.png", "mg_machine_mechanical_metal.png", "mg_machine_mechanical_wood.png", "mg_factory_activate.png"},
    machine = {type="controller", num = 3, active = false},
    formspec = mg_factory.manufactory.controller_formspec,
    inventories = {}
}, {})

mg_factory.manufactory.register_machine("manufactory_on", {
    description = "Manufactory Controller (on)",
    mesh = "mg_manufactory_controller.obj",
    tiles = {"mg_machine_mechanical_frame.png", "mg_machine_mechanical_metal.png", "mg_machine_mechanical_wood.png", "mg_factory_deactivate.png"},
    machine = {type="controller", num = 3, active = true},
    formspec = mg_factory.manufactory.controller_formspec,
    inventories = {}
}, {groups={diggable=1, machine=3, not_in_creative_inventory=1}})
]]

local manufacture_particles = function(pos)
    local tiles = core.registered_nodes[core.get_node(pos).name].tiles or {"mg_machine_generic_metal.png"}
    local texture = tiles[1]
    core.add_particlespawner({
        amount = 300,
        time = 1,
        collisiondetection = true,
        --object_collision = true,

        pos = {
            min = vector.new(pos.x-0.6,pos.y-0.6,pos.z-0.6),
            max = vector.new(pos.x+0.6,pos.y+0.6,pos.z+0.6),
            bias = 0
        },
        acc = vector.new(0, -1, -10),
        size = { min = 0.5, max = 1 },
        exptime = { min = 0.5, max = 1 },
        glow = 10,
        texture = texture
    })
end

local manufacture_item = function(pos, type)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    local stack = inv:get_stack("src", 1)

    local machines = get_nearby_machines(pos)
    local discharge = nil
    for _,v in pairs(machines) do
        local n = core.get_node(v)
        if mg_factory.manufactory.machines[n.name].num == 2 then
            discharge = v
            break
        end
    end
    if discharge == nil then return false end -- no power sources nearby
    local dmeta = core.get_meta(discharge)
    if dmeta:get_int("power") < 5 then return true end -- not enough power
    dmeta:set_int("power", dmeta:get_int("power") - 5)

    local product = mg_factory.manufacture(stack:get_name(), type)
    if product == nil then return end
    local inv = core.get_meta(pos):get_inventory()
    inv:add_item("dst", ItemStack(product.result, product.amount))
    stack:set_count(product.amount)
    inv:remove_item("src", stack)
    if product.left ~= nil then
        inv:add_item("src", ItemStack(product.left, product.amount))
    end
    manufacture_particles(pos)
end

local get_items = function(items, inv)
    local has_items = true
    for _,v in pairs(items) do
        if not inv:contains_item("src", ItemStack(v)) then
            has_items = false
        end
    end
    if has_items then
        for _,v in pairs(items) do
            inv:remove_item("src", ItemStack(v))
        end
    end
    return has_items
end

local m_manufacture = function(pos, input)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()

    local machines = get_nearby_machines(pos)
    local discharge = nil
    for _,v in pairs(machines) do
        local n = core.get_node(v)
        if mg_factory.manufactory.machines[n.name].num == 2 then
            discharge = v
            break
        end
    end
    if discharge == nil then return false end -- no power sources nearby
    local dmeta = core.get_meta(discharge)
    if dmeta:get_int("power") < 5 then return true end -- not enough power
    dmeta:set_int("power", dmeta:get_int("power") - 5)

    local product = mg_factory.manufacture(input, "manufacturing")
    if product == nil then return false end

    local success = get_items(product.requires, inv)
    if success then
        inv:add_item("dst", ItemStack(product.result, product.amount))
        manufacture_particles(pos)
    end
    return success
end

-- Mechanical Machines

mg_factory.manufactory.register_machine("roller", {
    description = "Roller Press",
    mesh = "mg_roller_press.obj",
    tiles = {"mg_machine_mechanical_frame.png", "mg_machine_mechanical_metal.png", "mg_machine_mechanical_wood.png", "mg_machine_mechanical_metal.png"},
    machine = {type="user", num = 1, active = false},
    formspec = mg_factory.manufactory.press_formspec,
    inventories = {
        {name="src", size=1},
        {name="dst", size=4}
    },
    on_inventory_put = function(pos, listname, index, stack, player) --pos, from_list, from_index, to_list, to_index, count
        if listname == "src" then
            core.get_node_timer(pos):start(5)
            --manufacture_item(pos, "pressing")
        end
    end,
    on_inventory_move = function(pos, from_list, from_index, to_list, to_index, count)
        if to_list == "src" then
            core.get_node_timer(pos):start(5)
            --local stack = core.get_meta(pos):get_inventory():get_stack(from_list, from_index)
            --manufacture_item(pos, "pressing")
        end
    end,
    on_timer = function(pos, elapsed, node, timeout)
        --core.log("Timer at " .. core.pos_to_string(pos))
        manufacture_item(pos, "pressing")
        local inv = core.get_meta(pos):get_inventory()
        if inv:get_stack("src", 1):get_count() < 1 then
            return false
        end
        return true
    end
}, {})

mg_factory.manufactory.register_machine("crank", {
    description = "Pulley Crank",
    mesh = "mg_pulley_crank.obj",
    tiles = {"mg_machine_mechanical_frame.png", "mg_machine_mechanical_wood.png", "mg_machine_mechanical_metal.png"},
    machine = {type="generator", num = 2, active = false},
    formspec = mg_factory.manufactory.generator_formspec,
    power = {max = 100}
}, {
    on_punch = function(pos, node, puncher, pointed_thing)
        local meta = generate(pos, 1)
        meta:set_string("formspec", mg_factory.manufactory.generator_formspec(pos))
    end
})

mg_factory.manufactory.register_machine("mill", {
    description = "Ball Mill",
    mesh = "mg_ball_mill.obj",
    tiles = {"mg_machine_mechanical_frame.png", "mg_machine_mechanical_metal.png", "mg_machine_mechanical_wood.png"},
    machine = {type="user", num = 1, active = false},
    formspec = mg_factory.manufactory.refinery_formspec,
    inventories = {
        {name="src", size=1},
        {name="dst", size=4}
    },
    on_inventory_put = function(pos, listname, index, stack, player)
        if listname == "src" then
            core.get_node_timer(pos):start(5)
            --manufacture_item(pos, "refining")
        end
    end,
    on_inventory_move = function(pos, from_list, from_index, to_list, to_index, count)
        if to_list == "src" then
            core.get_node_timer(pos):start(5)
            --local stack = core.get_meta(pos):get_inventory():get_stack(to_list, to_index)
            --manufacture_item(pos, "refining")
        end
    end,
    on_timer = function(pos, elapsed, node, timeout)
        --core.log("Timer at " .. core.pos_to_string(pos))
        manufacture_item(pos, "refining")
        local inv = core.get_meta(pos):get_inventory()
        if inv:get_stack("src", 1):get_count() < 1 then
            return false -- stop the timer if nothing is left in src
        end
        return true
    end
}, {})

-- Hydrothermal Machines

mg_factory.manufactory.register_machine("compressor", {
    description = "Steam Press",
    mesh = "mg_steam_press.obj",
    tiles = {"mg_machine_hydrothermal_metal.png", "mg_machine_hydrothermal_frame.png"},
    machine = {type="user", num = 1, active = false},
    formspec = mg_factory.manufactory.press_formspec,
    inventories = {
        {name="src", size=1},
        {name="dst", size=4}
    },
    on_inventory_put = function(pos, listname, index, stack, player) --pos, from_list, from_index, to_list, to_index, count
        if listname == "src" then
            core.get_node_timer(pos):start(3)
        end
    end,
    on_inventory_move = function(pos, from_list, from_index, to_list, to_index, count)
        if to_list == "src" then
            core.get_node_timer(pos):start(3)
        end
    end,
    on_timer = function(pos, elapsed, node, timeout)
        --core.log("Timer at " .. core.pos_to_string(pos))
        manufacture_item(pos, "pressing")
        local inv = core.get_meta(pos):get_inventory()
        if inv:get_stack("src", 1):get_count() < 1 then
            return false
        end
        return true
    end
}, {})

mg_factory.manufactory.register_machine("engine", {
    description = "Steam Engine",
    mesh = "mg_steam_engine.obj",
    tiles = {"mg_machine_hydrothermal_metal.png", "mg_machine_hydrothermal_frame.png", "mg_machine_hydrothermal_coals.png"},
    machine = {type="generator", num = 2, active = false},
    formspec = mg_factory.manufactory.generator_formspec,
    inventories = {
        {name="fuel", size=4}
    },
    power = {max = 500},
    on_inventory_put = function(pos, listname, index, stack, player) --pos, from_list, from_index, to_list, to_index, count
        if listname == "fuel" then
            core.get_node_timer(pos):start(3)
        end
    end,
    on_inventory_move = function(pos, from_list, from_index, to_list, to_index, count)
        if to_list == "fuel" then
            core.get_node_timer(pos):start(3)
        end
    end,
    on_timer = function(pos, elapsed, node, timeout)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        local fuel = ItemStack("mg_core:raw_coal")

        if inv:contains_item("fuel", fuel) and meta:get_int("power") <= meta:get_int("capacity") - 10 then
            manufacture_particles(pos)
            inv:remove_item("fuel", fuel)
            local meta = generate(pos, 10)
            meta:set_string("formspec", mg_factory.manufactory.generator_formspec(pos))
            return true
        end
        return false
    end
}, {})

mg_factory.manufactory.register_machine("furnace", {
    description = "Blast Furnace",
    mesh = "mg_blast_furnace.obj",
    tiles = {"mg_machine_hydrothermal_frame.png", "mg_machine_hydrothermal_metal.png", "mg_machine_hydrothermal_coals.png"},
    machine = {type="user", num = 1, active = false},
    formspec = mg_factory.manufactory.refinery_formspec,
    inventories = {
        {name="src", size=1},
        {name="dst", size=4}
    },
    on_inventory_put = function(pos, listname, index, stack, player)
        if listname == "src" then
            core.get_node_timer(pos):start(1)
        end
    end,
    on_inventory_move = function(pos, from_list, from_index, to_list, to_index, count)
        if to_list == "src" then
            core.get_node_timer(pos):start(1)
        end
    end,
    on_timer = function(pos, elapsed, node, timeout)
        --core.log("Timer at " .. core.pos_to_string(pos))
        manufacture_item(pos, "refining")
        local inv = core.get_meta(pos):get_inventory()
        if inv:get_stack("src", 1):get_count() < 1 then
            return false -- stop the timer if nothing is left in src
        end
        return true
    end
}, {})

-- Nuclear Machines


mg_factory.manufactory.register_machine("chamber", {
    description = "Pressure Chamber",
    mesh = "mg_chamber.obj",
    tiles = {"mg_machine_nuclear_frame.png", "mg_machine_nuclear_metal.png"},
    machine = {type="user", num = 1, active = false},
    formspec = mg_factory.manufactory.press_formspec,
    inventories = {
        {name="src", size=1},
        {name="dst", size=4}
    },
    on_inventory_put = function(pos, listname, index, stack, player) --pos, from_list, from_index, to_list, to_index, count
        if listname == "src" then
            core.get_node_timer(pos):start(1)
        end
    end,
    on_inventory_move = function(pos, from_list, from_index, to_list, to_index, count)
        if to_list == "src" then
            core.get_node_timer(pos):start(1)
        end
    end,
    on_timer = function(pos, elapsed, node, timeout)
        --core.log("Timer at " .. core.pos_to_string(pos))
        manufacture_item(pos, "pressing")
        local inv = core.get_meta(pos):get_inventory()
        if inv:get_stack("src", 1):get_count() < 1 then
            return false
        end
        return true
    end
}, {})

mg_factory.manufactory.register_machine("reactor", {
    description = "Nuclear Reactor",
    mesh = "mg_reactor.obj",
    tiles = {"mg_machine_nuclear_frame.png", "mg_machine_nuclear_metal.png", {name="mg_machine_nuclear_glass.png", backface_culling=false,}},
    use_texture_alpha="blend",
    machine = {type="generator", num = 2, active = false},
    formspec = mg_factory.manufactory.generator_formspec,
    inventories = {
        {name="fuel", size=4},
        {name="inp", size=2}
    },
    power = {max = 5000},
    on_inventory_put = function(pos, listname, index, stack, player) --pos, from_list, from_index, to_list, to_index, count
        if listname == "fuel" or listname == "inp" then
            core.get_node_timer(pos):start(1)
        end
    end,
    on_inventory_move = function(pos, from_list, from_index, to_list, to_index, count)
        if to_list == "fuel" or to_list == "inp" then
            core.get_node_timer(pos):start(1)
        end
    end,
    on_timer = function(pos, elapsed, node, timeout)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        local fuel = ItemStack("mg_core:uranium 2")
        local inp = ItemStack("mg_core:nickel")

        if inv:contains_item("fuel", fuel) and inv:contains_item("inp", inp) and meta:get_int("power") <= meta:get_int("capacity") - 10 then
            manufacture_particles(pos)
            inv:remove_item("fuel", fuel)
            inv:remove_item("inp", inp)
            local meta = generate(pos, 100)
            meta:set_string("formspec", mg_factory.manufactory.generator_formspec(pos))
            return true
        end
        return false
    end
}, {})

mg_factory.manufactory.register_machine("centrifuge", {
    description = "Centrifuge",
    mesh = "mg_centrifuge.obj",
    tiles = {"mg_machine_nuclear_metal.png", "mg_machine_nuclear_frame.png"},
    machine = {type="user", num = 1, active = false},
    formspec = mg_factory.manufactory.refinery_formspec,
    inventories = {
        {name="src", size=1},
        {name="dst", size=4}
    },
    on_inventory_put = function(pos, listname, index, stack, player)
        if listname == "src" then
            core.get_node_timer(pos):start(1)
        end
    end,
    on_inventory_move = function(pos, from_list, from_index, to_list, to_index, count)
        if to_list == "src" then
            core.get_node_timer(pos):start(1)
        end
    end,
    on_timer = function(pos, elapsed, node, timeout)
        --core.log("Timer at " .. core.pos_to_string(pos))
        manufacture_item(pos, "refining")
        local inv = core.get_meta(pos):get_inventory()
        if inv:get_stack("src", 1):get_count() < 1 then
            return false -- stop the timer if nothing is left in src
        end
        return true
    end
}, {})

-- Generic Machines

mg_factory.manufactory.register_machine("manufacturer", {
    description = "Manufacturer",
    mesh = "mg_manufacturer.obj",
    tiles = {"mg_machine_generic_frame.png", "mg_machine_generic_metal.png"},
    machine = {type="user", num = 1, active = false},
    formspec = mg_factory.manufactory.manufacturer_formspec,
    inventories = {
        {name="src", size=4},
        {name="dst", size=4}
    },
    on_timer = function(pos, elapsed, node, timeout)
        --core.log("Timer at " .. core.pos_to_string(pos))
        local meta = core.get_meta(pos)
        local item =  meta:get_string("mod") .. ":" .. meta:get_string("item")
        --core.log("Manufacturer Preset: " .. tostring(item))
        return m_manufacture(pos, item)
    end,
}, {})

local miner_positions = {}
local miner_size = {x=16, y=128, z=16}

for y=-1,-miner_size.y,-1 do
    for x=-math.round(miner_size.x/2),math.round(miner_size.x/2),1 do
        for z=-math.round(miner_size.z/2),math.round(miner_size.z/2),1 do
            table.insert(miner_positions, vector.new(x, y, z))
        end
    end
end

mg_factory.manufactory.register_machine("miner", {
    description = "Quarry Miner",
    mesh = "mg_miner.obj",
    tiles = {"mg_machine_generic_metal.png", "mg_machine_generic_frame.png"},
    machine = {type="user", num = 1, active = false},
    formspec = mg_factory.manufactory.miner_formspec,
    inventories = {
        {name="msi", size=8}
    },
    on_timer = function(pos, elapsed, node, timeout)
        local meta = core.get_meta(pos)
        local index =  meta:get_int("ind")
        if index == 0 then index = 1 end

        if index <= #miner_positions then
            local machines = get_nearby_machines(pos)
            local discharge = nil
            for _,v in pairs(machines) do
                local n = core.get_node(v)
                if mg_factory.manufactory.machines[n.name].num == 2 then
                    discharge = v
                    break
                end
            end
            if discharge == nil then return false end -- no power sources nearby
            local dmeta = core.get_meta(discharge)
            if dmeta:get_int("power") < 1 then return true end -- not enough power
            dmeta:set_int("power", dmeta:get_int("power") - 1)

            local a = true -- loop around if air until it hits smth other than air
            while a do
                local p = miner_positions[index]
                if p ~= nil then
                    local node = core.get_node(vector.add(pos, p))
                    if node.name ~= "air" then
                        local inv = meta:get_inventory()
                        local stack = ItemStack(core.registered_nodes[node.name].drop or node.name)
                        if inv:room_for_item("msi", stack) then
                            inv:add_item("msi", stack)
                            core.remove_node(vector.add(pos, p))
                            manufacture_particles(vector.add(pos, p))
                        else
                            index = index - 1 -- go back to the same node until the inventory is emptied
                        end
                        a = false
                    else
                        index = index + 1
                    end
                end
            end

            meta:set_int("ind", index + 1)
            return true -- keep mining
        end
        return false -- stop mining, it has reached the end
    end,
}, {})

core.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "manufacturer" then
        local item = nil
        for k,v in pairs(fields) do
            --core.log(tostring(k) .. " <-> " .. tostring(v))
            if k ~= "quit" and k ~= "pos" then
                item = k
            end
        end
        local pos = nil
        if fields.pos then
            pos = core.string_to_pos(fields.pos)
            --core.log("Formspec Pos: " .. fields.pos)
        else
            return -- no positon so we can't perform operations on nodemeta
        end
        --core.log("Selected: " .. tostring(item))
        local itm = string.split(item, ":") -- meta doesn't allow you to store the colon (:) charactor for some reason
        core.get_meta(pos):set_string("mod", itm[1])
        core.get_meta(pos):set_string("item", itm[2])
        core.get_node_timer(pos):start(1)
    elseif formname == "miner" then
        local pos = nil
        if fields.pos then
            pos = core.string_to_pos(fields.pos)
        end
        if fields.activate and pos ~= nil then
            --core.log("Starting timer for miner")
            core.get_node_timer(pos):start(5)
        end
    end
end)

--[[
core.register_node("mg_factory:manufactory", {
	description = "Manufactory Controller",
    drawtype = "mesh",
    mesh = "mg_manufactory_controller.obj",
	tiles = {"mg_machine_mechanical_frame.png", "mg_machine_mechanical_metal.png", "mg_machine_mechanical_wood.png", "mg_factory_activate.png"},
    paramtype2 = "facedir",
	groups = {diggable=1, machine=3},
    on_construct = function(pos)
		local meta = core.get_meta(pos)
        meta:set_string("formspec", mg_factory.manufactory.controller_formspec(pos))
		--local inv = meta:get_inventory()
		--inv:set_size('src', 1)
		--inv:set_size('dst', 1)
		--inv:set_size('dst', 4)
	end,
})

core.register_node("mg_factory:manufactory_on", {
	description = "Manufactory Controller (On)",
    drawtype = "mesh",
    mesh = "mg_manufactory_controller.obj",
	tiles = {"mg_machine_mechanical_frame.png", "mg_machine_mechanical_metal.png", "mg_machine_mechanical_wood.png", "mg_factory_deactivate.png"},
    paramtype2 = "facedir",
	groups = {diggable=1, machine=3, not_in_creative_inventory=1},
    on_construct = function(pos)
		local meta = core.get_meta(pos)
        meta:set_string("formspec", mg_factory.manufactory.controller_formspec(pos))
		--local inv = meta:get_inventory()
		--inv:set_size('src', 1)
		--inv:set_size('dst', 1)
		--inv:set_size('dst', 4)
	end,
})

core.register_node("mg_factory:roller_press", {
	description = "Roller Press",
    drawtype = "mesh",
    mesh = "mg_roller_press.obj",
	tiles = {"mg_machine_mechanical_frame.png", "mg_machine_mechanical_metal.png", "mg_machine_mechanical_wood.png", "mg_machine_mechanical_metal.png"},
    paramtype2 = "facedir",
	groups = {diggable=1, machine=1},
    on_construct = function(pos)
		local meta = core.get_meta(pos)
        meta:set_string("formspec", mg_factory.manufactory.press_formspec(pos))
		local inv = meta:get_inventory()
		inv:set_size('src', 1)
		inv:set_size('dst', 4)
	end,
})

core.register_node("mg_factory:smelter", {
	description = "Smelting Furnace",
	tiles = {"mg_manufactory_smelter.png"},
    paramtype2 = "facedir",
	groups = {diggable=1, machine=1},
    on_construct = function(pos)
		local meta = core.get_meta(pos)
        meta:set_string("formspec", mg_factory.manufactory.smelter_formspec(pos))
		local inv = meta:get_inventory()
		inv:set_size('src', 1)
        inv:set_size('fuel', 1)
		inv:set_size('dst', 4)
	end,
})]]