-- Session handling routines - written for acf
-- Copyright (C) 2007 N. Angelacos - GPL2 License


--[[ Note that in this library, we use empty (0 byte) files 
-- everwhere we can, as they only take up dir entries, not inodes
-- as the tmpfs blocksize is 4K, and under denial of service 
-- attacks hundreds or thousands of events can come in each 
-- second, we could end up in a disk full condition if we did
-- not take this precaution.
-- ]]--

module (..., package.seeall)

require "posix"

local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"

-- Return a sessionid of at least size bits length
random_hash = function (size)
	local file = io.open("/dev/urandom")
	local str = ""
	if file == nil then return nil end
	while (size > 0 ) do
		local offset = (string.byte(file:read(1)) % 64) + 1 
		str = str .. string.sub (b64, offset, offset)
		size = size - 6
	end
	return str
end

-- FIXME: only hashes ipv4

hash_ip_addr = function (string)
	local str = ""
	for i in string.gmatch(string, "%d+") do
		str = str .. string.format("%02x", i )
	end
	return str
end

ip_addr_from_hash = function (string)
	local str = ""
	for i in string.gmatch(string, "..") do
		str = str .. string.format("%d", "0x" .. i) .. "."
	end
	return string.sub(str, 1, string.len(str)-1)
end


--[[ 
	These functions serialize a table, including nested tables.
	The code based on code in PiL 2nd edition p113
]]--
local function basicSerialize (o)
	if type(o) == "number" then
		return tostring(o)
	else
		return string.format("%q", o)
	end
end


function serialize (name, value, saved )
	local str = str or ""
	saved = saved or {}
	str = str .. name .. " = "
	if type(value) == "number" or type(value) == "string" then
		str = str .. basicSerialize (value) .. "\n"
	elseif type(value) == "table" then
		if saved[value] then
			str = str .. saved[value] .. "\n"
		else
			saved[value] = name
			str = str .. "{}\n" 
			for k,v in pairs(value) do
				local fieldname = string.format("%s[%s]", name, basicSerialize(k))
				str = str .. serialize (fieldname, v, saved)
			end
		end
	elseif type(value) == "boolean" then
			str = str .. tostring(value) .. "\n"
	else
		str = str .. "nil\n"	 -- cannot save other types, so skip them
	end
	return str
end

save_session = function( sessionpath, session, sessiontable)
	local file = io.open(sessionpath .. "/session." .. session , "w")
	if file == nil then 
		return false
	end

	local id = sessiontable.id	
	
	-- clear the id key
	sessiontable.id = nil
	-- count the keys
	local count = 0
	for k,v in pairs (sessiontable) do
		count = count + 1 
	end
	-- If the table only has an "id" field, then don't save it
	if count > 0 and file then 
		file:write ( "-- This is an ACF session table.\n")
		file:write ( "\nlocal " )
		file:write ( serialize("s", sessiontable) )
		file:write ( "return s\n")
	end
	file:close()
	sessiontable.id=id
	return true
end


-- Loads a session
-- Returns a timestamp (when the session data was saved) and the session table.
-- We insert a "id" field from the "session"
load_session = function ( sessionpath, session )
	local s = {}
	-- session can only have b64 characters in it
	session = string.gsub ( session or "", "[^" .. b64 .. "]", "")
	if #session == 0 then
		return nil, {}
	end
	local spath = sessionpath .. "/session." .. session
	local ts = posix.stat(spath, "ctime")
	if (ts) then
		s = dofile(spath) or {}
		s.id = session 
		return ts, s
	else
		return nil, {}
	end
end

-- unlinks a session
unlink_session = function (sessionpath, session)
	if type(session)  ~= "string" then return nil end
	local s = string.gsub (session, "[^" .. b64 .. "]", "")
	if s ~= session then
		return nil
	end
	session = sessionpath .. "/session." .. s
	os.remove (session)
	return nil
end


-- Record an invalid login event 
-- ID would typically be an ip address or username
-- the format is lockevent.id.datetime.processid
record_event = function( sessionpath, id )
	local x = io.open (string.format ("%s/lockevent.%s.%s.%s",
		 sessionpath or "/", id or "", os.time(), 
		 (posix.getpid("pid")) or "" ), "w")
	io.close(x)
end
	
