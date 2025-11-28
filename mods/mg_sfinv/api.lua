mg_sfinv = {
	pages = {},
	pages_unordered = {},
	contexts = {},
	enabled = true
}

function mg_sfinv.register_page(name, def)
	assert(name, "Invalid mg_sfinv page. Requires a name")
	assert(def, "Invalid mg_sfinv page. Requires a def[inition] table")
	assert(def.get, "Invalid mg_sfinv page. Def requires a get function.")
	assert(not mg_sfinv.pages[name], "Attempt to register already registered mg_sfinv page " .. dump(name))

	mg_sfinv.pages[name] = def
	def.name = name
	table.insert(mg_sfinv.pages_unordered, def)
end

function mg_sfinv.override_page(name, def)
	assert(name, "Invalid mg_sfinv page override. Requires a name")
	assert(def, "Invalid mg_sfinv page override. Requires a def[inition] table")
	local page = mg_sfinv.pages[name]
	assert(page, "Attempt to override mg_sfinv page " .. dump(name) .. " which does not exist.")
	for key, value in pairs(def) do
		page[key] = value
	end
end

function mg_sfinv.get_nav_fs(player, context, nav, current_idx)
	-- Only show tabs if there is more than one page
	if #nav > 1 then
		return "tabheader[0,0;mg_sfinv_nav_tabs;" .. table.concat(nav, ",") ..
				";" .. current_idx .. ";true;false]"
	else
		return ""
	end
end

mg_sfinv.theme_inv = [[
		image[0,5.2;1,1;gui_hb_bg.png]
		image[1,5.2;1,1;gui_hb_bg.png]
		image[2,5.2;1,1;gui_hb_bg.png]
		image[3,5.2;1,1;gui_hb_bg.png]
		image[4,5.2;1,1;gui_hb_bg.png]
		image[5,5.2;1,1;gui_hb_bg.png]
		image[6,5.2;1,1;gui_hb_bg.png]
		image[7,5.2;1,1;gui_hb_bg.png]
		list[current_player;main;0,5.2;8,1;]
	]] --list[current_player;main;0,6.35;8,3;8]

function mg_sfinv.make_formspec(player, context, content, show_inv, size)
	local tmp = {
		size or "size[8,9.1]",
		"formspec_version[10]",
		mg_sfinv.get_nav_fs(player, context, context.nav_titles, context.nav_idx),
		show_inv and mg_sfinv.theme_inv or "",
		content
	}
	return table.concat(tmp, "")
end

function mg_sfinv.get_homepage_name(player)
	return "mg_sfinv:bag"
end

function mg_sfinv.get_formspec(player, context)
	-- Generate navigation tabs
	local nav = {}
	local nav_ids = {}
	local current_idx = 1
	for i, pdef in pairs(mg_sfinv.pages_unordered) do
		if not pdef.is_in_nav or pdef:is_in_nav(player, context) then
			nav[#nav + 1] = pdef.title
			nav_ids[#nav_ids + 1] = pdef.name
			if pdef.name == context.page then
				current_idx = #nav_ids
			end
		end
	end
	context.nav = nav_ids
	context.nav_titles = nav
	context.nav_idx = current_idx

	-- Generate formspec
	local page = mg_sfinv.pages[context.page] or mg_sfinv.pages["404"]
	if page then
		return page:get(player, context)
	else
		local old_page = context.page
		local home_page = mg_sfinv.get_homepage_name(player)

		if old_page == home_page then
			minetest.log("error", "[mg_sfinv] Couldn't find " .. dump(old_page) ..
					", which is also the old page")

			return ""
		end

		context.page = home_page
		assert(mg_sfinv.pages[context.page], "[mg_sfinv] Invalid homepage")
		minetest.log("warning", "[mg_sfinv] Couldn't find " .. dump(old_page) ..
				" so switching to homepage")

		return mg_sfinv.get_formspec(player, context)
	end
end

function mg_sfinv.get_or_create_context(player)
	local name = player:get_player_name()
	local context = mg_sfinv.contexts[name]
	if not context then
		context = {
			page = mg_sfinv.get_homepage_name(player)
		}
		mg_sfinv.contexts[name] = context
	end
	return context
end

function mg_sfinv.set_context(player, context)
	mg_sfinv.contexts[player:get_player_name()] = context
end

function mg_sfinv.set_player_inventory_formspec(player, context)
	local fs = mg_sfinv.get_formspec(player,
			context or mg_sfinv.get_or_create_context(player))
	player:set_inventory_formspec(fs)
end

function mg_sfinv.set_page(player, pagename)
	local context = mg_sfinv.get_or_create_context(player)
	local oldpage = mg_sfinv.pages[context.page]
	if oldpage and oldpage.on_leave then
		oldpage:on_leave(player, context)
	end
	context.page = pagename
	local page = mg_sfinv.pages[pagename]
	if page.on_enter then
		page:on_enter(player, context)
	end
	mg_sfinv.set_player_inventory_formspec(player, context)
end

function mg_sfinv.get_page(player)
	local context = mg_sfinv.contexts[player:get_player_name()]
	return context and context.page or mg_sfinv.get_homepage_name(player)
end

minetest.register_on_joinplayer(function(player)
	if mg_sfinv.enabled then
		mg_sfinv.set_player_inventory_formspec(player)
	end
end)

minetest.register_on_leaveplayer(function(player)
	mg_sfinv.contexts[player:get_player_name()] = nil
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "" or not mg_sfinv.enabled then
		return false
	end

	-- Get Context
	local name = player:get_player_name()
	local context = mg_sfinv.contexts[name]
	if not context then
		mg_sfinv.set_player_inventory_formspec(player)
		return false
	end

	-- Was a tab selected?
	if fields.mg_sfinv_nav_tabs and context.nav then
		local tid = tonumber(fields.mg_sfinv_nav_tabs)
		if tid and tid > 0 then
			local id = context.nav[tid]
			local page = mg_sfinv.pages[id]
			if id and page then
				mg_sfinv.set_page(player, id)
			end
		end
	else
		-- Pass event to page
		local page = mg_sfinv.pages[context.page]
		if page and page.on_player_receive_fields then
			return page:on_player_receive_fields(player, context, fields)
		end
	end
end)
