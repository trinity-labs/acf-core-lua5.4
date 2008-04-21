-- Logon / Logoff functions

module (..., package.seeall)

mvc = {}
mvc.on_load = function(self, parent)
	self.conf.default_action = "status"
end

-- Logon a new user based upon id and password in clientdata
logon = function(self)
	local cmdresult
	if clientdata.userid and clientdata.password then
		local logon = self.model:logon(clientdata, conf.clientip, conf.sessiondir, sessiondata)
		-- If successful logon, redirect to status, otherwise try again
		if logon then
			self.conf.action = "status"
			self.conf.type = "redir"
			error(self.conf)
		else
			cmdresult = "Logon Attempt Failed"
		end
	end
	return ({ cmdresult = cmdresult })
end

-- Log out current user and go to login screen
logout = function(self)
	local logout = self.model.logoff(conf.sessiondir, sessiondata)
	-- We have to redirect so a new session / menu is created
	self.conf.action = "logon"
	self.conf.type = "redir"
	error (self.conf)
end

-- Report the login status
status = function(self)
	return self.model.status(sessiondata)
end
