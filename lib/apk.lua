-- apk library
module (..., package.seeall)

get_all_packages = function()
	-- read in all of the packages
	local cmd = "/sbin/apk_fetch -l 2>/dev/null"
	local f = io.popen( cmd )
	local all = {}
	for line in f:lines() do all[#all + 1] = line end
	f:close()
	return all
end

get_loaded_packages = function()
	-- read in the loaded packages
	local cmd = "/sbin/apk_info 2>/dev/null"
	local f = io.popen( cmd )
	local loaded = {}
	for line in f:lines() do
		local temp = {}
		temp.name = string.match(line, "(.-)-%d+.*")
		temp.version, temp.description = string.match(line, "([^ ]+) %- (.+)")
		loaded[#loaded+1] = temp
	end
	return loaded
end

get_available_packages = function(_loaded, _all)
	-- available are all except loaded
	local loaded = _loaded or get_loaded_packages()
	local all = _all or get_all_packages()
	local available = {}
	local reverseloaded = {}
	for i,packagetable in ipairs(loaded) do reverseloaded[packagetable.name] = i end
	for i,package in ipairs(all) do
		if (reverseloaded[package]==nil) then available[#available + 1] = package end
	end
	return available
end

delete_package = function(package)
	local success = false
	local cmdresult = "Delete failed - Invalid package"
	local loaded = get_loaded_packages()
	for i,pack in pairs(loaded) do
		if pack.name == package then
			success = true
			local cmd = "/sbin/apk_delete " .. package .. " 2>&1"
			local f = io.popen( cmd )
			cmdresult = f:read("*a") or ""
			f:close()
		end
	end
	return success, cmdresult
end

install_package = function(package)
	local success = false
	local cmdresult = "Install failed - Invalid package"
	local available = get_available_packages()
	for i,pack in pairs(available) do
		if pack == package then
			success = true
			local cmd = "PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin apk_add " .. package .. " 2>&1"
			local f = io.popen( cmd )
			cmdresult = f:read("*a")
			f:close()
		end
	end
	return success, cmdresult
end
