-- Based off the MTG creative mod (https://github.com/luanti-org/core_game/tree/master/mods/creative)

local player_inventory = {}
local inventory_cache = {}

local function init_mapmaker_cache(items)
	inventory_cache[items] = {}
	local i_cache = inventory_cache[items]

	for name, def in pairs(items) do
		if def.groups.not_in_creative_inventory ~= 1 and
				def.description and def.description ~= "" then
			i_cache[name] = def
		end
	end
	table.sort(i_cache)
	return i_cache
end

function mapmaker.init_mapmaker_inventory(player)
	local player_name = player:get_player_name()
	player_inventory[player_name] = {
		size = 0,
		filter = "",
		start_i = 0,
		old_filter = nil, -- use only for caching in update_mapmaker_inventory
		old_content = nil
	}

	core.create_detached_inventory("mapmaker_" .. player_name, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player2)
			local name = player2 and player2:get_player_name() or ""
			if not core.is_creative_enabled(name) or
					to_list == "main" then
				return 0
			end
			return count
		end,
		allow_put = function(inv, listname, index, stack, player2)
			return 0
		end,
		allow_take = function(inv, listname, index, stack, player2)
			local name = player2 and player2:get_player_name() or ""
			if not core.is_creative_enabled(name) then
				return 0
			end
			return -1
		end,
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player2)
		end,
		on_take = function(inv, listname, index, stack, player2)
			if stack and stack:get_count() > 0 then
				core.log("action", player_name .. " takes " .. stack:get_name().. " from mapmaker inventory")
			end
		end,
	}, player_name)

	return player_inventory[player_name]
end

local NO_MATCH = 999
local function match(s, filter)
	if filter == "" then
		return 0
	end
	if s:lower():find(filter, 1, true) then
		return #s - #filter
	end
	return NO_MATCH
end

local function description(def, lang_code)
	local s = def.description
	if lang_code then
		s = core.get_translated_string(lang_code, s)
	end
	return s:gsub("\n.*", "") -- First line only
end

function mapmaker.update_mapmaker_inventory(player_name, tab_content)
	local inv = player_inventory[player_name] or
			mapmaker.init_mapmaker_inventory(core.get_player_by_name(player_name))
	local player_inv = core.get_inventory({type = "detached", name = "mapmaker_" .. player_name})

	if inv.filter == inv.old_filter and tab_content == inv.old_content then
		return
	end
	inv.old_filter = inv.filter
	inv.old_content = tab_content

	local items = inventory_cache[tab_content] or init_mapmaker_cache(tab_content)

	local lang
	local player_info = core.get_player_information(player_name)
	if player_info and player_info.lang_code ~= "" then
		lang = player_info.lang_code
	end

	local mapmaker_list = {}
	local order = {}
	for name, def in pairs(items) do
		local m = match(description(def), inv.filter)
		if m > 0 then
			m = math.min(m, match(description(def, lang), inv.filter))
		end
		if m > 0 then
			m = math.min(m, match(name, inv.filter))
		end

		if m < NO_MATCH then
			mapmaker_list[#mapmaker_list+1] = name
			-- Sort by match value first so closer matches appear earlier
			order[name] = string.format("%02d", m) .. name
		end
	end

	table.sort(mapmaker_list, function(a, b) return order[a] < order[b] end)

	player_inv:set_size("main", #mapmaker_list)
	player_inv:set_list("main", mapmaker_list)
	inv.size = #mapmaker_list
end

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	player_inventory[name] = nil
end)

-- Create the trash field
local trash = core.create_detached_inventory("trash", {
	-- Allow the stack to be placed and remove it in on_put()
	-- This allows the mapmaker inventory to restore the stack
	allow_put = function(inv, listname, index, stack, player)
		return stack:get_count()
	end,
	on_put = function(inv, listname)
		inv:set_list(listname, {})
	end,
})
trash:set_size("main", 1)

mapmaker.formspec_add = ""

function mapmaker.register_tab(name, title, items)
	sfinv.register_page("mapmaker:" .. name, {
		title = title,
		is_in_nav = function(self, player, context)
			return core.is_creative_enabled(player:get_player_name())
		end,
		get = function(self, player, context)
			local player_name = player:get_player_name()
			mapmaker.update_mapmaker_inventory(player_name, items)
			local inv = player_inventory[player_name]
			local pagenum = math.floor(inv.start_i / (4*8) + 1)
			local pagemax = math.max(math.ceil(inv.size / (4*8)), 1)
			local esc = core.formspec_escape
			return sfinv.make_formspec(player, context,
				(inv.size == 0 and ("label[3,2;"..esc("No items to show.").."]") or "") ..
				"label[5.8,4.15;" .. core.colorize("#FFFF00", tostring(pagenum)) .. " / " .. tostring(pagemax) .. "]" ..
				[[
					image[4.08,4.2;0.8,0.8;mapmaker_trash.png]
					listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]
					list[detached:trash;main;4.02,4.1;1,1;]
					listring[]
					image_button[5,4.05;0.8,0.8;mapmaker_prev.png;mapmaker_prev;]
					image_button[7.25,4.05;0.8,0.8;mapmaker_next.png;mapmaker_next;]
					image_button[2.63,4.05;0.8,0.8;mapmaker_search.png;mapmaker_search;]
					image_button[3.25,4.05;0.8,0.8;mapmaker_clear.png;mapmaker_clear;]
				]] ..
				"tooltip[mapmaker_search;" .. esc("Search") .. "]" ..
				"tooltip[mapmaker_clear;" .. esc("Reset") .. "]" ..
				"tooltip[mapmaker_prev;" .. esc("Previous page") .. "]" ..
				"tooltip[mapmaker_next;" .. esc("Next page") .. "]" ..
				"listring[current_player;main]" ..
				"field_enter_after_edit[mapmaker_filter;true]" ..
				"field_close_on_enter[mapmaker_filter;false]" ..
				"field[0.3,4.2;2.8,1.2;mapmaker_filter;;" .. esc(inv.filter) .. "]" ..
				"listring[detached:mapmaker_" .. player_name .. ";main]" ..
				"list[detached:mapmaker_" .. player_name .. ";main;0,0;8,4;" .. tostring(inv.start_i) .. "]" ..
				"list[player:" .. player_name .. ";main;0,6.35;8,3;8]" ..
				mapmaker.formspec_add, true)
		end,
		on_enter = function(self, player, context)
			local player_name = player:get_player_name()
			local inv = player_inventory[player_name]
			if inv then
				inv.start_i = 0
			end
		end,
		on_player_receive_fields = function(self, player, context, fields)
			local player_name = player:get_player_name()
			local inv = player_inventory[player_name]
			assert(inv)

			if fields.mapmaker_clear then
				inv.start_i = 0
				inv.filter = ""
				sfinv.set_player_inventory_formspec(player, context)
			elseif (fields.mapmaker_search or
					fields.key_enter_field == "mapmaker_filter")
					and fields.mapmaker_filter then
				inv.start_i = 0
				inv.filter = fields.mapmaker_filter:sub(1, 128) -- truncate to a sane length
						:gsub("[%z\1-\8\11-\31\127]", "") -- strip naughty control characters (keeps \t and \n)
						:lower() -- search is case insensitive
				sfinv.set_player_inventory_formspec(player, context)
			elseif not fields.quit then
				local start_i = inv.start_i or 0

				if fields.mapmaker_prev then
					start_i = start_i - 4*8
					if start_i < 0 then
						start_i = inv.size - (inv.size % (4*8))
						if inv.size == start_i then
							start_i = math.max(0, inv.size - (4*8))
						end
					end
				elseif fields.mapmaker_next then
					start_i = start_i + 4*8
					if start_i >= inv.size then
						start_i = 0
					end
				end

				inv.start_i = start_i
				sfinv.set_player_inventory_formspec(player, context)
			end
		end
	})
end

-- Sort registered items
local registered_nodes = {}
local registered_tools = {}
local registered_craftitems = {}

core.register_on_mods_loaded(function()
	for name, def in pairs(core.registered_items) do
		local group = def.groups or {}

		local nogroup = not (group.node or group.tool or group.craftitem)
		if group.node or (nogroup and core.registered_nodes[name]) then
			registered_nodes[name] = def
		elseif group.tool or (nogroup and core.registered_tools[name]) then
			registered_tools[name] = def
		elseif group.craftitem or (nogroup and core.registered_craftitems[name]) then
			registered_craftitems[name] = def
		end
	end
end)

mapmaker.register_tab("all", "All", core.registered_items)
mapmaker.register_tab("nodes", "Nodes", registered_nodes)
mapmaker.register_tab("tools", "Tools", registered_tools)
mapmaker.register_tab("craftitems", "Items", registered_craftitems)

local old_homepage_name = sfinv.get_homepage_name
function sfinv.get_homepage_name(player)
	if core.is_creative_enabled(player:get_player_name()) then
		return "mapmaker:all"
	else
		return old_homepage_name(player)
	end
end
