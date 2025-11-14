core.register_node("mg_carts:rail_straight", {
	description = "Rail",
    drawtype = "mesh",
    mesh = "mg_rail_straight.obj",
	tiles = {
        "mg_rail.png",
        "mg_tie.png"
    },
    collision_box = {
        type = "fixed",
        fixed = {0.5, -0.425, 0.5, -0.5, -0.5, -0.5}
    },
    selection_box = {
        type = "fixed",
        fixed = {0.5, -0.425, 0.5, -0.5, -0.5, -0.5}
    },
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propogates = true,
    attached_node = true,
	groups = {rail=1, diggable=1},
})

core.register_node("mg_carts:rail_curved", {
	description = "Rail",
    drawtype = "mesh",
    mesh = "mg_rail_curved.obj",
	tiles = {
        "mg_rail.png", 
        "mg_tie.png"
    },
    collision_box = {
        type = "fixed",
        fixed = {0.5, -0.425, 0.5, -0.5, -0.5, -0.5}
    },
    selection_box = {
        type = "fixed",
        fixed = {0.5, -0.425, 0.5, -0.5, -0.5, -0.5}
    },
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propogates = true,
    attached_node = true,
	groups = {rail=1, diggable=1, not_in_creative_inventory=1},
})

--[[local function dump(t)
    local s = ""
    for k, v in pairs(t) do
        for k2, v2 in pairs(t[k]) do
            s = s .. tostring(v2) .. ", "
        end
        s = s .. "\n"
    end
    return s
end]]

local function slopedBox(y)
    local box = {{-0.5, -0.5, -0, 0.5, 0, 0.5}}
    for i=-y/2, y/2 do
        table.insert(box, {-0.5, -0.5, -(i/y), 0.5, -(i/y), 0.5})
    end
    --core.log(dump(box))
    return box
end

core.register_node("mg_carts:rail_incline", {
	description = "Rail",
    drawtype = "mesh",
    mesh = "mg_rail_incline.obj",
	tiles = {
        "mg_rail.png", 
        "mg_tie.png"
    },
    collision_box = {
        type = "fixed",
        fixed = slopedBox(8)
    },
    selection_box = {
        type = "fixed",
        fixed = slopedBox(16)
    },
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propogates = true,
    attached_node = true,
	groups = {rail=1, diggable=1, not_in_creative_inventory=1},
})