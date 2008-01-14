module (..., package.seeall)

function daemoncontrol (process, action)
	local cmdresult = ""
	if (string.lower(action) == "start") or (string.lower(action) == "stop") or (string.lower(action) == "restart") then
		local file = io.popen( "PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin /etc/init.d/" .. process .. " " .. action .. " 2>&1" )
		if file ~= nil then
			line = file:read( "*l" )
			while line ~= nil do
				cmdresult = cmdresult .. "\n" .. line
				line = file:read( "*l" )
			end
			file:close()
		end
	else
		cmdresult = "Unknown command!"
	end
	return {cmdresult=cmdresult, process=process, action=action, }
end
