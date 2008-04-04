-- Logon / Logoff functions

module (..., package.seeall)

--require ("session")
	
mvc.on_load = function(self, parent)
     if (self.worker[self.conf.action] == nil ) or ( self.conf.action == "init" ) then
      self.worker[self.conf.action] = list_redir(self)
      end
 --logit ("logon.mvc.on_load activated")
 end

logon = function(self)
	return ( {logon=self.model.logon(self, clientdata.userid, clientdata.password,clientdata.sessionid) })
end

logout = function(self)
	local logout = self.model:logoff(clientdata.sessionid)
	if (logout) and (logout[1]) and (logout[1]["value"]) and (string.lower(logout[1]["value"]) == "successful") then
		self.conf.action = "logon"
		self.conf.type = "redir"
		error (self.conf)
	end

	return  { logout = logout } 
end

status = function(self)
	return( {stats= self.model:status(clientdata.sessionid) })
end
