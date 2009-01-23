--[[
	module for generic filesystem funcs

	Copyright (c) Natanael Copa 2006
        MM edited to use "posix"
]]--

module (..., package.seeall)

require("posix")
require("format")

basename = function (string, suffix)
	string = string or ""
	local basename = string.gsub (string, "[^/]*/", "")
	if suffix then 
		basename = string.gsub ( basename, suffix, "" )
	end
	return basename 
end

dirname = function ( string)
	string = string or ""
	-- strip trailing / first
	string = string.gsub (string, "/$", "")
	local basename = basename ( string)
	string = string.sub(string, 1, #string - #basename - 1)
	return(string)	
end 

-- generic wrapper funcs
function is_dir ( pathstr )
	return posix.stat ( pathstr or "", "type" ) == "directory"
end

function is_file ( pathstr )
	return posix.stat ( pathstr or "", "type" ) == "regular"
end

function is_link ( pathstr )
	return posix.stat ( pathstr or "", "type" ) == "link"
end


-- Creates a directory if it doesn't exist, including the parent dirs
function create_directory ( path )
	local pos = string.find(path, "/")
	while pos do
		posix.mkdir(string.sub(path, 1, pos))
		pos = string.find(path, "/", pos+1)
	end
	posix.mkdir(path)
	return is_dir(path)
end

-- Creates a blank file (and the directory if necessary)
function create_file ( path )
	path = path or ""
	if dirname(path) and not posix.stat(dirname(path)) then create_directory(dirname(path)) end
	local f = io.open(path, "w")
	if f then f:close() end
	return is_file(path)
end

-- Returns the contents of a file as a string
function read_file ( path )
	local file = io.open(path or "")
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
	local file, error = io.open(path or "")
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
	
-- write a string to a file, will replace file contents
function write_file ( path, str )
	path = path or ""
	if dirname(path) and not posix.stat(dirname(path)) then create_directory(dirname(path)) end
	local file = io.open(path, "w")
	--append a newline char to EOF
	str = string.gsub(str or "", "\n*$", "\n")
	if ( file ) then
		file:write(str)
		file:close()
	end
end

-- this could do more than a line. This will append
-- fs.write_line_file ("filename", "Line1 \nLines2 \nLines3")
function write_line_file ( path, str )
	path = path or ""
	if dirname(path) and not posix.stat(dirname(path)) then create_directory(dirname(path)) end
	local file = io.open(path)
	if ( file) then
		local c = file:read("*a") or ""
		file:close()
		fs.write_file(path, c .. (str or ""))
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
		if fs.is_dir(where) then
			for d in posix.files ( where ) do
				if fs.is_dir ( where .. "/" ..  d ) and (d ~= ".") and ( d ~= "..") then
					find_files_as_array (f, where .. "/" .. d, t )
				end
				if (string.match (d, "^" .. f .. "$" ))  then
					table.insert (t, ( string.gsub ( where .. "/" .. d, "/+", "/" ) ) )
				end
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
	local filedetails = posix.stat(path or "")
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
