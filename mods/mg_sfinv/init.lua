-- sfinv/init.lua

dofile(minetest.get_modpath("sfinv") .. "/api.lua")

-- Load support for MT game translation.
--local S = minetest.get_translator("sfinv")

sfinv.register_page("sfinv:bag", {
	title = "Bag",
	get = function(self, player, context)
		return sfinv.make_formspec(player, context, "" ..
			"model[2.5,0;3,6;player_preview;character.obj;character.png;0;false;true;]" ..
			"image[0,5.2;1,1;gui_hb_bg.png]" ..
			"image[1,5.2;1,1;gui_hb_bg.png]" ..
			"image[2,5.2;1,1;gui_hb_bg.png]" ..
			"image[3,5.2;1,1;gui_hb_bg.png]" ..
			"image[4,5.2;1,1;gui_hb_bg.png]" ..
			"image[5,5.2;1,1;gui_hb_bg.png]" ..
			"image[6,5.2;1,1;gui_hb_bg.png]" ..
			"image[7,5.2;1,1;gui_hb_bg.png]" ..
			"image[0,6.5;9.725,3;gui_bag_bg.png]" ..
			"list[current_player;main;0,5.2;8,1;]" ..
			"label[3,7;" .. core.formspec_escape(core.colorize("#F24", "You don't have a bag")) .. "]", false)
	end
})

--[[
list[current_player;craft;1.75,0.5;3,3;]
list[current_player;craftpreview;5.75,1.5;1,1;]
image[4.75,1.5;1,1;sfinv_crafting_arrow.png]
listring[current_player;craft]
listring[current_player;main]
]]--