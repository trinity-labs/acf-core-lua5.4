<% local form, viewlibrary, pageinfo = ... %>
<% require("viewfunctions") %>
<%
--[[ DEBUG INFORMATION
io.write("<H1>DEBUGGING</H1><span style='color:red'><H2>DEBUG INFO: CFE</H2>")
io.write(html.cfe_unpack(form))
io.write(html.cfe_unpack(FORM))
io.write("</span>")
--]]
%>

<H1><%= form.label %></H1>
<% 
	if form.value.password and form.value.password_confirm then
		form.value.password.type = "password"
		form.value.password_confirm.type = "password"
	end
	-- If not in newuser action, disable userid
	if pageinfo.action ~= "newuser" then
		form.value.userid.contenteditable = false
	end
	local order = { "userid", "username", "roles", "password", "password_confirm" }
	displayform(form, order)
%>
