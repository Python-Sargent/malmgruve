carts.rails = {}

local function face4(pos)
    local positions = {
        vector.new(1, 0, 0),
        vector.new(-1, 0, 0),
        vector.new(0, 0, 1),
        vector.new(0, 0, -1)
    }

    local nodes = {}
    for _,v in pairs(positions) do
        local p = vector.add(pos, v)
        table.insert(nodes, p)
    end

    return nodes
end

local function facing(vec)
    if vec.x == 1 then
        return 1
    elseif vec.x == -1 then
        return 3
    elseif vec.z == 1 then
        return 0
    elseif vec.z == -1 then
        return 2
    end
end

carts.rails.reface_rail = function(pos, r, f)
    r = r-1
    if r < 1 then return end -- if recursion has reached max distance then stop
    if f[pos] ~= nil then return end -- if position has already been refaced then stop

    table.insert(f, pos)

    local sides = face4(pos)
    local above = face4(vector.offset(pos, 0, 1, 0))
    local below = face4(vector.offset(pos, 0, -1, 0))
    local dir = core.get_node(pos).param2
    --core.log("dir: " .. dir)

    for _,v in pairs(sides) do
        local node = core.get_node(v)
        if core.get_node_group(node.name, "rail") > 0 then
            core.set_node(pos, {name="mg_carts:rail_straight", param2=facing(vector.subtract(pos,v))})
            carts.rails.reface_rail(v, r, f)
        end
    end

    for _,v in pairs(sides) do
        local node = core.get_node(v)
        if core.get_node_group(node.name, "rail") > 0 then
            local dif = pos-v
            dif = vector.new(math.abs(dif.x), 0, math.abs(dif.z))
            if ((node.param2 == 2 or node.param2 == 0) and dif.z ~= 0) or ((node.param2 == 3 or node.param2 == 1) and dif.x ~= 0) then

                if node.param2 % 2 == 0 and dir  % 2 ~= 0 then
                    local sub = 3
                    if dir == 3 or dir == 0 then sub = 2 end
                    --elseif dir == 2 or dir == 1 then sub = 0 end
                    core.set_node(pos, {name="mg_carts:rail_curved", param2=facing(vector.subtract(pos,v))-sub})
                elseif node.param2 % 2 ~= 0 and dir  % 2 == 0 then
                    local sub = 3
                    if dir == 2 or dir == 1 then sub = 2 end
                    --elseif dir == 2 or dir == 1 then sub = 0 end
                    core.set_node(pos, {name="mg_carts:rail_curved", param2=facing(vector.subtract(pos,v))-sub})
                end
            end
        end
    end
    
    for _,v in pairs(above) do
        local node = core.get_node(v)
        if core.get_node_group(node.name, "rail") > 0 then
            core.set_node(pos, {name="mg_carts:rail_incline", param2=facing(vector.subtract(pos,v))-2})
            carts.rails.reface_rail(v, r, f)
        end
    end

    for _,v in pairs(below) do
        local node = core.get_node(v)
        if core.get_node_group(node.name, "rail") > 0 then
            core.set_node(pos, {name="mg_carts:rail_incline", param2=facing(vector.subtract(pos,v))})
            carts.rails.reface_rail(v, r, f)
        end
    end

    return core.get_node(pos).param2 or "nil"
end

carts.rails.face_rail = function(pos)
    carts.rails.reface_rail(pos, 2, {})
end

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
    paramtype2 = "4dir",
    sunlight_propogates = true,
    attached_node = true,
	groups = {rail=1, diggable=1},
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        carts.rails.face_rail(pos)
    end
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
    paramtype2 = "4dir",
    drop = "mg_carts:rail_straight",
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
    paramtype2 = "4dir",
    drop = "mg_carts:rail_straight",
    sunlight_propogates = true,
    attached_node = true,
	groups = {rail=1, diggable=1, not_in_creative_inventory=1},
})

carts.railparams["mg_carts:rail_straight"] = {acceleration=1}
carts.railparams["mg_carts:rail_curved"] = {acceleration=1}
carts.railparams["mg_carts:rail_incline"] = {acceleration=1}