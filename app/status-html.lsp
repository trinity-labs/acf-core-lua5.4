<% local data, viewlibrary, page_info, session = ... 
require("viewfunctions")
%>

<% displaycommandresults({"install","edit"}, session) %>

<H1>System Info</H1>
<DL>
<%
displayitem(data.value.status)

displayitem(data.value.version)
if data.value.version and data.value.version.errtxt and session.permissions.apk and session.permissions.apk.install then
%>
	<a href="<%= html.html_escape(page_info.script .. "/apk-tools/apk/install?package="..data.value.version.name) %>">Install</a>
<%
end

displayitem(data.value.autostart)
if not (data.value.version and data.value.version.errtxt) and data.value.autostart and data.value.autostart.errtxt and session.permissions.rc and session.permissions.rc.edit then
%>
	<a href="<%= html.html_escape(page_info.script .. "/alpine-baselayout/rc/edit?servicename="..data.value.autostart.name.."&redir=".. page_info.orig_action) %>">Enable autostart</a>
<% end %>
</DL>
