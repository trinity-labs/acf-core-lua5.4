<% local form, viewlibrary, page_info = ... %>
<% require("viewfunctions") %>

<% if form.type == "form" then %>
<H1>Configuration</H1>
<H2>Expert Configuration</H2>
<% else %>
<H1>View File</H1>
<% end %>
<H3>File Details</H3>
<DL>
<% 
displayitem(form.value.filename)
displayitem(form.value.filesize)
displayitem(form.value.mtime)
%>
</DL>

<H3>File Content</H3>
<% if form.type == "form" then %>
<% form.action = page_info.script .. page_info.prefix .. page_info.controller .. "/" .. page_info.action %>
<% displayformstart(form) %>
<input type="hidden" name="filename" value="<%= html.html_escape(form.value.filename.value) %>">
<% end %>
<textarea name="filecontent">
<%= html.html_escape(form.value.filecontent.value) %>
</textarea>
<% if form.value.filecontent.errtxt then %><P CLASS='error'><%= string.gsub(html.html_escape(form.value.filecontent.errtxt), "\n", "<BR>") %></P><% end %>
<% if form.value.filecontent.descr then %><P CLASS='descr'><%= string.gsub(html.html_escape(form.value.filecontent.descr), "\n", "<BR>") %></P><% end %>

<% if form.type == "form" then %>
<H3>Save</H3>
<% displayformend(form) %>
<% end %>
</form>
