-- apk library
module (..., package.seeall)

local repo = nil
local path = "PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin "
local install_cache = false

local reload_installed = function()
	if repo then
		-- clear out installed info
		for name,value in pairs(repo) do
			if value then
				value.installed = nil
				value.comment = nil
			end
		end
		-- read in which are installed
		local f = io.popen(path.."/sbin/apk_info 2>/dev/null")
		local line
		for line in f:lines() do
			local name, ver, comment = string.match(line, "(%S+)%-(%d+%S*)%s+(.*)")
			if not repo[name] then
				repo[name] = {}
			end
			repo[name].installed = ver
			repo[name].comment = comment
		end
		install_cache = true
	end
	return repo
end


repository = function()
	if not repo then
		-- read in all of the packages
		local f = io.popen(path.."/sbin/apk_fetch -lvq 2>/dev/null")
		repo = {}
		install_cache = false
		for line in f:lines() do
			local name, ver = string.match(line, "(.*)%-(%d+.*)")
			if name then
				repo[name] = {}
				repo[name].version = ver
			end
		end
		f:close()
	end
	if not install_cache then
		reload_installed()
	end
	return repo
end

get_all = function()
	repo = repository()
	-- read in all of the available packages
	local all = {}
	for name,value in pairs(repo) do
		if value.version then
			local temp = {}
			temp.name = name
			temp.version = value.version
			all[#all + 1] = temp
		end
	end
	table.sort(all, function(a,b) return (a.name < b.name) end)
	return all
end

get_loaded = function()
	repo = repository()
	-- read in the loaded packages
	local loaded = {}
	for name,value in pairs(repo) do
		if value.installed then 
			local temp = {}
			temp.name = name
			temp.version = value.installed
			temp.description = value.comment
			loaded[#loaded+1] = temp
		end
	end
	table.sort(loaded, function(a,b) return (a.name < b.name) end)
	return loaded
end

get_available = function()
	repo = repository()
	-- available are all except same version installed
	local available = {}
	for name,value in pairs(repo) do
		if value.version ~= value.installed then
			local temp = {}
			temp.name = name
			temp.version = value.version
			available[#available + 1] = temp
		end
	end
	table.sort(available, function(a,b) return (a.name < b.name) end)
	return available
end

delete = function(package)
	repo = repository()
	local success = false
	local cmdresult = "Delete failed - Invalid package"
	if package and repo[package] then
		success = true
		local cmd = path .. "apk_delete " .. package .. " 2>&1"
		local f = io.popen( cmd )
		cmdresult = f:read("*a") or ""
		f:close()
		install_cache = false
	end
	return success, cmdresult
end

install = function(package)
	repo = repository()
	local success = false
	local cmdresult = "Install failed - Invalid package"
	if package and repo[package] then
		success = true
		local cmd = path .. "apk_add " .. package .. " 2>&1"
		local f = io.popen( cmd )
		cmdresult = f:read("*a")
		f:close()
		install_cache = false
	end
	return success, cmdresult
end

is_installed = function(package)
	repo = repository()
	return package and repo[package] and repo[package].installed
end
