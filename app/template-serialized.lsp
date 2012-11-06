<% local view, viewlibrary, page_info, session = ... %>
Status: 200 OK
Content-Type: "text/text"
<% io.write("\n") %>
<% page_info.viewfunc(view, viewlibrary, page_info, session) %>
