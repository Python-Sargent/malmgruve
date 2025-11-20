
core.register_craftitem("mg_core:bag", {
    description = "Bag",
    inventory_image = "mg_bag_inv.png"
})

local bag_entity = {
	initial_properties = {
		physical = false,
		--collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		--selectionbox = {-9/16, -0.5, -15/16, 9/16, 0.5, 15/16, rotate=true},
		visual = "mesh",
		mesh = "mg_bag.glb",
		visual_size = {x=10, y=10},
		textures = {"mg_bag.png"},
        static_save = false,
	},
}

core.register_entity("mg_core:bag", bag_entity)

--[[
core.register_on_leaveplayer(function(player, timed_out)
    local attached = player:get_children()
    for _,v in pairs(attached) do
        if v:get_entity_name() == "mg_core:bag" then
            v:set_detach() -- don't know if the object has to be detached before removal, but just to be safe
            v:remove()
        end
    end
end)
]]