<% local view= ... %> 
<% require("htmlviewfunctions") %>
<h1>Log Out</h1>

<%= htmlviewfunctions.cfe_unpack(view) %>

<%= html.html_escape(view.logout.value) %>
