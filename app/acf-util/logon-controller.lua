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
--return ( {logon=self.model:logon(self,clientdata.userid, clientdata.password) })
	
local userid=cfe({ name="userid" })
local password=cfe({ name="password" })
local logon=cfe({ name="Logon", type="submit"})
local s = ""

	-- FIXME - if they are already logged in, log out first
	
	if clientdata.userid and clientdata.password then
	local t = self.model.logon(self,clientdata.userid,clientdata.password)
	
		if t == nil then
		userid.value = self.clientdata.userid
			userid.errtxt = "There was a problem logging in"
		else
		-- the login was successful - give them a new session, and redir to logged in
			sessiondata.id = session.random_hash ( 512)
			sessiondata.userinfo = t or {}
			self.conf.prefix="/acf-util/"
			self.conf.controller="logon"
			self.conf.action = "status"
			self.conf.type = "redir"
			error (self.conf)
		end
	end
	-- If we reach this point, just give them the login page
        	return ( cfe ({type="form",
		option={ script=ENV["SCRIPT_NAME"],
		prefix=self.conf.prefix,
		controller = self.conf.controller,
		action = "logon" },
		value = { userid, password, logon } }))
end


logout = function(self)
	return  { logout = self.model:logoff(clientdata.sessionid) } 
end

status = function(self)
	return( {stats= self.model:status(clientdata.sessionid) })
end
