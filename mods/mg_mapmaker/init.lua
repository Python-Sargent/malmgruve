-- Based off the MTG creative mod (https://github.com/luanti-org/minetest_game/tree/master/mods/creative)

mapmaker = {}

local function update_sfinv(name)
	core.after(0, function()
		local player = core.get_player_by_name(name)
		if player then
			if sfinv.get_page(player):sub(1, 9) == "mapmaker:" then
				sfinv.set_page(player, sfinv.get_homepage_name(player))
			else
				sfinv.set_player_inventory_formspec(player)
			end
		end
	end)
end

core.register_privilege("mapmaker", {
	description = "Allow player to use the mapmaker",
	give_to_singleplayer = false,
	give_to_admin = false,
	on_grant = update_sfinv,
	on_revoke = update_sfinv,
})

-- Override the engine's mapmaker mode function
local old_is_creative_enabled = core.is_creative_enabled

function core.is_mapmaker_enabled(name)
	if name == "" then
		return old_is_creative_enabled(name)
	end
	return core.check_player_privs(name, {mapmaker = true}) or old_is_creative_enabled(name)
end

-- For backwards compatibility:
function mapmaker.is_enabled_for(name)
	return core.is_mapmaker_enabled(name)
end

dofile(core.get_modpath("mg_mapmaker") .. "/inventory.lua")

if core.is_mapmaker_enabled("") then
	
	core.register_on_mods_loaded(function()
		local digtime = 0
		local caps = {times = {digtime, digtime, digtime}, uses = 0, maxlevel = 256}

		-- Override the hand tool
		core.override_item("", {
			range = 10,
			tool_capabilities = {
				full_punch_interval = 0.5,
				max_drop_level = 3,
				groupcaps = {
					ground = caps,
					diggable = caps,
					dig_immediate = {times = {[2] = digtime, [3] = 0}, uses = 0, maxlevel = 256},
				},
				damage_groups = {fleshy = 10},
			}
		})
	end)
end

-- Unlimited node placement
core.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack)
	if placer and placer:is_player() then
		return core.is_creative_enabled(placer:get_player_name())
	end
end)

-- Don't pick up if the item is already in the inventory
local old_handle_node_drops = core.handle_node_drops
function core.handle_node_drops(pos, drops, digger)
	if not digger or not digger:is_player() or
		not core.is_creative_enabled(digger:get_player_name()) then
		return old_handle_node_drops(pos, drops, digger)
	end
	local inv = digger:get_inventory()
	if inv then
		for _, item in ipairs(drops) do
			if not inv:contains_item("main", item, true) then
				inv:add_item("main", item)
			end
		end
	end
end
