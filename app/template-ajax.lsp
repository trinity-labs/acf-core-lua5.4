<% local view, viewlibrary, page_info, session = ... %>
<% require("json") %>
Status: 200 OK
Content-Type: "application/json"
<% io.write("\n") %>
<% page_info.viewfunc(view, viewlibrary, page_info, session) %>
