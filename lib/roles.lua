--this module is for authorization help and group/role management

require ("authenticator")
require ("fs")
require ("format")

module (..., package.seeall)

guest_role = "GUEST"

-- returns a table of the *.roles files
-- startdir should be the app dir
local get_roles_candidates = function (startdir)
	local t = {}
	local fh = io.popen('find ' .. startdir .. ' -name "*.roles"')
	for x in fh:lines() do
		t[#t + 1] = x
	end
	return t
end

-- Return a list of *controller.lua files
list_controllers = function(self)
	local list = {}
	local f = io.popen("/usr/bin/find /usr/share/acf/ |/bin/grep \"controller.lua$\" ")
	for a in f:lines() do
		if not string.find(a, "acf_") then
			list[#list + 1 ] = a
		end
	end
	f:close()
	return list
end

-- Return information about all or specified controller files
get_controllers = function(self,controller)
	--we get all the controllers
	local list = roles.list_controllers()
	--we need to grab the directory and name of file
	local temp = {}
	for k,v in pairs(list) do
		path = string.match(v,"[/%w-]+/")
		filename = string.match(v,"[^/]*.lua")
		name = string.match(filename,"[^.]*")
		sname = string.match(filename,"[^-]*")
		temp[sname] = {path=path,filename=filename,name=name,sname=sname}
	end
	if controller then
		return temp[controller]
	else
		return temp
	end
end

-- Find all public functions in a controller
get_controllers_func = function(self,controller_info)
	if controller_info == nil then
		return "Could not be processed"
	else
	package.path=package.path .. ";" .. controller_info.path .. "?.lua"
	temp = require (controller_info.name)
	temp1 = {}
	for a,b in pairs(temp) do 
		local c = string.match(a,"^mvc") or string.match(a,"^_") 
		if c == nil and type(temp[a])=="function" then
			temp1[#temp1 +1] = a
		end
	end
	--require (controller_info.name)
	--we need to go through bobo and take out the mvc func and locals and --
	return temp1
	end
end

-- Find all views for a controller
get_controllers_view = function(self,controller_info)
	local temp = {}
	for file in fs.find(controller_info.sname.."%-[^%.]+%-html%.lsp", controller_info.path) do
		temp[#temp + 1] = string.match(file, controller_info.sname.."%-([^%./]+)%-html%.lsp")
	end
	return temp	
end

list_default_roles = function(self)
	local default_roles = {}
	local reverseroles = {}

	-- find all of the default roles files and parse them
	local rolesfiles = get_roles_candidates(self.conf.appdir)

	for x,file in ipairs(rolesfiles) do
		f = fs.read_file_as_array(file)
		for y,line in pairs(f) do
			if not reverseroles[string.match(line,"^[%w_]+")] then
				default_roles[#default_roles+1] = string.match(line,"^[%w_]+")
				reverseroles[default_roles[#default_roles]] = #default_roles
			end
		end
	end

	return default_roles, reverseroles
end

list_roles = function(self)
	local defined_roles = {}
	local default_roles, reverseroles = list_default_roles(self)

	-- Open the roles file and parse for defined roles
	local entries = authenticator.auth.read_field(self, authenticator.roletable, "") or {}
	for x,entry in ipairs(entries) do
		if not reverseroles[entry.id] then
			defined_roles[#defined_roles + 1] = entry.id
		end
	end

	return defined_roles, default_roles
end

list_all_roles = function(self)
	local defined_roles, default_roles = list_roles(self)
	for x,role in ipairs(defined_roles) do
		default_roles[#default_roles + 1] = role
	end
	return default_roles
end	

-- Go through the roles files and determine the permissions for the specified list of roles (including guest)
get_roles_perm = function(self,roles)
	permissions = {}
	permissions_array = {}

	local reverseroles = {}
	for x,role in ipairs(roles) do
		reverseroles[role] = x
	end
	reverseroles[guest_role] = 0 -- always include guest role

	-- find all of the default roles files and parse them
	local rolesfiles = get_roles_candidates(self.conf.appdir)

	for x,file in ipairs(rolesfiles) do
		f = fs.read_file_as_array(file)
		for y,line in pairs(f) do
			if reverseroles[string.match(line,"^[%w_]+")] then
				temp = format.string_to_table(string.match(line,"[,%a_:]+$"),",")
				for z,perm in pairs(temp) do
					local control,action = string.match(perm,"([%a_]+):([%a_]+)")
					if control then
						if nil == permissions[control] then
							permissions[control] = {}
						end
						if action then
							permissions[control][action] = {file}
							permissions_array[#permissions_array + 1] = control .. ":" .. action
						end
					end
				end
			end
		end
	end

	-- then look in the user-editable roles
	local entries = authenticator.auth.read_field(self, authenticator.roletable, "") or {}
	for x,entry in ipairs(entries) do
		if reverseroles[entry.id] then
			temp = format.string_to_table(entry.entry, ",")
			for z,perm in pairs(temp) do
				local control,action = string.match(perm,"([%a_]+):([%a_]+)")
				if control then
					if nil == permissions[control] then
						permissions[control] = {}
					end
					if action then
						permissions[control][action] = {}
						permissions_array[#permissions_array + 1] = control .. ":" .. action
					end
				end
			end
		end
	end
	
	return permissions, permissions_array
end

-- Go through the roles files and determine the permissions for the specified role
get_role_perm = function(self,role)
	permissions = {}
	permissions_array = {}
	default_permissions_array = {}

	-- find all of the default roles files and parse them
	local rolesfiles = get_roles_candidates(self.conf.appdir)

	for x,file in ipairs(rolesfiles) do
		f = fs.read_file_as_array(file)
		for y,line in pairs(f) do
			if role == string.match(line,"^[%w_]+") then
				temp = format.string_to_table(string.match(line,"[,%a_:]+$"),",")
				for z,perm in pairs(temp) do
					local control,action = string.match(perm,"([%a_]+):([%a_]+)")
					if control then
						if nil == permissions[control] then
							permissions[control] = {}
						end
						if action then
							permissions[control][action] = {file}
							permissions_array[#permissions_array + 1] = control .. ":" .. action
							default_permissions_array[#default_permissions_array + 1] = control .. ":" .. action
						end
					end
				end
			end
		end
	end

	-- then look in the user-editable roles
	local entry = authenticator.auth.read_entry(self, authenticator.roletable, "", role)
	if entry then
		temp = format.string_to_table(entry, ",")
		for z,perm in pairs(temp) do
			local control,action = string.match(perm,"([%a_]+):([%a_]+)")
			if control then
				if nil == permissions[control] then
					permissions[control] = {}
				end
				if action then
					permissions[control][action] = {}
					permissions_array[#permissions_array + 1] = control .. ":" .. action
				end
			end
		end
	end

	return permissions, permissions_array, default_permissions_array
end

-- Delete a role from role file
delete_role = function(self, role)
	local result = authenticator.auth.delete_entry(self, authenticator.roletable, "", role)
	local cmdresult = "Role entry not found"
	if result then cmdresult = "Role deleted" end

	return result, cmdresult
end

-- Set permissions for a role in role file
set_role_perm = function(self, role, permissions, permissions_array)
	if role==nil or role=="" then
		return false, "Invalid Role"
	end
	if string.find(role, '[^%w_]') then
		return false, "Role can only contain letters, numbers, and '_'"
	end
	if permissions and not permissions_array then
		permissions_array = {}
		for cont,actions in pairs(permissions) do
			for action in pairs(actions) do
				permissions_array[#permissions_array + 1] = cont .. ":" .. action
			end
		end
	end
	
	return authenticator.auth.write_entry(self, authenticator.roletable, "", role, table.concat(permissions_array or {},","))
end
