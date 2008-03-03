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

local function check_logonstatus(self)
	-- Redirect the user if he's not logged in.
	if not (self.sessiondata.userinfo) then
		self.conf.action = "logon"
		self.conf.controller = "logon"
		self.conf.type = "redir"
		error (self.conf)
		return self
	end
end

local function get_config(self,userid)
	local config = {}
	local userinfo = {}
	if (#userid > 0) then
		userinfo=auth.get_userinfo(self,userid)
	end
	if not (userinfo) then
		userinfo = {userid = "", username = "", roles = {} }
	end

	-- Get list of available roles
	local avail_roles=auth.list_roles()

--	config.debug = userid		-- Debug info

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
		})
	config.password_confirm =  cfe({
		name="password_confirm",
		label="Password (confirm)",
		type="passwd",
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

	-- Redirect the user if he's not logged in.
	check_logonstatus(self)

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
--			debug=userinfo,		-- Debug info
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
		local errormessage = ""
		-- Check if this user has got any errors in the config
		if (userinfo.password == "") or (userinfo.password == nil) then
			errormessage = "This user has no password! ".. errormessage
		end
		-- Check if user has no roles
		if (table.maxn(userinfo.roles) == 0) then
			errormessage = "This user has no roles! " .. errormessage
		end
		-- If there where any errormessages, then present them
		if (#errormessage > 0) then
			status.users[k].value.errors = cfe ({
				name="errors",
				label="Attention",
				value=errormessage,
				})
		end
	end

	--Create a button for 'New user account'
	status.cmdnew = cfe ({
		name="cmdnew",
		type="submit",
		label="Create new account",
		value="Create",
--		disabled="yes",
		})
	return {	status=status }
end

function administrator(self)

	-- Redirect the user if he's not logged in.
	check_logonstatus(self)

	local output = {}

	-- Check for admin persmissions - else redirect to personal options
	if not (admin_permission()) then
		self.conf.action = "edit_me"
		self.conf.type = "redir"
		return edit_me(self)
	end

	-- Output userinfo
	output = get_config(self,(self.clientdata.orguserid or self.clientdata.userid or ""))

	-- Clear password-field
	output.password.value = ""

	-- Add some buttons
	output.cmdsave = cfe ({
		name="cmdsave",
		type="submit",
		label="Save changes",
		value="Save",
		})
	output.cmddelete = cfe ({
		name="cmddelete",
		type="submit",
		label="Delete this account",
		value="Delete",
		})

	return {config=output}
end

function edit_me(self)

	-- Redirect the user if he's not logged in.
	check_logonstatus(self)

	-- Output userinfo
	local output = get_config(self,sessiondata.userinfo.userid)

	-- Hide roles/cmddelete for current the user
	output.roles = nil
	output.cmddelete = nil

	-- Disable userid
	output.userid.disabled = "yes"

	-- Set userid
	output.orguserid.value = self.sessiondata.userinfo.userid

	-- Add save-button
	output.cmdsave = cfe ({
		name="cmdsave",
		type="submit",
		label="Save changes",
		value="Save",
		})

	return {config=output}
end

local clientdata_from_roles = function(self)
	local output = {}

	for k,v in pairs(auth.list_roles()) do
		if (self.clientdata[v]) then
			table.insert(output, v)
		end
	end
	
	return output
end

function save(self)
	-- Redirect the user if he's not logged in.
	check_logonstatus(self)

	local errormessage = {}
	local cmdresult = {}

	-- FIXME: Check if user is allowed to save settings
	-- FIXME: If user has little priviliges, then see to that he only can change hes own settings
	--   At the moment... the user could send self.clientdata.orguserid = 'someoneelseid' and change hes settings.
	--   This field is hidden for user... but advanced users could probably workaround somehow.

	-- Delete selected user
	if (clientdata.cmddelete) then
		cmdresult["delete"],errormessage["delete"] = auth.delete_user(self,self.clientdata.orguserid)
	end

	-- If userid-filed is disabled, then use orguserid instead (hidden filed)
	if not (self.clientdata.userid) then
		self.clientdata.userid = self.clientdata.orguserid
	end

	-- We start changing things based on input
	if (clientdata.cmdsave) then
		-- Check if password is written correct
		if (self.clientdata.password == self.clientdata.password_confirm) and 
		  (#self.clientdata.userid > 0) then
			-- Check if we are editing a existing user or creating a new one
			if (#clientdata.orguserid > 0) then
				local variables="username userid roles"
				-- Change password if user entered any values
				if (#self.clientdata.password > 0) then 
					variables = variables .. " password" 
				end
				-- Concate roles into one chunk of data (needed by the model)
				self.clientdata.roles = table.concat(clientdata_from_roles(self), ",")

--				cmdresult.debugs = self.clientdata.orguserid	-- Debug information
				for var in string.gmatch(variables, "%S+") do
					if (self.clientdata[var]) then
						cmdresult["cmdtype"] = "change"
						cmdresult[var],errormessage[var] = auth.change_settings(
							self,
							self.clientdata.orguserid, 
							var, self.clientdata[var]
							)
					end
				end
			else
				-- We are about to create a new user
				cmdresult["cmdtype"] = "new"
				cmdresult["new"],errormessage["new"] = auth.new_settings(
					self,
					self.clientdata.userid,
					self.clientdata.username,
					self.clientdata.password,
					self.clientdata.password_confirm,
					clientdata_from_roles(self)
				 	)
			end
		elseif (self.clientdata.password ~= self.clientdata.password_confirm) then		
			errormessage.none = {password_confirm = "You entered wrong password/confirmation"}
		elseif (#self.clientdata.userid == 0) then		
			errormessage.none = {userid = "Userid can not be blank!"}
		end
	end

	-- Fetch saved values
	local output = administrator(self)

	-- Report errors from previously entered values (present this error for the user)
	if (cmdresult["cmdtype"] == "new") then
		-- Report where the user entered som errors
		for k,v in pairs(errormessage["new"]) do
			output.config[k].errtxt = v
		end
	else
		-- Report where the user entered som errors
		for k,v in pairs(errormessage) do
			for kk,vv in pairs(v) do
				output.config[kk].errtxt = vv
			end
		end
	end

	-- If there was any errormessage then return to previous page and present the errormessage
	for k,v in pairs(errormessage) do
		for kk,vv in pairs(v) do

			-- Incase we entered some invalid options, but entered correct Password (and it has been changed)
			-- then inform the user that the password has been changed
			if (cmdresult.password) then
				output.config.password.descr = "* Password has been changed!"
			end

			-- Write the previously entered information on the screen.
			for k,v in pairs(self.clientdata) do
				if (output.config[k]) and (k == roles) then
					table.insert(output.config[k].option, v)
				elseif (output.config[k]) then
					output.config[k].value = v
				end
			end

			-- Because something went wrong... clear the password and let the user re-enter the password/confirmation
			output.config.password.value = ""
			output.config.password_confirm.value = ""

			-- Debug information
--			output.config.debugcmdresult  = cmdresult	-- Debug information

			-- Redirect page
			self.conf.action = "administrator"
			self.conf.type = "redir"
			return output
		end
	end

	--If everything went OK then redirect to main page
	self.conf.action = "status"
	self.conf.type = "redir"
	return status(self)
end
