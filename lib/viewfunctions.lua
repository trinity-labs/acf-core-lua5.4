
function displayinfo(myform,tags,viewtype)
	for k,v in pairs(tags) do 
		if (myform[v]) and (myform[v]["value"]) then
			local val = myform[v] 
			io.write("\n\t<DT")
			if (#val.errtxt > 0) then 
				val.class = "error"
				io.write(" class='error'")
			end
			io.write(">" .. val.label .. "</DT>")
			io.write("\n\t\t<DD>")
			if (viewtype == "viewonly") then
				if (val.value == "") and (val.errtxt == "") and ((val.descr) and (val.descr == "")) then val.value = "&nbsp;" end
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
			if (#val.errtxt > 0) then io.write("\n\t\t<P CLASS='error'>" .. string.gsub(val.errtxt, "\n", "<BR>") .. "</P>") end
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
