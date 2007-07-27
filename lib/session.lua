-- Session handling routines - written for acf
-- Copyright (C) 2007 N. Angelacos - GPL2 License

module (..., package.seeall)

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
	local file = io.open(sessionpath .. "/" .. session , "w")
	if file then
		file:write ( "-- This is an ACF session table.\nlocal timestamp=" .. os.time() ) 
		file:write ( "\nlocal " )
		file:write ( serialize("s", sessiontable) )
		file:write ( "return timestamp, s\n")
		file:close()
		return true
	else
		return false
	end
end


--- FIXME:  This is really a generic "test if file exists" thing.

-- Tests if a session is valid
-- Returns true if valid, false if not
session_is_valid = function (session)
	local file = io.open(session)
	if file then
		file:close()
		return true
	else
		return false
	end
end

-- Loads a session
-- Returns a timestamp (when the session data was saved) and the session table.
load_session = function ( sessionpath, session )
	-- session can only have b64 characters in it
	session = string.gsub ( session, "[^" .. b64 .. "]", "")
	if #session == 0 then
		return nil, {}
	end
	session = sessionpath .. "/" .. session
	if (session_is_valid(session)) then
	local file = io.open(session)
		return dofile(session)
	else
		return nil, {}
	end
end

-- unlinks a session
invalidate_session = function (sessionpath, session)
	if type(session)  ~= "string" then return nil end
	local s = string.gsub (session, "[^" .. b64 .. "]", "")
	if s ~= session then
		return nil
	end
	session = sessionpath .. "/" .. s
	os.remove (session)
	return nil
end


expire_old_sessions = function ( sessiondir )
	file = io.popen("ls " .. sessiondir )
	x = file:read("*a")
	file:close()
	for a in string.gmatch(x, "[^%c]+")  do
	                timestamp, foo = load_session ( sessiondir .. "/" .. a )
			print ( a .. " is " .. os.time()  - timestamp .. " seconds old")
			end
end
