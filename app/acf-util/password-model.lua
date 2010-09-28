module(..., package.seeall)

require("authenticator")
require("roles")

avail_roles, avail_skins = nil

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

-- validate the settings (ignore password if it's nil)
local validate_settings = function(settings)
	-- Username, password, roles, and skin are allowed to not exist, just leave the same
	-- Set errtxt when entering invalid values
	if (#settings.value.userid.value == 0) then settings.value.userid.errtxt = "You need to enter a valid userid!" end
	if string.find(settings.value.userid.value, "[^%w_]") then settings.value.userid.errtxt = "Can only contain letters, numbers, and '_'" end
	if settings.value.username and string.find(settings.value.username.value, "%p") then settings.value.username.errtxt = "Cannot contain punctuation" end
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
	if settings.value.skin then modelfunctions.validateselect(settings.value.skin) end

	-- Return false if any errormessages are set
	for name,value in pairs(settings.value) do
		if value.errtxt then
			return false, settings
		end
	end

	return true, settings
end

function create_user(self, settings)
	return update_user(self, settings, true)
end

function update_user(self, settings, create)
	local success, settings = validate_settings(settings)

	if success then
		local userinfo = authenticator.get_userinfo(self, settings.value.userid.value)
		if userinfo and create then
			settings.value.userid.errtxt = "This userid already exists!"
			success = false
		elseif not userinfo and not create then
			settings.value.userid.errtxt = "This userid does not exist!"
			success = false
		end
	end

	if success then
		local userinfo = {}
		for name,val in pairs(settings.value) do
			userinfo[name] = val.value
		end
		success = authenticator.write_userinfo(self, userinfo)
	end

	if not success then
		if create then
			settings.errtxt = "Failed to create new user"
		else
			settings.errtxt = "Failed to save settings"
		end
	end

	return settings
end


function read_user(self, user)
	local result = {}
        result.userid = cfe({ value=user, label="User id" })
	
	local userinfo = {}
	if not user then
		local userlist = authenticator.list_users(self)
		if #userlist == 0 then
			-- There are no users yet, suggest some values
			result.userid.value = "root"
			userinfo = { userid="root", username="Admin account", roles={"ADMIN"} }
		end
	else
		userinfo = authenticator.get_userinfo(self, user)
		if not userinfo then
			result.userid.errtxt = "User does not exist"
			userinfo = {}
		end
	end

	if not avail_roles then
		avail_roles = roles.list_all_roles(self)
		for x,role in ipairs(avail_roles) do
			if role==roles.guest_role then
				table.remove(avail_roles,x)
				break
			end
		end
	end
	
	-- Call into skins controller to get the list of skins
	if not avail_skins then
		avail_skins = {""}
		local contrl = self:new("acf-util/skins")
		skins = contrl:read()
		contrl:destroy()
		for i,s in ipairs(skins.value) do
			avail_skins[#avail_skins + 1] = s.value
		end
	end

	-- Passwords are set to empty string
	result.username = cfe({ value=userinfo.username or "", label="Real name" })
	result.password = cfe({ value="", label="Password" })
	result.password_confirm = cfe({ value="", label="Password (confirm)" })
	result.roles = cfe({ type="multi", value=userinfo.roles or {}, label="Roles", option=avail_roles or {} })
	result.skin = cfe({ type="select", value=userinfo.skin or "", label="Skin", option=avail_skins or {""} })

	return cfe({ type="group", value=result, label="User Config" })
end

function get_users(self)
	--List all users and their userinfo
	local users = {}
	local userlist = authenticator.list_users(self)
	table.sort(userlist)
	
	for x,user in pairs(userlist) do
		users[#users+1] = read_user(self, user)
	end

	return cfe({ type="group", value=users, label="User Configs" })
end

function delete_user(self, userid)
	result = cfe({ label="Delete user result", errtxt="Failed to delete user"})
	if authenticator.delete_user(self, userid) then
		result.value = "User deleted"
		result.errtxt = nil
	end
	return result
end
