<% local view, viewlibrary, page_info, session = ... %>
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

<%
local header_level = htmlviewfunctions.displayheader(view, page_info)
header_level = htmlviewfunctions.incrementheader(header_level)
local redir = cfe({ type="hidden", value=page_info.orig_action })
htmlviewfunctions.displayitem(cfe({ type="link", value={redir=redir}, label="Create New Role", option="Create", action="newrole" }), header_level, page_info)

htmlviewfunctions.displayheader(cfe({label="Existing Roles"}), page_info, header_level)
%>
<table id="list" class="tablesorter"><thead>
	<tr><th>Role</th><th>Action</th></tr>
</thead><tbody>
<% if view.value.defined_roles then %>
	<% for x,role in pairs(view.value.defined_roles.value) do %>
		<tr><td><img src='<%= html.html_escape(page_info.wwwprefix..page_info.staticdir) %>/tango/16x16/apps/system-users.png' height='16' width='16'> <%= html.html_escape(role) %></td>
		<td>
		<%
		local r = cfe({type="hidden", value=role})
		htmlviewfunctions.displayitem(cfe({ type="link", value={role=r}, label="", option="View", action="viewroleperms" }), -1, page_info)
		htmlviewfunctions.displayitem(cfe({ type="link", value={role=r, redir=redir}, label="", option="Edit", action="editrole" }), -1, page_info)
		htmlviewfunctions.displayitem(cfe({ type="form", value={role=r}, label="", option="Delete", action="deleterole" }), -1, page_info)
		%>
		</td></tr>
	<% end %>
<% end %>
<% if view.value.default_roles then %>
	<% for x,role in pairs(view.value.default_roles.value) do %>
		<tr><td><img src='<%= html.html_escape(page_info.wwwprefix..page_info.staticdir) %>/tango/16x16/categories/applications-system.png' height='16' width='16'> <%= html.html_escape(role) %></td>
		<td>
		<%
		local r = cfe({type="hidden", value=role})
		htmlviewfunctions.displayitem(cfe({ type="link", value={role=r}, label="", option="View", action="viewroleperms" }), -1, page_info)
		htmlviewfunctions.displayitem(cfe({ type="link", value={role=r, redir=redir}, label="", option="Edit", action="editrole" }), -1, page_info)
		%>
		</td></tr>
	<% end %>
<% end %>
</tbody></table>
