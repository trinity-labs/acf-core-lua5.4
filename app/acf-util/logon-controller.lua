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
	return  { logout = self.model:logoff(clientdata.sessionid) } 
end

status = function(self)
	return( {stats= self.model:status(clientdata.sessionid) })
end
