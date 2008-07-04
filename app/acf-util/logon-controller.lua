-- Logon / Logoff functions

module (..., package.seeall)

default_action = "status"

-- Logon a new user based upon id and password in clientdata
logon = function(self)
	local userid = cfe({ value=clientdata.userid or "", label="User ID" })
	local password = cfe({ label="Password" })
	local cmdresult = cfe({ type="form", value={userid=userid, password=password}, label="Logon", option="Logon" })
	if clientdata.Logon then
		local logon = self.model:logon(clientdata.userid, clientdata.password, conf.clientip, conf.sessiondir, sessiondata)
		-- If successful logon, redirect to welcome-page, otherwise try again
		if logon.value then
			cmdresult.descr = "Logon Successful"
		else
			cmdresult.errtxt = "Logon Attempt Failed"
		end
		cmdresult = self:redirect_to_referrer(cmdresult)
		if logon.value then
			redirect(self, "/welcome/read")
		end
	else
		cmdresult = self:redirect_to_referrer() or cmdresult
	end
	return cmdresult
end

-- Log out current user and go to login screen
logout = function(self)
	local logout = self.model.logoff(conf.sessiondir, sessiondata)
	-- We have to redirect so a new session / menu is created
	redirect(self, "logon")
end

-- Report the login status
status = function(self)
	local name = cfe({ label="User Name" })
	local sessionid = cfe({ value=self.sessiondata.id or "", label="Session ID" })
	if self.sessiondata.userinfo then
		name.value = self.sessiondata.userinfo.username or ""
	end
	return cfe({ type="group", value={username=name, sessionid=sessionid} })
end
