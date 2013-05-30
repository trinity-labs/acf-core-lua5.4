-- Logon / Logoff functions

module (..., package.seeall)

default_action = "status"

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
logon = function(self)
	local userid = cfe({ value=clientdata.userid or "", label="User ID", seq=1 })
	local password = cfe({ type="password", label="Password", seq=2 })
	local redir = cfe({ type="hidden", value=clientdata.redir, label="" })
	local cmdresult = cfe({ type="form", value={userid=userid, password=password, redir=redir}, label="Logon", option="Logon" })
	if clientdata.submit then
		local logonredirect = self.sessiondata.logonredirect
		local logon = self.model:logon(clientdata.userid, clientdata.password, conf.clientip, conf.sessiondir, sessiondata)
		-- If successful logon, redirect to welcome-page, otherwise try again
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
			redirect(self, cmdresult.value.redir.value)
		end
	else
		if check_users(self) then return end
		cmdresult = self:redirect_to_referrer() or cmdresult
	end
	return cmdresult
end

-- Log off current user and go to logon screen
logoff = function(self)
	local logoff = self.model.logoff(conf.sessiondir, sessiondata)
	-- We have to redirect so a new session / menu is created
	redirect(self, "logon")
	return logoff
end

-- Report the logon status
status = function(self)
	local name = cfe({ label="User Name" })
	local sessionid = cfe({ value=self.sessiondata.id or "", label="Session ID" })
	if self.sessiondata.userinfo then
		name.value = self.sessiondata.userinfo.username or ""
	end
	return cfe({ type="group", value={username=name, sessionid=sessionid}, label="Logon Status" })
end
