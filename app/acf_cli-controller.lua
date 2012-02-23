module(..., package.seeall)

require("posix")

local parent_exception_handler

mvc = {}
mvc.on_load = function (self, parent)
	-- Make sure we have some kind of sane defaults for libdir
	self.conf.libdir = self.conf.libdir or ( string.match(self.conf.appdir, "[^,]+/") .. "/lib/" )
	self.conf.script = ""
	self.conf.default_prefix = "/acf-util/"	
	self.conf.default_controller = "welcome"
	self.conf.viewtype = "serialized"

	parent_exception_handler = parent.exception_handler

	-- this sets the package path for us and our children
	for p in string.gmatch(self.conf.libdir, "[^,]+") do
		package.path=  p .. "?.lua;" .. package.path
	end

	self.session = {}
	local x=require("session")
end

mvc.pre_exec = function ()
end

mvc.post_exec = function ()
end

exception_handler = function (self, message )
	print(session.serialize("exception", message))
	parent_exception_handler(self, message)
end

redirect = function (self, str, result)
	return result
end

redirect_to_referrer = function(self, result)
	return result
end

-- syslog something
logevent = function ( ... )
	os.execute ( "logger \"" .. ... .. "\"" )
end

-- FIXME - remove the haserl specific stuff
handle_clientdata = function(form, clientdata)
	form.errtxt = nil
	for n,value in pairs(form.value) do
		value.errtxt = nil
		local name = n
		if name:find("%.") and not clientdata[name] then
			-- If the name has a '.' in it, haserl will interpret it as a table
			local actualval = clientdata
			for entry in name:gmatch("[^%.]+") do
				if tonumber(entry) then
					actualval = actualval[tonumber(entry)]
				else
					actualval = actualval[entry]
				end
				if not actualval then break end
			end
			clientdata[name] = actualval
		end
		if value.type == "group" then
			handle_clientdata(value, clientdata[name])
		elseif value.type == "boolean" then
			value.value = (clientdata[name] ~= nil) and (clientdata[name] ~= "false")
		elseif value.type == "multi" then
			if clientdata[name] == nil then
				-- for cli we use name[num] as the name
				clientdata[name] = {}
				for n,val in pairs(clientdata) do
					if string.find(n, "^"..name.."%[%d+%]$") then
						clientdata[name][tonumber(string.match(n, "%[(%d+)%]$"))] = val
					end
				end
			end
			-- FIXME this is because multi selects don't work in haserl
			local oldtable = clientdata[name] or {}
			-- Assume it's a sparse array, and remove blanks
			local newtable={}
			for x=1,table.maxn(oldtable) do
				if oldtable[x] then
					newtable[#newtable + 1] = oldtable[x]
				end
			end
			value.value = newtable
		elseif value.type == "list" then
			value.value = {}
			if clientdata[name] and clientdata[name] ~= "" then
				-- for www we use \r separated list
				for ip in string.gmatch(clientdata[name].."\n", "%s*([^\n]*%S)%s*\n") do
					table.insert(value.value, ip)
				end
			else
				-- for cli we use name[num] as the name
				for n,val in pairs(clientdata) do
					if string.find(n, "^"..name.."%[%d+%]$") then
						value.value[tonumber(string.match(n, "%[(%d+)%]$"))] = val
					end
				end
			end
		else
			value.value = clientdata[name] or value.value
		end
	end
end
