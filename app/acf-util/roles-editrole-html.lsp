<% local form, viewtable, page_info = ... %> 
<% require("viewfunctions") %>

<% --[[
	io.write(html.cfe_unpack(form))
--]] %>

<H1><%= form.label %></H1>
<%
	form.action = page_info.script .. page_info.prefix .. page_info.controller .. "/" .. page_info.action
	-- If editing existing role, disable role
	if page_info.action ~= "newrole" then
		form.value.role.contenteditable = false
	end
	local order = { "role", "permissions" }
	displayform(form, order)
%>
