<% local form, viewlibrary, page_info = ... %>
<% htmlviewfunctions = require("htmlviewfunctions") %>
<% html = require("acf.html") %>

<% if form.type == "form" then %>
<h1>Configuration</h1>
<h2>Expert Configuration</h2>
<% else %>
<h1>View File</h1>
<% end %>
<h3>File Details</h3>
<% 
htmlviewfunctions.displayitem(form.value.filename)
htmlviewfunctions.displayitem(form.value.filesize)
htmlviewfunctions.displayitem(form.value.mtime)
%>

<h3>File Content</h3>
<% if form.type == "form" then %>
<% form.action = page_info.script .. page_info.prefix .. page_info.controller .. "/" .. page_info.action %>
<% htmlviewfunctions.displayformstart(form) %>
<input type="hidden" name="filename" value="<%= html.html_escape(form.value.filename.value) %>">
<% end %>
<textarea name="filecontent">
<%= html.html_escape(form.value.filecontent.value) %>
</textarea>
<% if form.value.filecontent.errtxt then %><p class='error'><%= string.gsub(html.html_escape(form.value.filecontent.errtxt), "\n", "<br/>") %></p><% end %>
<% if form.value.filecontent.descr then %><p class='descr'><%= string.gsub(html.html_escape(form.value.filecontent.descr), "\n", "<br/>") %></p><% end %>

<% if form.type == "form" then %>
<% htmlviewfunctions.displayformend(form) %>
<% end %>
