--[[
	module for generic filesystem funcs

	Copyright (c) Natanael Copa 2006

]]--

module (..., package.seeall)

require ("lfs")

-- generic wrapper funcs
function is_dir ( pathstr )
	return lfs.attributes ( pathstr, "mode" ) == "directory"
end

function is_file ( pathstr )
	return lfs.attributes ( pathstr, "mode" ) == "file"
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
	end
	file:close()
	return f
end

	
	
	
-- write a string to a file
function write_file ( path, str )
	local file = io.open(path, "w")
	if ( file ) then
		file:write(str)
		file:close()
	end
end


-- iterator function for finding dir entries matching filespec (what)
-- starting at where, or currentdir if not specified.
-- Finds regexes, not fileglobs
function find ( what, where )
	-- returns an array of files under "where" that match what "f"
	local function find_files_as_array ( f, where, t )
		where = where or lfs.currentdir()
		f = f or ".*"
		t =  t or {}
		for d in lfs.dir ( where ) do
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

