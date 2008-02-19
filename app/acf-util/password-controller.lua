module(..., package.seeall)

auth=require("authenticator-plaintext")

local list_redir = function (self)
	self.conf.action = "status"
	self.conf.type = "redir"
	error (self.conf)
end

mvc = {}
mvc.on_load = function(self, parent)
	if (self.worker[self.conf.action] == nil ) or ( self.conf.action == "init" ) then
		self.worker[self.conf.action] = list_redir(self)
	end
end

local function admin_permission()
	if (sessiondata.userinfo) and (sessiondata.userinfo.userid == "alpine") then
		return true
	else
		return false
	end
end

local function config(self,userid)
	local config = {}
	local userinfo = {}
	if (userid) then
		userinfo=auth.get_userinfo(self,userid)
	else
		userinfo.userid = ""
		userinfo.username = ""
		userinfo.roles = {}

	end
	local avail_roles=auth.list_roles()

	config.debug = userid

	config.userid =  cfe({
		name="userid",
		label="User id",
		value=(userinfo.userid or ""),
		})
	config.orguserid = cfe({
		name="orguserid",
		value=(userinfo.userid or ""),
		type="hidden",
		})
	
	config.username =  cfe({
		name="username",
		label="User name",
		value=userinfo.username,
		})
	config.roles =  cfe({
		name="roles",
		label="Roles",
		option=userinfo.roles,
		type="select",
		size=#avail_roles,
		})
	config.password =  cfe({
		name="password",
		label="Password",
		type="passwd",
		disabled="yes",
		})
	config.password_confirm =  cfe({
		name="password_confirm",
		label="Password (confirm)",
		type="passwd",
		disabled="yes",
		})

	config.availableroles =  cfe({
		name="availableroles",
		label="Available roles",
		type="select",
		option=avail_roles,
		})

	return config
end

function status(self)
	local status = {}

	-- Check for admin persmissions - else redirect to personal options
	if not (admin_permission()) then
		self.conf.action = "edit_me"
		return edit_me(self)
	end

	-- Redirect when creating a new account
	if (clientdata.cmdnew) then
		self.conf.action = "administrator"
		self.conf.type = "redir"

		return administrator(self)
	end

	--List all users and their userinfo
	status.users = {}
	local userlist = auth.list_users(self)
	for k,v in pairs(userlist) do
		local userinfo = auth.get_userinfo(self,v)
		status.users[k] = cfe({
			name=v,
			label=v,
--			debug=userinfo,
			value={	userid=cfe ({
					name="userid",
					label="User ID",
					value=userinfo.userid,
					}),
				username=cfe ({
					name="username",
					label="User name",
					value=userinfo.username,
					}),
				roles=cfe ({
					name="roles",
					label="Roles",
					value=table.concat(userinfo.roles," / "),
					option=userinfo.roles,
					type="select",
					}),
				},

			})
	end

	--Create a button for 'New user account'
	status.cmdnew = cfe ({
		name="cmdnew",
		type="submit",
		label="Create new account",
		value="Create",
--		disabled="yes",
		})
	return { status=status }
end

function administrator(self)
	local output = {}

	-- Check for admin persmissions - else redirect to personal options
	if not (admin_permission()) then
		self.conf.action = "edit_me"
		return edit_me(self)
	end

	-- Output userinfo
	output = config(self,self.clientdata.userid)

	--Clear password-field
	output.password.value = ""

	-- Add some buttons
	output.cmdsave = cfe ({
		name="cmdsave",
		type="submit",
		label="Save changes",
		value="Save",
--		disabled="yes",
		})
	output.cmddelete = cfe ({
		name="cmddelete",
		type="submit",
		label="Delete this account",
		value="Delete",
		disabled="yes",
		})

	return {config=output}
end

function edit_me(self)

	--FIXME: Redirect to Welcome or logon if user is not logged on
--	if not ( self.sessiondata.userinfo) then
--		self.conf.action = ""
--		self.conf.type = "redir"
--	end

	-- Output userinfo
	local output = config(self,sessiondata.userinfo.userid)

	--Hide roles/cmddelete for current the user
	output.roles = nil
	output.cmddelete = nil

	--Disable userid
	output.userid.disabled = "yes"

	--Add save-button
	output.cmdsave = cfe ({
		name="cmdsave",
		type="submit",
		label="Save changes",
		value="Save",
		disabled="yes",
		})

	return {config=output}
end

function save(self)

	--FIXME: Check if user is allowed to save settings

	-- We start changing things based on input
	local cmdresult = {}
	cmdresult.debug = {}
	if (clientdata.cmdsave) then
		if (#clientdata.orguserid > 0) then
			local variables="username userid"
			cmdresult.debugs = self.clientdata.orguserid
			for var in string.gmatch(variables, "%S+") do
				if (self.clientdata[var]) then
					cmdresult[var],cmdresult.debug[var] = auth.change_settings(
						self,
						self.clientdata.orguserid, 
						var, self.clientdata[var]
						)
				end
			end
		else
			cmdresult["new"],cmdresult.debug["new"] = auth.new_settings(
				self,
				self.clientdata.userid,
				self.clientdata.username,
				self.clientdata.password,
				self.clientdata.password_confirm )
		end
	end

	cmdresult.clientdata = self.clientdata

	return cmdresult
--[[
	--FIXME: Redirect somewhere when changed settings
	self.conf.action = "status"
	self.conf.type = "redir"
	
	return status(self)
--]]
end
