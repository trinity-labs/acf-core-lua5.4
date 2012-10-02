<% local data, viewlibrary, page_info, session = ... 
require("htmlviewfunctions")
html = require("acf.html")
%>

<% htmlviewfunctions.displaycommandresults({"install","edit"}, session) %>
<% htmlviewfunctions.displaycommandresults({"startstop"}, session) %>

<H1>System Info</H1>
<DL>
<%
htmlviewfunctions.displayitem(data.value.status)

htmlviewfunctions.displayitem(data.value.version)
if data.value.version and data.value.version.errtxt and viewlibrary.check_permission("apk-tools/apk/install") then
%>
	<DT>Install package</DT>
	<DD><form action="<%= html.html_escape(page_info.script .. "/apk-tools/apk/install") %>" method="POST">
	<input type='hidden' name='package' value='<%= html.html_escape(data.value.version.name) %>'>
	<input class='submit' type='submit' name='submit' value='Install'></form></DD>
<%
end

htmlviewfunctions.displayitem(data.value.autostart)
if not (data.value.version and data.value.version.errtxt) and data.value.autostart and data.value.autostart.errtxt and viewlibrary.check_permission("alpine-baselayout/rc/edit") then
%>
	<DT>Enable autostart</DT>
	<DD><form action="<%= html.html_escape(page_info.script .. "/alpine-baselayout/rc/edit") %>" method="POST">
	<input type='hidden' name='servicename' value='<%= html.html_escape(data.value.autostart.name) %>'>
	<input type='hidden' name='redir' value='<%= html.html_escape(page_info.orig_action) %>'>
	<input class='submit' type='submit' value='Enable'></form></DD>
<% end %>
</DL>

<% if viewlibrary and viewlibrary.dispatch_component and viewlibrary.check_permission("startstop") then
	viewlibrary.dispatch_component("startstop")
end %>
