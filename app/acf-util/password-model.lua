module(..., package.seeall)

local auth=require("authenticator-plaintext")

function create_user(self, clientdata)
	return update_user(self, clientdata, true)
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

function update_user(self, clientdata, newuser)
	local config
	local result
	local errtxt
	local errormessage = {}

	-- Try to write new or update existing data
	if newuser == true then
		result, errormessage = auth.new_settings(self, clientdata.userid, clientdata.username, clientdata.password, clientdata.password_confirm, clientdata.roles)
		if result == false then
			errtxt = "Failed to create new user"
		end
	else
		result, errormessage = auth.change_settings(self, clientdata.userid, clientdata.username, clientdata.password, clientdata.password_confirm, clientdata.roles)
		if result == false then
			errtxt = "Failed to save changes"
		end
	end
	
	if result == true then
		config = read_user(self, clientdata.userid)
	else
		-- get a blank table
		config = read_user(self)

		-- now, copy in the user info and errors
		config.value.userid.value = clientdata.userid or ""
		config.value.userid.errtxt = errormessage.userid
		config.value.username.value = clientdata.username or config.value.username.value
		config.value.username.errtxt = errormessage.username
		config.value.roles.value = clientdata.roles or config.value.roles.value
		config.value.roles.errtxt = errormessage.roles
		--config.value.password.value = clientdata.password or config.value.password.value
		config.value.password.errtxt = errormessage.password
		--config.value.password_confirm.value = clientdata.password_confirm or config.value.password_confirm.value
		config.value.password_confirm.errtxt = errormessage.password_confirm
		config.errtxt = errtxt
	end

	return config
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
	auth.delete_user(self, userid)
end
