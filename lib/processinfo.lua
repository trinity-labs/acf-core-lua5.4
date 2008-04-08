
module(..., package.seeall)

require("posix")

function package_version(packagename)
	local cmderrors
	local f = io.popen( "/sbin/apk_version -vs " .. packagename .." | egrep -v 'acf' 2>/dev/null" )
	local cmdresult = f:read("*l")
	if (cmdresult) and (#cmdresult > 0) then
		cmdresult = (string.match(cmdresult,"^%S*") or "Unknown")
	else
		cmderrors = "Program not installed"
	end	
	f:close()
	return cmdresult,cmderrors
end

function process_botsequence(processname)
	local cmderrors
	local f = io.popen( "/sbin/rc_status | egrep '^S' | egrep '" .. processname .."' 2>/dev/null" )
	local cmdresult = f:read("*a")
	if (cmdresult) and (#cmdresult > 0) then
		cmdresult = "Process will autostart at next boot (at sequence '" .. string.match(cmdresult,"^%a+(%d%d)") .. "')"
	else
		cmderrors = "Not programmed to autostart"
	end	
	f:close()
	return cmdresult,cmderrors
end

