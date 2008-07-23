-- ACF Authenticator - does validation and loads sub-authenticator to read/write database
module (..., package.seeall)

require("modelfunctions")
require("fs")

-- This will be the sub-authenticator
local auth
-- This will hold the auth structure from the database
local authstruct
-- This is a list of fields in the database that we are allowed to use.
-- Could be used to check that right variable-name is used.
local availablefields = {
	['userid']=true, 
	['password']=true, 
	['username']=true, 
	['roles']=true, 
	['dnsfiles']=true, 
	}


local load_auth = function(self)
	-- For now, just loads the plaintext version
	auth = auth or require("authenticator-plaintext")
end

local load_database = function(self)
	load_auth(self)
	authstruct = authstruct or auth.load_database(self)
end
	
local get_id = function(userid)
	if authstruct ~= nil then
		for x = 1,#authstruct do
			if authstruct[x].userid == userid then
				return authstruct[x]
			end
		end
	end
	return nil
end

local weak_password = function(password)
	-- If password is too short, return false
	if (#password < 4) then
		return true, "Password is too short!"
	end	
	if (tonumber(password)) then
		return true, "Password can't contain only numbers!"
	end	

	return false, nil
end

local write_settings = function(self, settings, id)
	load_database()
	id = id or get_id(settings.value.userid.value) or {}
	-- Password, password_confirm, roles, dnsfiles are allowed to not exist, just leave the same
	id.userid = settings.value.userid.value
	id.username = settings.value.username.value
	if settings.value.password then id.password = fs.md5sum_string(settings.value.password.value) end
	if settings.value.roles then id.roles = table.concat(settings.value.roles.value, ",") end
	if settings.value.dnsfiles then id.dnsfiles = table.concat(settings.value.dnsfiles.value, ",") end

	return auth.write_entry(self, id)
end
	
-- validate the settings (ignore password if it's nil)
local validate_settings = function(settings)
	-- Password, password_confirm, roles, dnsfiles are allowed to not exist, just leave the same
	-- Set errtxt when entering invalid values
	if (#settings.value.userid.value == 0) then settings.value.userid.errtxt = "You need to enter a valid userid!" end
	if string.find(settings.value.userid.value, "[^%w_]") then settings.value.userid.errtxt = "Can only contain letters, numbers, and '_'" end
	if string.find(settings.value.username.value, "%p") then settings.value.username.value = "Cannot contain punctuation" end
	if settings.value.password then
		if (#settings.value.password.value == 0) then
			settings.value.password.errtxt = "Password cannot be blank!"
		elseif (not settings.value.password_confirm) or (settings.value.password.value ~= settings.value.password_confirm.value) then
			settings.value.password.errtxt = "You entered wrong password/confirmation"
		else
			local weak_password_result, weak_password_errormessage = weak_password(settings.value.password.value)
			if (weak_password_result) then settings.value.password.errtxt = weak_password_errormessage end
		end
	end
	if settings.value.roles then modelfunctions.validatemulti(settings.value.roles) end
	if settings.value.dnsfiles then modelfunctions.validatemulti(settings.value.dnsfiles) end

	-- Return false if any errormessages are set
	for name,value in pairs(settings.value) do
		if value.errtxt then
			return false, settings
		end
	end

	return true, settings
end

--- public methods

-- This function returns true or false, and
-- if false:  the reason for failure
authenticate = function(self, userid, password)
	local errtxt

	if not userid or not password then
		errtxt = "Invalid parameter"
	else
		load_database(self)

		if authstruct == false then
			errtxt = "Could not load authentication database"
		else	
			local id = get_id(userid)
			if not id then
				errtxt = "Userid not found"
			elseif id.password ~= fs.md5sum_string(password) then
				errtxt = "Invalid password"
			end
		end
	end

	return (errtxt == nil), errtxt
end

-- This function returns the username, roles, ...
get_userinfo = function(self, userid)
	load_database(self)
	local id = get_id(userid)
	local user = cfe({ value=userid, label="User id" })
	local username = cfe({ label="Real name" })
	if id then
		username.value = id.username
	elseif userid then
		user.errtxt = "User does not exist"
	end
	local password = cfe({ label="Password" })
	local password_confirm = cfe({ label="Password (confirm)" })
	local roles = get_userinfo_roles(self, userid)
	local dnsfiles = get_userinfo_dnsfiles(self, userid)

	return cfe({ type="group", value={ userid=user, username=username, password=password, password_confirm=password_confirm, roles=roles, dnsfiles=dnsfiles }, label="User Config" })
end

get_userinfo_roles = function(self, userid)
	load_database(self)
	local id = get_id(userid)
	local roles = cfe({ type="multi", value={}, label="Roles", option={} })
	if id then
		for x in string.gmatch(id.roles or "", "([^,]+),?") do
			roles.value[#roles.value + 1] = x
		end
	elseif userid then
		roles.errtxt = "Could not load roles"
	end
	local rol = require("roles")
	if rol then
		local avail_roles = rol.list_all_roles()
		for x,role in ipairs(avail_roles) do
			if role=="ALL" then
				table.remove(avail_roles,x)
				break
			end
		end
		roles.option = avail_roles
	end
	return roles
end

get_userinfo_dnsfiles = function(self, userid)
	load_database(self)
	local id = get_id(userid)
	local dnsfiles = cfe({ type="multi", value={}, label="DNS Files", option={} })
	if id then
		for x in string.gmatch(id.dnsfiles or "", "([^,]+),?") do
			dnsfiles.value[#dnsfiles.value + 1] = x
		end
	elseif userid then
		dnsfiles.errtxt = "Could not load DNS files"
	end
	local dns = self:new("tinydns/tinydns")
	if dns then
		local avail_files = dns.model.getfilelist()
		dnsfiles.option = avail_files.value
		dns:destroy()
	end
	return dnsfiles
end

list_users = function (self)
	load_database(self)
	local output = {}
	if authstruct then
		for k,v in pairs(authstruct) do
			table.insert(output,v.userid)
		end
	end
	return output
end

-- This function will change one user setting by name
-- Cannot be used for password or userid
change_setting = function (self, userid, parameter, value) 
	local success = false
	local cmdresult = "Failed to change setting"
	local errtxt

	-- Get the current user info
	local userinfo = get_userinfo(self, userid)
	if not userinfo then
		errtxt = "This userid does not exist"
	end

	-- Check if user entered available commands
	if not value then
		errtxt = "Invalid value"
	elseif not (availablefields[parameter]) then
		errtxt = "Invalid parameter"
	elseif parameter == "userid" or parameter == "password" then
		errtxt = "Cannot change "..parameter.." with this function"
	else
		userinfo.value[parameter].value = value
		userinfo.value.password = nil
		userinfo.value.password_confirm = nil
		if not validate_settings(userinfo) then
			errtxt = userinfo.value[parameter].errtxt
		else
			success = write_settings(self, userinfo)
		end
	end

	if success then cmdresult = "Changed setting" end

	return cfe({ value=cmdresult, label="Change setting result", errtxt=errtxt })
end

-- For an existing user, change the settings that are non-nil
change_settings = function (self, settings)
	local success, settings = validate_settings(settings)

	-- Get the current user info
	local id
	if success then
		load_database(self)
		id = get_id(settings.value.userid.value)
		if not id then
			settings.value.userid.errtxt = "This userid does not exist!"
			success = false
		end
	end

	if success then
		success = write_settings(self, settings, id)
	end

	if not success then
		settings.errtxt = "Failed to save settings"
	end

	return settings
end

new_settings = function (self, settings)
	local success, settings = validate_settings(settings)

	if success then
		load_database(self)
		local id = get_id(settings.value.userid.value)
		if id then
			settings.value.userid.errtxt = "This userid already exists!"
			success = false
		end
	end

	if success then
		success = write_settings(self, settings)
	end

	if not success then
		settings.errtxt = "Failed to create new user"
	end

	return settings
end

delete_user = function (self, userid)
	load_auth(self)
	local cmdresult = "Failed to delete user"
	if auth.delete_entry(self, userid) then
		cmdresult = "User deleted"
	end
	return cfe({ value=cmdresult, label="Delete user result" })
end
