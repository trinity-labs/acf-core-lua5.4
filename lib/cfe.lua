module(..., package.seeall)

-- create a Configuration Framework Entity (cfe)
-- returns a table with at least "value", "type", and "label"
cfe = function ( optiontable )
	optiontable = optiontable or {}
	me = { 	value="",
		type="text",
		label="" }
	for key,value in pairs(optiontable) do
		me[key] = value
	end
	return me
end
_G.cfe = cfe
