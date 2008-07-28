<% local viewtable, viewlibrary, pageinfo, session = ... %>
Status: 200 OK
Content-Type: <% print(viewtable.option or "application/octet-stream") %>
<% if viewtable.label ~= "" then %>
Content-Disposition: attachment; filename="<%= viewtable.label %>"
<% end %>
<% io.write("\n") %>
<%= viewtable.value %>
