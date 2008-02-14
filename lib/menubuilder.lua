--[[ parse through the *.menu tables and return a "menu" table
     Written for Alpine Configuration Framework (ACF) -- see www.alpinelinux.org
     Copyright (C) 2007  Nathan Angelacos
     Licensed under the terms of GPL2
  ]]--
module(..., package.seeall)

-- returns a table of the "*.menu" tables 
-- uses the system "find" command
-- startdir should be the app dir.
local get_candidates = function (startdir)
	local t = {}
	startdir = startdir .. "/"
	local fh = io.popen('find ' .. startdir .. ' -name "*.menu"')

	local start = string.gsub(startdir, "/$", "")
	for x in fh:lines() do
		table.insert (t, (string.gsub(x, start, "")))
	end

	return t
end


-- internal function for table.sort
local t_compare = function  (x,y,f)
		for k,v in pairs(f) do
			local a = x[v]  
			local b = y[v] 
			if tonumber(a) and tonumber(b) then
				a=tonumber(a) 
				b=tonumber(b) 
			end
			if a < b then return true end
			if a > b then return false end
		end
		return false
		end

-- Returns a table of all submenu items found
-- Displayorder of the tabs comes from the order in the .menu files
get_submenuitems = function (startdir)
	local t = {}
	local menuitems = get_menuitems(startdir)

	for k,v in pairs(menuitems) do
		if (menuitems[k]["tab"] ~= "") then
			if not (t[menuitems[k]["controller"]]) then t[menuitems[k]["controller"]] = {} end
			table.insert (t[menuitems[k]["controller"]], {tab=menuitems[k]["tab"],action=menuitems[k]["action"]})
		end
	end

	return t
end

-- returns a table of all the menu items found, sorted by priority
-- Table format:   prefix  controller  cat group tab action
get_menuitems = function (startdir)
	local t = {}
	for k,v in pairs(get_candidates(startdir)) do
		local prefix, controller = mvc.dirname(v), mvc.basename(v, ".menu")
		-- open the thing, and parse the contents
		local fh = io.open(startdir .. "/" .. v)
		local prio = 10
		for x in fh:lines() do
			local c = string.match(x, "^#") or string.match(x,"^$")
			if c == nil then
				local item = {}
				for i in string.gmatch(x, "%S+") do
					table.insert(item, i)
				end
				table.insert(t, { prefix=prefix, 
						  controller=controller, 
						  catprio="nan",
						  cat=item[1] or "",
						  groupprio="nan", 
						  group=item[2] or "",
						  tabprio=tostring(prio),
						  tab=item[3] or "",
						  action=item[4] or "" })
				prio=prio+5
			end
		end
		fh:close()	
	end
	-- Ok, we now have the raw menu table 
	-- now try to parse out numbers in front of any cat, group or tabs
	for x in ipairs(t) do
		local f = t[x]
		if (string.match(f.cat, "^%d")) then
			f.catprio, f.cat = string.match(f.cat, "(%d+)(.*)")
		end
		if (string.match(f.group, "^%d")) then
			f.groupprio, f.group = string.match(f.group, "(%d+)(.*)")
		end
		if (string.match(f.tab, "^%d")) then
			f.tabprio, f.tab = string.match(f.tab, "(%d+)(.*)")
		end
	end

	-- Convert underscores to spaces
	for x in ipairs(t) do
		t[x].cat = string.gsub(t[x].cat, "_", " ")
		t[x].group = string.gsub(t[x].group, "_", " ")
		t[x].tab = string.gsub(t[x].tab, "_", " ")
	end

	-- Now alpha sort
	table.sort(t, function(x,y)
		return t_compare (x,y,{"cat", "catprio", "group", "groupprio", "tab", "tabprio"} )
		end)

	-- Fill in the priorities
	local fill_prio = function (t, start, stop, col)
		local prio = t[start][col] 
		if prio == "nan" then prio = "0" end
		while start <= stop do
			t[start][col] = prio
			start = start + 1
		end
	end


-- Fill in the priorities
-- Warning - UGLY code ahead.
-- Basic rules, for each cat and group, if the prio is nan, then set it
-- to the lowest value for that group or cat.  
 	local k = 1
	while ( k <= table.maxn(t) ) do
		local c = k
		while ( c <= table.maxn(t) and t[c].cat == t[k].cat ) do 
			c=c+1 
			end
		c=c-1 -- back up one - we only want whats the same
		fill_prio(t,k,c,"catprio")
		-- from k,c is a mini table, do the same for groupprio
		local g = k
		while ( g <= c ) do
			local h = g
			while ( h <= c and t[h].group == t[g].group ) do
				h=h+1
			end
			h=h-1 --- back up one (again)
			fill_prio(t,g,h,"groupprio")
			g=h+1
		end
		k = c + 1
	end
	
	-- Now priority sort
	table.sort(t, function(x,y)
		return t_compare (x,y,{"catprio", "cat", "groupprio", "group", "tabprio", "tab"} )
		end)


	-- drop the priorities - they were internal
	for k,v in ipairs(t) do
		v.catprio = nil
		v.groupprio = nil
		v.tabprio = nil
	end

	return t
end


