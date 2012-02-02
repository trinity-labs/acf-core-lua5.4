<% local data, viewlibrary, page_info, session = ... %>
<% require("htmlviewfunctions") %>
<H1>Debugging</H1>
<H2>View Data:</H2>
<%= htmlviewfunctions.cfe_unpack(data) %>
<H2>Session:</H2>
<%= htmlviewfunctions.cfe_unpack(session) %>
<H2>Page Info:</H2>
<%= htmlviewfunctions.cfe_unpack(page_info) %>
