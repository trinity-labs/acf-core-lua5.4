module(..., package.seeall)

function handle_clientdata(form, clientdata)
	form.errtxt = nil
	for name,value in pairs(form.value) do
		value.errtxt = nil
		if name:find("%.") then
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
		if value.type == "boolean" then
			value.value = (clientdata[name] ~= nil)
		elseif value.type == "multi" then
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
				for ip in string.gmatch(clientdata[name].."\n", "%s*(%S[^\n]*%S)%s*\n") do
					table.insert(value.value, ip)
				end
			end
		else
			value.value = clientdata[name] or value.value
		end
	end
end

function handle_form(self, getFunction, setFunction, clientdata, option, label, descr, redirectOnSuccess)
	local form = getFunction()

	if clientdata[option] then
		handle_clientdata(form, clientdata)

		form = setFunction(form)
		if not form.errtxt and descr then
			form.descr = descr
		end
		form = self:redirect_to_referrer(form)
		if redirectOnSuccess and not form.errtxt then
			self:redirect(redirectOnSuccess)
		end
	else
		form = self:redirect_to_referrer() or form
	end

	form.type = "form"
	form.option = option
	form.label = label

	return form
end

function handle_startstop(self, startstopfunction, getstatusfunction, clientdata)
	local result
	if clientdata.action then
		result = startstopfunction(clientdata.action)
	end
	result = self:redirect_to_referrer(result)

	local status = getstatusfunction()
	if status.value.status then status = status.value.status end

	return cfe({ type="group", value={status=status, result=result} })
end

