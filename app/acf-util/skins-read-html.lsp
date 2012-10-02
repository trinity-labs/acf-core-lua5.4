<% local view, viewlibrary, page_info, session = ... %>
<% require("htmlviewfunctions") %>
<% html = require("acf.html") %>

<% htmlviewfunctions.displaycommandresults({"update"}, session) %>

<h1>Available skins</h1>

<DL>
<% for i,skin in ipairs(view.value) do %>
	<dt><%= html.html_escape(skin.value) %></dt>
	<% if (skin.inuse) then %>
		<dd>in use</dd>
	<% else %>
		<dd>[<a href="update?skin=<%= html.html_escape(skin.value) %>&submit=true">use this skin</a>]</dd>
	<% end %>
<% end %>
</DL>
