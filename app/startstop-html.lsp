<% local data, viewlibrary, page_info = ... %>
<% require("htmlviewfunctions") %>

<H1>Management</H1>
<%
for i,v in ipairs(data.option) do
	data.option[i] = v:gsub("^%l", string.upper)
end
htmlviewfunctions.displayform(data, nil, nil, page_info)
%>
