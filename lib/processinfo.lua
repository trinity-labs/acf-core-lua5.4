
module(..., package.seeall)

require("posix")

function package_version(packagename)
	local cmderrors
	local f = io.popen( "PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin apk_version -vs " .. packagename .." | egrep -v 'acf' 2>/dev/null" )
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

function daemoncontrol (process, action)
	local cmdresult = ""
	local cmderrors
	if (string.lower(action) == "start") or (string.lower(action) == "stop") or (string.lower(action) == "restart") then
		local file = io.popen( "PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin /etc/init.d/" .. 
			process .. " " .. string.lower(action) .. " 2>&1" )
		if file ~= nil then
			cmdresult = file:read( "*a" )
			file:close()
		end
		posix.sleep(2)	-- Wait for the process to start|stop
	else
		cmderrors = "Unknown command!"
	end
	return cmdresult,cmderrors
end

-- the following methods are available:
-- /proc/<pid>/stat	the comm field (2nd) field contains name but only up 
--   			to 15 chars. does not resolve links
--
-- /proc/<pid>/cmdline	argv[0] contains the command. However if it is a script
--   			then will the interpreter show up
--
-- /proc/<pid>/exe	link to exe file. this will resolv links
--
-- returns list of all pids for given exe name

--[[
-- gives lots of false positives for busybox
local function is_exe(path, name)
	local f = posix.readlink(path.."/exe")
	if f and (f == name or posix.basename(f) == name) then
		return true
	else
		return false
	end
end
]]--


local function is_stat(path, name)
	local f = io.open(path.."/stat")
	if (f) then
		local line = f:read()
		local p = string.gsub(line, ".*%(", "")
		p = string.gsub(p, "%).*", "")
		f:close()
	end
	if p ~= nil then	
		if string.len(name) <= 15 and p == name then
			return true
		end
	end
	return false
end

local function is_cmdline(path, name)
	local f = io.open(path.."/cmdline")
	if f == nil then
		return false
	end
	local line = f:read()
	f:close()
	if line == nil then 
		return false
	end
	local arg0 = string.gsub(line, string.char(0)..".*", "")
	if posix.basename(arg0) == name then
		return true
	end
end

function pidof(name)
	local pids = {}
	local i, j

	for i,j in pairs(posix.glob("/proc/[0-9]*")) do
		local pid = tonumber(posix.basename(j))
		if is_stat(j, name) or is_cmdline(j, name) then
			table.insert(pids, pid)
		end
	end
	if #pids == 0 then
		pids = nil
	end
	return pids
end

