-- Roles/Group  model functions

require ("session")
require ("roles")

module (..., package.seeall)

read = function(self,sessionid)
	useid , theroles = session.check_session(conf.sessiondir,sessionid,"roles")
	return ( cfe { value=theroles,name="roles" })	
end

getcont = function(self)
	--need to get a list of all the controllers
	--t = roles.get_controllers(self,"skins")	
	bobo = roles.get_controllers(self)
	local table_m = {}
	for a,b in pairs(bobo) do
	temp = roles.get_controllers_func(self,b)
	table_m[b.sname] = temp
	end

	return (cfe {value=table_m,name="mtable"})

end
