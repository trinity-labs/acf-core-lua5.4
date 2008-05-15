module(..., package.seeall)

default_action = "editme"

function status(self)
	return self.model.get_users(self)
end

function editme(self)
	local output
	if clientdata.Save then
		-- just to make sure can't modify any other user from this action
		self.clientdata.userid = self.sessiondata.userinfo.userid
		self.clientdata.roles = nil
		-- if password is blank, don't update it or require it
		if self.clientdata.password == "" then self.clientdata.password = nil end
		if self.clientdata.password_confirm == "" then self.clientdata.password_confirm = nil end

		-- Update userinfo
		output = self.model.update_user(self, self.clientdata)

		if not output.errtxt then
			output.descr = "Saved user"
		end
	else
		output = self.model.read_user(self, self.sessiondata.userinfo.userid)
	end

	-- Don't allow changing of roles for yourself
	output.value.roles = nil

	output.type = "form"
	output.label = "Edit My Settings"
	output.option = "Save"
	return output
end

function edituser(self)
	local output
	if self.clientdata.Save then
		-- if password is blank, don't update it or require it
		if self.clientdata.password == "" then self.clientdata.password = nil end
		if self.clientdata.password_confirm == "" then self.clientdata.password_confirm = nil end

		-- Update userinfo
		output = self.model.update_user(self, self.clientdata)

		-- result
		if not output.errtxt then
			redirect(self, "status")
		end
	else
		output = self.model.read_user(self, self.clientdata.userid)
	end

	output.type = "form"
	output.label = "Edit User Settings"
	output.option = "Save"
	return output
end

function newuser(self)
	local output
	if self.clientdata.Save then
		-- Update userinfo
		output = self.model.create_user(self, self.clientdata)
		
		-- result
		if not output.errtxt then
			redirect(self, "status")
		end
	else
		output = self.model.read_user(self)
	end

	output.type = "form"
	output.label = "New User Settings"
	output.option = "Save"
	return output
end

function deleteuser(self)
	self.model.delete_user(self, self.clientdata.userid)
	redirect(self, "status")
end
