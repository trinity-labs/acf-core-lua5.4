module (..., package.seeall)
require("fs")

-- Create a new config file entry
-- see function description for setoptsinfile
-- line is the current line for this name:value if it exists
local create_entry = function(search_name, value, to_table, optionvalue, line)
	local oldvalue, comment = "", ""
	if line then
		-- find the old value
		oldvalue = string.match ( line, '^%s*%S+%s*%=%s*(.*)$' ) or ""
		-- split out comment
		if string.find ( oldvalue, '#' ) then
			oldvalue, comment = string.match ( oldvalue, '^(.*)(#.*)$' )
			if comment then
				comment = " " .. string.match ( comment, '^(.*%S)%s*$' )
			else
				comment = ""
			end
		end
		-- remove spaces
		oldvalue = string.match ( oldvalue, '^%s*(.*%S)%s*$' ) or ""
	end

	if to_table == true then
		local table = opts_to_table(oldvalue) or {}
		table[value] = optionvalue
		return search_name .. "=" .. table_to_opts(table) .. comment
	else
		if value then
			return search_name .. "=" .. value .. comment
		else
			return nil
		end
	end
end

-- Search the option string for separate options (-x or --xyz) and put them in a table
opts_to_table = function ( optstring, filter )
	local optsparams
	if optstring then
		local optstr = optstring .. " "
		for o in string.gmatch(optstr, "%-%-?%a+%s+[^-%s]*") do
			local option = string.match(o, "%-%-?%a+")
			if not filter or filter == option then
				if not optsparams then optsparams = {} end
				optsparams[option] = string.match(o, "%S*$")
			end
		end
	end
	return optsparams
end

-- Go through an options table and create the option string
table_to_opts = function ( optsparams )
	local optstring = {}
	for opt,val in pairs(optsparams) do
		if val ~= "" then
			optstring[#optstring + 1] = opt .. " " .. val
		else
			optstring[#optstring + 1] = opt
		end
	end
	return table.concat(optstring, " ")
end

-- Set a name=value pair
-- If search_section is undefined or "", goes in the default section
-- If to_table is false or undefined
-- 	if value is defined we put "search_name=value" into search_section
-- 	if value is undefined, we clear search_name out of search section
-- If to_table is true (and value is defined)
-- 	if optionvalue defined, we add "search_value optionvalue" to the value for search_name in search_section
-- 	if optionvalue undefined, we remove search_value from the value of search_name in search_section
-- Try not to touch anything but the value we're interested in (although will combine multi-line into one)
-- If the search_section is not found, we'll add it at the end of the file
-- If the search_name is not found, we'll add it at the end of the section
function setoptsinfile (file, search_section, search_name, value, to_table, optionvalue)
	if not file or file == "" or not search_name or search_name == "" or (to_table == true and not value) then
		return false, nil, "Invalid input for getopts.setoptsinfile()"
	end
	search_section = search_section or ""
	local conf_file = fs.read_file_as_array ( file )
	local new_conf_file = {}
	local section = ""
	local done = false
	local skip_lines = 0
	for i,l in ipairs(conf_file) do
		if skip_lines>0 then
			skip_lines = skip_lines-1
		else
			-- check if comment line
			if done == false and not string.find ( l, "^%s*#" ) then
				-- first, concat lines
				local j = 1
				while string.find ( l, "\\%s*$" ) and conf_file[i+j] do
					l = string.match ( l, "^(.*)\\%s*$" )  .. " " .. conf_file[i+j]
					j = j+1
				end
				if j>1 then skip_lines = j-1 end
				-- find section name
				local a = string.match ( l, "^%s*%[%s*(%S+)%s*%]" )
				if a then
					-- we reached a new section, if we were in the one we wanted
					-- we have to add in the name:value pair now
					if (search_section == section) then
						new_conf_file[#new_conf_file + 1] = create_entry(search_name, value, to_table, optionvalue, nil)
						done = true
					end
					section = a
				elseif (search_section == section) then
					-- find name
					a = string.match ( l, "^%s*(%S+)%s*=" )
					if a and (search_name == a) then
						-- We found the name, change the value
						l = create_entry(search_name, value, to_table, optionvalue, l)
						done = true
					end
				end
			end
			new_conf_file[#new_conf_file + 1] = l
		end
	end

	if done == false then
		-- we didn't find the section:name, add it now
		if section ~= search_section then
			new_conf_file[#new_conf_file + 1] = '[' .. search_section .. ']'
		end
		new_conf_file[#new_conf_file + 1] = create_entry(search_name, value, to_table, optionvalue, nil)
	end

	fs.write_file(file, table.concat(new_conf_file, '\n'))
	return true, "File '" .. file .. "' has been modified!", nil
end

-- Parse file for name=value pairs, returned in a table
-- If search_section is defined, only report values in matching section
-- If search_name is defined, only report matching name (possibly in multiple sections)
-- If to_table is true, attempt to convert value string to array of options
-- If filter is defined (and table is true), only list option matching filter
function getoptsfromfile (file, search_section, search_name, to_table, filter)
	local opts = nil
	if not (fs.is_file(file)) then return nil end
	local conf_file = fs.read_file_as_array ( file )
	local section = ""
	local skip_lines = 0
	for i,l in ipairs(conf_file) do
		if skip_lines>0 then
			skip_lines = skip_lines-1
		-- check if comment line
		elseif not string.find ( l, "^%s*#" ) then
			-- first, concat lines
			local j = 1
			while string.find ( l, "\\%s*$" ) and conf_file[i+j] do
				l = string.match ( l, "^(.*)\\%s*$" )  .. " " .. conf_file[i+j]
				j = j+1
			end
			if j>1 then skip_lines = j-1 end
			-- find section name
			local a = string.match ( l, "^%s*%[%s*(%S+)%s*%]" )
			if a then
				section = a
			elseif not (search_section) or (search_section == section) then
				-- find name
				a = string.match ( l, "^%s*(%S+)%s*=" )
				if a and (not (search_name) or (search_name == a)) then
					-- Figure out the value
					local b = string.match ( l, '^%s*%S+%s*%=%s*(.*)$' ) or ""
					-- remove comments from end of line
					if string.find ( b, '#' ) then
						b = string.match ( b, '^(.*)#.*$' ) or ""
					end
					-- remove spaces from front and back
					b = string.match ( b, '^%s*(.*%S)%s*$' ) or ""
					-- finally, remove quotes
					if #b > 1 and string.sub(b,1,1) == '"' and string.sub(b,-1) == '"' then
						b = string.sub(b,2,-2) or ""
					end
					if to_table == true then
						local optstable = opts_to_table(b,filter)
						if (optstable) then
							if not (opts) then opts = {} end
							if not (opts[section]) then opts[section] = {} end
							opts[section][a] = optstable
							---[[ Next line is DEBUG info. Should be commented out!
							--opts[a]["debug"] = b
							-- End debug info. --]] 
						end
					else
						if not (opts) then opts = {} end
						if not (opts[section]) then opts[section] = {} end
						opts[section][a] = b
					end
				end
			end
		end
	end

	if opts and search_section and search_name then
		return opts[search_section][search_name]
	elseif opts and search_section then
		return opts[search_section]
	end	
	return opts
end
