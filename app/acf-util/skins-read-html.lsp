<% local view, viewlibrary, page_info, session = ... %>
<% htmlviewfunctions = require("htmlviewfunctions") %>
<% html = require("acf.html") %>

<% htmlviewfunctions.displaycommandresults({"update"}, session) %>

<h1>Available skins</h1>

<% for i,skin in ipairs(view.value) do %>
	<div class='item'><p class='left'><%= html.html_escape(skin.value) %></p>
	<div class='right'>
	<% if (skin.inuse) then %>
		in use
	<% else %>
		[<a href="update?skin=<%= html.html_escape(skin.value) %>&submit=true">use this skin</a>]
	<% end %>
	</div></div><!-- end .item -->
<% end %>
