-- mg_sfinv/init.lua

dofile(minetest.get_modpath("mg_sfinv") .. "/api.lua")

-- Load support for MT game translation.
--local S = minetest.get_translator("mg_sfinv")

core.register_on_newplayer(function(player)
	local inv = player:get_inventory()
	inv:set_size("bag", 1)
end)

local creative = core.is_creative_enabled("")

core.register_on_joinplayer(function(player, last_login)
	local inv = player:get_inventory()
	local bagslot = inv:get_stack("bag", 1)
	if bagslot:get_name() == "mg_core:bag" or creative then
		player:get_inventory():set_size("main", 8*4)
	elseif not creative then
		player:get_inventory():set_size("main", 8)
	end
end)

mg_sfinv.register_page("mg_sfinv:bag", {
	title = "Bag",
	get = function(self, player, context)
		return mg_sfinv.make_formspec(player, context, "" ..
			"model[2.6878,0;3,6;player_preview;character.obj;character.png;0;false;true;]" ..
			"image[0,5.2;1,1;gui_hb_bg.png]" ..
			"image[1,5.2;1,1;gui_hb_bg.png]" ..
			"image[2,5.2;1,1;gui_hb_bg.png]" ..
			"image[3,5.2;1,1;gui_hb_bg.png]" ..
			"image[4,5.2;1,1;gui_hb_bg.png]" ..
			"image[5,5.2;1,1;gui_hb_bg.png]" ..
			"image[6,5.2;1,1;gui_hb_bg.png]" ..
			"image[7,5.2;1,1;gui_hb_bg.png]" ..
			"image[-0.3,6.15;10.5,3.9;gui_bag_bg.png]" ..
			"list[current_player;main;0,5.2;8,1;]" ..
			"list[current_player;main;0,6.4;8,3;8]" .. -- should be invisible when inv is smaller than 8+
			"image[7,0;1,1;gui_bag_slot_bg.png]" ..
			"list[current_player;bag;7,0;1,1]",
			--"label[3,7;" .. core.formspec_escape(core.colorize("#F24", "You don't have a bag")) .. "]",
			false)
	end,
	on_player_receive_fields = function(self, player, context, fields)
		local inv = player:get_inventory()
		local bagslot = inv:get_stack("bag", 1)
		if bagslot:get_name() == "mg_core:bag" then
			inv:set_size("main", 8*4)
		elseif not creative then
			local main = inv:get_list("main")
			local overflow = {unpack(main, 8+1)}
			inv:set_size("main", 8)
			local drop = {}
			for _,v in pairs(overflow) do
				local extra = inv:add_item("main", v)
				table.insert(drop, extra)
			end
			for _,v in pairs(drop) do
				core.item_drop(v, player, player:get_pos())
			end
		end
	end
})

--[[
list[current_player;craft;1.75,0.5;3,3;]
list[current_player;craftpreview;5.75,1.5;1,1;]
image[4.75,1.5;1,1;mg_sfinv_crafting_arrow.png]
listring[current_player;craft]
listring[current_player;main]
]]--