local modpath = core.get_modpath("mg_core")

mg_core = {}

mg_core.ores = {}

dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/ores.lua")
--dofile(modpath .. "/mapgen.lua")
dofile(modpath .. "/tools.lua")
dofile(modpath .. "/bag.lua")
core.register_mapgen_script(modpath .. "/mapgen.lua")

-- Override the hand tool
core.override_item("", {
	wield_scale = {x=1,y=1,z=3.5},
	tool_capabilities = {
		groupcaps = {
			diggable = {times = {1.00}, uses = 0},
			layer = {times={[0]=0.50}, uses=0},
		},
	}
})

local initial_items = {
	"mg_core:trusty_pick",
	"mg_factory:crank",
	"mg_factory:roller",
	"mg_factory:mill",
	"mg_factory:manufacturer"
}

core.register_on_newplayer(function(player)
	local inv = player:get_inventory()
	for _,v in pairs(initial_items) do
		inv:add_item("main", ItemStack(v))
	end
end)

-- GUI related stuff (from MTG defualt mod)
core.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	if inv:get_size("bag") ~= 1 then inv:set_size("bag", 1) end

	local formspec = [[
			bgcolor[#080808BB;true]
			listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF] ]]
	local name = player:get_player_name()
	local info = core.get_player_information(name)
	if info.formspec_version > 1 then
		formspec = formspec .. "background9[5,5;1,1;gui_formbg.png;true;10]"
	else
		formspec = formspec .. "background[5,5;1,1;gui_formbg.png;true]"
	end
	player:set_formspec_prepend(formspec)

	-- Set hotbar textures
	player:hud_set_hotbar_image("gui_hotbar.png")
	player:hud_set_hotbar_selected_image("gui_hotbar_selected.png")

	player:set_clouds({
		density = 0.9,
		color = "#aaaabbdd",
		ambient = "#ffffff",
		shadow = "#aaaaaa",
		thickness = 128,
		speed = {x=2, y=2},
		height = 120
	})
	player:set_sky({
		type = "regular",
		clouds = true,
		sky_color = {
			night_sky = "#666677",
			night_horizon = "#887799",
			day_horizon = "#dfddff",
			day_sky = "#ddddff",
			dawn_sky = "#eeddff",
			dawn_horizon = "#eeedff",
			indoors = "#aaaaaa",
			fog_sun_tint = "#ddddff",
			fog_moon_tint = "#ddddff",
			fog_tint_type = "custom"
		},
		fog = {
			fog_start = 0.2,
			fog_distance = 40,
			fog_color = "#ddddff00"
		}
	})
	player:set_lighting({exposure = {exposure_correction = 0.5}, saturation = 1.2})
end)

core.register_on_generated(function(minp, maxp, _)
    core.fix_light(minp, maxp)
end)