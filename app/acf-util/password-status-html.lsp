<% local form, viewlibrary, page_info, session = ... %>
<% require("viewfunctions") %>
<%
--[[ DEBUG INFORMATION
io.write("<H1>DEBUGGING</H1><span style='color:red'><H2>DEBUG INFO: CFE</H2>")
io.write(html.cfe_unpack(form))
io.write("</span>")
--]]
%>

<% displaycommandresults({"newuser", "edituser", "deleteuser"}, session) %>

<H1>User Accounts</H1>
<H2>Create new account</H2>
<form action="<%= page_info.script .. page_info.prefix .. page_info.controller %>/newuser" method="POST">
<input class="hidden" type="hidden"  name="redir"  value="<%= html.html_escape(page_info.orig_action) %>" >
<dl><dt></dt><dd><input class="submit" type="submit" value="Create"></dd></dl>
</form>
<H2>Existing account</H2>
<DL>
<% for name,user in pairs(form.value) do %>
	<DT><IMG SRC='/skins/static/tango/16x16/apps/system-users.png' HEIGHT='16' WIDTH='16'> <%= html.html_escape(name) %></DT>
	<DD><TABLE>
		<TR>
			<TD STYLE='border:none;'><B><%= html.html_escape(user.value.userid.label) %></B></TD>
			<TD STYLE='border:none;' WIDTH='90%'><%= html.html_escape(user.value.userid.value) %></TD>
		</TR><TR>
			<TD STYLE='border:none;'><B><%= html.html_escape(user.value.username.label) %></B></TD>
			<TD STYLE='border:none;'><%= html.html_escape(user.value.username.value) %></TD>
		</TR><TR>
			<TD STYLE='border:none;'><B><%= html.html_escape(user.value.roles.label) %></B></TD>
			<TD STYLE='border:none;'><%= html.html_escape(table.concat(user.value.roles.value, " / ")) %></TD>
		</TR><TR>
			<TD STYLE='border:none;'><B>Option</B></TD>
			<TD STYLE='border:none;'>
			[<A HREF='edituser?userid=<%= html.html_escape(name) %>&redir=<%= html.html_escape(page_info.orig_action) %>'>Edit this account</A>]
			[<A HREF='deleteuser?userid=<%= html.html_escape(name) %>'>Delete this account</A>]
			[<A HREF='<%= html.html_escape(page_info.script) %>/acf-util/roles/viewuserroles?userid=<%= html.html_escape(name) %>'>View roles for this account</A>]
			</TD>
		</TR>
	</TABLE></DD>
<% end %>
</DL>
