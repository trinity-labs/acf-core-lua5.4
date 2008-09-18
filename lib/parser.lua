module(..., package.seeall)

function parseconfigfile(file)
	file = file or ""
	local retval = {commented={}}
	local linenum=0
	for line in string.gmatch(file, "([^\n]*)\n?") do
		linenum=linenum+1
		if not string.match(line, "^[%s#]*$") then
			local linetable = {linenum=linenum, line=line}
			if string.match(line, "^%s*#") then
				table.insert(retval.commented, linetable)
				line = string.match(line, "^%s*#(.*)")
			else
				table.insert(retval, linetable)
			end
			-- Iterate through each word, being careful about quoted strings and comments
			local offset = 1
			while string.find(line, "%S+", offset) do
				local word = string.match(line, "%S+", offset)
				local endword = select(2, string.find(line, "%S+", offset))
				if string.find(word, "^#") then
					break
				elseif string.find(word, "^\"") then
					endword = select(2, string.find(line, "\"[^\"]*\"", offset))
					word = string.sub(line, string.find(line, "\"", offset), endword)
				end
				table.insert(linetable, word)
				offset = endword + 1
			end
		end
	end
	return retval
end

-- Removes the linenum line from file and replaces it with line.
-- Do nothing if doesn't exist
function replaceline(file, linenum, line)
	-- Split the file to remove the line
	local startchar, endchar = string.match(file, "^" .. string.rep("[^\n]*\n", linenum-1) .. "()[^\n]*\n?()")
	if startchar and endchar then
		local lines = {}
		lines[1] = string.sub(file, 1, startchar-1)
		lines[2] = string.sub(file, endchar, -1)
		if line then
			table.insert(lines, 2, line .. "\n")
		end
		file = table.concat(lines)
	end
	return file
end

-- Inserts the line into the file after the linenum (or at the end)
function insertline(file, linenum, line)
	-- Split the file to remove the line
	local startchar = string.match(file, "^" .. string.rep("[^\n]*\n", linenum) .. "()")
	local lines = {}
	if startchar then
		lines[1] = string.sub(file, 1, startchar-1)
		lines[2] = string.sub(file, startchar, -1)
	else
		lines[1] = file
	end
	if line then
		table.insert(lines, 2, line .. "\n")
	end
	file = table.concat(lines)
	return file
end

function getline(file, linenum)
	-- Split the file to remove the line
	local startchar, endchar = string.match(file, "^" .. string.rep("[^\n]*\n", linenum-1) .. "()[^\n]*()")
	local line
	if startchar and endchar then
		line = string.sub(file, startchar, endchar-1)
	end
	return line
end
