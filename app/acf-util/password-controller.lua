module(..., package.seeall)

local list_redir = function (self)
	self.conf.action = "status"
	self.conf.type = "redir"
	error (self.conf)
end

mvc = {}
mvc.on_load = function(self, parent)
	if (self.worker[self.conf.action] == nil ) or ( self.conf.action == "init" ) then
		self.worker[self.conf.action] = list_redir(self)
	end
end

function status(self)
	local status=self.model.getstatus(self)
	status.cmdnew = cfe ({
		name="cmdnew",
		type="submit",
		label="Create new account",
		value="Create",
		disabled="yes",
		})
	return { status=status }
end

function edit(self)
	local config=self.model.getsettings(self.clientdata.userid)
	config.cmdsave = cfe ({
		name="cmdsave",
		type="submit",
		label="Save changes",
		value="Save",
		disabled="yes",
		})
	config.cmddelete = cfe ({
		name="cmddelete",
		type="submit",
		label="Delete this account",
		value="Delete",
		disabled="yes",
		})

	return { config=config, clientdata=self.clientdata }
end

