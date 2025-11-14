local modpath = core.get_modpath("mg_core")

mg_core = {}

dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/ores.lua")
--dofile(modpath .. "/mapgen.lua")
core.register_mapgen_script(modpath .. "/mapgen.lua")

-- GUI related stuff (stolen from MTG defualt mod)
minetest.register_on_joinplayer(function(player)
	local formspec = [[
			bgcolor[#080808BB;true]
			listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF] ]]
	local name = player:get_player_name()
	local info = minetest.get_player_information(name)
	if info.formspec_version > 1 then
		formspec = formspec .. "background9[5,5;1,1;gui_formbg.png;true;10]"
	else
		formspec = formspec .. "background[5,5;1,1;gui_formbg.png;true]"
	end
	player:set_formspec_prepend(formspec)

	-- Set hotbar textures
	player:hud_set_hotbar_image("gui_hotbar.png")
	player:hud_set_hotbar_selected_image("gui_hotbar_selected.png")
end)

core.register_on_generated(function(minp, maxp, _)
    core.fix_light(minp, maxp)
end)