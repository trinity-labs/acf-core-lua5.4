<% local form, viewlibrary, page_info, session = ... %>
<% require("viewfunctions") %>

<% displaycommandresults({"newuser", "edituser", "deleteuser"}, session) %>

<H1>User Accounts</H1>
<H2>Create new account</H2>
<form action="<%= page_info.script .. page_info.prefix .. page_info.controller %>/newuser" method="POST">
<input class="hidden" type="hidden"  name="redir"  value="<%= html.html_escape(page_info.orig_action) %>" >
<dl><dt></dt><dd><input class="submit" type="submit" value="Create"></dd></dl>
</form>
<H2>Existing account</H2>
<DL>
<% for i,user in ipairs(form.value) do
	local name = html.html_escape(user.value.userid.value) %>
	<DT><IMG SRC='<%= html.html_escape(page_info.wwwprefix..page_info.staticdir) %>/tango/16x16/apps/system-users.png' HEIGHT='16' WIDTH='16'> <%= name %></DT>
	<DD><TABLE>
		<TR>
			<TD STYLE='border:none;'><B><%= html.html_escape(user.value.userid.label) %></B></TD>
			<TD STYLE='border:none;' WIDTH='90%'><%= html.html_escape(user.value.userid.value) %></TD>
		</TR><TR>
			<TD STYLE='border:none;'><B><%= html.html_escape(user.value.username.label) %></B></TD>
			<TD STYLE='border:none;'><%= html.html_escape(user.value.username.value) %></TD>
		</TR><TR>
			<TD STYLE='border:none;'><B><%= html.html_escape(user.value.roles.label) %></B></TD>
			<TD STYLE='border:none;'><%= html.html_escape(table.concat(user.value.roles.value, ", ")) %></TD>
		</TR><TR>
			<TD STYLE='border:none;'><B>Option</B></TD>
			<TD STYLE='border:none;'>
			[<A HREF='edituser?userid=<%= name %>&redir=<%= html.html_escape(page_info.orig_action) %>'>Edit this account</A>]
			[<A HREF='deleteuser?userid=<%= name %>'>Delete this account</A>]
			[<A HREF='<%= html.html_escape(page_info.script) %>/acf-util/roles/viewuserroles?userid=<%= name %>'>View roles for this account</A>]
			</TD>
		</TR>
	</TABLE></DD>
<% end %>
</DL>
