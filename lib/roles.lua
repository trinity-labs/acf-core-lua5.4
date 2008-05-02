--this module is for authorization help and group/role management


require ("posix")
require ("fs")
require ("format")

module (..., package.seeall)

local roles_file = "/etc/acf/roles"
local default_roles = { "CREATE", "UPDATE", "DELETE", "READ", "ALL" }

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
		local c = string.match(a,"mvc") or string.match(a,"^_") 
		if c == nil and type(temp[a])=="function" then
			temp1[#temp1 +1] = a
		end
	end
	--require (controller_info.name)
	--we need to go through bobo and take out the mvc func and locals and --
	return temp1
	end
end

list_default_roles = function()
	return default_roles
end

list_roles = function()
	local defined_roles = {}
	local reverseroles = {}
	for x,role in ipairs(default_roles) do
		reverseroles[role] = x
	end

	-- Open the roles file and parse for defined roles
	f = fs.read_file_as_array(roles_file)
	for x,line in pairs(f) do
		temprole = string.match(line,"^[%a]+")
		if not reverseroles[temprole] then
			defined_roles[#defined_roles + 1] = temprole
		end
	end

	return defined_roles, default_roles
end

list_all_roles = function()
	local defined_roles, default_roles = list_roles()
	for x,role in ipairs(defined_roles) do
		default_roles[#default_roles + 1] = role
	end
	return default_roles
end	

-- Go through the roles files and determine the permissions for the specified roles
get_roles_perm = function(startdir,roles)
	permissions = {}
	permissions_array = {}

	-- find all of the roles files and add in the master file
	local rolesfiles = get_roles_candidates(startdir)
	rolesfiles[#rolesfiles + 1]  = roles_file

	local reverseroles = {}
	for x,role in ipairs(roles) do
		reverseroles[role] = {}
	end
	reverseroles["ALL"] = {} -- always include ALL role

	for x,file in ipairs(rolesfiles) do
		f = fs.read_file_as_array(file)
		for y,line in pairs(f) do
			if reverseroles[string.match(line,"^[%a]+")] then
				temp = format.string_to_table(string.match(line,"[,%a:]+$"),",")
				for z,perm in pairs(temp) do
					local control,action = string.match(perm,"(%a+):(%a+)")
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
	end
	
	return permissions, permissions_array
end

-- Go through the roles files and determine the permissions for the specified role
get_role_perm = function(startdir,role)
	permissions = {}
	permissions_array = {}

	-- find all of the roles files and add in the master file
	local rolesfiles = get_roles_candidates(startdir)
	rolesfiles[#rolesfiles + 1]  = roles_file

	for x,file in ipairs(rolesfiles) do
		f = fs.read_file_as_array(file)
		for y,line in pairs(f) do
			if role == string.match(line,"^[%a]+") then
				temp = format.string_to_table(string.match(line,"[,%a:]+$"),",")
				for z,perm in pairs(temp) do
					local control,action = string.match(perm,"(%a+):(%a+)")
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
	end
	
	return permissions, permissions_array
end

-- Delete a role from role file
delete_role = function(role)
	for x,ro in ipairs(default_roles) do
		if role==ro then
			return false, "Cannot delete default roles"
		end
	end
	local rolecontent = fs.read_file_as_array(roles_file)
	local output = {}
	local result = false
	local cmdresult = "Role entry not found"
	for x,line in pairs(rolecontent) do
		if not string.match(line, "^" .. role .. "=") then
			table.insert(output,line)
		else
			result = true
			cmdresult = "Role deleted"
		end
	end

	if result == true then
		fs.write_file(roles_file, table.concat(output,"\n"))
	end

	return result, cmdresult
end

-- Set permissions for a role in role file
set_role_perm = function(role, permissions, permissions_array)
	if role==nil or role=="" then
		return false, "Invalid Role"
	end
	for x,ro in ipairs(default_roles) do
		if role==ro then
			return false, "Cannot modify default roles"
		end
	end
	if permissions and not permissions_array then
		permissions_array = {}
		for cont,actions in pairs(permissions) do
			for action in pairs(actions) do
				permissions_array[#permissions_array + 1] = cont .. ":" .. action
			end
		end
	end
	if permissions_array==nil or #permissions_array==0 then
		return false, "No permissions set"
	end

	delete_role(role)
	fs.write_line_file(roles_file, role .. "=" .. table.concat(permissions_array,","))
	return true
end
