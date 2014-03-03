<% local form, viewlibrary, page_info = ... %>
<% htmlviewfunctions = require("htmlviewfunctions") %>
<% html = require("acf.html") %>

<%
local header_level
if form.type == "form" then
	header_level = htmlviewfunctions.displayheader(cfe({label="Configuration"}), page_info)
	header_level = htmlviewfunctions.displayheader(cfe({label="Expert Configuration"}), page_info, htmlviewfunctions.incrementheader(header_level))
else
	header_level = htmlviewfunctions.displayheader(cfe({label="View File"}), page_info)
end
header_level = htmlviewfunctions.displayheader(cfe({label="File Details"}), page_info, htmlviewfunctions.incrementheader(header_level))
%>

<% 
htmlviewfunctions.displayitem(form.value.filename)
htmlviewfunctions.displayitem(form.value.filesize)
htmlviewfunctions.displayitem(form.value.mtime)
if form.value.grep and form.value.grep.value and form.value.grep.value ~= "" then
	htmlviewfunctions.displayitem(form.value.grep)
end
%>

<%
htmlviewfunctions.displayheader(cfe({label="File Content"}), page_info, header_level)
if form.type == "form" then
	form.action = page_info.script .. page_info.prefix .. page_info.controller .. "/" .. page_info.action
	htmlviewfunctions.displayformstart(form)
	form.value.filename.type = "hidden"
	htmlviewfunctions.displayformitem(form.value.filename)
end
%>
<textarea name="filecontent">
<%= html.html_escape(form.value.filecontent.value) %>
</textarea>
<% htmlviewfunctions.displayinfo(form.value.filecontent) %>

<% if form.type == "form" then %>
<% htmlviewfunctions.displayformend(form) %>
<% end %>
