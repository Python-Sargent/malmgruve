[![ContentDB](https://content.luanti.org/packages/SuperStarSonic/malmgruve/shields/downloads/)](https://content.luanti.org/packages/SuperStarSonic/malmgruve/)

<img width="1920" height="1080" alt="manufactory_machines.png" src="https://github.com/user-attachments/assets/468ac9e9-2b0b-4124-9297-f453f644d134" />

# Malmgruve

Malmgruve is a progression mining game made for the 2025 Luanti Game Jam. It focuses on realistic (and mostly accurate) geology. You can build machines, sell ores and create infrastructure.

## Features:
* Geologic levels and rock types
* Ore progression and generation
* Transport carts and railways
* A basic Economy
* The abilty to buy/sell stuff
* Mining utilities such as explosives
* Machine tiers including Mechanical, Steam and Nuclear
* Manufacturing machines including:
  * Refineries
  * Presses
  * Assembly Machines

See license for info on features adapted/inspired by other content. A basic list includes (all of which are from Minetest Game):

* Modified Player API
* Modified SFINV
* Explosives inspired by TNT
* Heavily Modified Carts
* Modified Creative (renamed to Mapmaker)

Other code that is borrowed/inspired and not required under license requirements is marked in the file generally.

*This section adapted from the ContentDB Description.*

## How to Play

The following is adapted from the in-game Guide.

#### MACHINE TIERS
There are three levels or tiers of machines, each with three machines:
* Mechanical
  * Roller Press: rolls refined metals into sheets
  * Ball Mill: crushes and refines raw materials
  * Crank: hand-cranked mechanical battery (punch to crank)
* Steam
  * Steam Press: presses refined metals into sheets
  * Blast Furnace: smelts and refines raw materials
  * Steam Engine: burns coal to generate power
* Nuclear
  * Compression Chamber: presses refined metals into sheets
  * Centrifuge: seperates and refines raw materials
  * And a Nuclear Reactor that fuses Refined Uranium with Nickel as the control

#### MANUFACTURING
Recipes for manufacturing these machines and materials\nare provided in the Recipes tab of your inventory.
There are three symbols to denote pressing, refining, and manufacturing.
Machines and materials may also be bought from the Store tab

#### EXCHANGE
Materials, machines, and utilities may be bought and sold, this is done from the store and exchange tabs in your inventory. The exchange rate for items is 0.9, meaning you will get 0.9 the amount it costs when you sell it.

#### GEOLOGIC LEVELS
There are 4 rock levels, with a soil level above (which is the surface). In each rock level there are a number of ores.
The levels are:
* Topsoil (Sand), Subsoil (Soil)
  * Contains no ores
* Surface (Limestone)
  * Aluminum (starts -20)
  * Iron (-80)
  * Azurite (-100)
  * Opal (-120)
  * Manganese (-140)
  * Halite (-160)
  * Coal (-170)
  * Emerald (-190)
* Subsurface (Granite)
  * Lead (-250)
  * Copper (-270)
  * Cinnabar (-310)
  * Topaz (-350)
  * Argentite (-370)
  * Bornite (-430)
  * Tourmaline (-460)
* Crust (Quartz)
  * Molybdenite (-500)
  * Tungsten (-590)
  * Nickel (-600)
  * Ruby (-650)
  * Cobalt (-700)
  * Gold (-810)
  * Sapphire (-900)
* Mantle (Peridotite)
  * Chromium (-1000)
  * Uranium (-1100)
  * Platinum (-1200)
  * Diamond (-1300)
  * Graphite (-1400)
  * Olivine (-1500)

#### CARTS AND RAILS
Carts can carry up to one stack of raw ore. Rightclick a cart with your stack of ore to fill it. To empty it, rightclick with an empty hand. The cart can be removed by shift-punching. Carts can be pushed by punching if they are still, or stopped by punching if they are moving. Rails will automatically place, but the algorithm is fairly basic. To place a straight, place it in the same direction on the end of a straight. To place a slope, place the rail above or below another rail. The rail will curve if placed perpendicular to a rail at it's end.

#### INVENTORY

Bags will expand the inventory to the default size when equipped in the bag slot. You can buy them from the store in your inventory.
