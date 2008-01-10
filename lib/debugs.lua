--Show various debug information

module(..., package.seeall)

require("session")

-- This will show all tables and their values as debug information
--
-- USAGE: <?
-- USAGE: require("debugs")
-- USAGE: io.write(debugs.variables(view))
-- USAGE: ?>
function variables ( view )
	debuginfo = [[
	<span style='color:#D2691E;font-family:courier;'>
	<h2>DEBUG INFO: THIS VIEW CONTAINS THE FOLLOWING VARIABLES/TABLES</h2>
	------------ START DEBUG INFORMATION ------------<BR>]]

	--print ("<span style='color:darkblue;font-family:courier;'>")
	for a,b in pairs(view) do
		if not (type(b) == "table") then
			debuginfo = debuginfo .. "<b>" .. a .. "</b>: ><span2 style='color:black'>" .. b .. "</span2><<BR>"
		else
			debuginfo = debuginfo .. "<b>" .. a .. "</b>:...<BR>"
			for c,d in pairs(view[a]) do
				if not (type(d) == "table") then
					debuginfo = debuginfo .. "<b> { " .. c .. "</b>: ><span2 style='color:black'>" .. d .. "</span2>< <B> }</B><BR>"
				else
					debuginfo = debuginfo .. "<b> { " .. c .. "</b>:...<BR>"
					for e,f in pairs(view[a][c]) do
						if not (type(f) == "table") then
							debuginfo = debuginfo .. "<b> { { " .. e .. "</b>: ><span2 style='color:black'>" .. f .. "</span2>< <B> } }</B><BR>"
						else
							debuginfo = debuginfo .. "<b> { { " .. e .. "</b>:...<BR>"
							for g,h in pairs(view[a][c][e]) do
								if not (type(h) == "table") then
									debuginfo = debuginfo .. "<b> { { { " .. g .. "</b>: ><span2 style='color:black'>" .. h .. "</span2>< <B> } } }</B><BR>"
								else
									debuginfo = debuginfo .. "<b> { { { " .. g .. "</b>:...<BR>"
									for i,j in pairs(view[a][c][e][g]) do
										if not (type(j) == "table") then
											debuginfo = debuginfo .. "<b> { { { { " .. i .. "</b>: ><span2 style='color:black'>" .. j .. "</span2>< <B> } } } }</B><BR>"
										else
											debuginfo = debuginfo .. "<b> { { { " .. i .. "</b>:...<BR>"
											for k,l in pairs(view[a][c][e][g][i]) do
												if not (type(l) == "table") then
													debuginfo = debuginfo .. "<b> { { { { { " .. i .. "</b>: ><span2 style='color:black'>" .. l .. "</span2>< <B> } } } } }</B><BR>"
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	a,b,c,d,e,f,g,h,i,j = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
	end
	debuginfo = debuginfo .. "------------ END DEBUG INFORMATION ------------</span>"
	return debuginfo
end

function serialize(vars)
	io.write("<pre>\n")
	io.write(session.serialize("", vars))
	io.write("\n</pre>")
end

