mg_mining.explosives = {}

local function add_drop(drops, item)
	item = ItemStack(item)
	local name = item:get_name()
	local drop = drops[name]
	if drop == nil then
		drops[name] = item
	else
		drop:set_count(drop:get_count() + item:get_count())
	end
end

local function add_effects(pos, radius)
	core.add_particle({
		pos = pos,
		velocity = vector.new(),
		acceleration = vector.new(),
		expirationtime = 0.4,
		size = radius * 10,
		collisiondetection = false,
		vertical = false,
		texture = {name = "mg_fire_particle.png"},
		glow = 15,
	})
	core.add_particlespawner({
		amount = 100,
		time = 0.5,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x = -7, y = -7, z = -7},
		maxvel = {x = 7, y = 7, z = 7},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 0.5,
		maxexptime = 1,
		minsize = radius * 6,
		maxsize = radius * 8,
		texture = {name = "mg_smoke.png"},
	})
end

local function rand_pos(center, pos, radius)
	local def
	local reg_nodes = minetest.registered_nodes
	local i = 0
	repeat
		-- Give up and use the center if this takes too long
		if i > 4 then
			pos.x, pos.z = center.x, center.z
			break
		end
		pos.x = center.x + math.random(-radius, radius)
		pos.z = center.z + math.random(-radius, radius)
		def = reg_nodes[minetest.get_node(pos).name]
		i = i + 1
	until def and not def.walkable
end

local function eject_drops(drops, pos, radius)
	local drop_pos = vector.new(pos)
	for _, item in pairs(drops) do
		local count = math.min(item:get_count(), item:get_stack_max())
		while count > 0 do
			local take = math.max(1,math.min(radius * radius,
					count,
					item:get_stack_max()))
			rand_pos(pos, drop_pos, radius)
			local dropitem = ItemStack(item)
			dropitem:set_count(take)
			local obj = minetest.add_item(drop_pos, dropitem)
			if obj then
				obj:get_luaentity().collect = true
				obj:set_acceleration({x = 0, y = -10, z = 0})
				obj:set_velocity({x = math.random(-3, 3),
						y = math.random(0, 10),
						z = math.random(-3, 3)})
			end
			count = count - take
		end
	end
end

local function explode(pos, radius)
	pos = vector.round(pos)
	local c_air = core.CONTENT_AIR
	local c_ignore = core.CONTENT_IGNORE

	local vm = VoxelManip()
	local pr = PseudoRandom(os.time())
	local p1 = vector.subtract(pos, radius)
	local p2 = vector.add(pos, radius)
	local minp, maxp = vm:read_from_map(p1, p2)
	local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm:get_data()

	local drops = {}
	local on_blast_queue = {}

    minetest.sound_play("mg_detonate", {pos = pos, gain = 4, max_hear_distance = math.min(radius * 20, 128)}, true)
    add_effects(pos, radius)

	-- Used to efficiently remove metadata of nodes that were destroyed.
	-- Metadata is probably sparse, so this may save us some work.
	local has_meta = {}
	for _, p in ipairs(core.find_nodes_with_meta(p1, p2)) do
		has_meta[a:indexp(p)] = true
	end

	for z = -radius, radius do
        for y = -radius, radius do
            local vi = a:index(pos.x + (-radius), pos.y + y, pos.z + z)
            for x = -radius, radius do
                local r = vector.length(vector.new(x, y, z))
                if (radius * radius) / (r * r) >= (pr:next(80, 125) / 100) then
                    local cid = data[vi]
                    local p = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
                    if cid ~= c_air and cid ~= c_ignore then
                        if c_air ~= data[vi] then
                            add_drop(drops, core.registered_nodes[cid])
                            data[vi] = c_air
                            if has_meta[vi] then
                                core.get_meta(p):from_table(nil)
                            end
                        end
                    end
                end
                vi = vi + 1
            end
        end
	end

	vm:set_data(data)
	vm:write_to_map()
	vm:update_liquids()
	if vm.close ~= nil then
		vm:close()
	end

	for _, queued_data in pairs(on_blast_queue) do
		local dist = math.max(1, vector.distance(queued_data.pos, pos))
		local intensity = (radius * radius) / (dist * dist)
		local node_drops = queued_data.on_blast(queued_data.pos, intensity)
		if node_drops then
			for _, item in pairs(node_drops) do
				add_drop(drops, item)
			end
		end
	end

    eject_drops(drops, pos, radius)
end

core.register_node("mg_mining:dynamite", {
    description = "Dynamite",
    drawtype = "mesh",
    mesh = "mg_dynamite.obj",
    tiles = {"mg_dynamite_strap.png", "mg_dynamite.png"},
    groups = {diggable = 1},
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local timer = core.get_node_timer(pos)
        if not timer:is_started() then
            timer:start(3)
            local spawner = core.add_particlespawner({
                amount = 100,
                time = 3,
                pos = vector.offset(pos, 0, 0.6, 0),
                minvel = {x=-0.5, y=1, z=-0.5},
                maxvel = {x=0.5, y=2, z=0.5},
                minsize = 2,
                maxsize = 3,
                texture = {name = "mg_smoke.png"},
            })
            core.get_meta(pos):set_int("spawner", spawner)
        else
            timer:stop()
            local spawner = core.get_meta(pos):get_int("spawner")
            if spawner ~= nil then
                core.delete_particlespawner(spawner)
            end
        end
    end,
    on_blast = function(pos, intensity)
        explode(pos, intensity)
    end,
    on_timer = function(pos)
        explode(pos, 5)
    end
})
