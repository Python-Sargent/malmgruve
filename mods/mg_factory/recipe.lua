local sm = {
    ["pressing"] = "mg_press.png",
    ["refining"] = "mg_refinery.png",
    ["manufacturing"] = "mg_factory.png"
}

core.register_on_mods_loaded(function()
    sfinv.register_page("recipes", {
        title = "Recipes",
        is_in_nav = function(self, player, context)
            return not core.is_creative_enabled(player:get_player_name())
        end,
        get = function(self, player, context)
            local player_name = player:get_player_name()
    
            local recipes = ""
            local n = 0
            for _,v in pairs(mg_factory.recipes) do
                if v.type == "single" then
                    n = n+2
                    --if v.result == "" then core.log("empty recipe result") end
                    --if v.requires[1] == "" then core.log("empty recipe requirement") end
                    --core.log(v.result)
                    recipes = recipes ..
                    "image[0,"..(n-0.25)..";9.75,1.5;mg_bg.png;]" ..
                    "item_image[1,"..n..";1,1;" .. v.requires[1] .. "]" ..
                    "image[3,"..n..";1,1;"..sm[v.machine]..";]" ..
                    "item_image[5,"..n..";1,1;" .. v.result .. "]" ..
                    "tooltip[1,"..n..";1,1;"..v.requires[1]..";blue;white]" ..
                    "tooltip[3,"..n..";1,1;"..v.machine..";blue;white]" ..
                    "tooltip[5,"..n..";1,1;"..v.result..";blue;white]"
                elseif v.type == "specific" then
                    n = n+2
                    local requires = ""
                    local r = 0.5
                    for _,t in pairs(v.requires) do
                        requires = requires .. "item_image["..r..","..n..";1,1;" .. t .. "]" ..
                        "tooltip["..r..","..n..";1,1;"..t..";blue;white]"
                        r = r+1
                    end
                    recipes = recipes ..
                    "image[0,"..(n-0.25)..";9.75,1.5;mg_bg.png;]" ..
                    requires ..
                    "image[3,"..n..";1,1;"..sm[v.machine]..";]" ..
                    "item_image[5,"..n..";1,1;" .. v.result .. "]" ..
                    "tooltip[3,"..n..";1,1;"..v.machine..";blue;white]" ..
                    "tooltip[5,"..n..";1,1;"..v.result..";blue;white]"
                end
            end
    
            return sfinv.make_formspec(player, context, "scroll_container[0,-2;10.25,"..n..";scroll;vertical;]" ..
            recipes ..
            "scrollbar[10.25,-2;0.25,"..n..";vertical;scroll;]" ..
            "scroll_container_end[]", false)
        end,
        on_enter = function(self, player, context)
    
        end,
        on_player_receive_fields = function(self, player, context, fields)
            
        end
    })
end)