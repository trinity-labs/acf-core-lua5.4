<% local data, viewlibrary, page_info, session = ... %>
<% htmlviewfunctions = require("htmlviewfunctions") %>

<%
local header_level = htmlviewfunctions.displayheader(cfe({label="Debugging"}), page_info)
header_level = htmlviewfunctions.incrementheader(header_level)

htmlviewfunctions.displayheader(cfe({label="View Data:"}), page_info, header_level)
io.write(htmlviewfunctions.cfe_unpack(data))

htmlviewfunctions.displayheader(cfe({label="Session:"}), page_info, header_level)
io.write(htmlviewfunctions.cfe_unpack(session))

htmlviewfunctions.displayheader(cfe({label="Page Info:"}), page_info, header_level)
io.write(htmlviewfunctions.cfe_unpack(page_info))
%>
