<% local form, viewlibrary, page_info = ... 
require("viewfunctions")
%>

<H1><%= html.html_escape(form.label) %></H1>
<%
	form.action = page_info.script .. page_info.prefix .. page_info.controller .. "/" .. page_info.action
	displayform(form)
%>
