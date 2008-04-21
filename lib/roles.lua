--this module is for authorization help and group/role management


require ("posix")
require ("fs")
require ("format")

module (..., package.seeall)

-- Return a list of *controller.lua files
list_controllers = function(self)
	local list = {}
	local f = io.popen("/usr/bin/find /usr/share/acf/ |/bin/grep \"controller.lua$\" ")
	for a in f:lines() do
		list[#list + 1 ] = a
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
		if c == nil then
			temp1[#temp1 +1] = a
		end
	end
	--require (controller_info.name)
	--we need to go through bobo and take out the mvc func and locals and --
	return temp1
	end
end

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

-- Go through the roles files and determine the permissions for the specified roles
get_roles_perm = function(startdir,roles)
	permissions = {}

	-- find all of the roles files and add in the master file
	local rolesfiles = get_roles_candidates(startdir)
	rolesfiles[#rolesfiles + 1]  = "/etc/acf/roles"

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
						if action and nil == permissions[control][action] then
							permissions[control][action] = {}
						end
					end
				end
			end
		end
	end
	
	return permissions
end

