<% local view= ... %> 
<h1>Log Out</h1>

<%= html.cfe_unpack(view) %>

<%= html.html_escape(view.logout.value) %>
