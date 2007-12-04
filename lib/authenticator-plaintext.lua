--[[ ACF Logon/Logoff authenticator that uses plaintext files
	Copyright (c) 2007 Nathan Angelacos
	GPL2 license


The password file is in the format:

userid:password:username:role1[,role2...]

]]--

module (..., package.seeall)

local sess = require ("session")

local pvt={}


pvt.read_authfile = function(id) 
	id = id or ""
	
	-- open our password file
	local f = io.open (self.conf.confdir .. "/passwd" )
	if f then
		local m = f:read("*all") .. "\n"
		f:close()
	
		for l in string.gmatch(m, "(%C*)\n") do
			local userid, password, username, roles =
				string.match(l, "([^:]*):([^:]*):([^:]*):(.*)")
			if userid == id then
				local r = {}
				for x in string.gmatch(roles, "([^,]*),?") do
					table.insert (r, x )
				end
				
				local a = {} 
				a.userid = userid
				a.password = password
				a.username = username
				a.roles = r
				return (a)
			end
		end
	else	
		return false
	end
end


--- public methods
	
-- This function returns true or false, and
-- if false:  the reason for failure
authenticate = function ( userid, password )
	password = password or ""
	
	local t = pvt.read_authfile(userid)

	if t == false then
		return false, "Userid not found"
	elseif t.password ~= password then
		return  false, "Invalid password" 
	else
		return true
	end
end



-- This function returns the username and roles 
-- or false on an error 
userinfo = function ( userid )
	local t = pvt.read_authfile(userid)
	if t == false then 
		return false
	else
		return t
	end
end

