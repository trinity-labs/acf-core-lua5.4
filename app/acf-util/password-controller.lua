module(..., package.seeall)

default_action = "editme"

function status(self)
	return self.model.get_users(self)
end

function editme(self)
	-- just to make sure can't modify any other user from this action
	self.clientdata.userid = sessiondata.userinfo.userid
	self.clientdata.roles = nil
	-- if password is blank, don't update it or require it
	if self.clientdata.password == "" then self.clientdata.password = nil end
	if self.clientdata.password_confirm == "" then self.clientdata.password_confirm = nil end

	-- Update userinfo
	local output = self.model.update_user(self, self.clientdata, false)

	-- Don't allow changing of roles for yourself
	output.value.roles = nil

	output.label = "Edit My Settings"
	return output
end

function edituser(self)
	-- if password is blank, don't update it or require it
	if self.clientdata.password == "" then self.clientdata.password = nil end
	if self.clientdata.password_confirm == "" then self.clientdata.password_confirm = nil end

	-- Update userinfo
	local output = self.model.update_user(self, self.clientdata, false)

	-- result
	if output.descr and output.errtxt == nil then
		redirect(self, "status")
	end

	output.label = "Edit User Settings"
	return output
end

function newuser(self)
	-- Update userinfo
	local output = self.model.update_user(self, self.clientdata, true)

	-- result
	if output.descr and output.errtxt == nil then
		redirect(self, "status")
	end

	output.label = "New User Settings"
	return output
end

function deleteuser(self)
	self.model.delete_user(self, self.clientdata.userid)
	redirect(self, "status")
end
