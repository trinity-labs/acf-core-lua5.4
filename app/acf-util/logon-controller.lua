-- Logon / Logoff functions

local mymodule = {}

mymodule.default_action = "status"

-- Logon a new user based upon id and password in clientdata
local check_users = function(self)
	-- If there are no users defined, add privileges and dispatch password/newuser
	local users = self.model:list_users()
	if #users.value == 0 then
		self.sessiondata.permissions[self.conf.prefix].password = {}
		self.sessiondata.permissions[self.conf.prefix].password.newuser = {"temp"}
		self:dispatch(self.conf.prefix, "password", "newuser")
		self.sessiondata.permissions[self.conf.prefix].password = nil
		self.conf.suppress_view = true
		return true
	end

	return false
end

-- Logon a new user based upon id and password in clientdata
mymodule.logon = function(self)
	local userid = cfe({ value=self.clientdata.userid or "", label="User ID", seq=1 })
	local password = cfe({ type="password", label="Password", seq=2 })
	local redir = cfe({ type="hidden", value=self.clientdata.redir, label="" })
	local cmdresult = cfe({ type="form", value={userid=userid, password=password, redir=redir}, label="Logon", option="Logon" })
	if self.clientdata.submit then
		local logonredirect = self.sessiondata.logonredirect
		local logon = self.model:logon(self.clientdata.userid, self.clientdata.password, self.conf.clientip, self.conf.sessiondir, self.sessiondata)
		-- If successful logon, redirect to home or welcome page, otherwise try again
		if logon.value then
			cmdresult.descr = "Logon Successful"
		else
			if check_users(self) then return end
			cmdresult.errtxt = "Logon Attempt Failed"
		end
		cmdresult = self:redirect_to_referrer(cmdresult)
		if logon.value then
			if redir.value == "" then
				if self.sessiondata.userinfo and self.sessiondata.userinfo.home and self.sessiondata.userinfo.home ~= "" then
					redir.value = self.sessiondata.userinfo.home
				elseif self.conf.home and self.conf.home ~= "" then
					redir.value = self.conf.home
				else
					redir.value = "/acf-util/welcome/read"
				end
			end
			-- only copy the logonredirect if redirecting to that page
			if logonredirect and cmdresult.value.redir.value then
				local prefix, controller, action = self.parse_redir_string(cmdresult.value.redir.value)
				if logonredirect.action == action and logonredirect.controller == controller and logonredirect.prefix == prefix then
					self.sessiondata.logonredirect = logonredirect
				end
			end
			self:redirect(cmdresult.value.redir.value)
		end
	else
		if check_users(self) then return end
		cmdresult = self:redirect_to_referrer() or cmdresult
	end
	return cmdresult
end

-- Log off current user and go to logon screen
mymodule.logoff = function(self)
	local logoff = self.model.logoff(self.conf.sessiondir, self.sessiondata)
	-- We have to redirect so a new session / menu is created
	self:redirect("logon")
	return logoff
end

-- Report the logon status
mymodule.status = function(self)
	local name = cfe({ label="User Name" })
	local sessionid = cfe({ value=self.sessiondata.id or "", label="Session ID" })
	if self.sessiondata.userinfo then
		name.value = self.sessiondata.userinfo.username or ""
	end
	return cfe({ type="group", value={username=name, sessionid=sessionid}, label="Logon Status" })
end

return mymodule
