local discovered = {}

local remove_hud = function(player, id)
    player:hud_remove(id)
end

local discover = function(player, nodename)
    local hud_id = player:hud_add({
        type = "text",
		name = "discovery",
		text = "Discovered: " .. core.registered_nodes[nodename].description,
		position = {x=0.87, y=0.03},
		number = 0xeecc33,
        size={x=2},
		style = 1
    })
    core.after(2, remove_hud, player, hud_id)
    local meta = player:get_meta()
    local key = string.split(nodename, ":")
    key = key[1] .. " " .. key[2]
    meta:set_int(key, 1)
    meta:set_int("kolro", meta:get_int("kolro") + 100)
end

core.register_on_joinplayer(function(player, last_login)
    discovered[player:get_player_name()] = {}
end)

core.register_on_dignode(function(pos, oldnode, digger)
    if mg_core.ores.registered_ores[oldnode.name] ~= nil and digger ~= nil and digger:is_player() then
        local meta = digger:get_meta()
        local key = string.split(oldnode.name, ":")
        key = key[1] .. " " .. key[2]
        if meta:get_int(key) ~= 1 then
            discover(digger, oldnode.name)
        end
    end
end)