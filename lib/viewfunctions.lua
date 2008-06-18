
function displayinfo(myform,tags,viewtype)
	for k,v in pairs(tags) do 
		if (myform[v]) and (myform[v]["value"]) then
			local val = myform[v] 
			local label = val.label
			io.write("\n\t<DT")
			if (val.errtxt) then 
				val.class = "error"
				io.write(" class='error'")
			end
			if val.id then
				label = "<label for=\"" .. val.id .."\">" .. val.label .. "</label>"
			end
			io.write(">" .. label .. "</DT>")
			io.write("\n\t\t<DD")
			if (val.errtxt) then 
				val.class = "error"
				io.write(" class='error'")
			end
			io.write(">")
			if (viewtype == "viewonly") then
				if (val.value == "") and (val.errtxt == nil) and ((val.descr) and (val.descr == "")) then val.value = "&nbsp;" end
				io.write(val.value)
			elseif (val.type == "radio") and (type(val.option) == "table") and (#val.option > 0) then
				io.write("<span style='display:inline' class='" .. ( val.class or "") .. "'>")
				for k1,v1 in pairs(val.option) do
					io.write(tostring(v1.label) .. ":")
					io.write("<input style='margin-right:20px;margin-left:5px;' type='radio' class='" .. ( val.class or "") .. "' name='" .. val.name .. "'")
					if (tostring(val.value) == tostring(v1.value)) then io.write(" checked='yes'") end
					io.write(" value='" .. v1.value .. "'>")
				end
				io.write("</input></span>")
			else
				io.write(html.form[val.type](val))
			end
			if (val.descr) and (#val.descr > 0) then io.write("\n\t\t<P CLASS='descr'>" .. string.gsub(val.descr, "\n", "<BR>") .. "</P>") end
			if (val.errtxt) then io.write("\n\t\t<P CLASS='error'>" .. string.gsub(val.errtxt, "\n", "<BR>") .. "</P>") end
			io.write("\n\t\t</DD>\n")
		end
	end
end

function displaymanagement (myform,tags)
	local descriptions, errors
	for k,v in pairs(tags) do
		if (myform[v]) then
			if (myform[v]['descr']) and (#myform[v]['descr'] > 0) then 
				descriptions = (descriptions or "") .. myform[v]['descr']
			end
			if (myform[v]['errtxt']) and (#myform[v]['errtxt'] > 0) then 
				errors = (errors or "") .. myform[v]['errtxt']
			end
		end
	end

	if (myform) and (myform[tags[1]]) then
		io.write('<dt>' .. (myform[tags[1]]["label"] or myform[tags[1]]["name"]) .. '</dt>')
		io.write('<dd>')
		--Show buttons
		for k,v in pairs(tags) do
			if (myform[v]) then
				io.write(html.form[myform[v].type](myform[v]))
			end
		end
		if (descriptions) and (#descriptions > 0) then 
			io.write("\n\t\t<P CLASS='descr'>" .. string.gsub(descriptions, "\n", "<BR>") .. "</P>")
		end
		if (errors) and (#errors > 0) then 
			io.write("\n\t\t<P CLASS='error'>" .. string.gsub(errors, "\n", "<BR>") .. "</P>") 
		end
		io.write('</dd>')

		-- Display the result of previous action
		if (myform) and (myform['actionresult']) then
			if (myform['actionresult']['errtxt']) and (#myform['actionresult']['errtxt'] > 0) then
				io.write('<dt class="error">' .. myform['actionresult']['label'] .. '</dt>')
				io.write('<dd><pre class="error">' .. (myform['actionresult']['errtxt'] or "") .. '</pre></dd>')
			elseif (myform['actionresult']['descr']) and (#myform['actionresult']['descr'] > 0) then
				io.write('<dt>' .. myform['actionresult']['label'] .. '</dt>')
				io.write('<dd><pre>' .. (myform['actionresult']['descr'] or "") .. '</pre></dd>')
			end
		end
	end
end

function displayitem(myitem)
	if not myitem then return end
	io.write("<DT")
	if myitem.errtxt then 
		myitem.class = "error"
		io.write(" class='error'")
	end
	io.write(">" .. myitem.label .. "</DT>\n")
	io.write("<DD>")
	io.write(string.gsub(tostring(myitem.value), "\n", "<BR>") .. "\n")
	if myitem.descr then io.write("<P CLASS='descr'>" .. string.gsub(myitem.descr, "\n", "<BR>") .. "</P>\n") end
	if myitem.errtxt then io.write("<P CLASS='error'>" .. string.gsub(myitem.errtxt, "\n", "<BR>") .. "</P>\n") end
	io.write("</DD>\n")
end

function displayformitem(myitem, name, viewtype)
	if not myitem then return end
	if name then myitem.name = name end
	io.write("<DT")
	if myitem.errtxt then 
		myitem.class = "error"
		io.write(" class='error'")
	end
	io.write(">" .. myitem.label .. "</DT>\n")
	io.write("<DD>")
	if (viewtype == "viewonly") then
		myitem.disabled = "true"
	end
	if myitem.type == "multi" then
		-- FIXME multiple select doesn't work in haserl, so use series of checkboxes
		--myitem.type = "select"
		--myitem.multiple = "true"
		local tempname = myitem.name
		local tempval = myitem.value or {}
		local reverseval = {}
		for x,val in ipairs(tempval) do
			reverseval[val] = x
		end
		for x,val in ipairs(myitem.option) do
			myitem.value = val
			myitem.checked = reverseval[val]
			myitem.name = tempname .. "." .. x
			io.write(html.form.checkbox(myitem) .. val .. "<br>\n")
		end
		myitem.name = tempname
		myitem.value = tempval
	elseif myitem.type == "boolean" then
		if (myitem.value == true) then myitem.checked = "" end
		myitem.value = "true"
		io.write(html.form.checkbox(myitem) .. "\n")
	else
		io.write((html.form[myitem.type](myitem) or "") .. "\n")
	end
	if myitem.descr then io.write("<P CLASS='descr'>" .. string.gsub(myitem.descr, "\n", "<BR>") .. "</P>\n") end
	if myitem.errtxt then io.write("<P CLASS='error'>" .. string.gsub(myitem.errtxt, "\n", "<BR>") .. "</P>\n") end
	io.write("</DD>\n")
end

function displayform(myform, order)
	if not myform then return end
	if myform.descr then io.write("<P CLASS='descr'>" .. string.gsub(myform.descr, "\n", "<BR>") .. "</P>\n") end
	if myform.errtxt then io.write("<P CLASS='error'>" .. string.gsub(myform.errtxt, "\n", "<BR>") .. "</P>\n") end
	io.write('<form action="' .. (myform.action or "") .. '" method="POST">\n')
	io.write('<DL>\n')
	local reverseorder= {}
	if order then
		for x,name in ipairs(order) do
			reverseorder[name] = x
			if myform.value[name] then
				myform.value[name].name = name
				displayformitem(myform.value[name])
			end
		end
	end
	for name,item in pairs(myform.value) do
		if nil == reverseorder[name] then
			item.name = name
			displayformitem(item)
		end
	end
	io.write('<DT></DT><DD><input class="submit" type="submit" name="' .. myform.option .. '" value="' .. (myform.submit or myform.option) .. '"></DD>\n')
	io.write('</DL>\n')
	io.write('</FORM>')
end
