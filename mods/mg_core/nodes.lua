core.override_item("air", {light_source=5}, {}) -- silly workaround to stop there from being low light levels

mg_core.node_sounds = function (tbl)
	tbl = tbl or {}
	tbl.footstep = tbl.footstep or
			{name = "mg_footstep", gain = 100}
	tbl.dug = tbl.dug or
			{name = "mg_footstep", gain = 100}
	tbl.place = tbl.place or
			{name = "mg_footstep", gain = 100}
	return tbl
end

mg_core.node_sounds_sand  = function (tbl)
	tbl = tbl or {}
	tbl.footstep = tbl.footstep or
			{name = "mg_sand_footstep", gain = 100}
	tbl.dug = tbl.dug or
			{name = "mg_sand_footstep", gain = 100}
	tbl.place = tbl.place or
			{name = "mg_sand_footstep", gain = 100}
	return tbl
end

core.register_node("mg_core:sand", {
	description = "Sand",
	tiles = {"mg_sand.png"},
	groups = {ground = 1, layer=0},
	sounds = mg_core.node_sounds_sand()
})

core.register_node("mg_core:silt", {
	description = "Silt",
	tiles = {"mg_silt.png"},
	groups = {ground = 1, layer=0},
	sounds = mg_core.node_sounds_sand()
})

core.register_node("mg_core:bush", {
	description = "Bush",
	drawtype = "plantlike",
	waving = 1,
	--visual_scale = 1.69,
	tiles = {"mg_bush.png"},
	inventory_image = "mg_bush.png",
	wield_image = "mg_bush.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {diggable=1},
	selection_box = {
		type = "fixed",
		fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, 0.5, 6 / 16},
	},
})

core.register_node("mg_core:tall_bush", {
	description = "Tall Bush",
	drawtype = "plantlike",
	waving = 1,
	visual_scale = 1.5,
	tiles = {"mg_tall_bush.png"},
	inventory_image = "mg_tall_bush.png",
	wield_image = "mg_tall_bush.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {diggable=1},
	selection_box = {
		type = "fixed",
		fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, 0.5, 6 / 16},
	},
})

core.register_node("mg_core:soil", {
	description = "Soil",
	tiles = {"mg_soil.png"},
	groups = {ground = 1, layer=0},
	sounds = mg_core.node_sounds_sand()
})

core.register_node("mg_core:limestone", {
	description = "Limestone",
	tiles = {"mg_limestone.png"},
	groups = {ground = 1, layer=1},
	sounds = mg_core.node_sounds()
})

core.register_node("mg_core:granite", {
	description = "Granite",
	tiles = {"mg_granite.png"},
	groups = {ground = 1, layer=2},
	sounds = mg_core.node_sounds()
})

core.register_node("mg_core:quartz", {
	description = "Quartz",
	tiles = {"mg_quartz.png"},
	groups = {ground = 1, layer=3},
	sounds = mg_core.node_sounds()
})

core.register_node("mg_core:peridotite", {
	description = "Peridotite",
	tiles = {"mg_peridotite.png"},
	groups = {ground = 1, layer=4},
	sounds = mg_core.node_sounds()
})

core.register_node("mg_core:brick", {
	description = "Brick",
	tiles = {"mg_brick.png"},
	groups = {diggable=1, layer=1},
	sounds = mg_core.node_sounds()
})