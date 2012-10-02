<% local form, viewlibrary, page_info = ... 
require("htmlviewfunctions")
html = require("acf.html")
%>

<H1><%= html.html_escape(form.label) %></H1>
<%
	htmlviewfunctions.displayform(form, nil, nil, page_info, 2)
%>
