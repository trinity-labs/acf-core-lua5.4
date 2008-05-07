module (..., package.seeall)
require("fs")

-- Search the option string for separate options (-x or --xyz) and put them in a table
local opts_to_table = function ( optstring, filter )
	local optsparams
	if optstring then
		local optstr = " " .. optstring .. " "
		for o in string.gmatch(optstr, "%s%-%-?%a+%s+%a*") do
			local option = string.match(o, "%-%-?%a+")
			if not filter or filter == option then
				if not optsparams then optsparams = {} end
				optsparams[option] = string.match(o, "%a*$")
			end
		end
	end
	return optsparams
end

function setoptsinfile (file, search, option, value)
	local opts = {}
	local newfilecontent = nil
	local filecontent = nil
	opts = getoptsfromfile(file) or {}
	filecontent = fs.read_file(file) or ""
	if (filecontent == "") or (opts[search] == "") or (opts[search] == nil) then
		opts[search] = {}
	end
	if not (search) or not (option) then 
		return fales, nil, "Systeminformation - Invalid usage of function getopts.setoptsinfile()"
	end

	--Change to new value
	opts[search][option] = value

	local optstr = ""
	for k,v in pairs(opts) do
		if (k == search) then
			optstr = optstr.. k .. "=\""
			for kk,vv in pairs(v) do
				optstr = optstr .. kk .. " " .. vv .. " "
			end
			optstr = string.match(optstr, "(.-)%s*$") .. "\""
		end
	end

	newfilecontent = string.gsub(filecontent, "%s*[;#]?" .. search .. "%s*=.-\n?$", "\n" .. optstr .. "\n") or ""
	if (string.find(newfilecontent, search .. "%s*=" ) == nil) or (newfilecontent == "") then
		fs.write_file(file,string.match(filecontent, "(.-)\n*$") .. "\n" .. optstr .. "\n")
	else
		fs.write_file(file,string.match(newfilecontent, "(.-)\n*$"))
	end
	return true, "File '" .. file .. "' has been modifyed!", nil
end

-- Parse file for options returned in a table
-- If search_section is defined, only report options in matching section
-- If search_option is defined, only report matching options
-- If to_table is true, attempt to convert option string to array of options
-- If filter is defined (and table is true), only list option matching filter
function getoptsfromfile (file, search_section, search_option, to_table, filter)
	local opts = nil
	if not (fs.is_file(file)) then return nil end
	local conf_file = fs.read_file_as_array ( file )
	local section = ""
	for i,l in ipairs(conf_file) do
		-- check if comment line
		if not string.find ( l, "^%s*#" ) then
			-- first, concat lines
			local j = 1
			while string.find ( l, "\\%s*$" ) and conf_file[i+j] do
				l = string.match ( l, "^(.*)\\%s*$" )  .. " " .. conf_file[i+j]
				j = j+1
			end
			-- find section name
			local a = string.match ( l, "^%s*%[%s*(%S+)%s*%]" )
			if a then
				section = a
			elseif not (search_section) or (search_section == section) then
				-- find option name
				a = string.match ( l, "^%s*(%S+)%s*=" )
				if a and (not (search_option) or (search_option == a)) then
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

	if opts and search_section and search_option then
		return opts[search_section][search_option]
	elseif opts and search_section then
		return opts[search_section]
	end	
	return opts
end
