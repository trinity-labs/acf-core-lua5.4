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
	return cfe({ type="group", value={permissions=self.model.get_perms_list(self)} })
end

viewroles = function(self)
	return self.model.view_roles(self)
end

newrole = function(self)
	return self.handle_form(self, self.model.getpermissions, self.model.setnewpermissions, self.clientdata, "Create", "Create New Role", "New Role Created")
end

editrole = function(self)
	return self.handle_form(self, self.model.getpermissions, self.model.setpermissions, self.clientdata, "Save", "Edit Role", "Role Saved")
end

deleterole = function(self)
	return self.handle_form(self, self.model.get_delete_role, self.model.delete_role, self.clientdata, "Delete", "Delete Role", "Role Deleted")
end
