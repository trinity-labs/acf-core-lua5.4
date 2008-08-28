<% local data, viewlibrary, page_info = ... %>

<H1>Management</H1>
<DL>
<form action="<%= page_info.script .. page_info.prefix .. page_info.controller .. "/" .. page_info.action %>" method="POST">
<DT>Program control-panel</DT>
<DD>
<input class="submit" type="submit" name="action" value="Start" <% if data.value.status.value== "Enabled" then io.write("disabled") end %>>
<input class="submit" type="submit" name="action" value="Stop" <% if data.value.status.value== "Disabled" then io.write("disabled") end %>>
<input class="submit" type="submit" name="action" value="Restart" <% if data.value.status.value== "Disabled" then io.write("disabled") end %>>
</DD>
</form>

<% if data.value.result then %>
<DT>Previous action result</DT>
<DD>
<% if data.value.result.value ~= "" then %>
<P CLASS='descr'><%= string.gsub(data.value.result.value, "\n", "<BR>") %></P>
<% end if data.value.result.errtxt then %>
<P CLASS='error'><%= string.gsub(data.value.result.errtxt, "\n", "<BR>") %></P>
<% end end %>
</DD>
</DL>
