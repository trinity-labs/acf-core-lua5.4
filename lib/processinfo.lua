
module(..., package.seeall)

require("posix")
require("fs")
require("format")

local path = "PATH=/usr/bin:/bin:/usr/sbin:/sbin "

function package_version(packagename)
	local result
	local errtxt = "Program not installed"
	local f = io.popen( "PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin apk_version -vs " .. format.escapespecialcharacters(packagename) )
	local cmdresult = f:read("*a") or ""
	f:close()
	for line in string.gmatch(cmdresult, "[^\n]+") do
		if string.match(line, "^"..format.escapemagiccharacters(packagename).."-") then
			result = string.match(line, "%S+")
			errtxt = nil
			break
		end
	end
	return result,errtxt
end

function process_startupsequence(servicename)
	local result
	local errtxt = "Not programmed to autostart"
	local f = io.popen( "/sbin/rc_status" )
	local cmdresult = f:read("*a") or ""
	f:close()
	for line in string.gmatch(cmdresult, "[^\n]+") do
		if string.match(line, "^%a%d%d"..format.escapemagiccharacters(servicename).."$") then
			result = "Service will autostart at next boot (at sequence '" .. string.match(line,"^%a(%d%d)") .. "')"
			errtxt = nil
			break
		end
	end	
	return result,errtxt
end

function read_startupsequence()
	local config = {}
	local f = io.popen( "/sbin/rc_status" )
	local cmdresult = f:read("*a") or ""
	f:close()
	local section = 0
	for line in string.gmatch(cmdresult, "([^\n]*)\n?") do
		local sequence, service = string.match(line, "(%d%d)(%S+)")
		if service then
			if section == 3 then	-- kill section
				for i,cfg in ipairs(config) do
					if cfg.servicename == service then
						cfg.kill = true
						break
					end
				end
			else
				config[#config+1] = {servicename=service, sequence=sequence, kill=false, system=(section == 1)}
			end
		elseif string.match(line, "^rc.%.d:") then
			section = section + 1
		end
	end
	-- Add in any missing init.d scripts
	local reverseservices = {} for i,cfg in ipairs(config) do reverseservices[cfg.servicename] = i end
	local temp = {}
	for name in posix.files("/etc/init.d") do
		if not reverseservices[name] and not string.find(name, "^rc[KLS]$") and not string.find(name, "^..?$") then
			temp[#temp+1] = {servicename=name, sequence="", kill=false, system=false}
		end
	end
	table.sort(temp, function(a,b) return a.servicename < b.servicename end)
	for i,val in ipairs(temp) do
		config[#config+1] = val
	end
	return config
end

function add_startupsequence(servicename, sequence, kill, system)
	local cmdresult,cmderrors
	if not servicename then
		cmderrors = "Invalid service name"
	else
		local cmd = {path, "rc_add"}
		if kill then cmd[#cmd+1] = "-k" end
		if system then cmd[#cmd+1] = "-S" end
		if sequence and tonumber(sequence) then cmd[#cmd+1] = "-s "..sequence end
		cmd[#cmd+1] = format.escapespecialcharacters(servicename)
		cmd[#cmd+1] = "2>&1"
		delete_startupsequence(servicename)
		local f = io.popen(table.concat(cmd, " "))
		cmdresult = f:read("*a")
		f:close()
		if cmdresult == "" then cmdresult = "Added sequence" end
	end

	return cmdresult,cmderrors
end

function delete_startupsequence(servicename)
	local cmdresult,cmderrors
	if not servicename then
		cmderrors = "Invalid service name"
	else
		local f = io.popen(path.."rc_delete "..format.escapespecialcharacters(servicename))
		cmdresult = f:read("*a")
		f:close()
		if cmdresult == "" then cmderrors = "Failed to delete sequence" end
	end

	return cmdresult,cmderrors
end

function daemoncontrol (process, action)
	local cmdresult = ""
	local cmderrors
	if not process then
		cmderrors = "Invalid service name"
	elseif (string.lower(action) == "start") or (string.lower(action) == "stop") or (string.lower(action) == "restart") then
		local file = io.popen( "PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin /etc/init.d/" .. 
			format.escapespecialcharacters(process) .. " " .. string.lower(action) .. " 2>&1" )
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

local function has_pidfile(name)
	local pid
	local file = "/var/run/"..name..".pid"
	if fs.is_file(file) then
		-- check to see if there's a matching proc directory and that it was created slightly after the pid file
		-- this allows us to find init scripts with differing process names and avoids the problem with
		-- proc numbers wrapping
		local tmp = string.match(fs.read_file(file) or "", "%d+")
		if tmp then
			local dir = "/proc/" .. tmp
			filetime = posix.stat(file, "ctime")
			dirtime = posix.stat(dir, "ctime")
			if dirtime and (tonumber(dirtime) - tonumber(filetime) < 100) then
				pid = tmp
			end
		end
	end
	return pid
end

function pidof(name)
	local pids = {has_pidfile(name)}
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

