<% local form, viewtable, page_info = ... %> 
<% require("viewfunctions") %>

<% --[[
	io.write(html.cfe_unpack(form))
--]] %>

<H1><%= form.label %></H1>
<%
	displayformstart(form, page_info)
	-- If editing existing role, disable role
	if page_info.action ~= "newrole" then
		form.value.role.readonly = true
	end
	io.write("<DL>\n")
	displayformitem(form.value.role, "role")

	-- copied this code from viewfunctions so we can disable the default boxes
	local myitem = form.value.permissions
	myitem.name = "permissions"
	io.write("<DT")
	if myitem.errtxt then 
		myitem.class = "error"
		io.write(' class="error"')
	end
	io.write(">" .. myitem.label .. "</DT>\n")
	io.write("<DD>")
	-- FIXME multiple select doesn't work in haserl, so use series of checkboxes
	myitem.class = nil
	local tempname = myitem.name
	local tempval = myitem.value or {}
	local reversedefault = {}
	for x,val in ipairs(myitem.default or {}) do
		reversedefault[val] = x
	end
	local reverseval = {}
	for x,val in ipairs(tempval) do
		reverseval[val] = x
	end
	local reverseopt = {}
	for x,val in ipairs(myitem.option) do
		reverseopt[val] = x
		myitem.value = val
		myitem.checked = reverseval[val]
		if reversedefault[val] then myitem.disabled = true else myitem.disabled = nil end
		myitem.name = tempname .. "." .. x
		io.write(html.form.checkbox(myitem) .. val .. "<br>\n")
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
			io.write(html.form.checkbox(myitem) .. val .. "<br>\n")
		end
	end
	if myitem.errtxt then
		io.write('</p>\n')
	end
	myitem.name = tempname
	myitem.value = tempval

	if myitem.descr then io.write('<P CLASS="descr">' .. string.gsub(myitem.descr, "\n", "<BR>") .. "</P>\n") end
	if myitem.errtxt then io.write('<P CLASS="error">' .. string.gsub(myitem.errtxt, "\n", "<BR>") .. "</P>\n") end
	io.write("</DD>\n")

	io.write("</DL>\n")
	displayformend(form)
%>
