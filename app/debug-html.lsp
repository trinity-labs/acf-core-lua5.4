<% local data, viewlibrary, page_info, session = ... %>
<% require("viewfunctions") %>
<H1>Debugging</H1>
<H2>View Data:</H2>
<%= cfe_unpack(data) %>
<H2>Session:</H2>
<%= cfe_unpack(session) %>
<H2>Page Info:</H2>
<%= cfe_unpack(page_info) %>
