module(..., package.seeall)
require("controllerfunctions")
require("roles")

default_action = "editme"

function status(self)
	return self.model.get_users(self)
end

function editme(self)
	-- just to make sure can't modify any other user from this action
	self.clientdata.userid = self.sessiondata.userinfo.userid
	return controllerfunctions.handle_form(self, function()
			local value = self.model.read_user(self, self.sessiondata.userinfo.userid)
			-- We don't allow a user to modify his own roles
			-- Since they can't modify roles, we should restrict the available options for home
			value.value.home.option = {""}
			local tmp1, tmp2 = roles.get_roles_perm(self, value.value.roles.value)
	        	table.sort(tmp2)
			for i,h in ipairs(tmp2) do
				value.value.home.option[#value.value.home.option+1] = h
			end
			value.value.roles = nil
			return value
		end, function(value)
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
	return controllerfunctions.handle_form(self, function()
			return self.model.read_user(self, self.clientdata.userid)
		end, function(value)
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
	return controllerfunctions.handle_form(self, function()
			return self.model.read_user(self)
		end, function(value)
			return self.model.create_user(self, value)
		end, self.clientdata, "Create", "Create New User", "Created user")
end

function deleteuser(self)
	return self:redirect_to_referrer(self.model.delete_user(self, self.clientdata.userid))
end
