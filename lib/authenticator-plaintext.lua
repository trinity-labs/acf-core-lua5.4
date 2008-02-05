--[[ ACF Logon/Logoff authenticator that uses plaintext files
	Copyright (c) 2007 Nathan Angelacos
	GPL2 license


The password file is in the format:

userid:password:username:role1[,role2...]

]]--

module (..., package.seeall)

local sess = require ("session")

local pvt={}

pvt.parse_authfile = function(filename) 
	local row = {}

	-- open our password file
	local f = io.open (filename)
	if f then
		local m = (f:read("*all")  or "" ).. "\n"
		f:close()

		for l in string.gmatch(m, "(%C*)\n") do
			local userid, password, username, roles =
				string.match(l, "([^:]*):([^:]*):([^:]*):(.*)")
			local r = {}
			roles=roles or ""
			for x in string.gmatch(roles, "([^,]%w+),?") do
				table.insert (r, x )
			end
				
			local a = {} 
			a.userid = userid
			a.password = password
			a.username = username
			a.roles = r
			table.insert (row, a)
		end
		return row
	else	
		return nil
	end
end

pvt.get_id = function(userid, authstruct)
	if authstruct == nil then return nil end
	for x = 1,#authstruct do
		if authstruct[x].userid == userid then
			return authstruct[x]
		end
	end
end

--- public methods
	
-- This function returns true or false, and
-- if false:  the reason for failure
authenticate = function ( self, userid, password )
		password = password or ""
		userid = userid or ""

		local t = pvt.parse_authfile(self.conf.confdir .. "/passwd")

		if t == false then
			return false, "password file is missing"
		else
		  if userid ~= nil then
			local id = pvt.get_id (userid, t)
			if id == false or id == nil then
				return false, "Userid not found"
			end
			if id.password ~= password then
				return false, "Invalid password"
			end
		  else 
		  return false
		  end
		return true
		end
end

-- This function returns the username and roles 
-- or false on an error 
get_userinfo = function ( self, userid )
	local t = pvt.parse_authfile(self.conf.confdir .. "/passwd")
	if t == false then 
		return nil
	else
		return pvt.get_id (userid, t)
	end
end

get_userinfo_roles = function (self, userid)
	local t = pvt.parse_authfile(self.conf.confdir .. "/passwd")
	if t == false then
		return nil
	else
		temp = pvt.get_id (userid, t)
		return temp.roles
	end
end
