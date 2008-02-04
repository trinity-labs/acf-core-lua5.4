--this module is for authorization help and group/role management


require ("posix")
require ("format")

module (..., package.seeall)

list_controllers = function(self)
local list = {}
local f = io.popen("/usr/bin/find /usr/share/acf/ |/bin/grep \"controller.lua$\" ")
       for a in f:lines() do
       list[#list + 1 ] = a
       end
f:close()
return list
end

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

