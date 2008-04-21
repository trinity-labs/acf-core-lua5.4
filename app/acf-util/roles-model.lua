-- Roles/Group  model functions

require ("roles")

module (..., package.seeall)

getcont = function(self)
	--need to get a list of all the controllers
	controllers = roles.get_controllers(self)
	local table_m = {}
	for a,b in pairs(controllers) do
	temp = roles.get_controllers_func(self,b)
	table_m[b.sname] = temp
	end

	return (table_m)
end
