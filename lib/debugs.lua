--Show various debug information

module(..., package.seeall)

require("session")
--local cnt = 0

function serialize ( view, cnt )
	if type(view) == "string" then
		io.write(" ><span2 style='color:black'>")
		io.write(string.format("%q", view))
		io.write("</span2><")
	elseif type(view) == "number" then
		io.write(" ><span2 style='color:black'>")
		io.write(view)
		io.write("</span2><")
	elseif type(view) == "table" then
		cnt = cnt + 1
--		io.write("<BR>")
		for k,v in pairs(view) do
			io.write("<br>")
			io.write(string.rep("{ ",cnt), "<B>", k, "</B>")
			serialize(v, cnt)
		end
--		io.write("}\n")
	else
		error("Cannot serialize a " .. type(view))
	end
end

function variables ( view )
	io.write [[
	<span style='color:#D2691E;font-family:courier;'>
	<h2>DEBUG INFO: THIS VIEW CONTAINS THE FOLLOWING VARIABLES/TABLES</h2>
	------------ START DEBUG INFORMATION ------------<BR>]]
	serialize(view,0)
	io.write( "<BR><BR>------------ END DEBUG INFORMATION ------------</span>")
	return
end


-- from http://lua-users.org/wiki/MakingLuaLikePhp
function print_r (t, indent) -- alt version, abuse to http://richard.warburton.it
  local indent=indent or ''
  for key,value in pairs(t) do
    io.write(indent,'[',tostring(key),']') 
    if type(value)=="table" then io.write(':\n') print_r(value,indent..'\t')
    else io.write(' = ',tostring(value),'\n') end
  end
end

