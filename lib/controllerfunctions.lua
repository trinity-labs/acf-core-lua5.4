module(..., package.seeall)

function handle_clientdata(form, clientdata, group)
	form.errtxt = nil
	for n,value in pairs(form.value) do
		value.errtxt = nil
		local name = n
		if group then name = group.."."..name end
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
			handle_clientdata(value, clientdata, name)
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

function handle_form(self, getFunction, setFunction, clientdata, option, label, descr)
	local form = getFunction()

	if clientdata[option] then
		handle_clientdata(form, clientdata)

		form = setFunction(form)
		if not form.errtxt and descr then
			form.descr = descr
		end
		
		if clientdata.redir then
			form.value.redir = cfe({ type="hidden", value=clientdata.redir, label="" })
		end
		form = self:redirect_to_referrer(form)
		if clientdata.redir and not form.errtxt then
			form.value = form.descr -- make it a command result
			form.descr = nil
			self:redirect(clientdata.redir, form)
		end
	else
		if clientdata.redir then
			form.value.redir = cfe({ type="hidden", value=clientdata.redir, label="" })
		end
		form = self:redirect_to_referrer() or form
	end

	form.type = "form"
	form.option = option
	form.label = label

	return form
end

function handle_startstop(self, startstopfunction, clientdata)
	local result = startstopfunction(clientdata.action)
	result.value.result = self:redirect_to_referrer(result.value.result)
	return result
end

