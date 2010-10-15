<% local form, viewlibrary, page_info = ... 
require("viewfunctions")
%>

<H1><%= html.html_escape(form.label) %></H1>
<%
	displayform(form, nil, nil, page_info, 2)
%>
