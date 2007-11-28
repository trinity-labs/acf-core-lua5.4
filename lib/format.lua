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

-- search and remove all blank lines and commented lines in a file

function remove_blanks_comments ( path )
f = fs.read_file_as_array(path)
local lines = {}
for _,line in pairs(f) do
local c = string.match(line, "^$") or string.match(line, "^%#")
if c == nil then lines[#lines + 1] = line end
end
-- returns a table to iterate over without the blank or commented lines
return lines
end

function cap_begin_word ( a )
	--first need to do the first word
	local data = string.gsub(a, "^%l", string.upper)
	--word is any space cause no <> regex
	data = string.gsub(data, " %l", string.upper)
	return data
end


-- This code comes from http://lua-users.org/wiki/SplitJoin
-- -- example: format.table_to_string(", ", {"Anna", "Bob", "Charlie", "Dolores"})
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
-- example: format.string_to_table(",%s*", "Anna, Bob, Charlie,Dolores")
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

--these maybe moved to html or something like that

-- give a cfe and get back a string of what is inside
function cfe_unpack ( a )
	if type(a) == "table" then 
	value = session.serialize("cfe", a)
	return value
	end

end

-- going to build more cfe to html functions below is just seeing what needed to be
-- done for a test

--give a lua table and unpack as html table
--t = { {row1}, {row2} ,options= {border = 2,align="left" } }
-- row one could technically be a title for the table ??? or t.title 
function table_unpack_html ( t )
	--first need the options
	if t.options ~= nil then
	for a,b in pairs(t.options) do
	if opt == nil then opt = a .. "=" .. "\"" .. b .. "\""  else
	opt = opt .. " " .. a .. "=" .. "\"" .. b .. "\"" end
	
	end
	html_table = "<table " .. opt .. ">"
	else
	html_table = "<table>"
	end
	
	for i = 1,table.maxn(t) do
	html_table = html_table .. "<tr>"
	for a,b in ipairs(t[i]) do 
	html_table = html_table .. "<td>" .. b .. "</td>"
	end
	html_table = html_table .. "</tr>"
		
	end
	html_table = html_table .. "</table>"
	return html_table
end
