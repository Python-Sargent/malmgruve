
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

produce["mg_mining:dynamite"] = {price=500}

produce["mg_factory:roller"] = {price=115+100}
produce["mg_factory:mill"] = {price=110+100}
produce["mg_factory:crank"] = {price=120+100}
produce["mg_factory:manufacturer"] = {price=127+103} -- base sale-equalized price + manufactured offset factor

produce["mg_carts:cart"] = {price=171+104}
produce["mg_carts:rail_straight"] = {price=82+103}

produce["mg_core:bag"] = {price=10000}
produce["mg_core:brick"] = {price=20}

for k,v in pairs(mg_core.ores.levels) do
    produce[v.node .. " 99"] = {price=level_prices[k]}
end

local keys = {}
for k in pairs(produce) do
    table.insert(keys, k)
end
table.sort(keys)

local shop_formspec = function(player, context, selling)
    local player_name = player:get_player_name()
    local meta = player:get_meta()
    local money = meta:get_int("kolro") or "nil"
    local cost_desc = ""
    if selling == true then
        cost_desc = "Sell for "
    else
        cost_desc = "Buy for "
    end

    local products = ""
    local p = 0

    local filter = meta:get_string("shop_filter")
    for _, key in ipairs(keys) do
        local name = key:match(":(.*)")
        if name and string.find(name, filter) then
            local v = produce[key]

            local price = v.price
            if selling == true then
                price = math.round(v.price * rate)
            end
            products = products .. "image[0,"..(p-0.25)..";5.75,1.5;mg_bg.png;]" ..
            "item_image_button[0.2,"..p..";1,1;"..key..";"..key..";]" ..
            "hypertext[1.5,"..(p+0.25)..";5,1;cost;<style color='gold' size='24' font='mono'><style color='yellow'>"..cost_desc.."</style><b>"..price.." Kolro</b></style>]"
            p = p+1.25
        end
    end
    
    return sfinv.make_formspec(player, context, "image[6.5,0;0.5,0.5;mg_kolro.png;]" ..
    "hypertext[7.25,0.1;5,1;kolro;<style color='gold' size='16'><b>"..money.." Klo</b></style>]" ..
    "field[5,4.25;3.5,1;filter;Search;"..meta:get_string("shop_filter").."]" ..
    "field_close_on_enter[filter;false]" ..
    "scroll_container[0,0;8.5,6;scroll;vertical;0.2]" ..
    "scrollbar[8,0;1,"..p..";vertical;scroll;"..meta:get_int("shop_scroll").."]" ..
    products ..
    "scroll_container_end[]" ..
    "list[current_player;main;0,5;8,1;]"..
    "list[current_player;main;0,6.25;8,3;8]", false)
end

local handle_fields = function(player, fields, item_action)
    local meta = player:get_meta()
    local item = nil
    for k,v in pairs(fields) do
        if k ~= "quit" and k ~= "scroll" then
            item = k
        end
    end
    if item ~= nil then
        --core.log(item)
        local prod = produce[item]
        if prod ~= nil and prod.price ~= nil then
            item_action(meta, prod, item)
        end
    end
    if fields.scroll ~= nil then
        meta:set_int("shop_scroll", string.split(fields.scroll, ":")[2])
    end
    if fields.filter ~= nil then
        meta:set_string("shop_filter", fields.filter)
    end
    if fields.quit then
        meta:set_int("shop_scroll", 0)
        meta:set_string("shop_filter", "")
    end
end

core.register_on_mods_loaded(function()
    sfinv.register_page("store", {
        title = "Store",
        is_in_nav = function(self, player, context)
            return not core.is_creative_enabled(player:get_player_name())
        end,
        get = function(self, player, context)
            return shop_formspec(player, context, false)
        end,
        on_enter = function(self, player, context)
            sfinv.set_player_inventory_formspec(player, context)
        end,
        on_player_receive_fields = function(self, player, context, fields)
            handle_fields(player, fields, function(meta, prod, item)
                local price = prod.price
                if meta:get_int("kolro") >= price then
                    meta:set_int("kolro", meta:get_int("kolro") - price)
                    player:get_inventory():add_item("main", ItemStack(item))
                end
            end)
            sfinv.set_player_inventory_formspec(player, context)
        end
    })

    sfinv.register_page("exchange", {
        title = "Exchange",
        is_in_nav = function(self, player, context)
            return not core.is_creative_enabled(player:get_player_name())
        end,
        get = function(self, player, context)
            return shop_formspec(player, context, true)
        end,
        on_enter = function(self, player, context)
            sfinv.set_player_inventory_formspec(player, context)
        end,
        on_player_receive_fields = function(self, player, context, fields)
            handle_fields(player, fields, function(meta, prod, item)
                local price = math.round(prod.price * rate)
                if player:get_inventory():contains_item("main", ItemStack(item)) then
                    meta:set_int("kolro", meta:get_int("kolro") + price)
                    player:get_inventory():remove_item("main", ItemStack(item))
                end
            end)
            sfinv.set_player_inventory_formspec(player, context)
        end
    })
end)