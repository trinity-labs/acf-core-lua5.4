<% local view= ... %> 
<% --[[
	io.write(html.cfe_unpack(view))
--]] %>
<h1>User Status </h1>
<p> Below is your current Session id <p>
<%= html.html_escape(view.value.sessionid.value) %>
<p>You are currently known to the system as <%= html.html_escape(view.value.username.value) %>.</p>
