module(..., package.seeall)

local auth=require("authenticator-plaintext")

function update_user(self, clientdata, newuser)
	local config = {}
	local errtxt
	local descr
	local errormessage = {}

	-- Try to write new or update existing data
	-- if clientdata.username exists, then pretty sure trying to write
	if newuser == true then
		if clientdata.username then
			result, errormessage = auth.new_settings(self, clientdata.userid, clientdata.username, clientdata.password, clientdata.password_confirm, clientdata.roles)
			if result == true then
				descr = "Created new user"
			else
				errtxt = "Failed to create new user"
			end
		end
	else
		result, errormessage = auth.change_settings(self, clientdata.userid, clientdata.username, clientdata.password, clientdata.password_confirm, clientdata.roles)
		if result == true and clientdata.username then
			descr = "Saved changes"
		elseif result == false and clientdata.username then
			errtxt = "Failed to save changes"
		elseif result == false then
			errtxt = "Bad user id"
		end
	end
	
	-- Now, read the updated / existing data
	local userinfo
	if ( errtxt == nil ) and clientdata.userid and (#clientdata.userid > 0) then
		userinfo = auth.get_userinfo(self,clientdata.userid)
	end
	userinfo = userinfo or {}

	-- Get list of available roles
	local avail_roles=auth.list_roles()

	config.userid =  cfe({
		label="User id",
		value=(userinfo.userid or clientdata.userid or ""),
		errtxt = errormessage.userid
		})
	config.username =  cfe({
		label="Real name",
		value=(userinfo.username or clientdata.username or ""),
		errtxt = errormessage.username
		})
	config.roles =  cfe({
		label="Roles",
		value=(userinfo.roles or clientdata.roles or {}),
		type="multi",
		option=avail_roles,
		errtxt = errormessage.roles
		})
	config.password =  cfe({
		label="Password",
		errtxt = errormessage.password
		})
	config.password_confirm =  cfe({
		label="Password (confirm)",
		errtxt = errormessage.password_confirm
		})

	return cfe({ type="form", value=config, errtxt = errtxt, descr = descr, label="User Config" })
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
