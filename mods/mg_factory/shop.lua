
local produce = {}

local ore_prices = {
    ["metal"] = 20,
    ["crystaline"] = 30,
    ["strata"] = 35,
    ["gem"] = 40
}

local level_prices = {
    [0] = 0,
    [1] = 10,
    [2] = 23,
    [3] = 38,
    [4] = 50
}

local rate = 0.9

local refined = 1.2
local sheet = 1.3

for _,v in pairs(mg_core.ores.registered_raw) do
    local price = 1
    price = price + tonumber(ore_prices[v.type])
    price = price + tonumber(level_prices[v.level])
    produce["mg_core:raw_" .. v.name] = {price = price}
    if v.type == "metal" then
        produce["mg_core:" .. v.name .. "_sheet"] = {price = math.round(price*sheet)}
        produce["mg_core:" .. v.name] = {price = math.round(price*refined)}
    elseif v.type == "gem" then
        produce["mg_core:" .. v.name] = {price = math.round(price*refined)}
    end
end

local shop_formspec = function(player, context)
    local player_name = player:get_player_name()
    local meta = player:get_meta()
    local money = meta:get_int("kolro") or "nil"

    local products = ""
    local p = 0
    for k,v in pairs(produce) do
        products = products .. "image[0,"..(p-0.25)..";9.75,1.5;mg_bg.png;]" ..
        "item_image_button[0.2,"..p..";1,1;"..k..";"..k..";]" ..
        "hypertext[1.75,"..(p+0.1)..";5,1;cost;<style color='gold' size='24'><b>"..v.price.." Klo</b></style>]"
        p = p+1.25
    end
    
    return sfinv.make_formspec(player, context, "image[6.5,0;0.5,0.5;mg_kolro.png;]" ..
    "hypertext[7.25,0.1;5,1;kolro;<style color='gold' size='16'><b>"..money.." Klo</b></style>]" ..
    "scroll_container[0,0;8,6;scroll;vertical;]" ..
    "scrollbar[8,0;1,"..p..";vertical;scroll;"..meta:get_int("shop_scroll").."]" ..
    products ..
    "scroll_container_end[]" ..
    "list[current_player;main;0,5;8,1;]"..
    "list[current_player;main;0,6.25;8,3;8]", false)
end

core.register_on_mods_loaded(function()
    sfinv.register_page("store", {
        title = "Store",
        is_in_nav = function(self, player, context)
            return not core.is_creative_enabled(player:get_player_name())
        end,
        get = function(self, player, context)
            return shop_formspec(player, context)
        end,
        on_enter = function(self, player, context)
            sfinv.set_player_inventory_formspec(player, context)
        end,
        on_player_receive_fields = function(self, player, context, fields)
            local meta = player:get_meta()
            local item = nil
            for k,v in pairs(fields) do
                if k ~= "quit"then
                    item = k
                end
            end
            if item ~= nil and item ~= "scroll" then
                core.log(item)
                local prod = produce[item]
                if prod ~= nil and prod.price ~= nil then
                    local price = prod.price
                    if meta:get_int("kolro") >= price then
                        meta:set_int("kolro", meta:get_int("kolro") - price)
                        player:get_inventory():add_item("main", ItemStack(item))
                    end
                end
            end
            if fields.scroll ~= nil then
                meta:set_int("shop_scroll", string.split(fields.scroll, ":")[2])
            end
            sfinv.set_player_inventory_formspec(player, context)
        end
    })

    sfinv.register_page("exchange", {
        title = "Exchange",
        is_in_nav = function(self, player, context)
            return not core.is_creative_enabled(player:get_player_name())
        end,
        get = function(self, player, context)
            return shop_formspec(player, context)
        end,
        on_enter = function(self, player, context)
            sfinv.set_player_inventory_formspec(player, context)
        end,
        on_player_receive_fields = function(self, player, context, fields)
            local meta = player:get_meta()
            local item = nil
            for k,v in pairs(fields) do
                if k ~= "quit"then
                    item = k
                end
            end
            if item ~= nil and item ~= "scroll" then
                core.log(item)
                local prod = produce[item]
                if prod ~= nil and prod.price ~= nil then
                    local price = math.round(prod.price * rate)
                    meta:set_int("kolro", meta:get_int("kolro") + price)
                    player:get_inventory():remove_item("main", ItemStack(item))
                end
            end
            if fields.scroll ~= nil then
                meta:set_int("shop_scroll", string.split(fields.scroll, ":")[2])
            end
            sfinv.set_player_inventory_formspec(player, context)
        end
    })
end)