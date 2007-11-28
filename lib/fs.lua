--[[
	module for generic filesystem funcs

	Copyright (c) Natanael Copa 2006
        MM edited to use "posix"
]]--

module (..., package.seeall)

require ("posix")

-- generic wrapper funcs
function is_dir ( pathstr )
	return posix.stat ( pathstr, "type" ) == "directory"
end

function is_file ( pathstr )
	return posix.stat ( pathstr, "type" ) == "regular"
end

function is_link ( pathstr )
	return posix.stat ( pathstr, "type" ) == "link"
end


	
-- Returns the contents of a file as a string
function read_file ( path )
	local file = io.open(path)
	if ( file ) then
		local f = file:read("*a")
		file:close()
		return f
	else
		return nil
	end
end

-- Returns an array with the contents of a file, 
-- or nil and the error message
function read_file_as_array ( path )
	local file, error = io.open(path)
	if ( file == nil ) then
		return nil, error
	end
	local f = {}
	for line in file:lines() do 
		table.insert ( f , line )
		--sometimes you will see it like f[#f+1] = line
	end
	file:close()
	return f
end

-- find all return characters and removes them, may get this from a browser
-- that is why didn't do file specific
 
function dostounix ( a )
local data = string.gsub(a, "\r", "")
return data

end

-- read a file without blank lines and commented lines

function remove_blanks_comments ( path )
local f = io.open(path)
local lines = {}
for line in f:lines() do
local c = string.match(line, "^$") or string.match(line, "^%#")
if c == nil then lines[#lines + 1] = line end
end
-- returns a table to iterate over without the blank or commented lines
return lines
end

--will search and replace through the whole of the file and return a table

function search_replace (path , find, replace)
local f = fs.read_file_as_array(path)
local lines = {}
for a,b in ipairs(f) do 
local c = string.gsub(b, find, replace)
lines[#lines + 1] = c end
return lines
end

--will interate over a ipairs(table) and make it into a string to be used by write_file
function ipairs_string ( t )
	for a,b in ipairs(t) do 
	if a == 1 then 
	c = b
	else
	c = c .. "\n" .. b
	end
	end
	--add a friendly \n for EOF
	c = c .. "\n"
	return c
end
	
-- write a string to a file !! MM-will replace file contents

function write_file ( path, str )
	local file = io.open(path, "w")
	if ( file ) then
		file:write(str)
		file:close()
	end
end

-- this could do more than a line. This will append
-- fs.write_line_file ("filename", "Line1 \nLines2 \nLines3")

function write_line_file ( path, str )
	local file = io.open(path)
	if ( file) then
	local c = file:read("*a")
	file:close()
	local d = (c .. "\n" .. str .. "\n")
	-- include a friendly newline for EOF
	fs.write_file(path,d)
	end
end




-- iterator function for finding dir entries matching filespec (what)
-- starting at where, or currentdir if not specified.
-- Finds regexes, not fileglobs
function find ( what, where )
	-- returns an array of files under "where" that match what "f"
	local function find_files_as_array ( f, where, t )
		where = where or posix.getcwd()
		f = f or ".*"
		t =  t or {}
		for d in posix.files ( where ) do
			if fs.is_dir ( where .. "/" ..  d ) and (d ~= ".") and ( d ~= "..") then
				find_files_as_array (f, where .. "/" .. d, t )
			end
			if (string.match (d, "^" .. f .. "$" ))  then
				table.insert (t, ( string.gsub ( where .. "/" .. d, "/+", "/" ) ) )
				end
			end
		return (t)
	end

	--  This is the iterator
	local t = find_files_as_array ( what, where )
	local idx = 0
	return function () 
		idx = idx + 1
		return t[idx]
	end
end

-- This code comes from http://lua-users.org/wiki/SplitJoin
-- -- example: strjoin(", ", {"Anna", "Bob", "Charlie", "Dolores"})
function table_to_string (delimiter, list)
	local len = getn(list)
	if len == 0 then 
		return "" 
	end
	local string = list[1]
	for i = 2, len do 
		string = string .. delimiter .. list[i] 
	end
	return string
end

-- This code comes from http://lua-users.org/wiki/SplitJoin
-- example: strsplit(",%s*", "Anna, Bob, Charlie,Dolores")
function string_to_table (delimiter, text)
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

