-- Logon / Logoff functions

module (..., package.seeall)

require ("session")

mvc.on_load = function(self, parent)
	-- If they specify an invalid action or try to run init, then redirect
	-- to the read function.
	if ( self.conf.action == nil  or self.conf.action == "init" )  then
		-- do what?
	end
	
end


logon = function(self)
	
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
			session.id = session.random_hash ( 512)
			session.userinfo = t or {}
			self.conf.controller="welcome"
			self.conf.action = ""
			self.conf.type = "redir"
			logevent ("Logon was successful for " .. session.userinfo.username or "" )
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
	self.model.logout(self, session.id)


        -- and raise an error to go to the homepage
	self.conf.action = ""
	self.conf.prefix = ""
	self.conf.controller = ""
	self.conf.type = "redir"
	error(self.conf)
end
