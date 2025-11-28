
core.register_on_mods_loaded(function()
    mg_sfinv.register_page("guide", {
        title = "Guide",
        is_in_nav = function(self, player, context)
            return not core.is_creative_enabled(player:get_player_name())
        end,
        get = function(self, player, context)
            local player_name = player:get_player_name()
    
            local ct = { "<big>Malmgruve Manufactory</big>",
                "The Manufactory in Malmgruve is an import system of infrastructure.",
                "With it you can process materials and manufacture machines and utilities.",
                "",
                "<style size='18'><b>CONTENTS</b>",
                "1 Machine Tiers\n2 Manufacturing\n3 Exchange\n4 Geologic Levels\n5 Carts and Rails",
                "</style>",
                "<style size='18'><b>MACHINE TIERS</b></style>",
                "There are three levels or tiers of machines, each with three machines:", 
                "The first tier is the Mechanical tier which has:",
                "* A Roller Press which rolls refined metals into sheets",
                "* A Ball Mill that crushes and refines raw materials",
                "* And a hand-cranked mechanical battery (punch to crank)",
                "",
                "The second tier, which is the Steam power tier has these machines:",
                "* A Steam Press which presses refined metals into sheets",
                "* A Blast Furnace that smelts and refines raw materials",
                "* And a Steam Engine that burns coal to provide power",
                "",
                "The third and final tier is the Nuclear tier which provides: ",
                "* A Compression Chamber which presses refined metals into sheets",
                "* A Centrifuge which seperates and refines raw materials",
                "* And a Nuclear Reactor that fuses Refined Uranium with Nickel as the control",
                "",
                "<style size='18'><b>MANUFACTURING</b></style>",
                "Recipes for manufacturing these machines and materials\nare provided in the Recipes tab of your inventory.",
                "There are three symbols to denote pressing, refining, and manufacturing.",
                "Machines and materials may also be bought from the Store tab",
                "",
                "<style size='18'><b>EXCHANGE</b></style>",
                "Materials, machines, and utilities may be bought and sold,\nthis is done from the store and exchange tabs in your inventory.",
                "The exchange rate for items is 0.9,\nmeaning you will get 0.9 the amount it costs when you sell it.",
                "",
                "<style size='18'><b>GEOLOGIC LEVELS</b></style>",
                "There are 4 rock levels, with a soil level above (which is the surface).",
                "In each rock level there are a number of ores.",
                "The levels are:<style font='mono'>",
                "Topsoil (Sand), Subsoil (Soil)",
                "* Contains no ores",
                "",
                "Surface (Limestone)",
                "* Aluminum (starts -20)",
                "* Iron (-80)",
                "* Azurite (-100)",
                "* Opal (-120)",
                "* Manganese (-140)",
                "* Halite (-160)",
                "* Coal (-170)",
                "* Emerald (-190)",
                "",
                "Subsurface (Granite)",
                "* Lead (-250)",
                "* Copper (-270)",
                "* Cinnabar (-310)",
                "* Topaz (-350)",
                "* Argentite (-370)",
                "* Bornite (-430)",
                "* Tourmaline (-460)",
                "",
                "Crust (Quartz)",
                "* Molybdenite (-500)",
                "* Tungsten (-590)",
                "* Nickel (-600)",
                "* Ruby (-650)",
                "* Cobalt (-700)",
                "* Gold (-810)",
                "* Sapphire (-900)",
                "",
                "Mantle (Peridotite)",
                "* Chromium (-1000)",
                "* Platinum (-1100)",
                "* Diamond (-1200)",
                "* Graphite (-1400)",
                "* Olivine (-1500)",
                "</style>",
                "<style size='18'><b>CARTS AND RAILS</b></style>",
                "Carts can carry up to one stack of raw ore.",
                "Rightclick a cart with your stack of ore to fill it",
                "To empty it, rightclick with an empty hand",
                "The cart can be removed by shift-punching",
                "Carts can be pushed by punching if they are still,",
                "or stopped by punching if they are moving.",
                "Rails will automatically place, but the algorithm is very basic",
                "To place a straight, place it in the same direction on the end of a straight.",
                "To place a slope, place the rail above or below another rail",
                "The rail will curve if placed perpendicular to a rail at it's end."
            }

            local content = ""
            local n = 0
            for _,v in pairs(ct) do
                n=n+1
                content = content .. v .. "\n"
            end

            return mg_sfinv.make_formspec(player, context, "scroll_container[0,0;10,11;scroll;vertical;]" ..
            "hypertext[0.5,0;10,"..n..";content;"..content.."]" ..
            "scrollbar[-1,0;0,0;vertical;scroll;]" ..
            "scroll_container_end[]", false)
        end,
        on_enter = function(self, player, context)
    
        end,
        on_player_receive_fields = function(self, player, context, fields)
            
        end
    })
end)