<% local view, viewlibrary, page_info, session= ... %>
<% require("viewfunctions") %>

<% displaycommandresults({"newrole", "editrole", "deleterole"}, session) %>

<H1>Roles</H1>
<H2>Create new role</H2>
<form action="<%= html.html_escape(page_info.script .. page_info.prefix .. page_info.controller) %>/newrole" method="POST">
<input class="hidden" type="hidden"  name="redir"  value="<%= html.html_escape(page_info.orig_action) %>" >
<dl><dt></dt><dd><input class="submit" type="submit" value="Create"></dd></dl>
</form>

<H2>Existing roles</H2>
<DL>
<TABLE>
<% if view.value.defined_roles then %>
	<% for x,role in pairs(view.value.defined_roles.value) do %>
		<TR><TD><dt><img src='<%= html.html_escape(page_info.wwwprefix..page_info.staticdir) %>/tango/16x16/apps/system-users.png' height='16' width='16'> <%= html.html_escape(role) %></dt>
		<dd>
		[<a href='viewroleperms?role=<%= html.html_escape(role) %>'>View this role</a>]
		[<a href='editrole?role=<%= html.html_escape(role) %>&redir=<%= html.html_escape(page_info.orig_action) %>'>Edit this role</a>]
		[<a href='deleterole?role=<%= html.html_escape(role) %>'>Delete this role</a>]
		</dd></TD></TR>
	<% end %>
<% end %>
<% if view.value.default_roles then %>
	<% for x,role in pairs(view.value.default_roles.value) do %>
		<TR><TD><dt><img src='<%= html.html_escape(page_info.wwwprefix..page_info.staticdir) %>/tango/16x16/categories/applications-system.png' height='16' width='16'> <%= html.html_escape(role) %></dt>
		<dd>
		[<a href='viewroleperms?role=<%= html.html_escape(role) %>'>View this role</a>]
		[<a href='editrole?role=<%= html.html_escape(role) %>&redir=<%= html.html_escape(page_info.orig_action) %>'>Edit this role</a>]
		</dd></TD></TR>
	<% end %>
<% end %>
</TABLE>
</DL>
