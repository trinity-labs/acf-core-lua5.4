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

mvc = {}
mvc.on_load = function(self, parent)
	-- It doesn't matter what action they choose - we only support read
	if ( self.conf.action ~= "read") then
		list_redir(self)
	end
end


read = function (self )
	return ( { } )
end


