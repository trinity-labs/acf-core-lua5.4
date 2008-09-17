--[[
	module for format changes in table,string,files...
	try to keep non input specific
]]--

module (..., package.seeall)

require ("posix")
require ("fs")
require ("session")

-- find all return characters and removes them, may get this from a browser
-- that is why didn't do file specific

function dostounix ( a )
	local data = string.gsub(a, "\r", "")
	return data
end

-- search and remove all blank lines and commented lines in a file or table

function remove_blanks_comments ( path )
	if type(path) == "string" then
		if fs.is_file == "false" then 
		error("Invalid file!") 
		else
		f = fs.read_file_as_array(path)
		end
	elseif type(path) == "table" then
		f = path
	end	
	local lines = {}
	for a,b in ipairs(f) do
	local c = string.match(b, "^$") or string.match(b, "^%#") 
	--this does not take care of lua comments with -- or --[[
	if c == nil then lines[#lines + 1] = b end
	end
-- returns a table to iterate over without the blank or commented lines
return lines
end

--great for search and replace through a file or table.
--string is easy string.gsub(string, find, replace)
--path can be either a file or a table

function search_replace (path, find, replace)
	--would be a string if is a path to a file
	if type(path) == "string" then
		if fs.is_file == "false" then 
		error("Invalid file!") 
		else
		f = fs.read_file_as_array(path)
		end
	elseif type(path) == "table" then
		f = path
	end	
		local lines = {}
		for a,b in ipairs(f) do
		local c = string.gsub(b, find, replace)
		lines[#lines + 1] = c end
		return lines
end

--great for line searches through a file. /etc/conf.d/ ???
--might be looking for more than one thing so will return a table
--will likely want to match whole line entries
--so we change find to include the rest of the line
-- say want all the _OPTS from a file format.search_for_lines ("/etc/conf.d/cron", "OPT")

function search_for_lines (path, find )
	find = "^.*" .. find .. ".*$"
	if type(path) == "string" then
		if fs.is_file == "false" then 
		error("Invalid file!") 
		else
		f = format.remove_blanks_comments(path)
		end
	elseif type(path) == "table" then
		f = path
	end	
	--don't want to match commented out lines
	local lines = {}
	for a,b in ipairs(f) do 
		local c = string.match(b, find)
		lines[#lines +1 ] = c end
	return lines
end

--string format function to cap the beginging of each word. 
function cap_begin_word ( str )
	--first need to do the first word
	local data = string.gsub(str, "^%l", string.upper)
	--word is any space cause no <> regex
	data = string.gsub(data, " %l", string.upper)
	return data
end

--give a table of ipairs and turn it into a string

function ipairs_to_string ( t )
	for a,b in ipairs(t) do 
		if a == 1 then
		d = b
		else
		d = d .. "\n" .. b
		end
	end
	return d
end


-- This code comes from http://lua-users.org/wiki/SplitJoin
-- -- example: format.table_to_string( {"Anna", "Bob", "Charlie", "Dolores"}, ",")
function table_to_string (list, delimiter)
	local len = #(list)
	if len == 0 then 
		return "" 
	end
	local string = list[1]
	for i = 2, len do 
		string = string .. delimiter .. list[i] 
	end
	return string
end

--for cut functionality do something like
--print(format.string_to_table(" ", "This is a test")[2])
--gives you the second field which is .... is

-- This code comes from http://lua-users.org/wiki/SplitJoin
-- example: format.string_to_table( "Anna, Bob, Charlie,Dolores", ",%s*")
function string_to_table ( text, delimiter)
	local list = {}
	local pos = 1
	-- this would result in endless loops
	if string.find("", delimiter, 1) then 
		error("delimiter matches empty string!")
	end
	while 1 do
		local first, last = string.find(text, delimiter, pos)
		if first then -- found?
			table.insert(list, string.sub(text, pos, first-1))
			pos = last+1
		else
			table.insert(list, string.sub(text, pos))
			break
		end
	end
	return list
end

function md5sum_string ( str)
	cmd = "/bin/echo -n " .. str .. "|/usr/bin/md5sum|cut -f 1 -d \" \" "
	f = io.popen(cmd)
	local checksum =  {}
	for line in f:lines() do
		checksum[#checksum + 1] = line
		end
	f:close()
	return checksum[1]
end


-- Takes a str and expands any ${...} constructs with the Lua variable
-- ex: a="foo"; print(expand_bash_syntax_vars("a=${a}) - > "a=foo"

expand_bash_syntax_vars = function ( str )

  local deref = function ( f)
    local v = _G
    for w in string.gfind(f, "[%w_]+") do
      v = v[w]
    end
  return v
  end

  for w in string.gmatch (str, "${[^}]*}" ) do
        local rvar = string.sub(w,3,-2)
        local rval = ( deref(rvar) or "nil" )
        str = string.gsub (str, w, rval)
  end
 return (str)
end


