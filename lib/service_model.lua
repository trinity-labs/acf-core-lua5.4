require("fs")

function create_service_model(cfglist, loglist, servlist, notepath)

	local me = {}

	local function get_any_pid(pname)
		for e in lfs.dir("/proc") do
			if e == string.match(e, "^%d*$") then
				for line in io.lines("/proc/" .. e .. "/status") do
					tag, val = string.match(line, "^([^:]*):%s*(%S*)$");
					if tag == "Name" then
						if val == pname then return e end
						break
					end
				end
			end
		end
	end

	local function get_cfg_path(name)
		if not cfglist or not cfglist[name] then
			return
		end
		return cfglist[name].path
	end

	local function get_log_path(name)
		if not loglist or not loglist[name] then
			return
		end
		return loglist[name].path
	end

	--[[ Public Functions go here ]]--

	function me.status(name)
		if not servlist or not servlist[name] then
			return "unknown service"
		end
		local cmdname = servlist[name].cmdname
		if get_any_pid(cmdname) == nil then
			return "seems to be stopped"
		else
			return "seems to be running"
		end
	end

	function me.initd(name, action)
		if not servlist or not servlist[name] then
			return "unknown service"
		end
		local p = io.popen("/etc/init.d/"
			.. servlist[name].initdname .. " " .. action, "r")
		local ret = p:read("*a")
		p:close()
		return ret
	end

	function me.get_note()
		if not notepath or not fs.is_file(notepath) then return "" end
		return fs.read_file(notepath)
	end

	function me.set_note(value)
		if notepath == nil then return end
		fs.write_file(notepath, value)
	end

	function me.get_cfg_names()
		return cfglist    
	end

	function me.get_log_names()
		return loglist    
	end

	function me.get_service_names()
		return servlist
	end

	function me.get_cfg(name)
		local path = get_cfg_path(name)
		if not path or not fs.is_file(path) then
			return ""
		end
		return fs.read_file(path)
	end

	function me.set_cfg(name, value)
		local path = get_cfg_path(name)
		if path then
			fs.write_file(path, value)
		end
	end

-- 	local function wrap_single(x)
-- 		return function(state, prev)
-- 			if not prev then
-- 				return x
-- 			end
-- 		end
-- 	end

	function me.get_log_producer(name)
		local path = get_log_path(name)
		if not path or not fs.is_file(path) then
			return "cannot access " .. path
		end
		return io.lines(path)
	end

	return me

end
