-- Roles/Group functions

module (..., package.seeall)

auth = require("authenticator-plaintext")
roll = require("roles")

default_action = "read"

-- Return your own roles/permissions
read = function(self)
	userid = cfe({ value=self.sessiondata.userinfo.userid, label="User Id" })
	roles = cfe({ type="list", value=self.sessiondata.userinfo.roles, label="Roles" })
	permissions = cfe({ type="table", value = self.sessiondata.permissions, label="Permissions" })
	return cfe({ type="group", value={userid=userid, roles=roles, permissions=permissions} })
end

-- Return roles/permissions for specified user
viewroles = function(self)
	if not (self.clientdata.userid) then
		redirect(self)
	end
	userid = cfe({ value=self.clientdata.userid, label="User Id" })
	roles = cfe({ type="list", value=auth.get_userinfo_roles(self, userid.value), label="Roles" })
	permissions = cfe({ type="table", value=roll.get_roles_perm(self.conf.appdir, roles.value), label="Permissions" })
	return cfe({ type="group", value={userid=userid, roles=roles, permissions=permissions} })
end

-- Return permissions for specified role
viewperms = function(self)
	if not (self.clientdata.role) then
		redirect(self, "getlist")
	end
	role = cfe({ value=self.clientdata.role, label="Role" })
	permissions = cfe({ type="table", value=roll.get_role_perm(self.conf.appdir, role.value), label="Permissions" })
	return cfe({ type="group", value={role=role, permissions=permissions} })
end

-- Return list of all permissions
getlist = function(self)
	return cfe({ type="group", value={permissions=self.model:getcont(self)} })
end
