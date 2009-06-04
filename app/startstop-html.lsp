<% local data, viewlibrary, page_info = ... %>

<H1>Management</H1>

<% if data.value.result then %>
<H2>Previous action result</H2>
<% if data.value.result.value ~= "" then %>
<P CLASS='descr'><%= string.gsub(html.html_escape(data.value.result.value), "\n", "<BR>") %></P>
<% end if data.value.result.errtxt then %>
<P CLASS='error'><%= string.gsub(html.html_escape(data.value.result.errtxt), "\n", "<BR>") %></P>
<% end end %>

<DL>
<form action="<%= html.html_escape(page_info.script .. page_info.prefix .. page_info.controller .. "/" .. page_info.action) %>" method="POST">
<DT>Program control-panel</DT>
<DD>
<% for i,act in ipairs(data.value.actions.value) do %>
	<input class="submit" type="submit" name="action" value="<%= act %>">
<% end %>
</DD>
</form>
</DL>
