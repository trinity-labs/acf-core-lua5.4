-- Roles/Group functions

module (..., package.seeall)

default_action = "read"

-- Return your own roles/permissions
read = function(self)
	userid = cfe({ value=self.sessiondata.userinfo.userid, label="User Id" })
	roles = cfe({ type="list", value=self.sessiondata.userinfo.roles, label="Roles" })
	permissions = cfe({ type="table", value = self.sessiondata.permissions, label="Permissions" })
	return cfe({ type="group", value={userid=userid, roles=roles, permissions=permissions} })
end

-- Return roles/permissions for specified user
viewuserroles = function(self)
	if not (self.clientdata.userid) then
		redirect(self)
	end
	userid = cfe({ value=self.clientdata.userid, label="User Id" })
	roles = self.model.get_user_roles(self, userid.value)
	roles.value.userid = userid
	return roles
end

-- Return permissions for specified role
viewroleperms = function(self)
	if not (self.clientdata.role) then
		redirect(self, "getlist")
	end
	role = cfe({ value=self.clientdata.role, label="Role" })
	permissions = self.model.get_role_perms(self, role.value)
	return cfe({ type="group", value={role=role, permissions=permissions} })
end

-- Return list of all permissions
getpermslist = function(self)
	return cfe({ type="group", value={permissions=self.model.get_perms_list()} })
end

viewroles = function(self)
	-- Get command result out of session data
	local cmdresult = self.sessiondata.cmdresult
	self.sessiondata.cmdresult = nil

	local roles = self.model.view_roles()
	roles.value.cmdresult = cmdresult

	return roles
end

newrole = function(self)
	local form = self.model.setpermissions(self, self.clientdata.role, self.clientdata.permissions, true)
	form.type = "form"
	form.label = "Edit new role"
	if form.value.role.errtxt then
		form.errtxt = "Failed to create role"
	elseif self.clientdata.permissions then
		-- If we have permissions, we tried to set
		local cmdresult = cfe({ value="New role created" })
		self.sessiondata.cmdresult = cmdresult
		redirect(self, "viewroles")
	end
	return form
end

editrole = function(self)
	local form = self.model.setpermissions(self, self.clientdata.role, self.clientdata.permissions, false)
	form.type = "form"
	form.label = "Edit role"
	if form.value.role.errtxt then
		form.errtxt = "Failed to save role"
	elseif self.clientdata.permissions then
		-- If we have permissions, we tried to set
		local cmdresult = cfe({ value="Role saved" })
		self.sessiondata.cmdresult = cmdresult
		redirect(self, "viewroles")
	end
	return form
end

deleterole = function(self)
	self.sessiondata.cmdresult = self.model.delete_role(self.clientdata.role)
	redirect(self, "viewroles")
end
