
local initial_items = {
	"mg_core:trusty_pick",
	"mg_factory:crank",
	"mg_factory:roller",
	"mg_factory:mill",
	"mg_factory:manufacturer"
}

local welcome_formspec = function(player)
	local content = "<center><style color='#aaccff' size='18'><b>Hello " .. player:get_player_name() .. ", welcome to Malmgruve.</b></style></center>" ..
	"Malmgruve is a progression mining game, made for the 2025 Luanti Game Jam\n" ..
	"Check out the Guide in your inventory to learn how to play.\n" ..
	"</style>\n\n<img name='malmgruve.png'> <style color='#aaccff' size='11'>by SuperStarSonic</style>\n\n"
	local i = 4
	--content = content .. "<normal> </normal>"

	local fog = core.settings:get_bool("enable_fog")
	if not fog then
		content = content .. "<style color='#eeaaaa'>Malmgruve works best with <style color='#ff5555'>fog enabled</style>, please enable fog in your settings.</style>\n"
		i = i+1
	end

	local formspec = "size[10,8]allow_close[false]formspec_version[10]"..
	"hypertext[0.5,0;9.5,"..(i*2)..";content;"..content.."]" ..
	"button_exit[3,7.5;4,1;exit;Continue to Game]"
	return formspec
end

--[[
"scroll_container[0,5;10,"..tostring(i*2)..";scroll;vertical;]" ..
"hypertext[0.5,0;9.5,"..i..";content;"..warns.."]" ..
"scrollbar[10.25,-2;0.25,"..i..";vertical;scroll;]" ..
"scroll_container_end[]" ..
]]

local find_suitable_spawn = function(player)
    local pos = player:get_pos()
    local offset = vector.new(0, 20, 0)
    local positions = core.find_nodes_in_area_under_air(vector.add(pos, -offset), vector.add(pos, offset), {"mg_core:sand"})
    local spawnpos = pos
    for _,v in pairs(positions) do
        --core.log(core.pos_to_string(v))
        spawnpos = vector.offset(v, 0, 2, 0)
    end
    player:set_pos(spawnpos)
end

core.register_on_newplayer(function(player)
	local inv = player:get_inventory()
	for _,v in pairs(initial_items) do
		inv:add_item("main", ItemStack(v))
	end
	local meta = player:get_meta()
	meta:set_int("kolro", 100) -- give the player 100 intial kolro
	core.show_formspec(player:get_player_name(), "welcome", welcome_formspec(player))
    core.after(0.5, find_suitable_spawn, player)
end)

core.register_on_dieplayer(function(player, reason)
    find_suitable_spawn(player)
end)

local step = 0

local ps = {}

core.register_globalstep(function(dtime)
	step = step + dtime
	if step >= 1 then
		step = 0
		local players = core.get_connected_players()
		for k,v in pairs(players) do
			local pos = v:get_pos()
			if pos.y > -20 then
				core.add_particlespawner({
					amount = 10000,
					time = 1,
					collisiondetection = true,
					object_collision = true,

					pos = {
						min = vector.new(pos.x-16,pos.y+16,pos.z-16),
						max = vector.new(pos.x+16,-10,pos.z+16),
						bias = 0
					},
			
					vel = {
						min = vector.new(-2, -5, -20),
						max = vector.new(2, 10, -5),
						bias = 0
					},
			
					acc = vector.new(0, -2, -2),
					size = { min = 0.125, max = 0.5 },
					exptime = { min = 0.5, max = 1 },
					glow = 2,
					texture = "mg_dust.png"
				})
				if ps[v:get_player_name()] == nil then ps[v:get_player_name()] = true end
				if ps[v:get_player_name()] == true then
					v:set_sky({
						type = "regular",
						clouds = true,
						sky_color = {
							night_sky = "#776644",
							night_horizon = "#997777",
							day_horizon = "#ffdddd",
							day_sky = "#eeeddd",
							dawn_sky = "#ddccaa",
							dawn_horizon = "#ddaaaa",
							indoors = "#aaaaaa",
							fog_sun_tint = "#ffdddd",
							fog_moon_tint = "#998866",
							fog_tint_type = "custom"
						},
						fog = {
							fog_start = 0.5,
							fog_distance = 50,
							fog_color = "#ddccaa00"
						}
					})
					v:set_lighting({exposure = {exposure_correction = 0.5}, saturation = 1.2})

					ps[v:get_player_name()] = false
				end
			else
				if ps[v:get_player_name()] == nil then ps[v:get_player_name()] = false end
				if ps[v:get_player_name()] == false then
					v:set_sky({
						type = "plain",
						base_color = "#000001",
						fog = {
							fog_start = 0.7,
							fog_distance = 20,
						}
					})
					v:set_lighting({exposure = {exposure_correction = 2}, saturation = 1.5})

					ps[v:get_player_name()] = true
				end
			end
		end
	end
end)

core.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	if inv:get_size("bag") ~= 1 then inv:set_size("bag", 1) end

	-- GUI related stuff (from MTG defualt mod)
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
		color = "#efeedd",
		ambient = "#efeeea",
		shadow = "#eeddbb",
		thickness = 256,
		speed = {x=2, y=2},
		height = 50
	})
	player:set_sky({
		type = "regular",
		clouds = true,
		sky_color = {
			night_sky = "#776644",
			night_horizon = "#997777",
			day_horizon = "#ffdddd",
			day_sky = "#eeeddd",
			dawn_sky = "#ddccaa",
			dawn_horizon = "#ddaaaa",
			indoors = "#aaaaaa",
			fog_sun_tint = "#ffdddd",
			fog_moon_tint = "#998866",
			fog_tint_type = "custom"
		},
		fog = {
			fog_start = 0.5,
			fog_distance = 50,
			fog_color = "#ddccaa00"
		}
	})
	player:set_lighting({exposure = {exposure_correction = 0.5}, saturation = 1.2})
end)
