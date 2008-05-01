-- Roles/Group  model functions

require ("roles")

module (..., package.seeall)

getcont = function(self)
	--need to get a list of all the controllers
	controllers = roles.get_controllers(self)
	local table_m = {}
	for a,b in pairs(controllers) do
		table_m[b.sname] = {}
		temp = roles.get_controllers_func(self,b)
		for x,y in ipairs(temp) do
			table_m[b.sname][y] = {}
		end
	end

	return cfe({ type="table", value=table_m, label="All permissions" })
end
