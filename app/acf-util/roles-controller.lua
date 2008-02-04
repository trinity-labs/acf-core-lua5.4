-- Roles/Group functions

module (..., package.seeall)

--require ("session")
	
mvc.on_load = function(self, parent)
     if (self.worker[self.conf.action] == nil ) or ( self.conf.action == "init" ) then
      self.worker[self.conf.action] = list_redir(self)
      end
 --logit ("logon.mvc.on_load activated")
 end

read = function(self)
	return( {read= self.model:read(clientdata.sessionid)})
end

getlist = function(self)
	return( { contlist = self.model:getcont(self)})
end
