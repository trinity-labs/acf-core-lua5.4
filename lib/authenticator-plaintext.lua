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

pvt.permission_to_change = function()
	--FIXME: See to that user is allowed to change things
	return true
end

pvt.availablefields = function (field)
	-- This is a list of fileds in the /passwd file that we are allowed to use.
	-- Could be used to check that right variable-name is used.
	local availablefileds = {
		['userid']=true, 
		['password']=true, 
		['username']=true, 
		['roles']=true, 
		}
	return availablefileds[field]
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

list_users = function (self)
	local output = {}
	local t = pvt.parse_authfile(self.conf.confdir .. "/passwd")
	if t == false then
		return nil
	else
		for k,v in pairs(t) do
			table.insert(output,v.userid)
		end
		return output

	end
end
list_roles = function (self)
	local output = {"CREATE","UPDATE","DELETE","READ"}
	return output
end

change_settings = function (self, userid,parameter,value) 
	-- We start by checking if user is allowed to do changes
	-- FIXME: This functions is probably not done yet!!!
	if not (pvt.permission_to_change) then
		return false, "No permission to change!"
	end

	-- Check if user entered available commands
	if not (userid) or not (parameter) or not (pvt.availablefields(parameter)) then
		return false, "You need to enter valid userid, parameter and value!"
	end

	local passwdfilecontent = fs.read_file_as_array(self.conf.confdir .. "/passwd")
	local changes
	for k,v in pairs(passwdfilecontent) do
		if ( string.match(v, "^".. userid .. ":") ) then
			changes = {}
			-- Get current values
			changes.userid, changes.password, changes.username, changes.roles =
				string.match(v, "([^:]*):([^:]*):([^:]*):(.*)")
			-- Actually change the value (remove all ':')
			changes[parameter] = string.gsub(value, ":", "")
			-- Update the table with the new values
			passwdfilecontent[k] = changes.userid .. ":" .. changes.password .. ":".. changes.username .. ":" .. changes.roles
		end
	end
	
	--Write changes to file
	fs.write_file(self.conf.confdir .. "/passwd", table.concat(passwdfilecontent,"\n"))
	return true
end

new_settings = function ( self, userid, username, password, password_confirm, ...)
	local errormessage = {}
	local roles = { ... }
	-- Set errormessages when entering invalid values
	if (#userid == 0) then errormessage.userid = "You need to enter a valid userid!" end
	if (password ~= password_confirm) then errormessage.password = "You entered wrong password/confirmation" end
	if not (password) or (#password == 0) then errormessage.password = "Password cant be blank!" end

	-- Return false if some errormessages is set
	for k,v in pairs(errormessage) do
		return false, errormessage
	end

	return true, errormessage
end
