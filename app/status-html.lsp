<% local data, viewlibrary, page_info, session = ... 
require("viewfunctions")
%>

<% displaycommandresults({"install","edit"}, session) %>

<H1>System Info</H1>
<DL>
<%
displayitem(data.value.status)

displayitem(data.value.version)
if data.value.version and data.value.version.errtxt and viewlibrary.check_permission("apk-tools/apk/install") then
%>
	<a href="<%= html.html_escape(page_info.script .. "/apk-tools/apk/install?package="..data.value.version.name) %>">Install</a>
<%
end

displayitem(data.value.autostart)
if not (data.value.version and data.value.version.errtxt) and data.value.autostart and data.value.autostart.errtxt and viewlibrary.check_permission("alpine-baselayout/rc/edit") then
%>
<DT>Enable autostart</DT>
<DD><form action="<%= html.html_escape(page_info.script .. "/alpine-baselayout/rc/edit?servicename="..data.value.autostart.name.."&redir=".. page_info.orig_action) %>" method="POST">
<input class='submit' type='submit' value='Enable'></form></DD>
<% end %>
</DL>
