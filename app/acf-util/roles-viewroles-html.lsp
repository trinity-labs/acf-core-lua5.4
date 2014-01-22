<% local view, viewlibrary, page_info, session= ... %>
<% htmlviewfunctions = require("htmlviewfunctions") %>
<% html = require("acf.html") %>

<script type="text/javascript">
        if (typeof jQuery == 'undefined') {
                document.write('<script type="text/javascript" src="<%= html.html_escape(page_info.wwwprefix) %>/js/jquery-latest.js"><\/script>');
	}
</script>

<script type="text/javascript">
	if (typeof $.tablesorter == 'undefined') {
		document.write('<script type="text/javascript" src="<%= html.html_escape(page_info.wwwprefix) %>/js/jquery.tablesorter.js"><\/script>');
	}
</script>

<script type="text/javascript">
	$(document).ready(function() {
		$("#list").tablesorter({headers: {1:{sorter: false}}, widgets: ['zebra']});
	});
</script>

<% htmlviewfunctions.displaycommandresults({"newrole", "editrole", "deleterole"}, session) %>

<h1>Roles</h1>
<h2>Create new role</h2>
<form action="<%= html.html_escape(page_info.script .. page_info.prefix .. page_info.controller) %>/newrole" method="POST">
<input class="hidden" type="hidden"  name="redir"  value="<%= html.html_escape(page_info.orig_action) %>" >
<div class='item'><p class='left'></p><div class='right'><input class="submit" type="submit" value="Create"></div></div><!-- end .item -->
</form>

<h2>Existing roles</h2>
<table id="list" class="tablesorter"><thead>
	<tr><th>Role</th><th>Action</th></tr>
</thead><tbody>
<% if view.value.defined_roles then %>
	<% for x,role in pairs(view.value.defined_roles.value) do %>
		<tr><td><img src='<%= html.html_escape(page_info.wwwprefix..page_info.staticdir) %>/tango/16x16/apps/system-users.png' height='16' width='16'> <%= html.html_escape(role) %></td>
		<td>
		[<a href='viewroleperms?role=<%= html.html_escape(role) %>'>View this role</a>]
		[<a href='editrole?role=<%= html.html_escape(role) %>&redir=<%= html.html_escape(page_info.orig_action) %>'>Edit this role</a>]
		[<a href='deleterole?role=<%= html.html_escape(role) %>&submit=true'>Delete this role</a>]
		</td></tr>
	<% end %>
<% end %>
<% if view.value.default_roles then %>
	<% for x,role in pairs(view.value.default_roles.value) do %>
		<tr><td><img src='<%= html.html_escape(page_info.wwwprefix..page_info.staticdir) %>/tango/16x16/categories/applications-system.png' height='16' width='16'> <%= html.html_escape(role) %></td>
		<td>
		[<a href='viewroleperms?role=<%= html.html_escape(role) %>'>View this role</a>]
		[<a href='editrole?role=<%= html.html_escape(role) %>&redir=<%= html.html_escape(page_info.orig_action) %>'>Edit this role</a>]
		</td></tr>
	<% end %>
<% end %>
</tbody></table>
