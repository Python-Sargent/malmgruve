
mg_factory.recipes = {}

mg_factory.register_recipe = function(name, def)
    mg_factory.recipes[name] = def
end

for _, v in pairs(mg_core.ores.registered_raw) do
    if v.type == "metal" then
        mg_factory.register_recipe("mg_core:" .. v.name, {
            type = "single",
            amount = 1,
            machine = "pressing",
            requires = {"mg_core:" .. v.name},
            result = "mg_core:" .. v.name .. "_sheet"
        })
    end
end

for _, v in pairs(mg_core.ores.registered_raw) do
    if v.type == "metal" then
        mg_factory.register_recipe("mg_core:raw_" .. v.name, {
            type = "single",
            amount = 1,
            machine = "refining",
            requires = {"mg_core:raw_" .. v.name},
            result = "mg_core:" .. v.name
        })
    end
end

-- Cart Items

mg_factory.register_recipe("mg_carts:cart", {
    type = "specific",
    amount = 1,
    machine = "manufacturing",
    requires = {"mg_core:iron 2", "mg_core:iron_sheet 2"},
    result = "mg_carts:cart"
})

mg_factory.register_recipe("mg_carts:rail_straight", {
    type = "specific",
    amount = 4,
    machine = "manufacturing",
    requires = {"mg_core:iron 2"},
    result = "mg_carts:rail_straight"
})

-- Manufactory Machines

mg_factory.register_recipe("mg_factory:compressor", {
    type = "specific",
    amount = 1,
    machine = "manufacturing",
    requires = {"mg_core:lead 2", "mg_core:iron_sheet 2"},
    result = "mg_factory:compressor"
})

mg_factory.register_recipe("mg_factory:engine", {
    type = "specific",
    amount = 1,
    machine = "manufacturing",
    requires = {"mg_core:copper_sheet 2", "mg_core:cinnabar"},
    result = "mg_factory:engine"
})

mg_factory.register_recipe("mg_factory:furnace", {
    type = "specific",
    amount = 1,
    machine = "manufacturing",
    requires = {"mg_core:copper 2", "mg_core:bornite"},
    result = "mg_factory:furnace"
})

mg_factory.register_recipe("mg_factory:manufacturer", {
    type = "specific",
    amount = 1,
    machine = "manufacturing",
    requires = {"mg_core:aluminum 2", "mg_core:iron_sheet"},
    result = "mg_factory:manufacturer"
})

--[[
mg_factory.register_recipe("mg_core:iron", {
    type = "single",
    amount = 1,
    machine = "pressing",
    requires = {"mg_core:iron"},
    result = "mg_core:rolled_iron"
})

mg_factory.register_recipe("mg_core:raw_iron", {
    type = "single",
    amount = 1,
    machine = "refining",
    requires = {"mg_core:raw_iron"},
    result = "mg_core:iron"
})
]]

mg_factory.manufacture = function(input, machine)
    local recipe = mg_factory.recipes[input]
    if recipe ~= nil and recipe.machine == machine then
        if recipe.type == "single" then
            return {result = recipe.result, amount = recipe.amount, left = recipe.replacements}
        elseif recipe.type == "specific" then
            return {result = recipe.result, amount = recipe.amount, left = recipe.replacements, requires=recipe.requires}
        end
    end
end