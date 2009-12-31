--this module is for authorization help and group/role management

require ("authenticator")
require ("fs")
require ("format")

module (..., package.seeall)

guest_role = "GUEST"

-- returns a table of the *.roles files
-- startdir should be the app dir
local get_roles_candidates = function(self)
	local list = {}
	for p in string.gmatch(self.conf.appdir, "[^,]+") do
		local l = fs.find_files_as_array(".*%.roles", p, true) or {}
		for i,f in ipairs(l) do
			list[#list+1] = f
		end
	end
	return list
end

-- Return a list of *controller.lua files
list_controllers = function(self)
	local list = {}
	for p in string.gmatch(self.conf.appdir, "[^,]+") do
		for file in fs.find(".*controller%.lua", p, true) do
			if not string.find(file, "acf_") then
				list[#list + 1] = file
			end
		end
	end

	return list
end

-- Return information about all or specified controller files
get_controllers = function(self,pre,controller)
	--we get all the controllers
	local list = roles.list_controllers(self)
	--we need to grab the directory and name of file
	local temp = {}
	for k,v in pairs(list) do
		path = string.match(v,".*/")
		prefix = string.match(path,"/[^/]+/$")
		filename = string.match(v,"[^/]*.lua")
		name = string.match(filename,"[^.]*")
		sname = string.match(filename,"[^-]*")
		temp[prefix..sname] = {path=path,prefix=prefix,filename=filename,name=name,sname=sname}
	end
	if pre and controller then
		return temp[pre..controller]
	else
		return temp
	end
end

-- Find all public functions in a controller
get_controllers_func = function(self,controller_info)
	if controller_info == nil then
		return "Could not be processed"
	else
		-- FIXME - would rather do this without 'require' since that messes with global variables
		-- but, haven't figured that out yet
		local PATH = package.path
		local loaded = package.loaded[controller_info.name]
		package.path = controller_info.path .. "?.lua;" .. package.path
		temp = require (controller_info.name)
		package.path = PATH
		package.loaded[controller_info.name] = loaded
		temp1 = {}
		for a,b in pairs(temp) do
			local c = string.match(a,"^mvc") or string.match(a,"^_") 
			if c == nil and type(temp[a])=="function" then
				temp1[#temp1 +1] = a
			end
		end
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
	local rolesfiles = get_roles_candidates(self)

	for x,file in ipairs(rolesfiles) do
		f = fs.read_file_as_array(file) or {}
		local rolefile = string.match(file, "(/[^/]+/[^/]+)%.roles$")
		for y,line in pairs(f) do
			local role = string.match(line,"^[%w_]+")
			if role then
				if not reverseroles[rolefile.."/"..role] then
					default_roles[#default_roles+1] = rolefile.."/"..role
					reverseroles[default_roles[#default_roles]] = #default_roles
				end
				if not reverseroles[role] then
					default_roles[#default_roles+1] = role
					reverseroles[default_roles[#default_roles]] = #default_roles
				end
			end
		end
	end

	table.sort(default_roles, function(a,b)
			if string.byte(a, 1) == 47 and string.byte(b,1) ~= 47 then return false
			elseif string.byte(a, 1) ~= 47 and string.byte(b,1) == 47 then return true
			else return a<b 
			end
		end)

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
	table.sort(defined_roles)

	return defined_roles, default_roles
end

list_all_roles = function(self)
	local defined_roles, default_roles = list_roles(self)
	-- put the defined roles first
	for x,role in ipairs(default_roles) do
		defined_roles[#defined_roles + 1] = role
	end
	return defined_roles
end	

-- Go through the roles files and determine the permissions for the specified list of roles
local determine_perms = function(self,roles)
	local permissions = {}
	local permissions_array = {}
	local default_permissions_array = {}

	local reverseroles = {}
	for x,role in ipairs(roles) do
		reverseroles[role] = x
	end

	-- find all of the default roles files and parse them
	local rolesfiles = get_roles_candidates(self)

	for x,file in ipairs(rolesfiles) do
		local prefix = string.match(file, "(/[^/]+/)[^/]+$") or "/"
		f = fs.read_file_as_array(file) or {}
		local rolefile = string.match(file, "(/[^/]+/[^/]+)%.roles$")
		for y,line in pairs(f) do
			local role = string.match(line,"^[%w_]+")
			if role then
				if reverseroles[role] or reverseroles[rolefile.."/"..role] then
					temp = format.string_to_table(string.match(line,"[,%w_:/]+$"),",")
					for z,perm in pairs(temp) do
						-- we'll allow for : or / to not break old format
						local control,action = string.match(perm,"([%w_]+)[:/]([%w_]+)")
						if control then
							if nil == permissions[prefix] then
								permissions[prefix] = {}
							end
							if nil == permissions[prefix][control] then
								permissions[prefix][control] = {}
							end
							if action then
								permissions[prefix][control][action] = {file}
								permissions_array[#permissions_array + 1] = prefix .. control .. "/" .. action
								default_permissions_array[#default_permissions_array + 1] = prefix .. control .. "/" .. action
							end
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
				local prefix,control,action = self.parse_path_info(perm)
				if control then
					if nil == permissions[prefix] then
						permissions[prefix] = {}
					end
					if nil == permissions[prefix][control] then
						permissions[prefix][control] = {}
					end
					permissions[prefix][control][action] = {}
					permissions_array[#permissions_array + 1] = prefix .. control .. "/" .. action
				end
			end
		end
	end

	return permissions, permissions_array, default_permissions_array
end

-- Go through the roles files and determine the permissions for the specified list of roles (including guest)
get_roles_perm = function(self,roles)
	roles[#roles+1] = guest_role
	return determine_perms(self, roles)
end

-- Go through the roles files and determine the permissions for the specified role
get_role_perm = function(self,role)
	return determine_perms(self, {role})
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
	if string.find(role, '[^%w_/]') then
		return false, "Role can only contain letters, numbers, '/', and '_'"
	end
	if permissions and not permissions_array then
		permissions_array = {}
		for prefix,contrllrs in pairs(permissions) do
			for cont,actions in pairs(contrllrs) do
				for action in pairs(actions) do
					permissions_array[#permissions_array + 1] = prefix .. cont .. "/" .. action
				end
			end
		end
	end
	
	return authenticator.auth.write_entry(self, authenticator.roletable, "", role, table.concat(permissions_array or {},","))
end
