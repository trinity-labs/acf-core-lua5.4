-- Roles/Group  model functions

require ("session")
require ("roles")

module (..., package.seeall)

read = function(self,sessionid)
	useid , theroles = session.check_session(conf.sessiondir,sessionid,"roles")
--we need to expand roles to give us real perm list
	perm = roles.get_roles_perm(self,theroles)
	return ( cfe { userid={value=useid,name="userid"},roles={ value=theroles,name="roles"}, perm={value=perm,name="perm"},{value=self.conf,name="self"},{value=sessiondata.userinfo.perm,name="perm2"} })	
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
