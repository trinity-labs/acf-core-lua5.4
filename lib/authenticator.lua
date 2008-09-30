-- ACF Authenticator - does validation and loads sub-authenticator to read/write database
-- We store the login info in the passwd table, "" field.  It looks like
--	password:username:ROLE1[,ROLE2...]
module (..., package.seeall)

require("modelfunctions")
require("format")

-- This is the sub-authenticator
-- In the future, this will be set based upon configuration
-- This is a public variable to allow other controllers (ie tinydns) to do their own permissions
auth = require("authenticator-plaintext")

-- Publicly define the pre-defined tables
usertable = "passwd"
roletable = "roles"

-- This will hold the auth structure from the database
local authstruct
-- This is a list of fields in the database that we are allowed to use.
-- Could be used to check that right variable-name is used.
local availablefields = {
	--['userid']=true, 
	['password']=true, 
	['username']=true, 
	['roles']=true, 
	}

local load_database = function(self)
	if not authstruct then
		local authtable = auth.read_field(self, usertable, "")
		authstruct = {}
		for i,value in ipairs(authtable) do
			if value.id ~= "" then
				local fields = {}
				for x in string.gmatch(value.entry, "([^:]*):?") do
					fields[#fields + 1] = x
				end
				local a = {}
				a.userid = value.id
				a.password = fields[1] or ""
				a.username = fields[2] or ""
				a.roles = fields[3] or ""
				table.insert(authstruct, a)
			end
		end
	end
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
	-- Password, password_confirm, roles are allowed to not exist, just leave the same
	id.userid = settings.value.userid.value
	id.username = settings.value.username.value
	if settings.value.password then id.password = format.md5sum_string(settings.value.password.value) end
	if settings.value.roles then id.roles = table.concat(settings.value.roles.value, ",") end

	return auth.write_entry(self, usertable, "", id.userid, (id.password or "")..":"..(id.username or "")..":"..(id.roles or ""))
end
	
-- validate the settings (ignore password if it's nil)
local validate_settings = function(settings)
	-- Password, password_confirm, roles are allowed to not exist, just leave the same
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

		if not authstruct then
			errtxt = "Could not load authentication database"
		else	
			local id = get_id(userid)
			if not id then
				errtxt = "Userid not found"
			elseif id.password ~= format.md5sum_string(password) then
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

	return cfe({ type="group", value={ userid=user, username=username, password=password, password_confirm=password_confirm, roles=roles }, label="User Config" })
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
		local avail_roles = rol.list_all_roles(self)
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
	local cmdresult = "Failed to delete user"
	if auth.delete_entry(self, usertable, "", userid) then
		cmdresult = "User deleted"
	end
	return cfe({ value=cmdresult, label="Delete user result" })
end
