--[[
	module for joining an array to a string
]]--

module (..., package.seeall)


-- This code comes from http://lua-users.org/wiki/SplitJoin
--
-- Concat the contents of the parameter list,
-- -- separated by the string delimiter (just like in perl)
-- -- example: strjoin(", ", {"Anna", "Bob", "Charlie", "Dolores"})
return function (delimiter, list)
	local len = getn(list)
	if len == 0 then 
		return "" 
	end
	local string = list[1]
	for i = 2, len do 
		string = string .. delimiter .. list[i] 
	end
	return string
end


