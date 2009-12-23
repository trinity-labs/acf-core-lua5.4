--[[ parse through the *.menu tables and return a "menu" table
     Written for Alpine Configuration Framework (ACF) -- see www.alpinelinux.org
     Copyright (C) 2007  Nathan Angelacos
     Licensed under the terms of GPL2
  ]]--
module(..., package.seeall)

require("format")

-- returns a table of the "*.menu" tables 
-- startdir should be the app dir.
local get_candidates = function (startdir)
	return fs.find_files_as_array(".*%.menu", startdir, true)
end

-- Split string into priority and name, convert '_' to space
local parse_menu_entry = function (entry)
	local name, priority
	if (string.match(entry, "^%d")) then
		priority, name = string.match(entry, "(%d+)(.*)")
	else
		name = entry
	end
	name = string.gsub(name, "_", " ")
	return name, priority
end

-- Parse menu file entry, returning cat, group, tab, action and priorities
local parse_menu_line = function (line)
	local result = nil
	--skip comments and blank lines
	if nil == (string.match(line, "^#") or string.match(line,"^$")) then
		local item = {}
		for i in string.gmatch(line, "%S+") do
			item[#item + 1] = i
		end
		if #item >= 1 then
			result = {}
			result.cat, result.cat_prio = parse_menu_entry(item[1])
			if (item[2]) then result.group, result.group_prio = parse_menu_entry(item[2]) end
			if (item[3]) then result.tab = parse_menu_entry(item[3]) end
			if (item[4]) then result.action = parse_menu_entry(item[4]) end
		end
	end
	return result
end

-- Function to compare priorities, missing priority moves to the front, same priority sorted alphabetically
local prio_compare = function(x,y)
	if x.priority == y.priority then
		if x.name < y.name then return true end
		return false
	end
	if nil == x.priority then return true end
	if nil == y.priority then return false end
	if tonumber(x.priority) < tonumber(y.priority) then return true end
	return false
end

-- returns a table of all the menu items found, sorted by priority
get_menuitems = function (startdir)
	local cats = {}
	local reversecats = {}
	startdir = (string.gsub(startdir, "/$", ""))	--remove trailing /
	for k,filename in pairs(get_candidates(startdir)) do
		local controller = mvc.basename(filename, ".menu")
		local prefix = (string.gsub(mvc.dirname(filename), startdir, "")).."/"

		-- open the menu file, and parse the contents
		local handle = io.open(filename)
		for x in handle:lines() do
			local result = parse_menu_line(x)
			if result then
				for i = 1,1 do	-- loop so break works
				-- Add the category
				if nil == reversecats[result.cat] then
					table.insert ( cats, 
						{ name=result.cat, 
						groups = {}, 
						reversegroups = {} } )
					reversecats[result.cat] = #cats
				end
				local cat = cats[reversecats[result.cat]]
				cat.priority = cat.priority or result.cat_prio
				-- Add the group
				if nil == result.group then break end
				if nil == cat.groups[cat.reversegroups[result.group]] then
					table.insert ( cat.groups,
						{ name = result.group,
						controllers = {},
						tabs = {} } )
					cat.reversegroups[result.group] = #cat.groups
				end
				cat.groups[cat.reversegroups[result.group]].controllers[prefix..controller] = true
				local group = cat.groups[cat.reversegroups[result.group]]
				group.priority = group.priority or result.group_prio
				-- Add the tab
				if nil == result.tab or nil == result.action then break end
				local tab = { name = result.tab,
						controller = controller,
						prefix = prefix,
						action = result.action }
				table.insert(group.tabs, tab)
				end
			end
		end
		handle:close()
	end

	-- Now that we have the entire menu, sort by priority
	-- Categories first
	table.sort(cats, prio_compare)

	-- Then groups
	for x, cat in ipairs(cats) do
		cat.reversegroups = nil	-- don't need reverse table anymore
		table.sort(cat.groups, prio_compare)
	end

	return cats
end


