<% local form, viewlibrary, page_info, session = ... %>
<% htmlviewfunctions = require("htmlviewfunctions") %>
<% html = require("acf.html") %>

<% htmlviewfunctions.displaycommandresults({"newuser", "edituser", "deleteuser"}, session) %>

<%
local header_level = htmlviewfunctions.displayheader(form, page_info)
local newaccount = cfe({ type="link", value={}, label="Create New Account", option="Create", action=page_info.script..page_info.prefix..page_info.controller.."/newuser" })
newaccount.value.redir = cfe({ type="hidden", value=page_info.orig_action })
htmlviewfunctions.displayitem(newaccount, htmlviewfunctions.incrementheader(header_level), page_info)

htmlviewfunctions.displayheader(cfe({label="Existing Accounts"}), page_info, htmlviewfunctions.incrementheader(header_level))
for i,user in ipairs(form.value) do
	local name = html.html_escape(user.value.userid.value) %>
	<div class='item'><p class='left'><img src='<%= html.html_escape(page_info.wwwprefix..page_info.staticdir) %>/tango/16x16/apps/system-users.png' height='16' width='16'> <%= name %></p>
	<div class='right'>
	<table><tbody>
		<tr>
			<td style='border:none;'><b><%= html.html_escape(user.value.userid.label) %></b></td>
			<td style='border:none;' width='90%'><%= html.html_escape(user.value.userid.value) %></td>
		</tr><tr>
			<td style='border:none;'><b><%= html.html_escape(user.value.username.label) %></b></td>
			<td style='border:none;'><%= html.html_escape(user.value.username.value) %></td>
		</tr><tr>
			<td style='border:none;'><b><%= html.html_escape(user.value.roles.label) %></b></td>
			<td style='border:none;'><%= html.html_escape(table.concat(user.value.roles.value, ", ")) %></td>
		</tr><tr>
			<td style='border:none;'><b>Option</b></td>
			<td style='border:none;'>
			[<a href='edituser?userid=<%= name %>&redir=<%= html.html_escape(page_info.orig_action) %>'>Edit this account</a>]
			[<a href='deleteuser?userid=<%= name %>&submit=true'>Delete this account</a>]
			[<a href='<%= html.html_escape(page_info.script) %>/acf-util/roles/viewuserroles?userid=<%= name %>'>View roles for this account</a>]
			</td>
		</tr>
	</tbody></table>
	</div></div><!-- end .item -->
<% end %>
