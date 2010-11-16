<% local view, viewlibrary, page_info = ... %>
<% require("json") %>
Status: 200 OK
Content-Type: "application/json"
<% io.write("\n") %>
<%
	print(json.encode(view))
%>
