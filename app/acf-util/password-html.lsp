<% local form, viewlibrary, pageinfo = ... %>
<% require("htmlviewfunctions") %>

<H1><%= html.html_escape(form.label) %></H1>
<% 
	if form.value.password and form.value.password_confirm then
		form.value.password.type = "password"
		form.value.password_confirm.type = "password"
	end
	-- If not in newuser action, disable userid
	if pageinfo.action ~= "newuser" then
		form.value.userid.readonly = true
	end
	local order = { "userid", "username", "roles", "password", "password_confirm" }
	htmlviewfunctions.displayform(form, order)
%>
