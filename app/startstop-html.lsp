<% local data, viewlibrary, page_info = ... %>

<% local reverseactions = {}
data.value.actions = data.value.actions or {}
local actions = data.value.actions.value or {"start", "stop", "restart"}
for i,act in ipairs(actions) do
	reverseactions[act] = i
end %>

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
<% if reverseactions.start then %><input class="submit" type="submit" name="action" value="Start" <% if data.value.status.value== "Running" then io.write("disabled") end %>><% end %>
<% if reverseactions.stop then %><input class="submit" type="submit" name="action" value="Stop" <% if data.value.status.value== "Stopped" then io.write("disabled") end %>><% end %>
<% if reverseactions.restart then %><input class="submit" type="submit" name="action" value="Restart" <% if data.value.status.value== "Stopped" then io.write("disabled") end %>><% end %>
<% if reverseactions.reload then %><input class="submit" type="submit" name="action" value="Reload" <% if data.value.status.value== "Stopped" then io.write("disabled") end %>><% end %>
</DD>
</form>
</DL>
