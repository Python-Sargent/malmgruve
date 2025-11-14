mg_factory.manufactory = {}

mg_factory.manufactory.machines = {}

mg_factory.manufactory.controller_formspec = function(pos)
    local switch = "mg_factory_activate.png"
    if mg_factory.manufactory.machines[core.get_node(pos).name].is_active == true then
        switch = "mg_factory_deactivate.png"
    end
    local formspec = "size[8,8.5]"..
    --"list[context;src;2.75,0.5;1,1;]"..
    --"list[context;dst;2.75,2.5;1,1;]"..
    "image_button[3.5,2;1,1;" .. switch .. ";activate;]" ..
    "list[current_player;main;0,4.25;8,1;]"..
    "list[current_player;main;0,5.5;8,3;8]"
    return formspec
end

mg_factory.manufactory.press_formspec = function(pos)
    local formspec = "size[8,8.5]"..
    "list[context;src;2.75,0.5;1,1;]"..
    "list[context;dst;2.75,2.5;4,4;]"..
    "list[current_player;main;0,4.25;8,1;]"..
    "list[current_player;main;0,5.5;8,3;8]"
    return formspec
end

mg_factory.manufactory.smelter_formspec = function(pos)
    local formspec = "size[8,8.5]"..
    "list[context;src;2.75,0.5;1,1;]"..
    "list[context;dst;2.75,2.5;4,4;]"..
    "list[current_player;main;0,4.25;8,1;]"..
    "list[current_player;main;0,5.5;8,3;8]"
    return formspec
end

mg_factory.manufactory.register_machine = function(name, def, overrides)
    local ndef = {
        description = def.description,
        drawtype = "mesh",
        mesh = def.mesh,
        tiles = def.tiles,
        paramtype2 = "facedir",
        groups = {diggable=1, machine=def.machine.num},
        on_construct = function(pos)
            local meta = core.get_meta(pos)
            meta:set_string("formspec", def.formspec(pos))
            local inv = meta:get_inventory()
            for _, i in pairs(def.inventories) do
                inv:set_size(i.name, i.size)
            end
        end,
    }

    for k, v in pairs(overrides) do
		ndef[k] = v
	end

    core.register_node("mg_factory:" .. name, ndef)

    mg_factory.manufactory.machines["mg_factory:" .. name] = {is_active = def.machine.active, name = def.name, num = def.machine.num}
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
end


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


mg_factory.manufactory.register_machine("roller", {
    description = "Roller Press",
    mesh = "mg_roller_press.obj",
    tiles = {"mg_machine_mechanical_frame.png", "mg_machine_mechanical_metal.png", "mg_machine_mechanical_wood.png", "mg_machine_mechanical_metal.png"},
    machine = {type="user", num = 1, active = false},
    formspec = mg_factory.manufactory.press_formspec,
    inventories = {
        {name="src", size=1},
        {name="dst", size=4}
    }
}, {})

mg_factory.manufactory.register_machine("ball_mill", {
    description = "Ball Mill",
    mesh = "mg_ball_mill.obj",
    tiles = {"mg_machine_mechanical_frame.png", "mg_machine_mechanical_metal.png", "mg_machine_mechanical_wood.png"},
    machine = {type="user", num = 1, active = false},
    formspec = mg_factory.manufactory.press_formspec,
    inventories = {
        {name="src", size=1},
        {name="dst", size=4}
    }
}, {})

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