#!/usr/bin/lua

require "object"

-- ed object
Ed = Object:new{ 
	filename = nil,
	lines = {}
}


-- openfile and read it to table
function Ed:open( filename, mode )
	local f = io.open( filename, mode )
	-- check that open was success
	if f == nil then
		return nil
	end
	
	-- read the lines
	for line in f:lines() do
		table.insert( self.lines, line )
	end
	f:close()
	self.filename = filename
	return self.lines
end


-- search and replace on lines that matches linematch
function Ed:find_gsub( linematch, search, replace, limit )
	local i, line
	for i, line in ipairs( self.lines ) do
		if string.find( line, linematch ) then
			self.lines[i] = string.gsub( line, search, replace, limit )	
		end
	end
end


-- Write the table to file again
function Ed:flush( filename ) 
	local f = io.open( filename, "w" )
	if f == nil then
		return false
	end

	-- write each line to file
	for i, line in ipairs( self.lines ) do
		f:write(line .. "\n") -- test this!
	end
	f:close()
	return true
end

function Ed:insert( line )
	self.lines:insert( line )
end


