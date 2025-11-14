--core.override_item("air", {light_source=3}, {})

core.register_node("mg_core:soil", {
	description = "Soil",
	tiles = {"mg_soil.png"},
	groups = {ground = 1, layer=0},
})

core.register_node("mg_core:limestone", {
	description = "Limestone",
	tiles = {"mg_limestone.png"},
	groups = {ground = 1, layer=1},
})

core.register_node("mg_core:granite", {
	description = "Granite",
	tiles = {"mg_granite.png"},
	groups = {ground = 1, layer=2},
})

core.register_node("mg_core:quartz", {
	description = "Quartz",
	tiles = {"mg_quartz.png"},
	groups = {ground = 1, layer=3},
})

core.register_node("mg_core:peridotite", {
	description = "Peridotite",
	tiles = {"mg_peridotite.png"},
	groups = {ground = 1, layer=4},
})