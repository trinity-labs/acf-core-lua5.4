module (..., package.seeall)
require("posix")

function daemoncontrol (process, action)
	local cmdmessage = ""
	if (string.lower(action) == "start") or (string.lower(action) == "stop") or (string.lower(action) == "restart") then
		local file = io.popen( "PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin /etc/init.d/" .. 
			process .. " " .. action .. " 2>&1" )
		if file ~= nil then
			cmdmessage = file:read( "*a" )
			file:close()
		end
	else
		return false,nil,"Unknown command!",action
	end
	posix.sleep(2)	-- Wait for the process to start|stop
	return true,cmdmessage,nil,action
end
