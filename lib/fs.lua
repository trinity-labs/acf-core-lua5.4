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
	
-- write a string to a file !! MM-will replace file contents

function write_file ( path, str )
	local file = io.open(path, "w")
	--append a newline char to EOF
	str = str .. "\n"
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
	local d = (c .. str .. "\n")
	-- include a friendly newline for EOF
	fs.write_file(path,d)
	end
end


--will return a string with md5sum and filename
function md5sum_file ( path )
	cmd = "/usr/bin/md5sum " .. path
	f = io.popen(cmd)
	checksum = f:read("*a")
	f:close()
	return checksum
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

-- This function does almost the same as posix.stat, but instead it writes the output human readable.
function stat ( path )
	local filedetails = posix.stat(path)
	if (filedetails) then
		filedetails["ctime"]=os.date("%c", filedetails["ctime"])
		filedetails["mtime"]=os.date("%c", filedetails["mtime"])
		filedetails["path"]=path
		if ( filedetails["size"] > 1073741824 ) then
			filedetails["size"]=((filedetails["size"]/1073741824) - (filedetails["size"]/1073741824%0.1)) .. "G"
		elseif ( filedetails["size"] > 1048576 ) then
			filedetails["size"]=((filedetails["size"]/1048576) - (filedetails["size"]/1048576%0.1))  .. "M"
		elseif ( filedetails["size"] > 1024 ) then
			filedetails["size"]=((filedetails["size"]/1024) - (filedetails["size"]/1024%0.1)) .. "k"
		else
			filedetails["size"]=filedetails["size"]
		end
	end
	return filedetails
end
