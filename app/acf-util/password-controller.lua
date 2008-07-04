module(..., package.seeall)

default_action = "editme"

function status(self)
	return self.model.get_users(self)
end

function editme(self)
	local output = self.model.read_user(self, self.sessiondata.userinfo.userid)
	if clientdata.Save then
		-- just to make sure can't modify any other user from this action
		self.clientdata.userid = self.sessiondata.userinfo.userid
		
		-- As a special case for update_user, settings that don't change are nil
		self.clientdata.roles = nil
		-- if password is blank, don't update it or require it
		if self.clientdata.password == "" then self.clientdata.password = nil end
		if self.clientdata.password_confirm == "" then self.clientdata.password_confirm = nil end

		for name,value in pairs(output.value) do
			value.value = self.clientdata[name]
		end

		-- Update userinfo
		output = self.model.update_user(self, output)
		if not output.errtxt then
			output.descr = "Saved user"
		end
		output = self:redirect_to_referrer(output)
	else
		output = self:redirect_to_referrer() or output
	end

	-- Don't allow changing of roles for yourself
	output.value.roles = nil

	output.type = "form"
	output.label = "Edit My Settings"
	output.option = "Save"
	return output
end

function edituser(self)
	local output = self.model.read_user(self, self.clientdata.userid)
	if self.clientdata.Save then
		-- As a special case for update_user, settings that don't change are nil
		-- if password is blank, don't update it or require it
		if self.clientdata.password == "" then self.clientdata.password = nil end
		if self.clientdata.password_confirm == "" then self.clientdata.password_confirm = nil end

		for name,value in pairs(output.value) do
			value.value = self.clientdata[name]
		end

		-- Update userinfo
		output = self.model.update_user(self, output)
		if not output.errtxt then
			redirect(self, "status")
		end
		output = self:redirect_to_referrer(output)
	else
		output = self:redirect_to_referrer() or output
	end

	output.type = "form"
	output.label = "Edit User Settings"
	output.option = "Save"
	return output
end

function newuser(self)
	local output = self.model.read_user(self)
	if self.clientdata.Save then
		for name,value in pairs(output.value) do
			if self.clientdata[name] then
				value.value = self.clientdata[name]
			end
		end

		-- Update userinfo
		output = self.model.create_user(self, output)
		if not output.errtxt then
			redirect(self, "status")
		end
		output = self:redirect_to_referrer(output)
	else
		output = self:redirect_to_referrer() or output
	end

	output.type = "form"
	output.label = "New User Settings"
	output.option = "Save"
	return output
end

function deleteuser(self)
	return self:redirect_to_referrer(self.model.delete_user(self, self.clientdata.userid))
end
