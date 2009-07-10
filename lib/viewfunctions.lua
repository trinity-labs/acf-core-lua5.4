require("html")

function displayitem(myitem)
	if not myitem then return end
	io.write("<DT")
	if myitem.errtxt then 
		myitem.class = "error"
		io.write(" class='error'")
	end
	io.write(">" .. html.html_escape(myitem.label) .. "</DT>\n")
	io.write("<DD>")
	io.write(string.gsub(html.html_escape(tostring(myitem.value)), "\n", "<BR>") .. "\n")
	if myitem.descr then io.write("<P CLASS='descr'>" .. string.gsub(html.html_escape(myitem.descr), "\n", "<BR>") .. "</P>\n") end
	if myitem.errtxt then io.write("<P CLASS='error'>" .. string.gsub(html.html_escape(myitem.errtxt), "\n", "<BR>") .. "</P>\n") end
	io.write("</DD>\n")
end

function displayformitem(myitem, name, viewtype)
	if not myitem then return end
	if name then myitem.name = name end
	if myitem.type ~= "hidden" then
		io.write("<DT")
		if myitem.errtxt then 
			myitem.class = "error"
			io.write(' class="error"')
		end
		io.write(">" .. html.html_escape(myitem.label) .. "</DT>\n")
		io.write("<DD>\n")
	end
	if (viewtype == "viewonly") then
		myitem.disabled = "true"
	end
	if myitem.type == "multi" then
		-- FIXME multiple select doesn't work in haserl, so use series of checkboxes
		--myitem.type = "select"
		--myitem.multiple = "true"
		myitem.class = nil
		local tempname = myitem.name
		local tempval = myitem.value or {}
		local reverseval = {}
		for x,val in ipairs(tempval) do
			reverseval[val] = x
		end
		local reverseopt = {}
		for x,val in ipairs(myitem.option) do
			reverseopt[val] = x
			myitem.value = val
			myitem.checked = reverseval[val]
			myitem.name = tempname .. "." .. x
			io.write(html.form.checkbox(myitem) .. html.html_escape(val) .. "<br>\n")
		end
		-- Check for values not in options
		if myitem.errtxt then
			myitem.class = "error"
			io.write('<p class="error">\n')
		end
		for x,val in ipairs(tempval) do
			if not reverseopt[val] then
				myitem.value = val
				myitem.checked = true
				io.write(html.form.checkbox(myitem) .. html.html_escape(val) .. "<br>\n")
			end
		end
		if myitem.errtxt then
			io.write('</p>\n')
		end
		myitem.name = tempname
		myitem.value = tempval
	elseif myitem.type == "boolean" then
		if (myitem.value == true) then myitem.checked = "" end
		myitem.value = "true"
		io.write(html.form.checkbox(myitem) .. "\n")
	elseif myitem.type == "list" then
		myitem.value = table.concat(myitem.value, "\n")
		io.write(html.form.longtext(myitem) .. "\n")
	else
		io.write((html.form[myitem.type](myitem) or "") .. "\n")
	end
	if myitem.type ~= "hidden" then
		if myitem.descr then io.write('<P CLASS="descr">' .. string.gsub(html.html_escape(myitem.descr), "\n", "<BR>") .. "</P>\n") end
		if myitem.errtxt then io.write('<P CLASS="error">' .. string.gsub(html.html_escape(myitem.errtxt), "\n", "<BR>") .. "</P>\n") end
		io.write("</DD>\n")
	end
end

function displayformstart(myform, page_info)
	if not myform then return end
	if not myform.action and page_info then
		myform.action = page_info.script .. page_info.prefix .. page_info.controller .. "/" .. page_info.action
	end
	if myform.descr then io.write('<P CLASS="descr">' .. string.gsub(html.html_escape(myform.descr), "\n", "<BR>") .. "</P>\n") end
	if myform.errtxt then io.write('<P CLASS="error">' .. string.gsub(html.html_escape(myform.errtxt), "\n", "<BR>") .. "</P>\n") end
	io.write('<form action="' .. html.html_escape(myform.action) .. '" ')
	if myform.enctype and myform.enctype ~= "" then
		io.write('enctype="'..html.html_escape(myform.enctype)..'" ')
	end
	io.write('method="POST">\n')
	if myform.value.redir then
		displayformitem(myform.value.redir, "redir")
	end
end

function displayform(myform, order, finishingorder, page_info)
	if not myform then return end
	displayformstart(myform, page_info)
	io.write('<DL>\n')
	local reverseorder= {["redir"]=0}
	if order then
		for x,name in ipairs(order) do
			reverseorder[name] = x
			if myform.value[name] then
				myform.value[name].name = name
				displayformitem(myform.value[name])
			end
		end
	end
	local reversefinishingorder = {}
	if finishingorder then
		for x,name in ipairs(finishingorder) do
			reversefinishingorder[name] = x
		end
	end
	for name,item in pairs(myform.value) do
		if nil == reverseorder[name] and nil == reversefinishingorder[name] then
			item.name = name
			displayformitem(item)
		end
	end
	if finishingorder then
		for x,name in ipairs(finishingorder) do
			if myform.value[name] then
				myform.value[name].name = name
				displayformitem(myform.value[name])
			end
		end
	end
	io.write('</DL>\n')
	displayformend(myform)
end

function displayformend(myform)
	if not myform then return end
	io.write('<DL>\n')
	io.write('<DT></DT><DD><input class="submit" type="submit" name="' .. html.html_escape(myform.option) .. '" value="' .. html.html_escape(myform.submit or myform.option) .. '"></DD>\n')
	io.write('</DL>\n')
	io.write('</FORM>')
end

function displaycommandresults(commands, session, preserveerrors)
	local cmdresult = {}
	for i,cmd in ipairs(commands) do
		if session[cmd.."result"] then
			cmdresult[#cmdresult + 1] = session[cmd.."result"]
			if not preserveerrors or not session[cmd.."result"].errtxt then
				session[cmd.."result"] = nil
			end
		end
	end
	if #cmdresult > 0 then
		io.write("<H1>Command Result</H1>\n<DL>\n")
		for i,result in ipairs(cmdresult) do
			if type(result.value) == "string" and result.value ~= "" then io.write(string.gsub(html.html_escape(result.value), "\n", "<BR>") .. "\n") end
			if result.descr then io.write('<P CLASS="descr">' .. string.gsub(html.html_escape(result.descr), "\n", "<BR>") .. "</P>\n") end
			if result.errtxt then io.write('<P CLASS="error">' .. string.gsub(html.html_escape(result.errtxt), "\n", "<BR>") .. "</P>\n") end
		end
		io.write("</DL>\n")
	end
end
