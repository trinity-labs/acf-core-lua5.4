module(..., package.seeall)

function handle_form(self, getFunction, setFunction, clientdata, option, label, descr, redirectOnSuccess)
	local form = getFunction()

	if clientdata[option] then
		form.errtxt = nil
		for name,value in pairs(form.value) do
			value.errtxt = nil
			if value.type == "boolean" then
				value.value = (clientdata[name] ~= nil)
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
		form = setFunction(form)
		if not form.errtxt then
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
	status = status.value.status

	return cfe({ type="group", value={status=status, result=result} })
end

