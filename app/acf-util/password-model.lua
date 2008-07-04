module(..., package.seeall)

local auth=require("authenticator-plaintext")

function create_user(self, userdata)
	return update_user(self, userdata, true)
end

function read_user(self, user)
	local config = {}
	local errtxt

	-- Read the user data
	local userinfo
	if user and (#user > 0) then
		userinfo = auth.get_userinfo(self,user)
		if not userinfo then
			errtxt = "User does not exist"
		end
	end
	userinfo = userinfo or {}

	config.userid =  cfe({
		label="User id",
		value=(userinfo.userid or user or ""),
		errtxt = errtxt
		})
	config.username =  cfe({
		label="Real name",
		value=(userinfo.username or ""),
		})
	config.roles =  cfe({
		label="Roles",
		value=(userinfo.roles or {}),
		type="multi",
		option=auth.list_roles(),
		})
	config.password =  cfe({
		label="Password",
		})
	config.password_confirm =  cfe({
		label="Password (confirm)",
		})

	return cfe({ type="group", value=config, errtxt = errtxt, label="User Config" })
end

function update_user(self, userdata, newuser)
	local result
	local errormessage = {}

	-- Try to write new or update existing data
	if newuser == true then
		result, errormessage = auth.new_settings(self, userdata.value.userid.value, userdata.value.username.value, userdata.value.password.value, userdata.value.password_confirm.value, userdata.value.roles.value)
		if result == false then
			userdata.errtxt = "Failed to create new user"
		end
	else
		-- As a special case, settings that don't change are nil
		result, errormessage = auth.change_settings(self, userdata.value.userid.value, userdata.value.username.value, userdata.value.password.value, userdata.value.password_confirm.value, userdata.value.roles.value)
		if result == false then
			userdata.errtxt = "Failed to save changes"
		end
		-- We can't return any nil values, so set then
		local olduserdata = read_user(self, userdata.value.userid.value)
		for name,value in pairs(userdata.value) do
			if value.value == nil then
				value.value = olduserdata.value[name].value
			end
		end
	end
	
	userdata.value.password.value = ""
	userdata.value.password_confirm.value = ""

	if result == false then
		-- now, copy in the errors
		for name,value in pairs(userdata.value) do
			value.errtxt = errormessage[name]
		end
	end

	return userdata
end

function get_users(self)
	--List all users and their userinfo
	local users = {}
	local userlist = auth.list_users(self)
	
	for x,user in pairs(userlist) do
		local userinfo = auth.get_userinfo(self,user)
		users[user] = cfe({
			type="group",
			label=user,
			value={	userid=cfe ({
					label="User ID",
					value=userinfo.userid,
					}),
				username=cfe ({
					label="Real name",
					value=userinfo.username,
					}),
				roles=cfe ({
					label="Roles",
					value=userinfo.roles,
					option=auth.list_roles(),
					type="multi",
					}),
				},

			})
	end

	return cfe({ type="group", value=users, label="User Configs" })
end

function delete_user(self, userid)
	local result, errmessages = auth.delete_user(self, userid)
	local value
	if result then value = "User Deleted" else value = "Failed to Delete User" end
	local errtxt
	if #errmessages > 0 then errtxt = errmessages:concat("\n") end
	return cfe({ value=value, errtxt=errtxt, label="Delete User Result" })
end
