local modpath = core.get_modpath("mg_core")

mg_core = {}

mg_core.ores = {}

dofile(modpath .. "/player.lua")
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/ores.lua")
dofile(modpath .. "/discovery.lua")
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

core.register_on_generated(function(minp, maxp, _)
    core.fix_light(minp, maxp)
end)