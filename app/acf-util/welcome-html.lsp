<% view = ... %>
<% htmlviewfunctions = require("htmlviewfunctions") %>
<h1>Alpine Configuration Framework</h1>
<p>Welcome.</p>

<% --[[
	io.write(htmlviewfunctions.cfe_unpack(view))
	io.write(htmlviewfunctions.cfe_unpack(FORM))
	io.write(htmlviewfunctions.cfe_unpack(ENV))
--]] %>
