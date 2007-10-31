module (..., package.seeall)

-- Cause an http redirect to our "read" action
-- We use the self.conf table because it already has prefix,controller,etc
-- The redir code is defined in the application error handler (acf-controller)
local list_redir = function (self)
	self.conf.action = "read"
	self.conf.type = "redir"
	error (self.conf)
end

mvc={}
mvc.on_load = function(self, parent)
	if (self.worker[self.conf.action] == nil ) or ( self.conf.action == "init" ) then
		self.worker[self.conf.action] = list_redir(self)
	end
end

-- Public methods

read = function (self )
	return ({logfile = self.model:get("/var/log/mini_httpd.log")} )
end

--update = function (self)
--	return nil
--end

--delete = function (self)
--	return nil
--end

--create = update
