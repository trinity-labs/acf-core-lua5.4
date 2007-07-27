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
	
	local username=cfe({ name="username" })
	local password=cfe({ name="password" })
	local logon=cfe({ name="Logon", type="submit"})
	local s = ""

	if self.clientdata.username and self.clientdata.password then
	if self.model.logon(self, self.clientdata.username, self.clientdata.password) == false then
		username.value = self.clientdata.username
		if self.session.id then
			username.errtxt = "You are already logged in. Logout first."
		else
			username.errtxt = "There was a problem logging in"
		end
	else
		self.conf.controller = ""
		self.conf.action = ""
		self.conf.prefix = ""
		self.conf.type = "redir"
		error(self.conf)
	end
	end
	-- If we reach this point, just give them the login page
        return ( cfe ({type="form",
	option={ script=ENV["SCRIPT_NAME"],
	prefix=self.conf.prefix,
	controller = self.conf.controller,
	action = "logon" },
	value = { username, password, logon } }))
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
