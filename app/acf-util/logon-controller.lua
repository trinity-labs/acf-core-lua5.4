-- Logon / Logoff functions

module (..., package.seeall)

default_action = "status"

-- Logon a new user based upon id and password in clientdata
logon = function(self)
	local cmdresult = cfe({ value=clientdata.userid or "", name="User ID" })
	if clientdata.userid and clientdata.password then
		local logon = self.model:logon(clientdata, conf.clientip, conf.sessiondir, sessiondata)
		-- If successful logon, redirect to status, otherwise try again
		if logon.value then
			redirect(self, "status")
		else
			cmdresult.errtxt = "Logon Attempt Failed"
		end
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
	local name = cfe({ name="User Name" })
	local sessionid = cfe({ value=self.sessiondata.id or "", name="Session ID" })
	if self.sessiondata.userinfo then
		name.value = self.sessiondata.userinfo.username or ""
	end
	return cfe({ type="group", value={username=name, sessionid=sessionid} })
end
