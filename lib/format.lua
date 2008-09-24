--[[
	module for format changes in tables and strings
	try to keep non input specific
]]--

module (..., package.seeall)

-- find all return characters and removes them, may get this from a browser
-- that is why didn't do file specific

function dostounix ( str )
	local data = string.gsub(str, "\r", "")
	return data
end

-- search and remove all blank and commented lines from a string or table of lines
-- returns a table to iterate over without the blank or commented lines

function parse_lines ( input )
	local lines = {}

	function parse(line)
		if not string.match(line, "^%s*$") and not string.match(line, "^%s*#") then
			lines[#lines + 1] = line
		end
	end

	if type(input) == "string" then
		for line in string.gmatch(input, "([^\n]*)\n?") do
			parse(line)
		end
	elseif type(input) == "table" then
		for i,line in ipairs(input) do
			parse(line)
		end
	end	
	
	return lines
end

-- search and remove all blank and commented lines from a string or table of lines
-- parse the lines for words, looking for quotes and removing comments
-- returns a table with an array of words for each line

function parse_linesandwords ( input )
	local lines = {}
	local linenum = 0

	function parse(line)
		linenum = linenum + 1
		if not string.match(line, "^%s*$") and not string.match(line, "^%s*#") then
			local linetable = {linenum=linenum, line=line}
			local offset = 1
			while string.find(line, "%S", offset) do
				local word = string.match(line, "%S+", offset)
				local endword
				if string.find(word, "^#") then
					break
				elseif string.find(word, "^\"") then
					endword = select(2, string.find(line, "\"[^\"]*\"", offset))
					word = string.sub(line, string.find(line, "\"", offset), endword)
				else
					endword = select(2, string.find(line, "%S+", offset))
				end
				table.insert(linetable, word)
				offset = endword + 1
			end
			lines[#lines + 1] = linetable
		end
	end

	if type(input) == "string" then
		for line in string.gmatch(input, "([^\n]*)\n?") do
			parse(line)
		end
	elseif type(input) == "table" then
		for i,line in ipairs(input) do
			parse(line)
		end
	end	
	
	return lines
end

-- returns a table with label value pairs

function parse_configfile( input )
	local config = {}
	local lines = parse_linesandwords(input)

	for i,linetable in ipairs(lines) do
		config[linetable[1]] = table.concat(linetable, " ", 2) or ""
	end
	return config
end

-- search and replace through a table
-- string is easy string.gsub(string, find, replace)

function search_replace (input, find, replace)
	local lines = {}
	for i,line in ipairs(input) do
		lines[#lines + 1] = string.gsub(line, find, replace)
	end
	return lines
end

-- great for line searches through a file. /etc/conf.d/ ???
-- might be looking for more than one thing so will return a table
-- will likely want to match whole line entries
-- so we change find to include the rest of the line
-- say want all the _OPTS from a file format.search_for_lines (fs.read_file("/etc/conf.d/cron"), "OPT")
-- if want to avoid commented lines, call parse_lines first

function search_for_lines (input, find)
	local lines = {}

	function findfn(line)
		if string.find(line, find) then
			lines[#lines + 1] = line
		end
	end

	if type(input) == "string" then
		for line in string.gmatch(input, "([^\n]*)\n?") do
			findfn(line)
		end
	elseif type(input) == "table" then
		for i,line in ipairs(input) do
			findfn(line)
		end
	end	
	
	return lines
end

--string format function to capitalize the beginging of each word. 
function cap_begin_word ( str )
	--first need to do the first word
	local data = string.gsub(str, "^%l", string.upper)
	--word is any space cause no <> regex
	data = string.gsub(data, "%s%l", string.upper)
	return data
end

--for cut functionality do something like
--print(format.string_to_table("This is a test", " ")[2])
--gives you the second field which is .... is

-- This code comes from http://lua-users.org/wiki/SplitJoin
-- example: format.string_to_table( "Anna, Bob, Charlie,Dolores", ",%s*")
function string_to_table ( text, delimiter)
	local list = {}
	-- this would result in endless loops
	if string.find("", delimiter) then 
		-- delimiter matches empty string!
		for i=1,#text do
			list[#list + 1] = string.sub(text, i, i)
		end
	else
		local pos = 1
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

-- Removes the linenum line from str and replaces it with line.
-- Do nothing if doesn't exist
-- Set line to nil to remove the line
function replace_line(str, linenum, line)
	-- Split the str to remove the line
	local startchar, endchar = string.match(str, "^" .. string.rep("[^\n]*\n", linenum-1) .. "()[^\n]*\n?()")
	if startchar and endchar then
		local lines = {}
		lines[1] = string.sub(str, 1, startchar-1)
		lines[2] = string.sub(str, endchar, -1)
		if line then
			table.insert(lines, 2, line .. "\n")
		end
		str = table.concat(lines)
	end
	return str
end

-- Inserts the line into the str after the linenum (or at the end)
function insert_line(str, linenum, line)
	-- Split the str to remove the line
	local startchar = string.match(str, "^" .. string.rep("[^\n]*\n", linenum) .. "()")
	local lines = {}
	if startchar then
		lines[1] = string.sub(str, 1, startchar-1)
		lines[2] = string.sub(str, startchar, -1)
	else
		lines[1] = str
	end
	if line then
		table.insert(lines, 2, line .. "\n")
	end
	str = table.concat(lines)
	return str
end

function get_line(str, linenum)
	-- Split the str to remove the line
	local startchar, endchar = string.match(str, "^" .. string.rep("[^\n]*\n", linenum-1) .. "()[^\n]*()")
	local line
	if startchar and endchar then
		line = string.sub(str, startchar, endchar-1)
	end
	return line
end
