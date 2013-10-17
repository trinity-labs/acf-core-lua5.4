local mymodule = {}

authenticator = require("authenticator")
roles = require("roles")

avail_roles, avail_skins, avail_homes = nil

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
	-- Username, password, roles, skin, and home are allowed to not exist, just leave the same
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
	if settings.value.home then modelfunctions.validateselect(settings.value.home) end

	-- Return false if any errormessages are set
	for name,value in pairs(settings.value) do
		if value.errtxt then
			return false, settings
		end
	end

	return true, settings
end

function mymodule.create_user(self, settings)
	return mymodule.update_user(self, settings, true)
end

function mymodule.update_user(self, settings, create)
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


function mymodule.read_user(self, user)
	local result = {}
        result.userid = cfe({ value=user, label="User id", seq=1 })
	if user and user ~= "" then
		result.userid.readonly = true
	end
	
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

	-- Call into ?? controller to get the list of home actions
	if not avail_homes then
		avail_homes = {""}
		local tmp1, tmp2 = roles.get_all_permissions(self)
	        table.sort(tmp2)
		for i,h in ipairs(tmp2) do
			avail_homes[#avail_homes+1] = h
		end
	end

	-- Passwords are set to empty string
	result.username = cfe({ value=userinfo.username or "", label="Real name", seq=2 })
	result.password = cfe({ type="password", value="", label="Password", seq=4 })
	result.password_confirm = cfe({ type="password", value="", label="Password (confirm)", seq=5 })
	result.roles = cfe({ type="multi", value=userinfo.roles or {}, label="Roles", option=avail_roles or {}, seq=3 })
	result.skin = cfe({ type="select", value=userinfo.skin or "", label="Skin", option=avail_skins or {""}, seq=7 })
	result.home = cfe({ type="select", value=userinfo.home or "", label="Home", option=avail_homes or {""}, seq=6 })

	return cfe({ type="group", value=result, label="User Config" })
end

function mymodule.get_users(self)
	--List all users and their userinfo
	local users = {}
	local userlist = authenticator.list_users(self)
	table.sort(userlist)
	
	for x,user in pairs(userlist) do
		users[#users+1] = mymodule.read_user(self, user)
	end

	return cfe({ type="group", value=users, label="User Configs" })
end

function mymodule.get_delete_user(self, clientdata)
	local userid = cfe({ label="User id", value=clientdata.userid or "" })
	return cfe({ type="group", value={userid=userid}, label="Delete User" })
end

function mymodule.delete_user(self, deleteuser)
	deleteuser.errtxt = "Failed to delete user"
	if authenticator.delete_user(self, deleteuser.value.userid.value) then
		deleteuser.errtxt = nil
	end
	return deleteuser
end

return mymodule
