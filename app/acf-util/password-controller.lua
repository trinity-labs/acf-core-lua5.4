module(..., package.seeall)
require("roles")

default_action = "editme"

function status(self)
	return self.model.get_users(self)
end

function editme(self)
	-- just to make sure can't modify any other user from this action
	self.clientdata.userid = self.sessiondata.userinfo.userid
	return self.handle_form(self, function()
			local value = self.model.read_user(self, self.sessiondata.userinfo.userid)
			-- We don't allow a user to modify his own roles
			-- Since they can't modify roles, we should restrict the available options for home
			value.value.home.option = {""}
			local tmp1, tmp2 = roles.get_roles_perm(self, value.value.roles.value)
	        	table.sort(tmp2)
			for i,h in ipairs(tmp2) do
				if h ~= "/acf-util/logon/logout" and h ~= "/acf-util/logon/logon" then
					value.value.home.option[#value.value.home.option+1] = h
				end
			end
			value.value.roles = nil
			return value
		end, function(self, value)
			-- If password and password_confirm are blank, don't set them
			local pw, pwc
			if value.value.password.value == "" and value.value.password_confirm.value == "" then
				pw = value.value.password
				pwc = value.value.password_confirm
				value.value.password = nil
				value.value.password_confirm = nil
			end
			value = self.model.update_user(self, value)
			if pw then
				value.value.password = pw
				value.value.password_confirm = pwc
			end
			return value
		end, self.clientdata, "Save", "Edit My Settings", "Saved user")
end

function edituser(self)
	return self.handle_form(self, function()
			return self.model.read_user(self, self.clientdata.userid)
		end, function(self, value)
			-- If password and password_confirm are blank, don't set them
			local pw, pwc
			if value.value.password.value == "" and value.value.password_confirm.value == "" then
				pw = value.value.password
				pwc = value.value.password_confirm
				value.value.password = nil
				value.value.password_confirm = nil
			end
			value = self.model.update_user(self, value)
			if pw then
				value.value.password = pw
				value.value.password_confirm = pwc
			end
			return value
		end, self.clientdata, "Save", "Edit User Settings", "Saved user")
end

function newuser(self)
	return self.handle_form(self, function() return self.model.read_user(self) end, self.model.create_user, self.clientdata, "Create", "Create New User", "Created user")
end

function deleteuser(self)
	return self.handle_form(self, self.model.get_delete_user, self.model.delete_user, self.clientdata, "Delete", "Delete User", "Deleted user")
end
