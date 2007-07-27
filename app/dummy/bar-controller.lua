-- A standin controller for testing

module (..., package.seeall)

-- Cause an http redirect to our "read" action
-- We use the self.conf table because it already has prefix,controller,etc
-- The redir code is defined in the application error handler (acf-controller)
local list_redir = function (self)
	self.conf.action = "read"
	self.conf.type = "redir"
	error (self.conf)
end


--init ( init by definition is a public method)
init = function(self, parent)
	-- If they specify an invalid action or try to run init, then redirect
	-- to the read function.
	if ( self.conf.action == nil  or self.conf.action == "init" )  then
		list_redir(self)
	end
	-- Make a function by the action name
	self.worker[self.conf.action] = function ()
		return cfe ( {name=self.conf.action, value=self.conf.action} )
		
		end
	
end


read = function (self )
	return ( { } )
end


