--[[ ACF Logon/Logoff authenticator that uses plaintext files
	Copyright (c) 2007 Nathan Angelacos
	GPL2 license


The password file is in the format:

userid:password:username:role1[,role2...]

]]--

module (..., package.seeall)

local sess = require ("session")
require("roles")

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
			for x in string.gmatch(roles, "([^,][%w_]+),?") do
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
	if authstruct ~= nil then
		for x = 1,#authstruct do
			if authstruct[x].userid == userid then
				return authstruct[x]
			end
		end
	end
	return nil
end

pvt.weak_password = function(password)
	-- If password is too short, return false
	if (#password < 4) then
		return true, "Password is too short!"
	end	
	if (tonumber(password)) then
		return true, "Password can't contain only numbers!"
	end	

	return false
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

-- validate the settings (ignore password if it's nil)
local validate_settings = function (self, userid, username, password, password_confirm, roles)
	local errormessage = {}

	-- Set errormessages when entering invalid values
	if (#userid == 0) then errormessage.userid = "You need to enter a valid userid!" end
	if string.find(userid, "[^%w_]") then errormessage.userid = "Userid can only contain letters, numbers, and '_'" end
	if string.find(username, "%p") then errormessage.username = "Real name cannot contain punctuation" end
	if password then
		if (#password == 0) then
			errormessage.password = "Password cannot be blank!"
		elseif (password ~= password_confirm) then 
			errormessage.password_confirm = "You entered wrong password/confirmation"
		else
			local weak_password_result, weak_password_errormessage = pvt.weak_password(password)
			if (weak_password_result) then errormessage.password = weak_password_errormessage end
		end
	end
	local reverseroles = {}
	for x,role in pairs(list_roles(self)) do
		reverseroles[role] = x
	end
	for x,role in pairs(roles) do
		if reverseroles[role] == nil then
			errormessage.roles = "Invalid role"
			break
		end
	end

	-- Return false if any errormessages are set
	for k,v in pairs(errormessage) do
		return false, errormessage
	end

	return true, errormessage
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
	end
	
	if userid ~= nil then
		local id = pvt.get_id (userid, t)
		if id == false or id == nil then
			return false, "Userid not found"
		end
		if id.password ~= fs.md5sum_string(password) then
			return false, "Invalid password"
		end
	else 
		return false
	end

	return true
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
	-- Get list of available roles (everything except ALL)
	local avail_roles = roles.list_all_roles()
	for x,role in ipairs(avail_roles) do
		if role=="ALL" then
			table.remove(avail_roles,x)
			break
		end
	end
	return avail_roles
end

change_setting = function (self, userid, parameter, value) 
	local result = true
	local errormessage = {}

	-- Get the current user info
	local userinfo = get_userinfo(self, userid)
	if userinfo == nil then
		errormessage.userid = "This userid does not exist!"
		result = false
	end

	-- Check if user entered available commands
	if not (userid) or not (parameter) or not (pvt.availablefields(parameter)) or not (value) then
		errormessage.userid = "You need to enter valid userid, parameter and value!"
		result = false
	end

	-- Check if userid already used
	if (parameter == "userid") and (userid ~= value) then
		for k,v in pairs(list_users(self)) do
			if (v == value) then
				errormessage.userid = "This userid already exists!"
				result = false
			end
		end
	end

	if result == true then
		-- Validate parameter
		userinfo[parameter] = value
		local password, password_confirm
		if (parameter == "password") then
			userinfo.password = fs.md5sum_string(value)
			password = value
			password_confirm = value
		end
		result, errormessage = validate_settings(self, username.userid, userinfo.username, password, password_confirm, userinfo.roles)
	end

	-- Write the updated user
	if (result == true) then
		delete_user(self, userid)

		-- Set path to passwordfile
		local passwd_path = self.conf.confdir .. "/passwd"
		-- Write the newline into the file
		fs.write_line_file(passwd_path, userinfo.userid .. ":" .. userinfo.password .. ":" .. userinfo.username .. ":" .. table.concat(userinfo.roles,",") )
	end

	return result, errormessage
end

-- For an existing user, change the settings that are non-nil
change_settings = function (self, userid, username, password, password_confirm, roles)
	local result = true
	local errormessage = {}

	-- Get the current user info
	local userinfo = get_userinfo(self, userid)
	if userinfo == nil then
		errormessage.userid = "This userid does not exist!"
		result = false
	end

	local change = username or password or password_confirm or roles
	if change then
		-- Validate the inputs
		if (result == true) then
			-- Use the current settings if new ones are nil, except for password
			result, errormessage = validate_settings(self, userid, username or userinfo.username, password, password_confirm, roles or userinfo.roles)
		end

		-- Update all the fields
		if (result == true) then
			userinfo.username = username or userinfo.username
			if password then
				userinfo.password = fs.md5sum_string(password)
			end
			userinfo.roles = roles or userinfo.roles

			-- Write the updated user
			delete_user(self, userid)

			-- Set path to passwordfile
			local passwd_path = self.conf.confdir .. "/passwd"
			-- Write the newline into the file
			fs.write_line_file(passwd_path, userid .. ":" .. userinfo.password .. ":" .. userinfo.username .. ":" .. table.concat(userinfo.roles,",") )
		end
	end

	return result, errormessage
end

new_settings = function (self, userid, username, password, password_confirm, roles)
	local result = true
	local errormessage = {}
	-- make sure to check all fields
	userid = userid or ""
	username = username or ""
	password = password or ""
	password_confirm = password_confirm or ""
	roles = roles or {}

	-- Check if userid already used
	for k,v in pairs(list_users(self)) do
		if (v == userid) then
			errormessage.userid = "This userid already exists!"
			result = false
		end
	end
	
	-- validate the settings
	if (result == true) then
		result, errormessage = validate_settings(self, userid, username, password, password_confirm, roles)
	end

	-- write the new user
	if (result == true) then
		-- Set path to passwordfile
		local passwd_path = self.conf.confdir .. "/passwd"

		-- Write the newline into the file
		fs.write_line_file(passwd_path, userid .. ":" .. fs.md5sum_string(password) .. ":" .. username .. ":" .. table.concat(roles,",") )
	end

	return result, errormessage
end

delete_user = function (self, userid)
	local result = false
	local errormessage = {userid="User not found"}

	local passwd_path = self.conf.confdir .. "/passwd"
	local passwdfilecontent = fs.read_file_as_array(passwd_path)
	local output = {}
	for k,v in pairs(passwdfilecontent) do
		if not ( string.match(v, "^".. userid .. ":") ) then
			table.insert(output, v)
		else
			result = true
			errormessage = {}
		end
	end
	
	--Save the updated table
	if result == true then
		fs.write_file(passwd_path, table.concat(output,"\n"))
	end

	return result, errormessage
end
