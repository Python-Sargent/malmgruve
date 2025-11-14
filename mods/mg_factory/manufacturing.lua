
mg_factory.recipes = {}

mg_factory.register_recipe = function(name, def)
    mg_factory.recipes[name] = def
end

mg_factory.register_recipe("mg_core:iron", {
    type = "single",
    machine = "pressing",
    requires = {"mg_core:iron"},
    result = "mg_core:rolled_iron"
})

mg_factory.register_recipe("mg_core:raw_iron", {
    type = "single",
    machine = "smelting",
    requires = {"mg_core:raw_iron"},
    result = "mg_core:iron"
})

mg_factory.manufacture = function(input, machine)
    local recipe = mg_factory.recipes[input]
    if recipe.type == "single" and recipe.machine == machine then
        return {result = recipe.result, left=recipe.replacements}
    end
end