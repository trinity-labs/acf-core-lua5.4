-- Roles/Group functions

module (..., package.seeall)

auth = require("authenticator-plaintext")
roll = require("roles")

local get_all_permissions = function(self)
	-- need to get a list of all the controllers
	controllers = roles.get_controllers(self)
	local table_perm = {}
	local array_perm = {}
	for a,b in pairs(controllers) do
		if nil == table_perm[b.sname] then
			table_perm[b.sname] = {}
		end
		temp = roles.get_controllers_func(self,b)
		for x,y in ipairs(temp) do
			table_perm[b.sname][y] = {}
			array_perm[#array_perm + 1] = b.sname .. ":" .. y
		end
	end

	return table_perm, array_perm
end

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
	roles = cfe({ type="list", value=auth.get_userinfo_roles(self, userid.value), label="Roles" })
	permissions = cfe({ type="table", value=roll.get_roles_perm(self.conf.appdir, roles.value), label="Permissions" })
	return cfe({ type="group", value={userid=userid, roles=roles, permissions=permissions} })
end

-- Return permissions for specified role
viewroleperms = function(self)
	if not (self.clientdata.role) then
		redirect(self, "getlist")
	end
	role = cfe({ value=self.clientdata.role, label="Role" })
	permissions = cfe({ type="table", value=roll.get_role_perm(self.conf.appdir, role.value), label="Permissions" })
	return cfe({ type="group", value={role=role, permissions=permissions} })
end

-- Return list of all permissions
getpermslist = function(self)
	permissions = cfe({ type="table", value=get_all_permissions(self), label="All Permissions" })
	return cfe({ type="group", value={permissions=permissions} })
end

viewroles = function(self)
	-- Get command result out of session data
	local cmdresult = self.sessiondata.cmdresult
	self.sessiondata.cmdresult = nil

	local defined_roles, default_roles = roll.list_roles()
	local defined_roles_cfe=cfe({ type="list", value=defined_roles, label="Locally-defined roles" })
	local default_roles_cfe=cfe({ type="list", value=default_roles, label="System-defined roles" })

	return cfe({ type="group", value={defined_roles=defined_roles_cfe, default_roles=default_roles_cfe, cmdresult=cmdresult} })
end

local setpermissions = function(self, role, permissions, newrole)
	local errtxt
	local my_perms = {}
	if permissions then
		-- we're changing permissions
		local result = true
		if newrole then
			-- make sure not overwriting role
			for x,ro in ipairs(roles.list_roles()) do
				if role==ro then
					result = false
					errtxt = "Role already exists"
					break
				end
			end
		end
		if result==true then
			result, errtxt = roles.set_role_perm(role, nil, permissions)
		end
		my_perms = self.clientdata.permissions
	else
		if role then
			tmp, my_perms = roles.get_role_perm(self.conf.appdir, role)
		else
			role = ""
		end
	end

	local tmp, all_perms = get_all_permissions(self)
	table.sort(all_perms)
	
	local permissions_cfe = cfe({ type="multi", value=my_perms, option=all_perms, label="Role permissions" })
	local role_cfe = cfe({ value=role, label="Role", errtxt=errtxt })

	return cfe({ type="table", value={role=role_cfe, permissions=permissions_cfe} })
end

newrole = function(self)
	local form = setpermissions(self, self.clientdata.role, self.clientdata.permissions, true)
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
	local form = setpermissions(self, self.clientdata.role, self.clientdata.permissions, false)
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
	local result, cmdresult = roles.delete_role(self.clientdata.role)
	self.sessiondata.cmdresult = cfe({ value=cmdresult })
	redirect(self, "viewroles")
end
