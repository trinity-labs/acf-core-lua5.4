<% local view= ... %> 
<% require("viewfunctions") %>
<h1>Log Out</h1>

<%= cfe_unpack(view) %>

<%= html.html_escape(view.logout.value) %>
