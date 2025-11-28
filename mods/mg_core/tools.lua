
minetest.register_tool("mg_core:trusty_pick", {
	description = "Trusty Pickaxe",
	inventory_image = "mg_trusty_pick.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			layer = {times={[4]=8.00, [3]=4.00, [2]=2.00, [1]=0.50}, uses=0},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {pickaxe = 1}
})