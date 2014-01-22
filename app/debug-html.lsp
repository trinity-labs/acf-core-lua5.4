<% local data, viewlibrary, page_info, session = ... %>
<% htmlviewfunctions = require("htmlviewfunctions") %>
<h1>Debugging</h1>
<h2>View Data:</h2>
<%= htmlviewfunctions.cfe_unpack(data) %>
<h2>Session:</h2>
<%= htmlviewfunctions.cfe_unpack(session) %>
<h2>Page Info:</h2>
<%= htmlviewfunctions.cfe_unpack(page_info) %>
