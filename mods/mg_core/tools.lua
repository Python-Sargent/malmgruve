
minetest.register_tool("mg_core:trusty_pick", {
	description = "Trusty Pickaxe",
	inventory_image = "mg_trusty_pick.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			layer = {times={[3]=6.00, [2]=3.00, [1]=1.00}, uses=0},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {pickaxe = 1}
})